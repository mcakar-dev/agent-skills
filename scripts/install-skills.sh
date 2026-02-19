#!/usr/bin/env bash

# ==============================================================================
# Agent Skills Installer
#
# Installs, removes, and manages agent skills across supported agentic IDEs.
#
# Usage:
#   ./install-skills.sh --ide <ide_name> [--skills <skill1,skill2>] [--link] [--force] [--dry-run]
#   ./install-skills.sh --remove --ide <ide_name> [--dry-run]
#   ./install-skills.sh --full-install [--link] [--force] [--dry-run]
#   ./install-skills.sh --list
#   ./install-skills.sh --help
#
# Supported IDEs: antigravity, gemini, cursor, windsurf, vscode, claude, codex, agents
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Bootstrap
# ==============================================================================

readonly ENTRYPOINT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ENTRYPOINT_DIR/lib/common.sh"
source "$ENTRYPOINT_DIR/lib/config.sh"
source "$ENTRYPOINT_DIR/lib/validation.sh"
source "$ENTRYPOINT_DIR/lib/operations.sh"
source "$ENTRYPOINT_DIR/lib/interactive.sh"

cleanup() {
    :
}
trap cleanup EXIT

# ==============================================================================
# Help
# ==============================================================================

show_help() {
    cat << EOF
Agent Skills Installer

USAGE:
    $(basename "$0") [--interactive] [OPTIONS]
    $(basename "$0") --ide <name> [OPTIONS]
    $(basename "$0") --remove --ide <name> [OPTIONS]
    $(basename "$0") --full-install [OPTIONS]

ACTIONS:
    --interactive       Launch interactive wizard (also triggered with no arguments)

    --ide <name>        Install skills to target IDE (incremental, skips existing)
                        Supported: ${SUPPORTED_IDES}

    --remove            Remove all installed skills from target IDE
                        Requires: --ide <name>

    --full-install      Install skills to ALL supported IDEs and ~/.agents/skills/

    --list              List available skills and exit

OPTIONS:
    --skills <names>    Comma-separated list of skill names to install
                        If not specified, installs ALL skills

    --force             Force overwrite of existing skills (default: skip existing)

    --link              Create symbolic links instead of copying files
                        (Useful for development, changes reflect immediately)

    --dry-run           Preview changes without modifying the filesystem

    --help              Show this help message

EXAMPLES:
    # Launch interactive wizard
    $(basename "$0")

    # Install all skills to Antigravity (skips already installed)
    $(basename "$0") --ide antigravity

    # Force reinstall all skills to Cursor
    $(basename "$0") --ide cursor --force

    # Install specific skills to Windsurf
    $(basename "$0") --ide windsurf --skills java-code-reviewer,commit-message-generator

    # Remove all skills from Claude
    $(basename "$0") --remove --ide claude

    # Install to ALL IDEs at once (with symbolic links)
    $(basename "$0") --full-install --link

    # Preview full installation
    $(basename "$0") --full-install --dry-run

    # List available skills
    $(basename "$0") --list

EOF
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    if [[ $# -eq 0 ]]; then
        run_interactive
        return
    fi

    local ide=""
    local skills=""
    local dry_run="false"
    local use_symlink="false"
    local force="false"
    local action="install"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --interactive)
                action="interactive"
                shift
                ;;
            --ide)
                if [[ -z "${2:-}" ]]; then
                    print_error "Option --ide requires an argument"
                    exit 1
                fi
                ide="$2"
                shift 2
                ;;
            --skills)
                if [[ -z "${2:-}" ]]; then
                    print_error "Option --skills requires an argument"
                    exit 1
                fi
                skills="$2"
                shift 2
                ;;
            --list)
                action="list"
                shift
                ;;
            --remove)
                action="remove"
                shift
                ;;
            --full-install)
                action="full-install"
                shift
                ;;
            --force)
                force="true"
                shift
                ;;
            --link)
                use_symlink="true"
                shift
                ;;
            --dry-run)
                dry_run="true"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    case "$action" in
        interactive)
            run_interactive
            ;;
        list)
            list_skills
            ;;
        remove)
            if [[ -z "$ide" ]]; then
                print_error "Missing required option: --ide (required for --remove)"
                echo "Use --help for usage information"
                exit 1
            fi
            validate_ide "$ide"
            remove_skills "$ide" "$dry_run"
            ;;
        full-install)
            full_install "$skills" "$dry_run" "$use_symlink" "$force"
            ;;
        install)
            if [[ -z "$ide" ]]; then
                print_error "Missing required option: --ide"
                echo "Use --help for usage information"
                exit 1
            fi
            validate_ide "$ide"
            install_skills "$ide" "$skills" "$dry_run" "$use_symlink" "$force"
            ;;
    esac
}

main "$@"
