#!/bin/bash
# generate_report.sh — Batch report generator for all log files
# Author: Sami Ul Haq
# Date: 2026-05-27

set -uo pipefail

# ─── Colors ───────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ─── Setup paths ──────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ANALYZE="$SCRIPT_DIR/analyze.sh"
TEST_DATA="$PROJECT_ROOT/test_data"
OUTPUT_DIR="$PROJECT_ROOT/output"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
SUMMARY_FILE="$OUTPUT_DIR/summary_${TIMESTAMP}.txt"

# ─── Functions ────────────────────────────────────────────────────

check_analyzer() {
    if [ ! -f "$ANALYZE" ]; then
        echo "Error: analyze.sh not found at $ANALYZE"
        exit 1
    fi
    if [ ! -x "$ANALYZE" ]; then
        chmod +x "$ANALYZE"
    fi
}

generate_all_reports() {
    mkdir -p "$OUTPUT_DIR"

    echo "╔══════════════════════════════════════╗"
    echo "║   RISC-V Log Analyzer — Batch Run   ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "Scanning: $TEST_DATA"
    echo "Output:   $OUTPUT_DIR"
    echo ""

    # Write summary header
    {
        echo "=== Batch Analysis Summary ==="
        echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
    } > "$SUMMARY_FILE"

    local total_logs=0
    local passed_logs=0
    local failed_logs=0

    # Process each log file found in test_data/
    for logfile in "$TEST_DATA"/*.log; do
        [ -f "$logfile" ] || continue

        local name
        name=$(basename "$logfile" .log)
        local out_file="$OUTPUT_DIR/report_${name}_${TIMESTAMP}.txt"

        echo -e "${YELLOW}Processing:${NC} $name"

        # Run analyzer and capture exit code
        if bash "$ANALYZE" "$logfile" --output "$out_file"; then
            echo -e "  ${GREEN}[PASS]${NC} Report saved: $(basename "$out_file")"
            echo "  $name: PASS" >> "$SUMMARY_FILE"
            passed_logs=$((passed_logs + 1))
        else
            echo -e "  ${RED}[FAIL]${NC} Report saved: $(basename "$out_file")"
            echo "  $name: FAIL" >> "$SUMMARY_FILE"
            failed_logs=$((failed_logs + 1))
        fi

        total_logs=$((total_logs + 1))
        echo ""
    done

    # Write summary footer
    {
        echo ""
        echo "--- Overall ---"
        echo "Total logs processed: $total_logs"
        echo "Logs with all passing: $passed_logs"
        echo "Logs with failures:    $failed_logs"
    } >> "$SUMMARY_FILE"

    echo "=== Batch Complete ==="
    echo "Total logs processed: $total_logs"
    echo -e "All passing: ${GREEN}$passed_logs${NC}"
    echo -e "With failures: ${RED}$failed_logs${NC}"
    echo ""
    echo "Summary saved to: $SUMMARY_FILE"
}

# ─── Main ─────────────────────────────────────────────────────────
check_analyzer
generate_all_reports
