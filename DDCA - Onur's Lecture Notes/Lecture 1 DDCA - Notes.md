# Digital Design & Computer Architecture - Lecture 1
### Digital Design & Computer Architecture | Prof. Onur Mutlu | ETH Zürich, Spring 2025

---

## What's Covered

The transformation hierarchy from electrons to software, computer architecture as a discipline, CPU vs FPGA vs ASIC tradeoffs, transistors, CMOS, and logic gates.

---

## The Transformation Hierarchy

The central diagram of the course. A real-world problem gets solved by electrons through a chain of abstractions:

```
Problem
  → Algorithm
    → Program / Language
      → System Software (OS, VM, etc.)
        → ISA (the HW/SW boundary)
          → Microarchitecture
            → Logic (gates)
              → Devices (transistors)
                → Electrons
```

Every layer abstracts over the one below it. The key point: looking at only one layer leaves performance on the table. Real gains come from co-designing across layers — hardware and software working together. Computer architecture in the broad sense covers the entire hierarchy, not just the middle.

---

## What Computer Architecture Is

The science and art of designing computing platforms to meet a set of goals. Those goals shift entirely depending on the application — a smartphone optimizes for battery life and size, a supercomputer for raw throughput, a self-driving car chip for safety and real-time response, a TPU for matrix operation throughput. Same fundamentals, completely different tradeoffs.

---

## CPU vs FPGA vs ASIC

| Type | Examples | Dev Time | Performance | Good For |
|------|----------|----------|-------------|----------|
| CPU | Intel, AMD, Apple M1 | Minutes | Moderate | General purpose |
| FPGA | Xilinx, Altera | Days | Better | Prototyping, smaller volume |
| ASIC | Google TPU, Cerebras | Months | Best | Mass production, max efficiency |

An adjustable wrench works on everything but isn't perfect for anything (CPU). A fixed wrench is perfect for one bolt and useless for everything else (ASIC). In the labs, a microprocessor gets built on an FPGA using Verilog — prototyping a CPU on reconfigurable hardware.

---

## Transistors

Every computation comes down to transistors switching on and off. A transistor is an electronic switch made from Metal, Oxide, and Semiconductor — hence MOS transistor.

| Type | Conducts when... |
|------|-----------------|
| n-type | Gate gets HIGH voltage |
| p-type | Gate gets LOW voltage |

n-type is a normally-open switch that closes when voltage is applied. p-type is the opposite.

Transistor counts over time: Intel 4004 (1971) had 2,300. Pentium IV (2000) had 42 million. Apple M2 Max (2022) has 67 billion. Moore's Law predicted roughly doubling every two years — it's been slowing down, which is why the industry has shifted toward specialized architectures rather than just adding more transistors.

---

## CMOS

Modern chips use CMOS (Complementary MOS) — both n-type and p-type transistors together. When one type is ON the other is OFF, so there is never a direct path from power to ground simultaneously. That's why CMOS dominates: low power dissipation.

The simplest CMOS circuit is the NOT gate (inverter). Input=0V → p-type ON, n-type OFF → output HIGH. Input=3V → n-type ON, p-type OFF → output LOW. Everything else is built from this.

General rule for CMOS gate design: pMOS transistors form the pull-up network (connected to VDD), nMOS transistors form the pull-down network (connected to ground). Exactly one network is ON at a time. Both ON → short circuit. Both OFF → floating output. Either way is bad.

---

## Logic Gates

Gates are transistors wired together to implement Boolean logic. NOT flips the input. NAND is AND then invert — output is LOW only when both inputs are HIGH. AND is NAND followed by NOT. NOR is OR then invert. OR is NOR followed by NOT.

NAND is universal — any logic function can be built from NAND gates alone. Same for NOR. In a NAND gate the two pMOS transistors are in parallel (only one needs to be ON to pull output HIGH) and the two nMOS transistors are in series (both must be ON to pull output LOW). That's exactly the NAND truth table.

---

## Key Terms

**ISA** — the contract between software and hardware. Defines what instructions exist and how they behave. Changes rarely. Examples: x86, ARM, RISC-V.

**Microarchitecture** — the actual hardware implementing an ISA. Changes often with each CPU generation while the same software keeps running.

**FPGA** — reconfigurable hardware programmed with Verilog/VHDL. Good for prototyping.

**ASIC** — custom chip built for one job. Maximum performance but months to design and cannot be changed after fabrication.

---
