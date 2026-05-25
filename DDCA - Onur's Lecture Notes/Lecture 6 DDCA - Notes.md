# Digital Design & Computer Architecture - Lecture 6
### Timing and Verification II | Prof. Onur Mutlu | ETH Zürich, Spring 2025

---

## What's Covered

Combinational and sequential circuit timing in full detail, clock skew, and the complete verification workflow — functional and timing.

---

## Combinational Circuit Timing

Digital logic assumes outputs change instantly with inputs — that's the abstraction. In real hardware transistors take finite time to switch and wires have capacitance and resistance. On a nanosecond scale even the speed of light matters.

**Contamination delay (tcd)**: earliest time after input changes that output starts moving — minimum delay.
**Propagation delay (tpd)**: latest time until output is fully settled — maximum delay.

Delay varies with input direction (0→1 vs 1→0), temperature, supply voltage, and aging — always a range.

For a circuit with two AND gates feeding an OR:
```
tpd = 2 × tpd_AND + tpd_OR   (critical path)
tcd = tcd_AND                  (short path)
```

**Critical path** — longest tpd — sets maximum operating frequency. **Short path** — smallest tcd — matters for hold time. In practice wire delays grow with length, the same gate type has different delays in different instances, and worst-case process/voltage/temperature corners must all be assumed.

---

## Glitches

One input transition causes multiple output transitions before settling. Fast and slow paths through the circuit temporarily disagree — the fast path produces a wrong intermediate output before the slow path catches up.

Visible in K-maps at transitions between prime implicants. Fix: add the consensus term — covers the transition and removes dependency on the changing input. But costs area, power, and design effort. Only worth fixing if intermediate output values actually matter. If only the final steady-state matters, glitches are harmless.

---

## Sequential Circuit Timing

A flip-flop samples D at the clock edge and holds until the next. It's built from combinational elements so D, Q, and CLK all have real timing requirements.

| Parameter | Meaning |
|-----------|---------|
| tsetup | D must be stable this long **before** the clock edge |
| thold | D must remain stable this long **after** the clock edge |
| tpcq | Max delay: clock edge → Q stable |
| tccq | Min delay: clock edge → Q starts changing |

Aperture = tsetup + thold. Violating it causes **metastability** — output stuck between 0 and 1, resolving to a random value after an unpredictable delay. A real hardware failure mode.

---

## Setup Time Constraint

Output of R1 must propagate through combinational logic and arrive stably at D2 before the next clock edge:

```
Tc > tpcq + tpd + tsetup
fmax = 1 / (tpcq + tpd_critical + tsetup)
```

Critical path tpd determines fmax. Time on tpcq and tsetup is sequencing overhead — wasted every cycle. Time on tpd is useful computation. A very short critical path means most of the cycle is wasted in overhead.

---

## Hold Time Constraint

Logic cannot propagate too fast — if Q1 reaches D2 before thold elapses after the clock edge, R2 samples data meant for the next cycle:

```
tccq + tcd > thold
tcd > thold - tccq
```

Does NOT depend on Tc — slowing the clock does nothing. Fixed by adding buffers on short paths to increase tcd. Doesn't touch the critical path, so fmax stays unchanged. Very hard to fix after manufacturing — must be caught at design time.

---

## Worked Example

tccq=30ps, tpcq=50ps, tsetup=60ps, thold=70ps, tpd=35ps/gate, tcd=25ps/gate. Critical path: 3 gates. Short path: 1 gate.

**Setup check:**
```
Tc > 50 + (3 × 35) + 60 = 215ps
fmax = 1/215ps ≈ 4.65GHz
```

**Hold check:**
```
tccq + tcd = 30 + 25 = 55ps
55ps > 70ps? → NO — violation
```

**Fix:** add one buffer on short path:
```
tccq + tcd = 30 + (2 × 25) = 80ps
80ps > 70ps? → YES — satisfied
fmax still 4.65GHz — unchanged
```

---

## Clock Skew

The clock doesn't reach every flip-flop simultaneously. Clock skew (tskew) is the difference in arrival time between two points. It tightens both constraints:

```
Setup: Tc > tpcq + tpd + tsetup + tskew
Hold:  tccq + tcd > thold + tskew
```

Skew inflates both tsetup and thold — more sequencing overhead and tighter hold requirements. Chip designers build clock distribution networks (H-trees, meshes) specifically to minimize skew across the die.

---

## Circuit Verification

Two problems: functional correctness and timing. Low-level circuit simulation is accurate but slow. HDL simulation is fast but doesn't capture real timing. Split responsibilities: functional correctness at HDL level, timing at circuit level after synthesis. Logic synthesis tools verify equivalence between HDL and synthesized netlist.

---

## Functional Verification — Testbench Types

The device under test is the **DUT**. A testbench is simulation-only — never synthesized, can use `#10` (wait 10ns) and `$display`.

| Type | Input Generation | Error Checking | Scalability |
|------|-----------------|----------------|-------------|
| Simple | Manual | Manual (waveforms) | Poor |
| Self-checking | Manual | Automatic (`$display`) | Poor |
| Testvectors | File (`$readmemb`) | Automatic | Moderate |
| Golden model | Automatic | Automatic (DUT vs. reference) | High |

Testvector format — `input_output` per line, e.g. `000_1`, `001_0`. Inputs applied on posedge clk, outputs checked on negedge clk. `$readmemb` loads the file into an array at simulation start.

Golden model: instantiate both DUT and a simpler trusted reference. Feed the same inputs, check outputs match every cycle. No hardcoded values. The difficulty is writing a correct golden model in the first place.

A 32-bit adder has 2⁶⁴ inputs — exhaustive testing at 1ns/test takes 58.5 years. Brute force is never feasible. Formal verification methods and coverage-driven testing are necessary.

---

## Timing Verification

After synthesis, tools (Vivado, Synopsys, Cadence) analyze the actual circuit and report: worst-case delay paths, fmax, and any violations. Designer provides target clock frequency as a constraint — the tool tries to meet it.

When tools fail: desired frequency too aggressive for critical path, too much logic on clock paths causing excessive skew, or asynchronous timing issues. Reports identify which paths failed — starting point for fixing.

Fixing is manual and iterative: simplify critical path logic, split long combinational chains across cycles, add buffers for hold violations, try different place-and-route options.

Three design principles:

**Critical path design** — minimize maximum combinational delay → raises fmax directly.
**Balanced design** — keep delays equal across all flip-flop pairs → no bottlenecks, no wasted cycles.
**Bread and butter design** — optimize for the common case → don't let rare edge cases set the clock period.

---
