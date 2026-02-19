#!/usr/bin/env bash
set -uo pipefail

readonly SCRIPT_UNDER_TEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install-skills.sh"

PASS_COUNT=0
FAIL_COUNT=0

assert_output_contains() {
    local description="$1"
    local expected_substring="$2"
    local input="${3:-}"
    shift 3 2>/dev/null || shift 2
    local output
    if [[ -n "$input" ]]; then
        output=$(echo "$input" | "$@" 2>&1) || true
    else
        output=$("$@" 2>&1) || true
    fi
    if [[ "$output" == *"$expected_substring"* ]]; then
        echo "✅ PASS: ${description}"
        ((PASS_COUNT++)) || true
    else
        echo "❌ FAIL: ${description}"
        echo "   Expected to contain: '${expected_substring}'"
        echo "   Actual output (first 300 chars): '${output:0:300}'"
        ((FAIL_COUNT++)) || true
    fi
}

assert_exit_code() {
    local description="$1"
    local expected_code="$2"
    shift 2
    local actual_code
    "$@" >/dev/null 2>&1
    actual_code=$?
    if [[ "$actual_code" -eq "$expected_code" ]]; then
        echo "✅ PASS: ${description}"
        ((PASS_COUNT++)) || true
    else
        echo "❌ FAIL: ${description}"
        echo "   Expected exit code: ${expected_code}, Actual: ${actual_code}"
        ((FAIL_COUNT++)) || true
    fi
}

# ==============================================================================
# Interactive Mode Tests
# ==============================================================================

echo "━━━ Interactive Mode Tests ━━━"
echo ""

assert_output_contains \
    "given_no_args_when_run_then_launches_interactive_mode" \
    "Choose an action" \
    "4" \
    bash "$SCRIPT_UNDER_TEST"

assert_output_contains \
    "given_interactive_flag_when_piped_input_selects_action_4_then_lists_skills" \
    "Available skills:" \
    "4" \
    bash "$SCRIPT_UNDER_TEST" --interactive

assert_output_contains \
    "given_interactive_flag_when_invalid_action_then_re_prompts" \
    "Invalid choice" \
    $'99\n4' \
    bash "$SCRIPT_UNDER_TEST" --interactive

assert_output_contains \
    "given_interactive_install_when_user_selects_back_at_ide_then_returns_to_action" \
    "Choose target IDE" \
    $'1\nb\n4' \
    bash "$SCRIPT_UNDER_TEST" --interactive

# ==============================================================================
# CLI Help & List Tests
# ==============================================================================

echo ""
echo "━━━ CLI Help & List Tests ━━━"
echo ""

assert_output_contains \
    "given_help_flag_when_run_then_mentions_interactive" \
    "--interactive" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --help

assert_output_contains \
    "given_help_flag_when_run_then_shows_supported_ides" \
    "antigravity" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --help

assert_output_contains \
    "given_list_flag_when_run_then_shows_available_skills" \
    "Available skills:" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --list

# ==============================================================================
# CLI Dry-Run Tests
# ==============================================================================

echo ""
echo "━━━ CLI Dry-Run Tests ━━━"
echo ""

assert_output_contains \
    "given_ide_flag_with_dry_run_when_run_then_shows_dry_run_warning" \
    "DRY RUN" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --ide agents --dry-run

assert_output_contains \
    "given_ide_install_with_dry_run_when_run_then_shows_would_install" \
    "Would install" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --ide agents --dry-run

assert_output_contains \
    "given_full_install_with_dry_run_when_run_then_shows_dry_run" \
    "DRY RUN" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --full-install --dry-run

assert_output_contains \
    "given_remove_with_dry_run_when_run_then_shows_removing" \
    "Removing skills from agents" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --remove --ide agents --dry-run

# ==============================================================================
# Error Path Tests
# ==============================================================================

echo ""
echo "━━━ Error Path Tests ━━━"
echo ""

assert_output_contains \
    "given_unknown_option_when_run_then_shows_error" \
    "Unknown option" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --bogus

assert_exit_code \
    "given_unknown_option_when_run_then_exits_non_zero" \
    1 \
    bash "$SCRIPT_UNDER_TEST" --bogus

assert_output_contains \
    "given_remove_without_ide_when_run_then_shows_error" \
    "Missing required option: --ide" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --remove

assert_exit_code \
    "given_remove_without_ide_when_run_then_exits_non_zero" \
    1 \
    bash "$SCRIPT_UNDER_TEST" --remove

assert_output_contains \
    "given_ide_without_argument_when_run_then_shows_error" \
    "Option --ide requires an argument" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --ide

assert_output_contains \
    "given_invalid_ide_when_run_then_shows_unsupported_error" \
    "Unsupported IDE" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --ide nonexistent-ide --dry-run

assert_exit_code \
    "given_invalid_ide_when_run_then_exits_non_zero" \
    1 \
    bash "$SCRIPT_UNDER_TEST" --ide nonexistent-ide --dry-run

assert_output_contains \
    "given_invalid_skill_when_run_then_shows_not_found_warning" \
    "not found, skipping" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --ide agents --skills nonexistent-skill,bash-script-generator --dry-run

# ==============================================================================
# Force & Link Flag Tests
# ==============================================================================

echo ""
echo "━━━ Force & Link Flag Tests ━━━"
echo ""

assert_output_contains \
    "given_link_flag_with_dry_run_when_run_then_shows_symlink_mode" \
    "symbolic links" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --ide agents --link --dry-run

assert_output_contains \
    "given_full_install_link_dry_run_when_run_then_shows_symlink_mode" \
    "symbolic links" \
    "" \
    bash "$SCRIPT_UNDER_TEST" --full-install --link --dry-run

# ==============================================================================
# Results
# ==============================================================================

echo ""
echo "━━━ Results: ${PASS_COUNT} passed, ${FAIL_COUNT} failed ━━━"
[[ "$FAIL_COUNT" -eq 0 ]] || exit 1
