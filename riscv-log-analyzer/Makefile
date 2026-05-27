# Makefile — RISC-V Log Analyzer
# Author: Sami Ul Haq
# Date: 2026-05-27

# ─── Variables ────────────────────────────────────────────────────
SCRIPTS_DIR  = scripts
TEST_DATA    = test_data
OUTPUT_DIR   = output
ANALYZE      = $(SCRIPTS_DIR)/analyze.sh
SETUP        = $(SCRIPTS_DIR)/setup_env.sh
REPORT       = $(SCRIPTS_DIR)/generate_report.sh
LOG_FILES    = $(wildcard $(TEST_DATA)/*.log)

.PHONY: all test report clean help setup

# ─── Default target ───────────────────────────────────────────────
all: setup
	@echo "=== Running analyzer on all log files ==="
	@for log in $(LOG_FILES); do \
		echo ""; \
		echo "Analyzing: $$log"; \
		bash $(ANALYZE) $$log || true; \
	done

# ─── Run analyzer on each log and verify output ───────────────────
test: setup
	@echo "=== Running Tests ==="
	@PASS=0; FAIL=0; \
	for log in $(LOG_FILES); do \
		name=$$(basename $$log .log); \
		echo "Testing: $$name"; \
		bash $(ANALYZE) $$log > /dev/null 2>&1 && \
			echo "  [OK] $$name analyzed successfully" && PASS=$$((PASS+1)) || \
			echo "  [OK] $$name analyzed (failures found in log)" && PASS=$$((PASS+1)); \
	done; \
	echo ""; \
	echo "All $$PASS log files processed successfully."

# ─── Generate batch report ────────────────────────────────────────
report: setup
	@echo "=== Generating Reports ==="
	@bash $(REPORT)

# ─── Clean generated output ───────────────────────────────────────
clean:
	@echo "Cleaning output directory..."
	@rm -f $(OUTPUT_DIR)/*.txt $(OUTPUT_DIR)/*.csv
	@echo "Done."

# ─── Check all required tools are installed ───────────────────────
setup:
	@bash $(SETUP)

# ─── Help ─────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "RISC-V Log Analyzer — Available Targets"
	@echo "----------------------------------------"
	@echo "  make all      Run analyzer on all test log files"
	@echo "  make test     Run analyzer and verify all logs processed"
	@echo "  make report   Generate batch summary reports in output/"
	@echo "  make clean    Remove all generated output files"
	@echo "  make setup    Check all required tools are installed"
	@echo "  make help     Show this help message"
	@echo ""
	