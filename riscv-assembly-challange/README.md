# RISC-V Assembly Programming Challenge
Three assembly programs written for the Venus RISC-V simulator.

## How to Run
Open https://venus.cs61c.org/, paste the .s file contents into
the editor, click Assemble & Simulate, then Run.

## Programs

**part1_array_ops.s**
Four array functions on a 12-element signed integer array.
sum_array, find_min, find_max, count_negative.

**part2_recursion.s**
Recursive merge sort on a 12-element signed integer array.
Input: 10 -5 20 -15 30 40 -8 50 60 -25 70 6
Output: -25 -15 -8 -5 6 10 20 30 40 50 60 70

**part3_encoding.s**
Loads 6 hand-encoded instructions (one per format: R I S B U J)
and extracts opcode, rd, rs1, funct3 using shift-and-mask.

## Docs
ENCODING_WORKSHEET.md — hand encoding work for all 6 instructions
PRIVILEGED_SUMMARY.md — RISC-V privilege levels, CSRs, trap flow
EXTENSION_SUMMARY.md  — RISC-V C extension summary

## Author
Sami Ul Haq — MEDS Lab, UET Lahore — Summer 2026