#ifndef MEMORY_H
#define MEMORY_H

#include <stdint.h>
#include <stddef.h>


size_t load_hex_file(const char *filename, uint32_t **memory, size_t *capacity);

#endif