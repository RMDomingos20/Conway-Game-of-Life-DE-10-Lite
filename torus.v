module torus(
	input wire clk,
	input wire seed,
	input wire seed_ena,
	input wire life_step,
	output wire [TORUS_WIDTH*TORUS_HEIGHT-1:0] torusv,
	output wire torus_last
);

    parameter TORUS_WIDTH  = 32;
    parameter TORUS_HEIGHT = 32;

    // Máscaras para garantir loop (wrap-around) em potências de 2
    localparam WMASK = TORUS_WIDTH - 1;  // 31 (0x1F)
    localparam HMASK = TORUS_HEIGHT - 1; // 31 (0x1F)

    genvar x, y;
    generate
        for(y=0; y<TORUS_HEIGHT; y=y+1) begin: crow
            for(x=0; x<TORUS_WIDTH; x=x+1) begin: ccol
                
                wire value;
                
                // Lógica de Carregamento (Shift Register Linear)
                // Conecta o bit anterior ao atual para carregar a seed
                wire seed_source;
                if (y==0 && x==0)
                    assign seed_source = seed;
                else if (x==0)
                    assign seed_source = crow[y-1].ccol[TORUS_WIDTH-1].value;
                else
                    assign seed_source = crow[y].ccol[x-1].value;

                // Instância da Célula
                // O segredo aqui é o & MASK, que faz o wrap (31+1->0, 0-1->31)
                xcell my_xcell(
                    .clk( clk ),
                    .seed_ena  (seed_ena),
                    .life_step (life_step),
                    
                    // Vizinhos com proteção de borda
                    .in_up_left   ( crow[(y-1) & HMASK].ccol[(x-1) & WMASK].value ),
                    .in_up        ( crow[(y-1) & HMASK].ccol[(x-0) & WMASK].value ),
                    .in_up_right  ( crow[(y-1) & HMASK].ccol[(x+1) & WMASK].value ),
                    
                    .in_left      ( seed_ena ? seed_source : 
                                    crow[(y-0) & HMASK].ccol[(x-1) & WMASK].value ),
                                    
                    .in_right     ( crow[(y-0) & HMASK].ccol[(x+1) & WMASK].value ),
                    
                    .in_down_left ( crow[(y+1) & HMASK].ccol[(x-1) & WMASK].value ),
                    .in_down      ( crow[(y+1) & HMASK].ccol[(x-0) & WMASK].value ),
                    .in_down_right( crow[(y+1) & HMASK].ccol[(x+1) & WMASK].value ),
                    
                    .cell_life( value )
                );
                
                assign torusv[y*TORUS_WIDTH+x] = value;
            end
        end
    endgenerate

    // Saída do último bit para reciclagem
    assign torus_last = crow[TORUS_HEIGHT-1].ccol[TORUS_WIDTH-1].value;

endmodule