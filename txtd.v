module txtd (
	input wire pixel_clock,
	input wire [15:0]wrdata,
	input wire [12:0]wradr,
	input wire wren,

	output reg hsync,
	output reg vsync,
	output reg [4:0]r,
	output reg [5:0]g,
	output reg [4:0]b,
	output reg visible
	);

	// ==========================================
	// PADRÃO SEGURO (Total 800 clocks)
	// ==========================================
	parameter h_visible = 640;
	parameter h_front   = 16;
	parameter h_sync    = 96;
	parameter h_back    = 48;  // Voltamos para 48 (Seguro)
	parameter h_total   = 800; // Frequência correta ~31kHz

	parameter v_visible = 480;
	parameter v_front   = 10;
	parameter v_sync    = 2;
	parameter v_back    = 33;
	parameter v_total   = 525; 

	reg [9:0] pixel_count = 0;
	reg [9:0] line_count  = 0;

	// Contadores
	always @(posedge pixel_clock) begin
		if (pixel_count < h_total - 1)
			pixel_count <= pixel_count + 1'b1;
		else begin
			pixel_count <= 0;
			if (line_count < v_total - 1)
				line_count <= line_count + 1'b1;
			else
				line_count <= 0;
		end
	end

	// Sincronismo (Polaridade Negativa)
	always @(posedge pixel_clock) begin
		hsync <= ~((pixel_count >= (h_visible + h_front)) && (pixel_count < (h_visible + h_front + h_sync)));
		vsync <= ~((line_count >= (v_visible + v_front)) && (line_count < (v_visible + v_front + v_sync)));
	end

	// Área Visível
	always @(posedge pixel_clock) begin
		visible <= (pixel_count < h_visible) && (line_count < v_visible);
	end

	// Memória e Cor
	reg [12:0] scr_addr;
	reg [11:0] fnt_addr;
	reg [15:0] scr_char;
	reg [7:0]  scr_char_line;
	reg [2:0]  fcolor;
	reg [2:0]  bcolor;
	reg rr, gg, bb;
	reg sbit;
	reg [2:0] get_char_line;

	wire [7:0] fnt_data;
	wire [15:0] scr_data;

	always @* begin
		if (visible)
			scr_addr = { line_count[8:4], pixel_count[9:4] + 1'b1 }; 
		else
			scr_addr = 0;

		fnt_addr = { scr_char[7:0], line_count[3:0] };
		sbit = scr_char_line[ 3'h7 - pixel_count[3:1] ];
	end

	always @(posedge pixel_clock) begin
		get_char_line <= { get_char_line[1:0], (pixel_count[3:0] == 4'hC) && visible };

		if (get_char_line[0]) scr_char <= scr_data;
		if (get_char_line[2]) begin
			scr_char_line <= fnt_data;
			fcolor <= scr_char[10:8];
			bcolor <= scr_char[14:12];
		end

		if (visible) begin
			rr <= sbit ? fcolor[2] : bcolor[2];
			gg <= sbit ? fcolor[1] : bcolor[1];
			bb <= sbit ? fcolor[0] : bcolor[0];
			
			r <= {rr, rr, 3'h0};
			g <= {gg, gg, 3'h0, visible};
			b <= {bb, bb, 3'h0};
		end else begin
			r <= 0; g <= 0; b <= 0;
		end
	end

	rom_font my_rom_font(
		.address( fnt_addr ),
		.clock( pixel_clock ),
		.q( fnt_data )
	);
	
	screen_ram my_screen_ram (
		.clock( pixel_clock ),
		.data( wrdata ),
		.rdaddress( scr_addr ),
		.wraddress( wradr ),
		.wren( wren ),
		.q( scr_data )
	);

endmodule