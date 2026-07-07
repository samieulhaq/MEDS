# Makefile — RISC-V RV32I Instruction Decoder
# Author: Sami Ul Haq

CC      = gcc
CFLAGS  = -Wall -Wextra -std=c11 -g -Iinclude
LDFLAGS =

SRC_DIR = src
OBJ_DIR = build
BIN_DIR = bin

SRC    = $(wildcard $(SRC_DIR)/*.c)
OBJ    = $(SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
TARGET = $(BIN_DIR)/riscv-decoder

.PHONY: all clean test debug release help

all: dirs $(TARGET)

dirs:
	@mkdir -p $(OBJ_DIR) $(BIN_DIR)

$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^
	@echo "Build complete: $@"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

debug: CFLAGS += -DDEBUG -O0
debug: all

release: CFLAGS += -O2 -DNDEBUG
release: all

test: all
	@echo "=== Testing r_type ==="
	@./$(TARGET) test/programs/r_type.hex
	@echo "=== Testing i_type ==="
	@./$(TARGET) test/programs/i_type.hex
	@echo "=== Testing branch ==="
	@./$(TARGET) test/programs/branch.hex
	@echo "=== Testing mixed ==="
	@./$(TARGET) test/programs/mixed.hex

valgrind: all
	valgrind --leak-check=full ./$(TARGET) test/programs/mixed.hex

clean:
	@rm -rf $(OBJ_DIR) $(BIN_DIR)
	@echo "Cleaned."

help:
	@echo ""
	@echo "RISC-V Decoder — Available targets:"
	@echo "  make all      Build the decoder"
	@echo "  make test     Run all test hex files"
	@echo "  make debug    Build with debug symbols and logging"
	@echo "  make release  Build optimized"
	@echo "  make valgrind Check for memory leaks"
	@echo "  make clean    Remove build artifacts"
	@echo "  make help     Show this message"
	@echo ""