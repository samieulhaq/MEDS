#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "memory.h"

#define MEMORY_SIZE 1024

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <hex_file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    uint32_t memory[MEMORY_SIZE];

    size_t count = load_hex_file(argv[1], memory, MEMORY_SIZE);

    printf("Loaded %zu instructions\n", count);

    for (size_t i = 0; i < count; i++) {
        printf("%08X\n", memory[i]);
    }

    return EXIT_SUCCESS;
}