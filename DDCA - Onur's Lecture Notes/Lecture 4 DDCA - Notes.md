# Digital Design & Computer Architecture - Lecture 4
### FSMs, FPGAs, and Verilog | Prof. Onur Mutlu | ETH Zürich, Spring 2025

---

## What's Covered

4a: Full FSM design walkthrough, Moore vs. Mealy, state encoding. 4b: Lab logistics, FPGA architecture, LUTs, design flow. 4c: Verilog — structural vs. behavioral, combinational and sequential logic, FSMs in Verilog.

---

## FSM Design — Full Walkthrough (Traffic Light Controller)

The three hardware parts of every FSM:

| Part | Type | Role |
|------|------|------|
| State register | Sequential (flip-flops) | Stores current state, loads next state on clock edge |
| Next state logic | Combinational | Computes next state from current state + inputs |
| Output logic | Combinational | Computes outputs from current state |

**Problem**: traffic light at Academic Ave. and Bravado Blvd. Inputs: TA (traffic on Academic), TB (traffic on Bravado). Outputs: LA, LB (light color for each road). Rule: every 5 seconds the state can change, but a green road stays green if it has traffic.

**4 states** (Moore — outputs labeled inside state circles):

- **S0**: LA=green, LB=red → if ~TA go to S1, else stay S0
- **S1**: LA=yellow, LB=red → always go to S2
- **S2**: LA=red, LB=green → if ~TB go to S3, else stay S2
- **S3**: LA=red, LB=yellow → always go to S0

**State transition table** (encoded S0=00, S1=01, S2=10, S3=11):

| S1 | S0 | TA | TB | S'1 | S'0 |
|----|----|----|----|-----|-----|
| 0 | 0 | 0 | X | 0 | 1 |
| 0 | 0 | 1 | X | 0 | 0 |
| 0 | 1 | X | X | 1 | 0 |
| 1 | 0 | X | 0 | 1 | 1 |
| 1 | 0 | X | 1 | 1 | 0 |
| 1 | 1 | X | X | 0 | 0 |

**Next state Boolean equations:**
```
S'1 = S1 XOR S0
S'0 = (~S1 · ~S0 · ~TA) + (S1 · ~S0 · ~TB)
```

**Output table** — encode green=00, yellow=01, red=10:

| S1 | S0 | LA | LB |
|----|----|-----|-----|
| 0 | 0 | green | red |
| 0 | 1 | yellow | red |
| 1 | 0 | red | green |
| 1 | 1 | red | yellow |

**Output equations:**
```
LA1 = S1        LA0 = ~S1 · S0
LB1 = ~S1       LB0 = S1 · S0
```

**Schematic**: next state logic → state register (two resettable D flip-flops) → output logic. TA and TB only feed next state logic. Output logic only sees S1 and S0 — that's the Moore property.

---

## Moore vs. Mealy

**Moore**: outputs depend only on current state. Labeled inside state circles. More states needed. Output only changes on clock edges — synchronized and predictable. Default for this course.

**Mealy**: outputs depend on current state AND inputs. Labeled on transition arcs as input/output pairs. Fewer states — can react within the same cycle. Harder to verify.

The snail example (smiles on reading "1101"): Moore needs 5 states, Mealy needs 4 — the smile fires on the arc itself without needing a dedicated smile state.

---

## State Encoding Options

| Encoding | Bits | Tradeoff |
|----------|------|---------|
| Binary | log₂(N) | Fewest flip-flops, more complex next state logic |
| One-hot | N (one per state) | Most flip-flops, simplest next state logic — EDA tools love it |
| Output | Based on output bits | Output readable directly from state bits — Moore only |

No universally correct choice — depends on area, speed, and synthesis constraints.

---

## FSM Design Procedure

1. Define all states. 2. Draw state transition diagram from reset state outward — every state must have a transition for every input combination. 3. Choose encoding. 4. Build state transition table. 5. Derive Boolean equations for next state logic. 6. Build output table. 7. Derive output equations. 8. Wire the schematic.

---

## FPGAs and Lab Setup

**Lab logistics**: labs start March 4th. Groups of two, each group gets a Basys 3 FPGA board. 10 labs, 30 points total — 70% in-class evaluation, 30% lab reports. 1-point penalty per late submission. Contact: digitaltechnik@lists.inf.ethz.ch

**What is an FPGA**: Field Programmable Gate Array — a software-reconfigurable hardware substrate with reconfigurable functions, interconnect, and I/O. Sits between CPU (flexible, less efficient) and ASIC (fixed, most efficient) on the tradeoff spectrum.

Real-world FPGA use: Microsoft Project Brainwave (real-time DNN inference), Amazon EC2 F1 (custom cloud acceleration), Illumina DRAGEN DNA sequencing (~16× speedup), FPGA-based near-memory accelerators (5–27× performance, 12–133× energy efficiency vs. 16-core IBM POWER9).

**FPGA architecture**: grid of logic blocks, switch blocks, and I/O blocks. Inside each logic block: a **LUT** and a flip-flop. A LUT is a MUX with configuration memory — the input bits are select lines, the stored truth table values are the data inputs. A 3-LUT has 3 select bits → 8 configuration bits → can implement any 3-input Boolean function. Modern FPGAs use 6-LUTs, with thousands per chip, plus on-chip SRAM, hardcoded high-performance blocks, and sometimes an embedded processor.

**FPGA design flow:**
```
Problem Definition + HDL (Verilog)   ← your job
        ↓
Logic Synthesis → Placement & Routing → Bitstream   ← Vivado
        ↓
Program FPGA via USB
```

**Lab exercises** — builds toward a complete 32-bit MIPS processor:
Lab 1: basic comparator circuit. Lab 2: 4-bit adder on FPGA (switches → LEDs). Lab 3: seven-segment display using Verilog. Lab 4: FSM for car turn signals. Lab 5: ALU implementation. Lab 6: ALU testing and simulation. Lab 7: MIPS assembly code. Lab 8: full MIPS processor, run snake. Lab 9: add multiply and shift instructions.

---

## Verilog — Combinational Logic

**Two styles:**

**Structural** — describes how modules are wired together. Instantiate sub-modules, connect ports. Use named port connections `.port(signal)` — safer than positional.

```verilog
small i_first  (.A(A), .B(SEL), .Y(n1));
small i_second (.A(n1), .B(C),  .Y(Y));
```

Built-in gate primitives: `not`, `and`, `or`, `nand`, `nor` — no module definition needed.

**Behavioral** — functional description using logical/mathematical operators. One description can map to many gate-level realizations.

**Module definition:**
```verilog
module example (input a, input b, input c, output y);
  assign y = ~a & ~b & ~c | a & ~b & ~c | a & ~b & c;
endmodule
```

Buses: `input [31:0] a;` — always MSB first `[31:0]`, never `[0:31]`. Bit slicing: `longbus[12:5]`. Concatenation: `{a[2], a[1], a[0]}`. Duplication: `{4{a[0]}}`.

Numbers: `N'Bxx` — N bits, B base (b/h/d/o), xx value. `X` = unknown, `Z` = floating.

| Verilog | Stored |
|---------|--------|
| `4'b1001` | 1001 |
| `8'b0000_1001` | 0000 1001 |
| `12'hFA3` | 1111 1010 0011 |
| `4'd5` | 0101 |

Bitwise: `&` AND, `|` OR, `^` XOR, `~` NOT. Reduction: `&a` ANDs all bits together. Conditional: `assign y = s ? d1 : d0;`

**Parameterized modules:**
```verilog
module mux2 #(parameter width = 8)
  (input [width-1:0] d0, d1, input s, output [width-1:0] y);
  assign y = s ? d1 : d0;
endmodule
// override width at instantiation:
mux2 #(12) i_mux (.d0(d0), .d1(d1), .s(s), .out(out));
```

---

## Verilog — Sequential Logic

Combinational logic uses `assign`. Sequential logic needs `always`. Variables assigned inside `always` must be declared `reg`.

**D flip-flop:**
```verilog
always @ (posedge clk)
  q <= d;
```

**Asynchronous reset** (fires independently of clock):
```verilog
always @ (posedge clk, negedge reset)
begin
  if (reset == 0) q <= 0;
  else            q <= d;
end
```

**Synchronous reset** (only on clock edge):
```verilog
always @ (posedge clk)
begin
  if (reset) q <= 0;
  else       q <= d;
end
```

With enable: `else if (en) q <= d;` — `en` is not in the sensitivity list.

**Blocking (`=`) vs. non-blocking (`<=`):**

| | Non-blocking (`<=`) | Blocking (`=`) |
|---|---|---|
| Assignment | End of block, concurrently | Immediately, sequentially |
| Use for | Sequential logic | Combinational in always blocks |

Non-blocking operates on "old" values — the block may trigger again after signals update, eventually settling correctly.

**Assignment rules:**
- Sequential: `always @(posedge clk)` + `<=`
- Simple combinational: `assign`
- Complex combinational: `always @(*)` + `=`
- Never assign the same signal from more than one always block

An `always @(*)` block is combinational only if every output is assigned in every branch of every if/case. Missing a case infers a latch — Vivado warns about this.

**Case statement:**
```verilog
always @ (*)
  case (data)
    4'd0: segments = 7'b111_1110;
    4'd1: segments = 7'b011_0000;
    default: segments = 7'b000_0000; // always include
  endcase
```

---

## FSMs in Verilog

Three always-separate blocks — keep them physically separate:

```verilog
// 1. State register
always @ (posedge clk, posedge reset)
  if (reset) state <= S0;
  else       state <= nextstate;

// 2. Next state logic
always @ (*)
  case (state)
    S0: nextstate = S1;
    S1: nextstate = S2;
    S2: nextstate = S0;
    default: nextstate = S0;
  endcase

// 3. Output logic (Moore)
assign q = (state == S0);
// Mealy: assign smile = (number & state == S3);
```

Define states as parameters: `parameter S0 = 2'b00;`

---

