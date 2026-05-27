# USAGE — RISC-V Log Analyzer

## analyze.sh — Command Reference

### Syntax

    bash scripts/analyze.sh <logfile> [OPTIONS]

### Options

    <logfile>           Path to simulation log file (required)
    --format text|csv   Output format (default: text)
    --output <path>     Save report to file instead of stdout
    --verbose           Print extra info during analysis
    --help              Show usage information

### Examples

    # Basic analysis
    bash scripts/analyze.sh test_data/sample_fail.log

    # Save as CSV
    bash scripts/analyze.sh test_data/sample_sim.log --format csv --output output/report.csv

    # Verbose mode
    bash scripts/analyze.sh test_data/sample_pass.log --verbose

    # Save report to file
    bash scripts/analyze.sh test_data/sample_fail.log --output output/my_report.txt

### Exit Codes

    0 — All tests passed
    1 — One or more tests failed

## generate_report.sh — Batch Runner

Processes all .log files in test_data/ and saves reports to output/.

    bash scripts/generate_report.sh
    make report

## setup_env.sh — Environment Checker

Checks all required tools are installed and directories exist.

    bash scripts/setup_env.sh
    make setup

## Log File Format

    [YYYY-MM-DD HH:MM:SS] TEST START: <test-name>
    [YYYY-MM-DD HH:MM:SS] TEST PASS: <test-name> (<time>s)
    [YYYY-MM-DD HH:MM:SS] TEST FAIL: <test-name> (<time>s)
    [YYYY-MM-DD HH:MM:SS] TEST SKIP: <test-name> (reason)
    [YYYY-MM-DD HH:MM:SS] SUMMARY: N tests, N passed, N failed, N skipped