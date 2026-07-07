#include "decoder.h"
#include <stdio.h>

/* sign extend a value of bit_width bits to 32 bits */
static int32_t sign_extend(uint32_t value, int bit_width) {
    uint32_t sign_bit = 1U << (bit_width - 1);
    return (int32_t)((value ^ sign_bit) - sign_bit);
}

void decode_instruction(uint32_t raw, decoded_instr_t *out) {
    out->raw    = raw;
    out->opcode = EXTRACT_BITS(raw, OPCODE_SHIFT, OPCODE_WIDTH);
    out->rd     = EXTRACT_BITS(raw, RD_SHIFT,     RD_WIDTH);
    out->funct3 = EXTRACT_BITS(raw, FUNCT3_SHIFT, FUNCT3_WIDTH);
    out->rs1    = EXTRACT_BITS(raw, RS1_SHIFT,    RS1_WIDTH);
    out->rs2    = EXTRACT_BITS(raw, RS2_SHIFT,    RS2_WIDTH);
    out->funct7 = EXTRACT_BITS(raw, FUNCT7_SHIFT, FUNCT7_WIDTH);
    out->imm    = 0;

    switch ((opcode_t)out->opcode) {

        case OP_I_ARITH:
        case OP_LOAD:
        case OP_JALR:
            /* I-type: imm[11:0] = bits[31:20] */
            out->imm = sign_extend(EXTRACT_BITS(raw, 20, 12), 12);
            break;

        case OP_STORE:
            /* S-type: imm[11:5] = bits[31:25], imm[4:0] = bits[11:7] */
            out->imm = sign_extend(
                (EXTRACT_BITS(raw, 25, 7) << 5) | EXTRACT_BITS(raw, 7, 5),
                12);
            break;

        case OP_BRANCH:
            /* B-type: imm[12|10:5|4:1|11] scattered */
            out->imm = sign_extend(
                (EXTRACT_BITS(raw, 31, 1) << 12) |
                (EXTRACT_BITS(raw, 7,  1) << 11) |
                (EXTRACT_BITS(raw, 25, 6) << 5)  |
                (EXTRACT_BITS(raw, 8,  4) << 1),
                13);
            break;

        case OP_LUI:
        case OP_AUIPC:
            /* U-type: imm[31:12] = bits[31:12] shifted left 12 */
            out->imm = (int32_t)(raw & 0xFFFFF000);
            break;

        case OP_JAL:
            /* J-type: imm[20|10:1|11|19:12] scattered */
            out->imm = sign_extend(
                (EXTRACT_BITS(raw, 31, 1)  << 20) |
                (EXTRACT_BITS(raw, 12, 8)  << 12) |
                (EXTRACT_BITS(raw, 20, 1)  << 11) |
                (EXTRACT_BITS(raw, 21, 10) << 1),
                21);
            break;

        case OP_R_TYPE:
        case OP_SYSTEM:
        default:
            break;
    }
}

void print_instruction(uint32_t addr, decoded_instr_t *d) {
    printf("0x%08X: %08X  ", addr, d->raw);

    switch ((opcode_t)d->opcode) {

        case OP_R_TYPE: {
            /* funct7 bit5 + funct3 determines exact operation */
            int alt = (d->funct7 >> 5) & 1;
            const char *mnemonic = "UNKNOWN";
            switch (d->funct3) {
                case 0x0: mnemonic = alt ? "sub"  : "add";  break;
                case 0x1: mnemonic = "sll";  break;
                case 0x2: mnemonic = "slt";  break;
                case 0x3: mnemonic = "sltu"; break;
                case 0x4: mnemonic = "xor";  break;
                case 0x5: mnemonic = alt ? "sra"  : "srl";  break;
                case 0x6: mnemonic = "or";   break;
                case 0x7: mnemonic = "and";  break;
            }
            printf("%-6s x%u, x%u, x%u\n", mnemonic, d->rd, d->rs1, d->rs2);
            break;
        }

        case OP_I_ARITH: {
            const char *mnemonic = "UNKNOWN";
            int alt = (d->funct7 >> 5) & 1;
            switch (d->funct3) {
                case 0x0: mnemonic = "addi";  break;
                case 0x1: mnemonic = "slli";  break;
                case 0x2: mnemonic = "slti";  break;
                case 0x3: mnemonic = "sltiu"; break;
                case 0x4: mnemonic = "xori";  break;
                case 0x5: mnemonic = alt ? "srai" : "srli"; break;
                case 0x6: mnemonic = "ori";   break;
                case 0x7: mnemonic = "andi";  break;
            }
            printf("%-6s x%u, x%u, %d\n", mnemonic, d->rd, d->rs1, d->imm);
            break;
        }

        case OP_LOAD: {
            const char *mnemonic = "UNKNOWN";
            switch (d->funct3) {
                case 0x0: mnemonic = "lb";  break;
                case 0x1: mnemonic = "lh";  break;
                case 0x2: mnemonic = "lw";  break;
                case 0x4: mnemonic = "lbu"; break;
                case 0x5: mnemonic = "lhu"; break;
            }
            printf("%-6s x%u, %d(x%u)\n", mnemonic, d->rd, d->imm, d->rs1);
            break;
        }

        case OP_STORE: {
            const char *mnemonic = "UNKNOWN";
            switch (d->funct3) {
                case 0x0: mnemonic = "sb"; break;
                case 0x1: mnemonic = "sh"; break;
                case 0x2: mnemonic = "sw"; break;
            }
            printf("%-6s x%u, %d(x%u)\n", mnemonic, d->rs2, d->imm, d->rs1);
            break;
        }

        case OP_BRANCH: {
            const char *mnemonic = "UNKNOWN";
            switch (d->funct3) {
                case 0x0: mnemonic = "beq";  break;
                case 0x1: mnemonic = "bne";  break;
                case 0x4: mnemonic = "blt";  break;
                case 0x5: mnemonic = "bge";  break;
                case 0x6: mnemonic = "bltu"; break;
                case 0x7: mnemonic = "bgeu"; break;
            }
            printf("%-6s x%u, x%u, %d\n", mnemonic, d->rs1, d->rs2, d->imm);
            break;
        }

        case OP_JAL:
            printf("%-6s x%u, %d\n", "jal", d->rd, d->imm);
            break;

        case OP_JALR:
            printf("%-6s x%u, %d(x%u)\n", "jalr", d->rd, d->imm, d->rs1);
            break;

        case OP_LUI:
            printf("%-6s x%u, 0x%X\n", "lui", d->rd, (uint32_t)d->imm >> 12);
            break;

        case OP_AUIPC:
            printf("%-6s x%u, 0x%X\n", "auipc", d->rd, (uint32_t)d->imm >> 12);
            break;

        case OP_SYSTEM:
            printf("ecall/ebreak\n");
            break;

        default:
            printf("UNKNOWN\n");
            break;
    }
}