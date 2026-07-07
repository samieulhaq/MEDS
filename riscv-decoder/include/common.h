/* RISC-V RV32I */
#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>

#define INSTRUCTION_SIZE 32

#define EXTRACT_BITS(value, start, length) \
    (((value) >> (start)) & ((1U << (length)) - 1))

// field widths for instruction decoding
#define OPCODE_SHIFT   0
#define OPCODE_WIDTH   7

#define RD_SHIFT       7
#define RD_WIDTH       5

#define FUNCT3_SHIFT   12
#define FUNCT3_WIDTH   3

#define RS1_SHIFT      15
#define RS1_WIDTH      5

#define RS2_SHIFT      20
#define RS2_WIDTH      5

#define FUNCT7_SHIFT   25
#define FUNCT7_WIDTH   7

#endif