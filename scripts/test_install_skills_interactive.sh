#!/usr/bin/env bash
set -uo pipefail

readonly SCRIPT_UNDER_TEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install-skills.sh"

PASS_COUNT=0
FAIL_COUNT=0

assert_output_contains() {
    local description="$1"
    local expected_substring="$2"
    local input="$3"
    shift 3
    local output
    output=$(echo "$input" | "$@" 2>&1) || true
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

assert_output_contains_no_input() {
    local description="$1"
    local expected_substring="$2"
    shift 2
    local output
    output=$("$@" 2>&1) || true
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

assert_output_contains_no_input \
    "given_help_flag_when_run_then_mentions_interactive" \
    "--interactive" \
    bash "$SCRIPT_UNDER_TEST" --help

assert_output_contains_no_input \
    "given_existing_flags_when_used_then_still_work" \
    "Available skills:" \
    bash "$SCRIPT_UNDER_TEST" --list

echo ""
echo "━━━ Results: ${PASS_COUNT} passed, ${FAIL_COUNT} failed ━━━"
[[ "$FAIL_COUNT" -eq 0 ]] || exit 1
