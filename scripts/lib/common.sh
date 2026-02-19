#!/usr/bin/env bash

# ==============================================================================
# Common — Colors, output helpers, and shared utilities
# ==============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_header() {
    echo -e "${CYAN}━━━ $1 ━━━${NC}"
}

safe_remove_dir() {
    local target="$1"

    if [[ -L "$target" ]]; then
        rm -f "$target"
    elif [[ -d "$target" ]]; then
        rm -rf "$target"
    fi
}
