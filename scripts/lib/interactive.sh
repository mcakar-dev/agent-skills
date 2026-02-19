#!/usr/bin/env bash

# ==============================================================================
# Interactive Mode — Prompt-driven wizard for skill management
#
# Convention: Functions return values via the global INTERACTIVE_RESULT variable.
# This is required because Bash subshells (command substitution) cannot read
# from /dev/tty reliably across platforms. Each prompt_* function sets
# INTERACTIVE_RESULT before returning.
#
# INTERACTIVE_INPUT is set by read_input as a shared read buffer.
# ==============================================================================

readonly ACTION_INSTALL="install"
readonly ACTION_REMOVE="remove"
readonly ACTION_FULL_INSTALL="full-install"
readonly ACTION_LIST="list"
readonly GO_BACK="__GO_BACK__"

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
