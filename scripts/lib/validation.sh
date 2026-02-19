#!/usr/bin/env bash

# ==============================================================================
# Validation — Precondition checking for skills and IDEs
# ==============================================================================

is_valid_skill() {
    local skill_path="$1"
    [[ -d "$skill_path" && -f "$skill_path/SKILL.md" ]]
}

validate_ide() {
    local ide="$1"
    local path
    path=$(get_ide_path "$ide")

    if [[ -z "$path" ]]; then
        print_error "Unsupported IDE: $ide"
        echo ""
        echo "Supported IDEs:"
        local i
        for i in $SUPPORTED_IDES; do
            echo "  - $i"
        done
        exit 1
    fi
}
