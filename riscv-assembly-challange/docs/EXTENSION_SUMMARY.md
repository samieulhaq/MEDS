# RISC-V C Extension Summary
MEDS Module 3 — Self-Study Deliverable

## What the C Extension Adds

The C (Compressed) extension adds 16-bit versions of the most
commonly used RV32I instructions. Every standard RISC-V instruction
is 32 bits wide. The C extension introduces a parallel set of
encodings that fit the same operations into 16 bits, reducing
code size by approximately 25%.

The processor decodes compressed instructions back to their 32-bit
equivalents internally — the programmer and compiler see no
functional difference. Only the binary representation changes.

---

## How It Works

Standard RV32I encodes every instruction in exactly 32 bits.
The C extension identifies instructions where:
- Registers involved are among the most-used (x8-x15, sp, ra)
- Immediates are small enough to fit in fewer bits

For these common cases a 16-bit encoding is used instead.
The two lowest bits of an instruction word identify whether
it is a 16-bit compressed instruction (00, 01, 10) or a
standard 32-bit instruction (11).

Common compressed instructions:
- c.add, c.mv      — register arithmetic and move
- c.lw, c.sw       — word load and store
- c.j, c.jr        — jumps
- c.beqz, c.bnez   — conditional branches
- c.addi, c.li     — immediate arithmetic
- c.addi16sp       — stack pointer adjustment

---

## Why It Matters

**Code density:** Embedded systems have tight flash/ROM constraints.
A 25% reduction in code size means either smaller, cheaper hardware
or more functionality in the same memory budget.

**Instruction cache efficiency:** Smaller code means more instructions
fit in the same cache size, reducing cache misses and improving
performance without changing the pipeline.

**Real-world adoption:** The C extension is part of RV32IMAC and
RV64GC — the two most common RISC-V profiles for embedded Linux
and application processors. Virtually every production RISC-V chip
ships with C enabled.

**Transparent to the programmer:** Unlike THUMB mode on ARM which
requires explicit mode switching, RISC-V C extension instructions
are intermixed freely with 32-bit instructions. The assembler
handles encoding automatically when you pass -march=rv32imac.