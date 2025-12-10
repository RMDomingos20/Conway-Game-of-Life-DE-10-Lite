module sloader(
    input wire clk,
    input wire [9:0] switches,
    input wire [7:0] rx_byte,
    input wire rbyte_ready,
    input wire vsync,
    input wire key0,
    input wire key1,
    
    input wire [TORUS_WIDTH*TORUS_HEIGHT-1:0] torus_state, 
    input wire torus_last, 
    
    output reg seed,
    output reg seed_ena,
    output wire life_step,
    output wire [15:0] wdata,
    output wire [12:0] waddr,
    output wire wr,
    output wire [7:0] debug
    );

    parameter TORUS_WIDTH  = 32;
    parameter TORUS_HEIGHT = 32;
    localparam MAX_CELLS = TORUS_WIDTH * TORUS_HEIGHT;

    // --- CONTROLES ---
    wire reset_hold = ~key0; 
    
    reg [1:0] k1_hist;
    reg is_running = 0;
    always @(posedge clk) begin
        k1_hist <= {k1_hist[0], key1};
        if (k1_hist == 2'b10) is_running <= ~is_running;
        if (reset_hold) is_running <= 0;
    end

    // --- TELEMETRIA ---
    reg [15:0] gen_count;

    // --- VELOCIDADE (TURBO SW8) ---
    reg [25:0] speed_counter; 
    reg tick;
    
    // Define o limite do contador baseado na chave SW[8]
    // Se SW[8] = 1 (Turbo): Conta até 800.000 (~31 FPS)
    // Se SW[8] = 0 (Normal): Conta até 5.000.000 (~5 FPS)
    wire [25:0] speed_limit = switches[8] ? 26'd800000 : 26'd5000000;

    always @(posedge clk) begin
        if (speed_counter < speed_limit) begin 
            speed_counter <= speed_counter + 1'b1;
            tick <= 0;
        end else begin
            speed_counter <= 0;
            tick <= 1;
        end
    end

    // --- ALEATÓRIO ---
    reg [30:0] lfsr = 31'h5A5A5A5A;
    always @(posedge clk) lfsr <= {lfsr[29:0], lfsr[30] ^ lfsr[27]};

    // --- MÁQUINA DE ESTADOS ---
    reg [2:0] state = 0;
    reg [12:0] cell_counter = 0;

    always @(posedge clk) begin
        if (reset_hold) begin
            state <= 1;          
            cell_counter <= 0;
            gen_count <= 0;
        end
        else begin
            case (state)
                0: begin // IDLE
                    cell_counter <= 0;
                    if (tick && is_running) state <= 3; 
                end
                1: begin // RESET
                    if (cell_counter == MAX_CELLS - 1) begin
                        state <= 4; 
                        cell_counter <= 0;
                    end else cell_counter <= cell_counter + 1'b1;
                end
                3: begin // EVOLVE
                    gen_count <= gen_count + 1'b1;
                    state <= 2; 
                end
                2: begin // UPDATE
                    if (cell_counter == MAX_CELLS - 1) begin
                        state <= 4; 
                        cell_counter <= 0;
                    end else cell_counter <= cell_counter + 1'b1;
                end
                4: begin // DRAW UI
                    if (cell_counter == 31) begin
                        state <= 0; 
                        cell_counter <= 0;
                    end else cell_counter <= cell_counter + 1'b1;
                end
            endcase
        end
    end

    assign life_step = (state == 3);

    // --- SEMENTES ---
    wire [5:0] cx = cell_counter[4:0];  
    wire [5:0] cy = cell_counter[9:5]; 
    reg init_alive;

    always @* begin
        init_alive = 0;
        if (switches[0]) if (cx >= 15 && cx <= 16 && cy >= 15 && cy <= 16) init_alive = 1; // BLOCO
        if (switches[1]) if ((cy==14 && cx>=15 && cx<=16) || (cy==15 && (cx==14 || cx==17)) || (cy==16 && cx>=15 && cx<=16)) init_alive = 1; // COLMEIA
        if (switches[2]) if (cx == 15 && cy >= 14 && cy <= 16) init_alive = 1; // BLINKER
        if (switches[3]) if ((cy==15 && cx>=15 && cx<=17) || (cy==16 && cx>=14 && cx<=16)) init_alive = 1; // TOAD
        if (switches[4]) if ((cx==14 && cy==14) || (cx==15 && cy==14) || (cx==14 && cy==15) || (cx==17 && cy==17) || (cx==16 && cy==17) || (cx==17 && cy==16)) init_alive = 1; // BEACON
        if (switches[5]) if ((cx==2 && cy==1) || (cx==3 && cy==2) || (cx==1 && cy==3) || (cx==2 && cy==3) || (cx==3 && cy==3)) init_alive = 1; // GLIDER
        if (switches[6]) if ((cx==16 && cy==14) || (cx==17 && cy==14) || (cx==15 && cy==15) || (cx==16 && cy==15) || (cx==16 && cy==16)) init_alive = 1; // R-PENTOMINO
        if (switches[7]) if ((cy==15 && cx==13) || (cy==15 && cx==14) || (cy==13 && cx==14) || (cy==14 && cx==16) || (cy==15 && cx==17) || (cy==15 && cx==18) || (cy==15 && cx==19)) init_alive = 1; // ACORN
        if (switches[9]) if (cx > 5 && cx < 26 && cy > 5 && cy < 26) init_alive = lfsr[0]; // RANDOM
    end

    function [7:0] nibble2hex;
        input [3:0] nibble;
        begin
            if (nibble < 10) nibble2hex = 8'h30 + nibble; 
            else nibble2hex = 8'h41 + (nibble - 10);      
        end
    endfunction

    // --- UI ---
    reg [7:0] char_ui;
    always @* begin
        case (cell_counter[4:0]) 
            5'd2: char_ui = is_running ? "P" : "S";
            5'd3: char_ui = is_running ? "L" : "T";
            5'd4: char_ui = is_running ? "A" : "O";
            5'd5: char_ui = is_running ? "Y" : "P";

            5'd7:  char_ui = "G"; 5'd8: char_ui = ":";
            5'd9: char_ui = nibble2hex(gen_count[11:8]);
            5'd10: char_ui = nibble2hex(gen_count[7:4]);
            5'd11: char_ui = nibble2hex(gen_count[3:0]);
            
            5'd14: char_ui = "S"; 5'd15: char_ui = "W"; 5'd16: char_ui = ":";
            5'd17: char_ui = nibble2hex({2'b00, switches[9:8]});
            5'd18: char_ui = nibble2hex(switches[7:4]);
            5'd19: char_ui = nibble2hex(switches[3:0]);

            default: char_ui = " "; 
        endcase
    end

    assign wr = (state == 1) || (state == 2) || (state == 4);
    
    // Mapeamento VGA + UI na linha 29
    assign waddr = (state == 4) ? { 2'b00, 5'd29, 1'b0, cell_counter[4:0] } : 
                                  { 2'b00, cy[4:0], 1'b0, cx[4:0] }; 

    wire cell_val = torus_state[cell_counter];
    
    wire [15:0] color_ui    = { 8'h70, char_ui }; 
    wire [15:0] color_alive = 16'h0FDB; 
    wire [15:0] color_dead  = 16'h0020; 

    assign wdata = (state == 4) ? color_ui :
                   (state == 1) ? (init_alive ? color_alive : color_dead) : 
                                  (cell_val ? color_alive : color_dead); 

    always @(posedge clk) begin
        if (state == 1) begin
            seed_ena <= 1; seed <= init_alive; 
        end else begin
            seed_ena <= 0; seed <= 0;
        end
    end
    
    assign debug = { 5'b0, state }; 

endmodule