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
# Configuration
# ==============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "$SCRIPT_DIR")"
readonly SKILLS_DIR="$REPO_ROOT/skills"

readonly SUPPORTED_IDES="antigravity gemini cursor windsurf vscode claude codex agents"

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

# ==============================================================================
# Colors
# ==============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# ==============================================================================
# Output Helpers
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

print_header() {
    echo -e "${CYAN}━━━ $1 ━━━${NC}"
}

# ==============================================================================
# Help
# ==============================================================================

show_help() {
    cat << EOF
Agent Skills Installer

USAGE:
    $(basename "$0") --ide <ide_name> [OPTIONS]
    $(basename "$0") --remove --ide <ide_name> [OPTIONS]
    $(basename "$0") --full-install [OPTIONS]

ACTIONS:
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
# Validation
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

# ==============================================================================
# Skill Discovery
# ==============================================================================

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
            description=$(grep -m1 "^description:" "$skill_dir/SKILL.md" 2>/dev/null | sed 's/^description: *//' | cut -c 1-60)
            if [[ -n "$description" ]]; then
                printf "  %-30s %s...\n" "$skill_name" "$description"
            else
                printf "  %s\n" "$skill_name"
            fi
        fi
    done
    echo ""
}

get_skills_to_install() {
    local skills_arg="$1"
    local skills_to_install=()
    
    if [[ -z "$skills_arg" ]]; then
        for skill_dir in "$SKILLS_DIR"/*/; do
            if is_valid_skill "$skill_dir"; then
                local skill_name
                skill_name=$(basename "$skill_dir")
                skills_to_install+=("$skill_name")
            fi
        done
    else
        IFS=',' read -ra requested_skills <<< "$skills_arg"
        for skill in "${requested_skills[@]}"; do
            skill="${skill#"${skill%%[![:space:]]*}"}"
            skill="${skill%"${skill##*[![:space:]]}"}"
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

# ==============================================================================
# Install
# ==============================================================================

copy_or_link_skill() {
    local source_dir="$1"
    local dest_dir="$2"
    local use_symlink="$3"
    
    if [[ "$use_symlink" == "true" ]]; then
        ln -s "$source_dir" "$dest_dir"
    else
        cp -r "$source_dir" "$dest_dir"
    fi
}

install_single_skill() {
    local skill="$1"
    local source_dir="$2"
    local dest_dir="$3"
    local dry_run="$4"
    local use_symlink="$5"
    local is_replace="$6"
    
    local mode_suffix=""
    if [[ "$use_symlink" == "true" ]]; then
        mode_suffix=" (symlink)"
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        local action_verb="install"
        [[ "$is_replace" == "true" ]] && action_verb="replace"
        echo "  Would $action_verb: $skill"
        return 0
    fi
    
    if [[ "$is_replace" == "true" ]]; then
        rm -rf "$dest_dir"
    fi
    
    copy_or_link_skill "$source_dir" "$dest_dir" "$use_symlink"
    
    local past_tense="Installed"
    [[ "$is_replace" == "true" ]] && past_tense="Replaced"
    print_success "${past_tense}${mode_suffix}: $skill"
}

ensure_target_directory() {
    local target_dir="$1"
    local dry_run="$2"
    
    if [[ ! -d "$target_dir" ]]; then
        if [[ "$dry_run" == "true" ]]; then
            echo "  Would create directory: $target_dir"
        else
            mkdir -p "$target_dir"
            print_success "Created directory: $target_dir"
        fi
    fi
}

print_install_header() {
    local ide="$1"
    local skill_count="$2"
    local target_dir="$3"
    local use_symlink="$4"
    local dry_run="$5"
    
    echo ""
    print_info "Installing $skill_count skill(s) to $ide"
    print_info "Target directory: $target_dir"
    if [[ "$use_symlink" == "true" ]]; then
        print_info "Mode: symbolic links"
    else
        print_info "Mode: copy"
    fi
    echo ""
    
    if [[ "$dry_run" == "true" ]]; then
        print_warning "DRY RUN - No changes will be made"
        echo ""
    fi
}

install_skills() {
    local ide="$1"
    local skills_arg="$2"
    local dry_run="$3"
    local use_symlink="$4"
    local force="$5"
    
    local target_dir
    target_dir=$(get_ide_path "$ide")
    
    read -ra skills_to_install <<< "$(get_skills_to_install "$skills_arg")"
    
    if [[ ${#skills_to_install[@]} -eq 0 ]]; then
        print_error "No valid skills to install"
        exit 1
    fi
    
    print_install_header "$ide" "${#skills_to_install[@]}" "$target_dir" "$use_symlink" "$dry_run"
    ensure_target_directory "$target_dir" "$dry_run"
    
    local installed_count=0
    local replaced_count=0
    local skipped_count=0
    
    for skill in "${skills_to_install[@]}"; do
        local source_dir="$SKILLS_DIR/$skill"
        local dest_dir="$target_dir/$skill"
        
        if [[ -d "$dest_dir" ]]; then
            if [[ "$force" == "true" ]]; then
                install_single_skill "$skill" "$source_dir" "$dest_dir" "$dry_run" "$use_symlink" "true"
                ((replaced_count++))
            else
                if [[ "$dry_run" == "true" ]]; then
                    echo "  Would skip (already exists): $skill"
                else
                    print_info "Already installed, skipping: $skill"
                fi
                ((skipped_count++))
            fi
        else
            install_single_skill "$skill" "$source_dir" "$dest_dir" "$dry_run" "$use_symlink" "false"
            ((installed_count++))
        fi
    done
    
    print_install_summary "$dry_run" "$installed_count" "$replaced_count" "$skipped_count"
}

print_install_summary() {
    local dry_run="$1"
    local installed_count="$2"
    local replaced_count="$3"
    local skipped_count="$4"
    
    echo ""
    local prefix="Would"
    [[ "$dry_run" != "true" ]] && prefix=""
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "${prefix} install ${installed_count} new, replace ${replaced_count} existing, skip ${skipped_count} skill(s)"
    else
        print_success "Installed ${installed_count} new, replaced ${replaced_count} existing, skipped ${skipped_count} skill(s)"
    fi
}

# ==============================================================================
# Remove
# ==============================================================================

remove_skills() {
    local ide="$1"
    local dry_run="$2"
    
    local target_dir
    target_dir=$(get_ide_path "$ide")
    
    echo ""
    print_info "Removing skills from $ide"
    print_info "Target directory: $target_dir"
    echo ""
    
    if [[ "$dry_run" == "true" ]]; then
        print_warning "DRY RUN - No changes will be made"
        echo ""
    fi
    
    if [[ ! -d "$target_dir" ]]; then
        print_warning "Target directory does not exist: $target_dir"
        return 0
    fi
    
    local removed_count=0
    
    for skill_dir in "$target_dir"/*/; do
        [[ ! -d "$skill_dir" ]] && continue
        
        local skill_name
        skill_name=$(basename "$skill_dir")
        
        if is_valid_skill "$skill_dir" || [[ -L "$skill_dir" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                echo "  Would remove: $skill_name"
            else
                rm -rf "$skill_dir"
                print_success "Removed: $skill_name"
            fi
            ((removed_count++))
        else
            print_warning "Skipping non-skill directory: $skill_name"
        fi
    done
    
    echo ""
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would remove $removed_count skill(s) from $ide"
    else
        print_success "Removed $removed_count skill(s) from $ide"
    fi
}

# ==============================================================================
# Full Install
# ==============================================================================

full_install() {
    local skills_arg="$1"
    local dry_run="$2"
    local use_symlink="$3"
    local force="$4"
    
    echo ""
    print_header "Full Installation — All IDEs"
    echo ""
    
    if [[ "$dry_run" == "true" ]]; then
        print_warning "DRY RUN - No changes will be made"
    fi
    
    local total_installed=0
    local total_replaced=0
    local total_skipped=0
    
    for ide in $SUPPORTED_IDES; do
        local target_dir
        target_dir=$(get_ide_path "$ide")
        
        print_header "$ide → $target_dir"
        install_skills "$ide" "$skills_arg" "$dry_run" "$use_symlink" "$force"
    done
    
    echo ""
    print_header "Full Installation Complete"
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    local ide=""
    local skills=""
    local dry_run="false"
    local use_symlink="false"
    local force="false"
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
