# Digital Design & Computer Architecture - Lecture 3
### Sequential Logic | Prof. Onur Mutlu | ETH Zürich, Spring 2025

---

## What's Covered

Wrapping up from Lecture 2: logical completeness, comparator, ALU, tri-state buffer. Then the main topic: sequential logic — storage elements, flip-flops, and finite state machines.

---

## From Combinational to Sequential

Every circuit covered so far was memoryless — same inputs always produce the same outputs. That's combinational logic.

Real computers need to remember things. A CPU has to remember what instruction it just ran. A traffic light has to remember what phase it's in. A lock has to remember how many correct steps have been entered. Sequential logic makes this possible — the output now depends on current inputs *and* past history (stored state).

This is why memory dominates modern chip die area. In almost every processor die shot shown in lecture — AMD Ryzen, Intel Pentium 4, IBM POWER10, Nvidia Ampere — the majority of the area is memory (caches). Computing without memory doesn't work.

---

## Storage Elements

### Cross-Coupled Inverters

Wire two NOT gates so each feeds the other's input. This has two stable states: Q=1 or Q=0, and holds indefinitely — that's memory. But there's no control mechanism, no way to write to it, so it's not useful on its own. There's also a third metastable state where outputs oscillate before settling — undefined and bad, more on that in the timing lecture.

---

### R-S Latch

Built from two cross-coupled NAND gates with two control inputs: **S (Set)** and **R (Reset)**.

Idle: both S and R at 1, Q holds. To set Q=1: pull S to 0. To reset Q=0: pull R to 0.

| R | S | Q |
|---|---|---|
| 1 | 1 | Qprev |
| 1 | 0 | 1 |
| 0 | 1 | 0 |
| 0 | 0 | **FORBIDDEN** |

R=S=0 is forbidden because both Q and Q' become 1, breaking the invariant that Q = NOT(Q'). Releasing both back to 1 simultaneously causes oscillation — metastability.

---

### Gated D Latch

The R-S latch's forbidden state is a real problem. Fix: add two more NAND gates, giving a **Gated D Latch** with inputs **D** (data) and **WE** (write enable).

When WE=1: Q follows D (transparent). When WE=0: Q holds, ignoring D.

| WE | D | Q |
|----|---|---|
| 0 | X | Qprev |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

S and R can never both be 0 here because D and NOT(D) are always opposites. Problem solved.

---

### Register

Multiple D latches in parallel with a shared WE signal. A 4-bit register is just four D latches sharing one WE, storing Q[3:0].

---

### Memory

Scale up: an array of locations each holding multiple bits. Two key properties — **address space** (the set of all unique locations, needing log₂(N) address bits) and **addressability** (bits per location, typically 8 in modern memory).

To read: address feeds a decoder to select the right row, a MUX brings those bits out. To write: decoder selects the row, WE enables only that row.

This is the basic SRAM architecture — about 6 transistors per bit, fast but expensive. DRAM uses 1 transistor + 1 capacitor per bit, cheaper and denser but slower and needs periodic refresh.

---

## The Problem with Latches in Sequential Circuits

When circuit output feeds back into the input, latches cause trouble. If CLK drives WE directly: when CLK=HIGH the latch is transparent, so Q changes, which can change D, which changes Q again — all within the same clock cycle. The output keeps shifting while the clock is high.

What's actually needed: Q updates once at the clock edge, then holds steady for the entire cycle even if D changes afterward. A latch can't do this — it's level-triggered. Something edge-triggered is needed.

---

### D Flip-Flop

Chain two D latches together. First latch is enabled when CLK=0 (propagates D internally). Second latch is enabled when CLK=1 (latches the value from the first). Q only updates at the **rising edge** (0→1), and holds for the rest of the cycle.

```
D → [Latch 1, enabled on CLK=LOW] → [Latch 2, enabled on CLK=HIGH] → Q
```

CLK rises: D is captured into Q. All other times: Q holds regardless of D.

Latch vs flip-flop in one line: a latch is level-triggered (follows D while enabled), a flip-flop is edge-triggered (captures D only on the clock edge).

Multiple D flip-flops in parallel = a **D flip-flop register**. This is the actual state register used in real CPUs.

---

## State

With flip-flops, circuits can genuinely remember history. State is a snapshot of all relevant stored values at a given moment.

Classic example: a combination lock for R13-L22-R3. The lock must remember progress through the sequence — State A (nothing done), State B (R13 done), State C (R13-L22 done), State D (unlocked). Any wrong input sends it back to A.

---

## Synchronous vs. Asynchronous

Asynchronous circuits change state whenever they change — no clock controls timing, like the combination lock above. Synchronous circuits change state only at clock edges — every flip-flop in the system updates simultaneously.

Modern computers are almost entirely synchronous. It's far easier to reason about correctness when everything changes at the same tick. The cost is clock overhead — power is always consumed just keeping the clock running.

The clock alternates between 0 and 1 at a fixed frequency. On each rising edge, state registers update simultaneously. Between edges, combinational logic evaluates the next state and must fully settle before the next edge. If the clock is too fast and logic hasn't finished evaluating, the flip-flops sample wrong values — timing violation.

---

## Finite State Machines

An FSM is the formal model for any sequential circuit. Any system with state can be described as one.

**5 elements:** a finite set of states, a finite set of inputs, a finite set of outputs, a transition function (current state + input → next state), and an output function (state → output, or state + input → output).

**3 hardware parts:**

| Part | Type | Role |
|------|------|------|
| State register | Sequential (flip-flops) | Stores current state, loads next state on clock edge |
| Next state logic | Combinational | Computes next state from current state + inputs |
| Output logic | Combinational | Computes outputs from current state (and maybe inputs) |

---

## Moore vs. Mealy

Moore FSM: outputs depend only on current state. Outputs labeled inside state circles. Simpler, more common, default for this course.

Mealy FSM: outputs depend on current state and inputs. Can respond faster since output can change within a cycle based on input, but harder to design and verify.

---

## FSM Design Process

The traffic light example from lecture walks through the full flow.

**1. Define states** — every distinct situation the system can be in.

**2. State transition diagram** — circles are states (labeled with outputs for Moore), arcs are transitions labeled with the input condition that triggers them. Start from the reset state.

**3. State transition table** — list current state + inputs → next state. Encode states as binary (S0=00, S1=01, etc.).

**4. Next state logic** — derive Boolean equations from the transition table using SOP. Simplify.

**5. Output table** — list current state → outputs. Derive Boolean equations.

**6. Schematic** — state register built from flip-flops, next state logic and output logic built from combinational gates.

---

### State Encoding Options

| Encoding | Bits | Tradeoff |
|----------|------|----------|
| Binary | log₂(N) | Fewest flip-flops, more complex next state logic |
| One-hot | N (one per state) | Most flip-flops, simplest next state logic — good for automated tools |
| Output | Based on output bits | Outputs readable directly from state, minimizes output logic — Moore only |

---
