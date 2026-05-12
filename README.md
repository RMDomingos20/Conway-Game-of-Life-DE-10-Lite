# Conway's Game of Life — FPGA DE10-Lite (VGA)

[![Board](https://img.shields.io/badge/Board-Intel_DE10--Lite-blue.svg)](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=216&No=1021)
[![FPGA](https://img.shields.io/badge/FPGA-MAX_10-blue.svg)]()
[![Language](https://img.shields.io/badge/Language-Verilog_HDL-orange.svg)]()
[![Video](https://img.shields.io/badge/Output-VGA_640x480-green.svg)]()

A pure hardware implementation of John Conway's **Game of Life** cellular automaton.
This project adapts and re-engineers a legacy HDMI-based architecture to the **analog VGA** standard, deeply exploring massive silicon parallelism and synchronous digital system design.

Developed as a capstone project for the **Reconfigurable Digital Systems** course  
(Control and Automation Engineering — IFSP Bragança Paulista, Brazil).

> *"People think that mathematics is complicated. Mathematics is the easy part. It's something we can understand. It's cats that are complicated... And how do you define a cat? I have no idea."*  
> — **John H. Conway**

---

# Mathematical Foundation & Cellular Logic

The system is defined as a tuple:

$$
(L, S, N, f)
$$

Where:
- $L$ → 2D grid
- $S = \{0,1\}$ → cell states (dead/alive)
- $N$ → Moore neighborhood

For a given cell $C$ at coordinates $(x,y)$, the sum of living neighbors $N_t$ at time $t$ is:

$$
N_t = \sum_{i=-1}^{1} \sum_{j=-1}^{1} C(x+i, y+j) - C(x,y)
$$

The state transition function:

$$
C_{t+1} = f(C_t, N_t)
$$

is implemented directly in hardware as piecewise Boolean logic:

$$
C_{t+1} =
\begin{cases}
1 & \text{if } N_t = 3 \text{ (Birth / Survival)} \\
1 & \text{if } N_t = 2 \text{ and } C_t = 1 \text{ (Survival)} \\
0 & \text{otherwise (Death by Underpopulation/Overpopulation)}
\end{cases}
$$

---

# System Architecture & RTL Implementation

Unlike software implementations that require:

$$
O(W \times H)
$$

time complexity to sequentially update memory arrays, this FPGA implementation utilizes **spatial computing**, allowing matrix updates in:

$$
O(1)
$$

time complexity per generation.

The Top-Down hierarchy is divided into three major IP cores.

---

## 1. Parallel Processing Core (`torus.v` & `xcell.v`)

A physical instantiation of a:

$$
32 \times 32
$$

matrix.

Each cell is an independent Verilog module containing:
- Adder tree
- State register
- Neighbor evaluation logic

### Toroidal Topology (Wrap-around)

To simulate an infinite grid without borders, modulo arithmetic is applied to the coordinates.  
Since the grid dimensions are powers of 2 (32), the modulo operation is computationally free in hardware, achieved via bitwise masking.

### Transition Logic Synthesis

The Verilog case statement below is synthesized into 9-input LUT structures (8 neighbors + current state).

---

## 2. VGA Video Pipeline (`txtd.v`)

Generates:
- **640×480 @ 60Hz**
- **25 MHz pixel clock**
- VESA-compatible VGA timings

The pixel clock:

$$
T_{pixel} \approx 40\,\text{ns}
$$

is derived from the DE10-Lite 50 MHz oscillator.

### Address Linearization & Memory Mapping

The screen is mapped into:

$$
16 \times 16
$$

pixel character tiles.

The translation from screen coordinates $(X_{vga}, Y_{vga})$ to a 1D memory address is achieved using bit-shifting:

$$
\text{Addr}_{mem} = 
\left\lfloor \frac{Y_{vga}}{16} \right\rfloor \times 32 +
\left\lfloor \frac{X_{vga}}{16} \right\rfloor
$$

This operation costs virtually zero combinational logic because the lower 4 bits are discarded.

---

## 3. FSM Control & Entropy Generation (`sloader.v`)

### LFSR (Linear Feedback Shift Register)

To inject stochastic initial conditions ("Primordial Soup"), a 31-bit LFSR is implemented using the primitive Galois polynomial:

$$
P(x) = x^{31} + x^{28} + 1
$$

This guarantees a maximal pseudo-random sequence length of:

$$
2^{31} - 1
$$

states before repetition.

---

# Hardware Specifications

Synthesized for the Intel DE10-Lite development board.

| Attribute           | Specification                    | Project Usage      |
|---------------------|----------------------------------|--------------------|
| FPGA Device         | Intel MAX 10 10M50DAF484C7G     | Core System        |
| Logic Elements      | 50,000 LEs                       | Moderate fraction  |
| Embedded Memory     | 1.638 Mbits (M9K)                | < 10% utilized     |
| System Clock        | 50 MHz                           | Divided to 25 MHz  |
| Video Output        | Resistor Ladder DAC              | 3-bit RGB          |

---

# Performance & Timing Closure

## Throughput

Updating the entire:

$$
1024
$$

cell matrix and writing to VRAM requires exactly:

$$
1024 \text{ clock cycles}
$$

Equivalent to:

$$
\approx 40.9\,\mu\text{s}
$$

## Framerate Limits

| Mode         | Framerate |
|--------------|---------|
| Normal Mode  | ~5 FPS  |
| Turbo Mode   | ~30 FPS |

---

## Timing Closure

The single-clock synchronous architecture respects the setup-time inequality:

$$
T_{clk} \ge T_{clk-to-q} + T_{comb} + T_{setup} + T_{skew}
$$
