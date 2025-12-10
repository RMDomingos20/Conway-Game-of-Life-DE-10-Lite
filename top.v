module top 
(
    input wire MAX10_CLK1_50,
    output wire VGA_HS, VGA_VS,
    output wire [3:0] VGA_R, VGA_G, VGA_B,
    input wire [1:0] KEY,
    input wire [9:0] SW,
    output wire [9:0] LEDR
);

    // 1. Gerador de Clock (50MHz -> 25MHz)
    reg r_video_clk = 0;
    always @(posedge MAX10_CLK1_50) r_video_clk <= ~r_video_clk;
    wire w_video_clk = r_video_clk;

    // 2. Reset Power-On
    reg [3:0] reset_cnt = 0;
    always @(posedge MAX10_CLK1_50) if (reset_cnt < 15) reset_cnt <= reset_cnt + 1'b1;

    // 3. Sinais VGA
    wire w_hsync, w_vsync, w_visible;
    wire [4:0] w_r, w_b; wire [5:0] w_g;
    
    // Conexão dos 4 bits mais significativos para a DE10-Lite
    assign VGA_HS = w_hsync;
    assign VGA_VS = w_vsync;
    assign VGA_R = w_r[4:1]; 
    assign VGA_G = w_g[5:2]; 
    assign VGA_B = w_b[4:1];

    // ==========================================
    // CONFIGURAÇÃO DO TABULEIRO (32x32)
    // ==========================================
    localparam WIDTH = 32;
    localparam HEIGHT = 32;

    wire scr_wr;
    wire [15:0] scr_wr_data;
    wire [12:0] scr_wr_addr;
    wire w_torus_last, w_life_step, w_seed, w_seed_ena;
    
    // Fio para ler o estado do jogo sem mover as células
    wire [WIDTH*HEIGHT-1:0] w_torus_state;

    // ==========================================
    // INSTÂNCIAS
    // ==========================================

    // Sloader: Controla o jogo, desenha na memória e gerencia a UI
    sloader #( .TORUS_WIDTH(WIDTH), .TORUS_HEIGHT(HEIGHT) ) m_sloader(
        .clk(w_video_clk), 
        .switches(SW), 
        .rx_byte(8'h00), 
        .rbyte_ready(1'b0),
        .vsync(w_vsync), 
        .key0(KEY[0]), 
        .key1(KEY[1]),
        
        .torus_state(w_torus_state), // Conexão para leitura direta
        .torus_last(w_torus_last),
        
        .seed(w_seed), 
        .seed_ena(w_seed_ena), 
        .life_step(w_life_step),
        .wdata(scr_wr_data), 
        .waddr(scr_wr_addr), 
        .wr(scr_wr), 
        .debug(LEDR[7:0])
    );

    // Torus: A lógica do Jogo da Vida
    torus #( .TORUS_WIDTH(WIDTH), .TORUS_HEIGHT(HEIGHT) ) m_torus(
        .clk(w_video_clk), 
        .seed(w_seed), 
        .seed_ena(w_seed_ena),
        .life_step(w_life_step), 
        
        .torusv(w_torus_state), // Saída do estado paralelo
        .torus_last(w_torus_last)
    );

    // TXTD: Driver de Vídeo (Zoom 2x ativado)
    txtd m_txtd(
        .pixel_clock(w_video_clk), 
        .wrdata(scr_wr_data), 
        .wradr(scr_wr_addr), 
        .wren(scr_wr),
        .hsync(w_hsync), 
        .vsync(w_vsync), 
        .r(w_r), 
        .g(w_g), 
        .b(w_b), 
        .visible(w_visible)
    );

endmodule