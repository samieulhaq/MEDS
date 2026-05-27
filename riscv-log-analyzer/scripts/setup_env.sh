#!/bin/bash
# setup_env.sh — Environment setup and dependency checker
# Author: Sami Ul Haq
# Date: 2026-05-27

set -uo pipefail

# ─── Colors ───────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ─── Functions ────────────────────────────────────────────────────

check_tool() {
    local tool="$1"
    if command -v "$tool" &>/dev/null; then
        echo -e "  ${GREEN}[OK]${NC}     $tool"
        return 0
    else
        echo -e "  ${RED}[MISSING]${NC} $tool"
        return 1
    fi
}

check_dependencies() {
    echo "=== Checking Required Tools ==="
    local missing=0

    for tool in bash grep awk sed sort uniq wc head tail date; do
        check_tool "$tool" || missing=$((missing + 1))
    done

    echo ""
    if [ "$missing" -gt 0 ]; then
        echo -e "${RED}Error: $missing required tool(s) missing.${NC}"
        echo "Please install them and re-run setup."
        return 1
    else
        echo -e "${GREEN}All required tools are available.${NC}"
        return 0
    fi
}

setup_directories() {
    echo ""
    echo "=== Setting Up Directories ==="

    # Get the project root (two levels up from this script)
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

    local dirs=("output" "test_data" "docs")
    for dir in "${dirs[@]}"; do
        if [ ! -d "$PROJECT_ROOT/$dir" ]; then
            mkdir -p "$PROJECT_ROOT/$dir"
            echo -e "  ${GREEN}[CREATED]${NC} $dir/"
        else
            echo -e "  ${GREEN}[EXISTS]${NC}  $dir/"
        fi
    done
}

check_scripts_executable() {
    echo ""
    echo "=== Checking Script Permissions ==="

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    for script in "$SCRIPT_DIR"/*.sh; do
        if [ -x "$script" ]; then
            echo -e "  ${GREEN}[OK]${NC}     $(basename "$script") is executable"
        else
            chmod +x "$script"
            echo -e "  ${YELLOW}[FIXED]${NC}  $(basename "$script") — made executable"
        fi
    done
}

# ─── Main ─────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════╗"
echo "║   RISC-V Log Analyzer — Setup       ║"
echo "╚══════════════════════════════════════╝"
echo ""

check_dependencies
setup_directories
check_scripts_executable

echo ""
echo -e "${GREEN}Setup complete! You are ready to run analyze.sh.${NC}"
echo ""
echo "Quick start:"
echo "  bash scripts/analyze.sh test_data/sample_fail.log"
