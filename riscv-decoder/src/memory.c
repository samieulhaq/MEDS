
size_t load_hex_file(const char *filename, uint32_t *memory, size_t memory_size) {
    if (filename == NULL || memory == NULL || memory_size == 0) return 0;
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Failed to open file");
        return 0;
    }

    size_t count = 0;
    while (count < memory_size && fscanf(file, "%x", &memory[count]) == 1) {
        count++;
    }

    fclose(file);
    return count;
}