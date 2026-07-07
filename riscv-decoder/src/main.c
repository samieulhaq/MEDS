#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "memory.h"
#include "decoder.h"
#include "common.h"

#define MEMORY_SIZE 1024

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <hex_file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    uint32_t memory[MEMORY_SIZE];
    size_t count = load_hex_file(argv[1], memory, MEMORY_SIZE);

    if (count == 0) {
        fprintf(stderr, "Error: no instructions loaded\n");
        return EXIT_FAILURE;
    }

    printf("RISC-V RV32I Instruction Decoder\n");
    printf("================================\n");
    printf("Loaded %zu instructions from %s\n\n", count, argv[1]);
    printf("%-10s %-10s %s\n", "Addr", "Hex", "Assembly");
    printf("---------- ---------- -------------------------\n");

    uint32_t valid = 0, unknown = 0;
    decoded_instr_t instr;

    for (size_t i = 0; i < count; i++) {
        decode_instruction(memory[i], &instr);
        print_instruction(i * 4, &instr);

        /* check if unknown — opcode not in our list */
        uint32_t op = instr.opcode;
        if (op != 0x33 && op != 0x13 && op != 0x03 && op != 0x23 &&
            op != 0x63 && op != 0x6F && op != 0x67 && op != 0x37 &&
            op != 0x17 && op != 0x73)
            unknown++;
        else
            valid++;
    }

    printf("\nDecoded %zu instructions (%u valid, %u unknown)\n",
           count, valid, unknown);

    return EXIT_SUCCESS;
}