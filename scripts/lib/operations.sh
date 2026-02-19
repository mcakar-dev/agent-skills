#!/usr/bin/env bash

# ==============================================================================
# Operations — Install, remove, full-install, skill discovery
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
                print_warning "Skill '$skill' is missing SKILL.md, skipping" >&2
            else
                print_warning "Skill '$skill' not found, skipping" >&2
            fi
        done
    fi

    echo "${skills_to_install[@]}"
}

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
        safe_remove_dir "$dest_dir"
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

print_install_summary() {
    local dry_run="$1"
    local installed_count="$2"
    local replaced_count="$3"
    local skipped_count="$4"

    echo ""
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would install ${installed_count} new, replace ${replaced_count} existing, skip ${skipped_count} skill(s)"
    else
        print_success "Installed ${installed_count} new, replaced ${replaced_count} existing, skipped ${skipped_count} skill(s)"
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

    local skills_output
    skills_output="$(get_skills_to_install "$skills_arg")"

    if [[ -z "$skills_output" ]]; then
        print_error "No valid skills to install"
        exit 1
    fi

    read -ra skills_to_install <<< "$skills_output"

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

        if [[ -d "$dest_dir" || -L "$dest_dir" ]]; then
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
                safe_remove_dir "$skill_dir"
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

    for ide in $SUPPORTED_IDES; do
        local target_dir
        target_dir=$(get_ide_path "$ide")

        print_header "$ide → $target_dir"
        install_skills "$ide" "$skills_arg" "$dry_run" "$use_symlink" "$force"
    done

    echo ""
    print_header "Full Installation Complete"
}
