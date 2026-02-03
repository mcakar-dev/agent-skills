#!/usr/bin/env bash

# ==============================================================================
# Agent Skills Installer
# 
# Installs agent skills to supported agentic IDEs.
# 
# Usage:
#   ./install-skills.sh --ide <ide_name> [--skills <skill1,skill2>] [--dry-run]
#   ./install-skills.sh --list
#   ./install-skills.sh --help
#
# Supported IDEs: antigravity, cursor, windsurf
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "$SCRIPT_DIR")"
readonly SKILLS_DIR="$REPO_ROOT/skills"

get_ide_path() {
    local ide="$1"
    case "$ide" in
        antigravity) echo "$HOME/.gemini/antigravity/skills" ;;
        cursor) echo "$HOME/.cursor/skills" ;;
        windsurf) echo "$HOME/.codeium/windsurf/skills" ;;
        *) echo "" ;;
    esac
}

readonly SUPPORTED_IDES="antigravity cursor windsurf"

# ==============================================================================
# Colors
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==============================================================================
# Functions
# ==============================================================================

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

show_help() {
    cat << EOF
Agent Skills Installer

USAGE:
    $(basename "$0") --ide <ide_name> [OPTIONS]

OPTIONS:
    --ide <name>        Target IDE (required for install)
                        Supported: antigravity, cursor, windsurf

    --skills <names>    Comma-separated list of skill names to install
                        If not specified, installs ALL skills

    --list              List available skills and exit

    --dry-run           Preview changes without installing

    --help              Show this help message

EXAMPLES:
    # Install all skills to Antigravity
    $(basename "$0") --ide antigravity

    # Install specific skills to Cursor
    $(basename "$0") --ide cursor --skills java-code-review,commit-message-generator

    # Preview installation
    $(basename "$0") --ide antigravity --dry-run

    # List available skills
    $(basename "$0") --list

EOF
}

# Validates if a given path is a valid skill directory
# A valid skill must be a directory containing SKILL.md
# Usage: is_valid_skill "/path/to/skill"
# Returns: 0 if valid, 1 if invalid
is_valid_skill() {
    local skill_path="$1"
    [[ -d "$skill_path" && -f "$skill_path/SKILL.md" ]]
}

list_skills() {
    echo "Available skills:"
    echo ""
    
    if [[ ! -d "$SKILLS_DIR" ]]; then
        print_error "Skills directory not found: $SKILLS_DIR"
        exit 1
    fi
    
    for skill_dir in "$SKILLS_DIR"/*/; do
        local skill_name
        skill_name=$(basename "$skill_dir")
        
        if is_valid_skill "$skill_dir"; then
            local description
            description=$(grep -m1 "^description:" "$skill_dir/SKILL.md" 2>/dev/null | sed 's/^description: *//' | head -c 60)
            if [[ -n "$description" ]]; then
                printf "  %-30s %s...\n" "$skill_name" "$description"
            else
                printf "  %s\n" "$skill_name"
            fi
        fi
    done
    echo ""
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

get_skills_to_install() {
    local skills_arg="$1"
    local skills_to_install=()
    
    if [[ -z "$skills_arg" ]]; then
        # Install all valid skills
        for skill_dir in "$SKILLS_DIR"/*/; do
            if is_valid_skill "$skill_dir"; then
                local skill_name
                skill_name=$(basename "$skill_dir")
                skills_to_install+=("$skill_name")
            fi
        done
    else
        # Install specific skills
        IFS=',' read -ra requested_skills <<< "$skills_arg"
        for skill in "${requested_skills[@]}"; do
            skill="${skill#"${skill%%[![:space:]]*}"}" # trim leading
            skill="${skill%"${skill##*[![:space:]]}"}" # trim trailing
            local skill_path="$SKILLS_DIR/$skill"
            
            if is_valid_skill "$skill_path"; then
                skills_to_install+=("$skill")
            elif [[ -d "$skill_path" ]]; then
                print_warning "Skill '$skill' is missing SKILL.md, skipping"
            else
                print_warning "Skill '$skill' not found, skipping"
            fi
        done
    fi
    
    echo "${skills_to_install[@]}"
}

install_skills() {
    local ide="$1"
    local skills_arg="$2"
    local dry_run="$3"
    
    local target_dir
    target_dir=$(get_ide_path "$ide")
    
    read -ra skills_to_install <<< "$(get_skills_to_install "$skills_arg")"
    
    if [[ ${#skills_to_install[@]} -eq 0 ]]; then
        print_error "No valid skills to install"
        exit 1
    fi
    
    echo ""
    print_info "Installing ${#skills_to_install[@]} skill(s) to $ide"
    print_info "Target directory: $target_dir"
    echo ""
    
    if [[ "$dry_run" == "true" ]]; then
        print_warning "DRY RUN - No changes will be made"
        echo ""
    fi
    
    if [[ ! -d "$target_dir" ]]; then
        if [[ "$dry_run" == "true" ]]; then
            echo "Would create directory: $target_dir"
        else
            mkdir -p "$target_dir"
            print_success "Created directory: $target_dir"
        fi
    fi
    
    local installed_count=0
    local replaced_count=0
    
    for skill in "${skills_to_install[@]}"; do
        local source_dir="$SKILLS_DIR/$skill"
        local dest_dir="$target_dir/$skill"
        
        if [[ -d "$dest_dir" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                echo "Would replace: $skill"
            else
                rm -rf "$dest_dir"
                cp -r "$source_dir" "$dest_dir"
                print_success "Replaced: $skill"
            fi
            ((replaced_count++))
        else
            if [[ "$dry_run" == "true" ]]; then
                echo "Would install: $skill"
            else
                cp -r "$source_dir" "$dest_dir"
                print_success "Installed: $skill"
            fi
            ((installed_count++))
        fi
    done
    
    echo ""
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would install $installed_count new skill(s), replace $replaced_count existing skill(s)"
    else
        print_success "Installed $installed_count new skill(s), replaced $replaced_count existing skill(s)"
    fi
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    local ide=""
    local skills=""
    local dry_run="false"
    local action="install"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
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
        list)
            list_skills
            ;;
        install)
            if [[ -z "$ide" ]]; then
                print_error "Missing required option: --ide"
                echo "Use --help for usage information"
                exit 1
            fi
            validate_ide "$ide"
            install_skills "$ide" "$skills" "$dry_run"
            ;;
    esac
}

main "$@"
