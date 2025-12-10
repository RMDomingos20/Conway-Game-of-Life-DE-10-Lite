# Política de Segurança

## Versões Suportadas

Atualmente, mantemos suporte apenas para a versão mais recente disponível na branch principal (`main`).

| Versão | Suportada          | Notas |
| :----- | :----------------- | :---- |
| 1.0.x  | :white_check_mark: | Versão estável (VGA 640x480 @ 60Hz) |
| < 1.0  | :x:                | Versões de desenvolvimento/instáveis |

## Reportando Vulnerabilidades ou Bugs Críticos

Este é um projeto acadêmico desenvolvido para fins educacionais na disciplina de **Sistemas Digitais Reconfiguráveis**. Dado que o sistema opera em hardware isolado (FPGA) sem conexão de rede, a superfície de ataque convencional é inexistente.

No entanto, nos preocupamos com a integridade do hardware. Se você identificar:

1.  **Erros de Pinagem:** Atribuições no arquivo `.qsf` que possam causar curto-circuito ou conflito de tensão na placa DE10-Lite.
2.  **Sinais de Vídeo Fora de Padrão:** Timings VGA que possam danificar monitores CRT antigos ou analógicos sensíveis.
3.  **Loops Combinacionais:** Lógica que possa causar aquecimento excessivo ou instabilidade no FPGA.

Por favor, abra uma **Issue** no GitHub descrevendo o problema técnico e, se possível, anexe os relatórios de síntese ou timing do Quartus.

## ⚠️ Aviso de Isenção de Responsabilidade (Hardware)

Este projeto foi validado especificamente para o kit de desenvolvimento **Terasic DE10-Lite (Intel MAX10 10M50DAF484C7G)**.

* **Portabilidade:** A tentativa de carregar o *bitstream* (`.sof`) gerado por este projeto em qualquer outra placa FPGA (mesmo que seja da família MAX10) sem remapear os pinos no *Pin Planner* pode resultar em **danos físicos permanentes** ao FPGA ou aos periféricos conectados.
* **Monitores:** O controlador VGA foi projetado para o padrão 640x480 @ 60Hz. Os autores não se responsabilizam por incompatibilidades com monitores que não suportem esta resolução nativa.

Use este código por sua conta e risco.
