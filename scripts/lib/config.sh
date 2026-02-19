#!/usr/bin/env bash

# ==============================================================================
# Config — Path resolution, IDE mapping, and derived constants
# ==============================================================================

resolve_script_dir() {
    local source_path="$1"
    local script_dir
    script_dir="$(cd "$(dirname "$source_path")" && pwd)"

    if [[ "$(basename "$script_dir")" == "lib" ]]; then
        echo "$(dirname "$script_dir")"
    else
        echo "$script_dir"
    fi
}

readonly INSTALLER_SCRIPT_DIR="$(resolve_script_dir "${BASH_SOURCE[0]}")"
readonly REPO_ROOT="$(dirname "$INSTALLER_SCRIPT_DIR")"
readonly SKILLS_DIR="$REPO_ROOT/skills"

readonly SUPPORTED_IDES="antigravity gemini cursor windsurf vscode claude codex agents"

get_ide_count() {
    local ide_list
    read -ra ide_list <<< "$SUPPORTED_IDES"
    echo "${#ide_list[@]}"
}

readonly IDE_COUNT=$(get_ide_count)
readonly ACTION_COUNT=4

get_ide_path() {
    local ide="$1"
    case "$ide" in
        antigravity) echo "$HOME/.gemini/antigravity/skills" ;;
        gemini)      echo "$HOME/.gemini/skills" ;;
        cursor)      echo "$HOME/.cursor/skills" ;;
        windsurf)    echo "$HOME/.codeium/windsurf/skills" ;;
        vscode)      echo "$HOME/.copilot/skills" ;;
        claude)      echo "$HOME/.claude/skills" ;;
        codex)       echo "$HOME/.codex/skills" ;;
        agents)      echo "$HOME/.agents/skills" ;;
        *)           echo "" ;;
    esac
}
