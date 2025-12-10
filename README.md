# Conway's Game of Life - FPGA DE10-Lite (VGA)

Este repositório contém a implementação do autômato celular "Jogo da Vida" (Game of Life) de John Conway para a placa **Terasic DE10-Lite** (Intel MAX10).

O projeto foi desenvolvido como requisito para a disciplina de **Sistemas Digitais Reconfiguráveis** e consiste em uma adaptação e reengenharia do projeto original [marsohod4you/FPGA_game_life](https://github.com/marsohod4you/FPGA_game_life), migrando a saída de vídeo de HDMI para **VGA Analógico**.

A documentação e o que foi feito estão na pasta **Documentação**.

## 📋 Características

* **Arquitetura Paralela:** Matriz lógica de 32x32 células com processamento simultâneo.
* **Vídeo VGA:** Resolução nativa 640x480 @ 60Hz (Clock 25MHz).
* **Visualização:** Zoom de hardware 2x (Células de 16x16 pixels) para melhor visibilidade.
* **Interface (UI):** Barra de status inferior exibindo contador de gerações (Hex) e Seed ativa.
* **Topologia:** Toroidal (bordas conectadas).
* **Gerador Aleatório:** Implementação de LFSR (Linear Feedback Shift Register) para criar padrões caóticos iniciais.

## 🛠 Hardware e Ferramentas

* **Placa:** Terasic DE10-Lite (MAX10 10M50DAF484C7G).
* **Linguagem:** Verilog HDL.
* **IDE:** Intel Quartus Prime Lite Edition 18.1.
* **Periféricos:** Monitor VGA, Botões (KEY) e Chaves (SW) da placa.

## 🏗 Estrutura do Projeto

O sistema é modularizado em três blocos principais instanciados no `top.v`:

1.  **`torus.v`**: Núcleo lógico. Contém a matriz de células e aplica as regras de Conway (Nascimento/Morte) em paralelo.
2.  **`txtd.v`**: Controlador de Vídeo. Gerencia os sinais de sincronismo VGA (HSync/VSync), renderiza os glifos da fonte e aplica o zoom 2x.
3.  **`sloader.v`**: Unidade de Controle. Máquina de estados (FSM) que gerencia o fluxo do jogo, carrega os padrões iniciais (Seeds) e controla a velocidade (Normal/Turbo).

## 🎮 Controles

| Componente | Função |
| :--- | :--- |
| **KEY[0]** | **Reset / Load:** Pausa o jogo e carrega o padrão selecionado nas chaves. |
| **KEY[1]** | **Play / Pause:** Inicia ou pausa a evolução automática. |
| **SW[0]** | Seed: Bloco (Estático). |
| **SW[1]** | Seed: Colmeia (Estático). |
| **SW[2]** | Seed: Blinker (Oscilador). |
| **SW[5]** | Seed: Glider (Nave Espacial). |
| **SW[7]** | Seed: Acorn (Padrão Methuselah). |
| **SW[8]** | **Modo Turbo:** Acelera a simulação (~30 FPS). |
| **SW[9]** | **Modo Aleatório:** Gera um padrão inicial randômico (LFSR). |

## 🚀 Como Executar

1.  Clone este repositório.
2.  Abra o arquivo de projeto `.qpf` no Quartus Prime.
3.  Certifique-se de que o arquivo `vgafont.mif` está na pasta raiz do projeto.
4.  Compile o projeto (Processing > Start Compilation).
5.  Conecte a DE10-Lite via USB.
6.  Abra o Programmer e grave o arquivo `.sof` na placa.

## 📄 Créditos e Referências

* **Autores:** Rafael Domingos Siqueira Magalhães & Matheus Gabriel.
* **Projeto Original:** [marsohod4you/FPGA_game_life](https://github.com/marsohod4you/FPGA_game_life) (Baseado em placa Marsohod3 com HDMI).
