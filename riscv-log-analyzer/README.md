# RISC-V Log Analyzer

A shell-based tool that processes RISC-V simulation log files, extracts useful information, and generates summary reports.

## Project Structure

    riscv-log-analyzer/
    ├── Makefile
    ├── README.md
    ├── .gitignore
    ├── scripts/
    │   ├── analyze.sh
    │   ├── setup_env.sh
    │   └── generate_report.sh
    ├── test_data/
    │   ├── sample_sim.log
    │   ├── sample_pass.log
    │   └── sample_fail.log
    ├── output/
    └── docs/
        └── USAGE.md

## Installation

    git clone git@github.com:samieulhaq/MEDS.git
    cd MEDS/riscv-log-analyzer
    make setup

## Usage

    bash scripts/analyze.sh test_data/sample_fail.log
    bash scripts/analyze.sh test_data/sample_fail.log --format csv
    bash scripts/analyze.sh test_data/sample_fail.log --output output/report.txt
    bash scripts/analyze.sh test_data/sample_fail.log --verbose

    make all      # Run analyzer on all logs
    make test     # Test all logs
    make report   # Generate batch reports
    make clean    # Remove output files
    make help     # Show all targets

## Sample Output

    === RISC-V Simulation Log Analysis ===
    Log file:      test_data/sample_fail.log
    Analysis date: 2026-05-27 01:06:44

    --- Results Summary ---
    Total tests:  8
    Passed:       5 (62.5%)
    Failed:       2
    Skipped:      1

    --- Failed Tests ---
      1. rv32i-sll
      2. rv32i-beq

    --- Timing Statistics ---
    Min time:  0.42s (rv32i-nop)
    Max time:  2.31s (rv32i-mul)
    Avg time:  1.06s

    --- Verdict: FAIL ---
    Exit code: 1

## Author

Sami Ul Haq — MEDS Lab, UET Lahore — Summer 2026