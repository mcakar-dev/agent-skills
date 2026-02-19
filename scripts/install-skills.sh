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
    $(basename "$0") [--interactive] [OPTIONS]
    $(basename "$0") --ide <ide_name> [OPTIONS]
    $(basename "$0") --remove --ide <ide_name> [OPTIONS]
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
# Interactive Mode
# ==============================================================================

readonly ACTION_INSTALL="install"
readonly ACTION_REMOVE="remove"
readonly ACTION_FULL_INSTALL="full-install"
readonly ACTION_LIST="list"
readonly GO_BACK="__GO_BACK__"

readonly IDE_COUNT=8
readonly ACTION_COUNT=4

read_input() {
    if ! read -r INTERACTIVE_INPUT; then
        echo ""
        print_info "Input stream ended. Exiting."
        exit 0
    fi
}

prompt_action() {
    while true; do
        echo ""
        print_header "Choose an action"
        echo "  1) Install skills to an IDE"
        echo "  2) Remove skills from an IDE"
        echo "  3) Install to ALL IDEs (full-install)"
        echo "  4) List available skills"
        echo ""
        printf "  Enter choice [1-${ACTION_COUNT}]: "
        read_input
        local choice="$INTERACTIVE_INPUT"

        case "$choice" in
            1) INTERACTIVE_RESULT="$ACTION_INSTALL"; return ;;
            2) INTERACTIVE_RESULT="$ACTION_REMOVE"; return ;;
            3) INTERACTIVE_RESULT="$ACTION_FULL_INSTALL"; return ;;
            4) INTERACTIVE_RESULT="$ACTION_LIST"; return ;;
            *) print_warning "Invalid choice. Please enter 1-${ACTION_COUNT}." ;;
        esac
    done
}

prompt_ide() {
    local ide_list
    read -ra ide_list <<< "$SUPPORTED_IDES"

    while true; do
        echo ""
        print_header "Choose target IDE"
        local i=1
        for ide in "${ide_list[@]}"; do
            printf "  %d) %s\n" "$i" "$ide"
            ((i++))
        done
        echo "  b) ← Go back"
        echo ""
        printf "  Enter choice [1-${IDE_COUNT}/b]: "
        read_input
        local choice="$INTERACTIVE_INPUT"

        if [[ "$choice" == "b" || "$choice" == "B" ]]; then
            INTERACTIVE_RESULT="$GO_BACK"
            return
        fi

        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= IDE_COUNT )); then
            INTERACTIVE_RESULT="${ide_list[$((choice - 1))]}"
            return
        fi

        print_warning "Invalid choice. Please enter 1-${IDE_COUNT} or 'b' to go back."
    done
}

prompt_skills_interactive() {
    local available_skills=()
    for skill_dir in "$SKILLS_DIR"/*/; do
        if is_valid_skill "$skill_dir"; then
            available_skills+=("$(basename "$skill_dir")")
        fi
    done

    echo ""
    printf "  Install ALL %d skills? (Y/n/b): " "${#available_skills[@]}"
    read_input
    local choice="$INTERACTIVE_INPUT"

    if [[ "$choice" == "b" || "$choice" == "B" ]]; then
        INTERACTIVE_RESULT="$GO_BACK"
        return
    fi

    if [[ -z "$choice" || "$choice" == "y" || "$choice" == "Y" ]]; then
        INTERACTIVE_RESULT=""
        return
    fi

    echo ""
    print_header "Select skills (enter numbers separated by spaces)"
    local i=1
    for skill in "${available_skills[@]}"; do
        printf "  %d) %s\n" "$i" "$skill"
        ((i++))
    done
    echo "  b) ← Go back"
    echo ""
    printf "  Enter choices (e.g. 1 3 5): "
    read_input
    local selections="$INTERACTIVE_INPUT"

    if [[ "$selections" == "b" || "$selections" == "B" ]]; then
        INTERACTIVE_RESULT="$GO_BACK"
        return
    fi

    local selected_skills=()
    for num in $selections; do
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#available_skills[@]} )); then
            selected_skills+=("${available_skills[$((num - 1))]}")
        else
            print_warning "Skipping invalid selection: $num"
        fi
    done

    local IFS=','
    INTERACTIVE_RESULT="${selected_skills[*]}"
}

prompt_options() {
    local result_link="false"
    local result_force="false"

    echo ""
    print_header "Installation options"

    printf "  Use symbolic links instead of copying? (y/N/b): "
    read_input
    local choice="$INTERACTIVE_INPUT"
    if [[ "$choice" == "b" || "$choice" == "B" ]]; then
        INTERACTIVE_RESULT="$GO_BACK"
        return
    fi
    [[ "$choice" == "y" || "$choice" == "Y" ]] && result_link="true"

    printf "  Force overwrite existing skills? (y/N/b): "
    read_input
    choice="$INTERACTIVE_INPUT"
    if [[ "$choice" == "b" || "$choice" == "B" ]]; then
        INTERACTIVE_RESULT="$GO_BACK"
        return
    fi
    [[ "$choice" == "y" || "$choice" == "Y" ]] && result_force="true"

    INTERACTIVE_RESULT="${result_link} ${result_force}"
}

print_interactive_summary() {
    local action="$1"
    local ide="$2"
    local skills="$3"
    local use_symlink="$4"
    local force="$5"

    echo ""
    print_header "Summary"
    echo "  Action:    $action"
    [[ -n "$ide" ]] && echo "  IDE:       $ide"
    if [[ -n "$skills" ]]; then
        echo "  Skills:    $skills"
    else
        echo "  Skills:    ALL"
    fi
    [[ "$use_symlink" == "true" ]] && echo "  Mode:      symbolic links"
    [[ "$force" == "true" ]]      && echo "  Force:     yes"
}

prompt_confirmation() {
    local action="$1"
    local ide="$2"
    local skills="$3"
    local use_symlink="$4"
    local force="$5"

    print_interactive_summary "$action" "$ide" "$skills" "$use_symlink" "$force"

    echo ""
    echo ""
    echo -e "${YELLOW}▸${NC} Dry-run preview first? (y/N/b): "
    read_input
    local dry_choice="$INTERACTIVE_INPUT"

    if [[ "$dry_choice" == "b" || "$dry_choice" == "B" ]]; then
        INTERACTIVE_RESULT="$GO_BACK"
        return
    fi

    if [[ "$dry_choice" == "y" || "$dry_choice" == "Y" ]]; then
        INTERACTIVE_RESULT="dry-run-first"
        return
    fi

    echo -e "${YELLOW}▸${NC} Proceed? (Y/n): "
    read_input
    local confirm="$INTERACTIVE_INPUT"

    if [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
        INTERACTIVE_RESULT="cancelled"
    else
        INTERACTIVE_RESULT="confirmed"
    fi
}

execute_interactive_action() {
    local action="$1"
    local ide="$2"
    local skills="$3"
    local use_symlink="$4"
    local force="$5"
    local dry_run="$6"

    case "$action" in
        "$ACTION_INSTALL")
            install_skills "$ide" "$skills" "$dry_run" "$use_symlink" "$force"
            ;;
        "$ACTION_REMOVE")
            remove_skills "$ide" "$dry_run"
            ;;
        "$ACTION_FULL_INSTALL")
            full_install "$skills" "$dry_run" "$use_symlink" "$force"
            ;;
    esac
}

handle_confirmation_result() {
    local confirmation="$1"
    local action="$2"
    local ide="$3"
    local skills="$4"
    local use_symlink="$5"
    local force="$6"

    case "$confirmation" in
        "$GO_BACK")
            return 1
            ;;
        "cancelled")
            echo ""
            print_info "Operation cancelled."
            return 0
            ;;
        "dry-run-first")
            execute_interactive_action "$action" "$ide" "$skills" "$use_symlink" "$force" "true"
            echo ""
            echo -e "${YELLOW}▸${NC} Apply these changes now? (Y/n): "
            read_input
            local apply_choice="$INTERACTIVE_INPUT"
            if [[ "$apply_choice" == "n" || "$apply_choice" == "N" ]]; then
                print_info "Operation cancelled after dry-run."
            else
                execute_interactive_action "$action" "$ide" "$skills" "$use_symlink" "$force" "false"
            fi
            return 0
            ;;
        "confirmed")
            execute_interactive_action "$action" "$ide" "$skills" "$use_symlink" "$force" "false"
            return 0
            ;;
    esac
}

run_interactive() {
    echo ""
    print_header "Agent Skills Installer — Interactive Mode"

    INTERACTIVE_RESULT=""

    while true; do
        prompt_action
        local action="$INTERACTIVE_RESULT"

        if [[ "$action" == "$ACTION_LIST" ]]; then
            list_skills
            continue
        fi

        local ide=""
        if [[ "$action" != "$ACTION_FULL_INSTALL" ]]; then
            prompt_ide
            [[ "$INTERACTIVE_RESULT" == "$GO_BACK" ]] && continue
            ide="$INTERACTIVE_RESULT"
        fi

        local skills=""
        local use_symlink="false"
        local force="false"

        if [[ "$action" != "$ACTION_REMOVE" ]]; then
            prompt_skills_interactive
            [[ "$INTERACTIVE_RESULT" == "$GO_BACK" ]] && continue
            skills="$INTERACTIVE_RESULT"

            prompt_options
            [[ "$INTERACTIVE_RESULT" == "$GO_BACK" ]] && continue
            read -r use_symlink force <<< "$INTERACTIVE_RESULT"
        fi

        prompt_confirmation "$action" "$ide" "$skills" "$use_symlink" "$force"
        local confirmation="$INTERACTIVE_RESULT"

        if handle_confirmation_result "$confirmation" "$action" "$ide" "$skills" "$use_symlink" "$force"; then
            break
        fi
    done
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
