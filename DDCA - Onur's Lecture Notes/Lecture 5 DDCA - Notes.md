# Digital Design & Computer Architecture - Lecture 5
### Digital Design & Computer Architecture | Prof. Onur Mutlu | ETH Zürich, Spring 2025

---

## What's Covered

5a: HDLs, structural vs. behavioral Verilog, sequential logic, FSMs in Verilog. 5b: combinational and sequential circuit timing, setup/hold constraints, glitches, verification.

---

## Why HDLs

HDLs let you describe hardware structures naturally — wires, gates, registers, clock edges — and capture the parallelism inherent in hardware. All hardware logic operates concurrently unlike software. This makes specification, simulation, and synthesis manageable. Hierarchical design (top-down or bottom-up) controls complexity the same way functions do in software.

---

## Structural vs. Behavioral Verilog

**Structural** describes how modules are wired together — instantiate gates and sub-modules, connect ports explicitly. Bottom-up view.

**Behavioral** describes what the circuit does using logical and mathematical operators. `assign y = s ? d1 : d0` is a complete MUX in one line. One behavioral description can map to many gate-level implementations.

Most real designs mix both.

---

## Key Verilog Syntax

Buses use `[31:0]` notation — MSB first, always consistent. Numbers written as `N'Bxx` (N bits, B base: b/h/d/o, xx value). `X` = unknown, `Z` = floating.

Bit operations:
```
assign shortbus = longbus[12:5];        // bit slicing
assign y = {a[2], a[1], a[0], a[0]};   // concatenation
assign y = {4{a[0]}};                   // duplication
```

Bitwise operators: `&` AND, `|` OR, `^` XOR, `~` NOT, `&a` reduction AND across all bits.

Conditional: `assign y = s ? d1 : d0;`

Chained conditional (4:1 MUX):
```
assign y = (s == 2'b11) ? d3 :
           (s == 2'b10) ? d2 :
           (s == 2'b01) ? d1 : d0;
```

**Parameterized modules** — avoid rewriting for every bit-width:
```
module mux2 #(parameter width = 8)
  (input [width-1:0] d0, d1, input s, output [width-1:0] y);
  assign y = s ? d1 : d0;
endmodule
// instantiate with different width:
mux2 #(12) i_mux (.d0(d0), .d1(d1), .s(s), .out(out));
```

---

## Sequential Logic in Verilog

Combinational logic uses `assign`. Sequential logic needs `always` — executes whenever the sensitivity list changes. Variables assigned inside `always` must be declared `reg`.

**D flip-flop:**
```
always @ (posedge clk)
  q <= d;
```

**Asynchronous reset** — reset fires independently of clock:
```
always @ (posedge clk, negedge reset)
begin
  if (reset == 0) q <= 0;
  else            q <= d;
end
```

**Synchronous reset** — reset only on clock edge:
```
always @ (posedge clk)
begin
  if (reset) q <= 0;
  else       q <= d;
end
```

**Blocking (`=`) vs. non-blocking (`<=`):**

| | Non-Blocking (`<=`) | Blocking (`=`) |
|---|---|---|
| When assigned | End of block, concurrently | Immediately, sequentially |
| Use for | Sequential logic | Combinational logic in always |

Rules: sequential → `always @(posedge clk)` + `<=`. Simple combinational → `assign`. Complex combinational → `always @(*)` + `=`. Never assign the same signal in more than one `always` block.

An `always` block is combinational only if every output is assigned in every branch and all inputs are in the sensitivity list. Missing a case infers a latch — Vivado will warn about it.

---

## FSMs in Verilog

Three always-separate blocks:

```
// 1. State register
always @ (posedge clk, posedge reset)
  if (reset) state <= S0;
  else       state <= nextstate;

// 2. Next state logic
always @ (*)
  case (state)
    S0: nextstate = S1;
    S1: nextstate = S2;
    default: nextstate = S0;
  endcase

// 3. Output logic (Moore)
assign q = (state == S0);
```

Moore: output depends only on state. Mealy: output depends on state and input — faster response, harder to verify.

---

## Combinational Circuit Timing

**Contamination delay (tcd)**: minimum time before output starts changing.
**Propagation delay (tpd)**: maximum time until output is fully settled.

For a circuit with two AND gates feeding an OR:
```
tpd = 2 × tpd_AND + tpd_OR   (critical/longest path)
tcd = tcd_AND                  (shortest path)
```

The **critical path** (longest tpd) limits maximum operating frequency. The **short path** (smallest tcd) matters for hold time. Delay varies with input direction, temperature, voltage, aging — always a range, never a single value.

---

## Glitches

One input transition → multiple output transitions before settling. Happens because fast and slow paths temporarily disagree. Visible in K-maps at transitions between prime implicants. Fixable by adding the consensus term — but costs area and power. Only worth fixing if intermediate output values actually matter.

---

## Sequential Circuit Timing

| Parameter | Meaning |
|-----------|---------|
| tsetup | D must be stable this long **before** the clock edge |
| thold | D must remain stable this long **after** the clock edge |
| tpcq | Max delay: clock edge → Q stable |
| tccq | Min delay: clock edge → Q starts changing |

Aperture = tsetup + thold. Violating it causes **metastability** — output stuck between 0 and 1, resolving non-deterministically.

**Setup constraint:**
```
Tc > tpcq + tpd + tsetup
fmax = 1 / (tpcq + tpd_critical + tsetup)
```
tpcq + tsetup is sequencing overhead — wasted. tpd is useful work.

**Hold constraint:**
```
tccq + tcd > thold
tcd > thold - tccq
```
Logic cannot be too fast. Independent of Tc — slowing the clock does nothing. Fixed by adding buffers on short paths. Doesn't affect fmax. Must be caught at design time — very hard to fix after manufacturing.

**Clock skew** — clock doesn't arrive everywhere simultaneously:
```
Setup: Tc > tpcq + tpd + tsetup + tskew
Hold:  tccq + tcd > thold + tskew
```
Inflates both constraints. Clock distribution networks (H-trees, meshes) exist to minimize this.

---

## Worked Example

tccq=30ps, tpcq=50ps, tsetup=60ps, thold=70ps, tpd=35ps/gate, tcd=25ps/gate. Critical path: 3 gates. Short path: 1 gate.

**Setup:** `Tc > 50 + (3×35) + 60 = 215ps` → fmax = 4.65GHz

**Hold:** `30 + 25 = 55ps > 70ps?` → No, violation.
Fix: add one buffer on short path → `30 + (2×25) = 80ps > 70ps` ✓ fmax unchanged.

---

## Verification

Two problems: functional correctness and timing. Low-level simulation is accurate but slow. HDL simulation is fast but misses real timing. Split: functional at HDL level, timing at circuit level after synthesis.

**Testbench types:**

| Type | Input Generation | Error Checking |
|------|-----------------|----------------|
| Simple | Manual | Manual (waveforms) |
| Self-checking | Manual | Automatic (`$display`) |
| Testvectors | File (`$readmemb`) | Automatic |
| Golden model | Automatic | Automatic (compare DUT vs. reference) |

A 32-bit adder has 2⁶⁴ inputs — exhaustive testing at 1ns/test takes 58.5 years. Brute force is never feasible. Formal methods and coverage-driven testing are necessary.

Timing verification runs after synthesis. Tools (Vivado, Synopsys) report worst-case paths, fmax, violations. Fixing is iterative: simplify critical path, split long chains, add buffers for hold violations.

Three design principles: minimize critical path delay (raises fmax), balance delays across paths (no bottlenecks), optimize for the common case.

---
