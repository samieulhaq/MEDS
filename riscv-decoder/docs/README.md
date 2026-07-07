# RISC-V RV32I Instruction Decoder

A command-line tool that reads a hex file containing RISC-V machine code,
decodes each instruction, and prints human-readable assembly.

## Build

    make all

## Usage

    ./bin/riscv-decoder <hex_file>

## Test

    make test

## Clean

    make clean

## Sample Output

    RISC-V RV32I Instruction Decoder
    ================================
    Loaded 8 instructions from test/programs/mixed.hex

    Addr       Hex        Assembly
    ---------- ---------- -------------------------
    0x00000000: 00500113  addi   x2, x0, 5
    0x00000004: 003100B3  add    x1, x2, x3
    0x00000008: FE209CE3  bne    x1, x2, -8

## Supported Instructions

    R-type: add, sub, and, or, xor, sll, srl, sra, slt, sltu
    I-type: addi, andi, ori, xori, slti, sltiu, slli, srli, srai
    Load:   lb, lh, lw, lbu, lhu
    Store:  sb, sh, sw
    Branch: beq, bne, blt, bge, bltu, bgeu
    Jump:   jal, jalr
    Upper:  lui, auipc

## Author

Sami Ul Haq — MEDS Lab, UET Lahore — Summer 2026