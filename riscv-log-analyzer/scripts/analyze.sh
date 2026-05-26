#!/bin/bash
# analyze.sh — RISC-V Simulation Log Analyzer
# Author: Sami Ul Haq
# Date: 2026-05-27
# Usage: ./analyze.sh <logfile> [--format text|csv] [--output <path>] [--verbose] [--help]

set -uo pipefail

# ─── Default values ───────────────────────────────────────────────
LOG_FILE=""
FORMAT="text"
OUTPUT=""
VERBOSE=0

# ─── Colors ───────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# ─── Functions ────────────────────────────────────────────────────

print_usage() {
    echo "Usage: $0 <logfile> [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --format [text|csv]   Output format (default: text)"
    echo "  --output <path>       Output file path (default: stdout)"
    echo "  --verbose             Enable verbose output"
    echo "  --help                Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 test_data/sample_fail.log --format text --verbose"
}

parse_args() {
    if [ $# -lt 1 ]; then
        echo "Error: No log file specified."
        print_usage
        exit 1
    fi

    LOG_FILE="$1"
    shift

    while [ $# -gt 0 ]; do
        case "$1" in
            --format)
                FORMAT="$2"
                shift 2
                ;;
            --output)
                OUTPUT="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=1
                shift
                ;;
            --help)
                print_usage
                exit 0
                ;;
            *)
                echo "Error: Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
}

validate_input() {
    # Check file exists and is readable
    if [ ! -f "$LOG_FILE" ]; then
        echo "Error: File not found: $LOG_FILE"
        exit 1
    fi

    # Check format is valid
    if [ "$FORMAT" != "text" ] && [ "$FORMAT" != "csv" ]; then
        echo "Error: Invalid format '$FORMAT'. Use 'text' or 'csv'."
        exit 1
    fi

    [ $VERBOSE -eq 1 ] && echo "Validating input: OK"
}

analyze_log() {
    # Count results — use grep -c safely (returns 0 if no match, don't exit)
    TOTAL=$(grep -c "TEST PASS\|TEST FAIL\|TEST SKIP" "$LOG_FILE") || TOTAL=0
    PASSED=$(grep -c "TEST PASS" "$LOG_FILE") || PASSED=0
    FAILED=$(grep -c "TEST FAIL" "$LOG_FILE") || FAILED=0
    SKIPPED=$(grep -c "TEST SKIP" "$LOG_FILE") || SKIPPED=0

    # Calculate pass rate
    if [ "$TOTAL" -gt 0 ]; then
        PASS_RATE=$(awk "BEGIN {printf \"%.1f\", ($PASSED/$TOTAL)*100}")
    else
        PASS_RATE="0.0"
    fi

    # Get list of failed test names
    FAILED_TESTS=$(grep "TEST FAIL" "$LOG_FILE" | awk '{print $5}') || FAILED_TESTS=""

    # Extract timing values safely
    TIMES=$(grep "TEST PASS\|TEST FAIL" "$LOG_FILE" | grep -oE '[0-9]+\.[0-9]+s' | sed 's/s//') || TIMES=""

    if [ -n "$TIMES" ]; then
        MIN_TIME=$(echo "$TIMES" | sort -n | head -1)
        MAX_TIME=$(echo "$TIMES" | sort -n | tail -1)
        AVG_TIME=$(echo "$TIMES" | awk '{sum+=$1; count++} END {printf "%.2f", sum/count}')

        # Find which test had min/max time
        MIN_TEST=$(grep "TEST PASS\|TEST FAIL" "$LOG_FILE" | grep "${MIN_TIME}s" | awk '{print $5}' | head -1) || MIN_TEST="N/A"
        MAX_TEST=$(grep "TEST PASS\|TEST FAIL" "$LOG_FILE" | grep "${MAX_TIME}s" | awk '{print $5}' | head -1) || MAX_TEST="N/A"
    else
        MIN_TIME="N/A"; MAX_TIME="N/A"; AVG_TIME="N/A"
        MIN_TEST="N/A"; MAX_TEST="N/A"
    fi

    [ $VERBOSE -eq 1 ] && echo "Analysis complete: $TOTAL tests found"
}

print_text_report() {
    echo "=== RISC-V Simulation Log Analysis ==="
    echo "Log file:      $LOG_FILE"
    echo "Analysis date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "--- Results Summary ---"
    echo "Total tests:  $TOTAL"
    printf "Passed:       %s (%s%%)\n" "$PASSED" "$PASS_RATE"
    printf "Failed:       %s\n" "$FAILED"
    printf "Skipped:      %s\n" "$SKIPPED"
    echo ""

    if [ "$FAILED" -gt 0 ]; then
        echo "--- Failed Tests ---"
        i=1
        while IFS= read -r test; do
            [ -n "$test" ] && echo "  $i. $test"
            i=$((i + 1))
        done <<< "$FAILED_TESTS"
        echo ""
    fi

    echo "--- Timing Statistics ---"
    echo "Min time:  ${MIN_TIME}s ($MIN_TEST)"
    echo "Max time:  ${MAX_TIME}s ($MAX_TEST)"
    echo "Avg time:  ${AVG_TIME}s"
    echo ""

    if [ "$FAILED" -gt 0 ]; then
        echo -e "${RED}--- Verdict: FAIL ---${NC}"
        echo "Exit code: 1"
    else
        echo -e "${GREEN}--- Verdict: PASS ---${NC}"
        echo "Exit code: 0"
    fi
}

print_csv_report() {
    echo "log_file,total,passed,failed,skipped,pass_rate,min_time,max_time,avg_time"
    echo "$LOG_FILE,$TOTAL,$PASSED,$FAILED,$SKIPPED,$PASS_RATE,$MIN_TIME,$MAX_TIME,$AVG_TIME"
}

# ─── Main ─────────────────────────────────────────────────────────
parse_args "$@"
validate_input
analyze_log

# Build and output the report
if [ "$FORMAT" = "csv" ]; then
    if [ -n "$OUTPUT" ]; then
        mkdir -p "$(dirname "$OUTPUT")"
        print_csv_report > "$OUTPUT"
        echo "Report saved to: $OUTPUT"
    else
        print_csv_report
    fi
else
    if [ -n "$OUTPUT" ]; then
        mkdir -p "$(dirname "$OUTPUT")"
        print_text_report > "$OUTPUT"
        echo "Report saved to: $OUTPUT"
    else
        print_text_report
    fi
fi

# Exit 1 if any tests failed
if [ "$FAILED" -gt 0 ]; then
    exit 1
fi

exit 0
