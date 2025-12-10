module xcell(
    input wire clk,
    input wire seed_ena,
    input wire life_step,
    
    // Vizinhos
    input wire in_up_left,
    input wire in_up,
    input wire in_up_right,
    input wire in_left,
    input wire in_right,
    input wire in_down_left,
    input wire in_down,
    input wire in_down_right,
    
    // Estado da própria célula
    output reg cell_life
);

    // Soma dos vizinhos vivos
    wire [3:0] neighbors;
    assign neighbors = in_up_left + in_up + in_up_right + 
                       in_left    + in_right + 
                       in_down_left + in_down + in_down_right;

    initial cell_life = 0;

    always @(posedge clk) begin
        if (seed_ena) begin
            // MODO CARGA: Comporta-se como Shift Register
            // Copia o vizinho da esquerda para passar o dado adiante
            cell_life <= in_left; 
        end
        else if (life_step) begin
            // MODO JOGO: Aplica as regras de Conway
            case (neighbors)
                4'd3: cell_life <= 1'b1;          // Nasce (se morto) ou Sobrevive (se vivo)
                4'd2: cell_life <= cell_life;     // Sobrevive (mantém estado)
                default: cell_life <= 1'b0;       // Morre (Solidão ou Superpopulação)
            endcase
        end
        // Se nem seed_ena nem life_step, mantém o estado (Pausa)
    end

endmodule