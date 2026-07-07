#ifndef DECODER_H
#define DECODER_H

#include <stdint.h>
#include "common.h"

/* RV32I opcodes */
typedef enum {
    OP_R_TYPE  = 0x33,
    OP_I_ARITH = 0x13,
    OP_LOAD    = 0x03,
    OP_STORE   = 0x23,
    OP_BRANCH  = 0x63,
    OP_JAL     = 0x6F,
    OP_JALR    = 0x67,
    OP_LUI     = 0x37,
    OP_AUIPC   = 0x17,
    OP_SYSTEM  = 0x73
} opcode_t;

/* decoded instruction fields */
typedef struct {
    uint32_t opcode;
    uint32_t rd;
    uint32_t funct3;
    uint32_t rs1;
    uint32_t rs2;
    uint32_t funct7;
    int32_t  imm;       /* sign extended immediate */
    uint32_t raw;       /* original 32 bit word */
} decoded_instr_t;

/* decode one instruction word into fields */
void decode_instruction(uint32_t raw, decoded_instr_t *out);

/* print decoded instruction in assembly format */
void print_instruction(uint32_t addr, decoded_instr_t *instr);

#endif /* DECODER_H */