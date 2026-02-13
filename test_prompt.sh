#!/bin/bash

# Test script for --prompt flag functionality
# Tests: parsing, empty commit creation, authorship, vibe-level interaction,
#        enforcement, reminder messages, special characters, equals-sign syntax

PASS_COUNT=0
FAIL_COUNT=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GIT_WRAPPER="$SCRIPT_DIR/executable_git"

pass() {
    echo "PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    echo "FAIL: $1"
    echo "      $2"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# Create a fresh test repo in an isolated temp directory
# Returns the path; caller must cd into it
setup_repo() {
    local tmpdir
    tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/test_prompt.XXXXXX")
    git init -q "$tmpdir"
    git -C "$tmpdir" config user.name "Human User"
    git -C "$tmpdir" config user.email "human@example.com"
    # Initial commit so we have a branch to work on
    git -C "$tmpdir" commit --allow-empty -m "Initial commit" -q
    echo "$tmpdir"
}

# Clean up a test repo and return to original directory
cleanup_repo() {
    cd "$SCRIPT_DIR" || exit 1
    rm -rf "$1"
}

# Create a human-mode wrapper: a copy of executable_git with AI detection
# forced to return "none". This simulates what happens when a human
# (non-AI) runs git commit through the wrapper.
# We need this because the test runner itself runs inside an AI agent,
# so process-tree detection would always find "claude".
HUMAN_WRAPPER=$(mktemp "${TMPDIR:-/tmp}/human_git_wrapper.XXXXXX")
{
    # Insert overrides right before the "# Main script" line.
    # The override functions must come AFTER the bundled am-i-ai definitions
    # (which would otherwise redefine them) but BEFORE the main logic uses them.
    sed '/^# Main script$/i\
# TEST OVERRIDE: force AI detection to "none" for human-simulation tests\
ami_detect() { echo "none"; }\
detect_ai_tool() { echo "none"; }\
ami_is_ai() { return 1; }\
' "$GIT_WRAPPER"
} > "$HUMAN_WRAPPER"
chmod +x "$HUMAN_WRAPPER"
trap 'rm -f "$HUMAN_WRAPPER"' EXIT

echo "=== Testing --prompt flag ==="
echo ""

# ---------------------------------------------------------------
# Test 1: Basic --prompt usage creates empty commit + code commit
# ---------------------------------------------------------------
TMPDIR_1=$(setup_repo)
cd "$TMPDIR_1" || exit 1

echo "test1" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
CLAUDECODE=1 "$GIT_WRAPPER" commit -m "Add feature" --prompt "Build a test feature" 2>/dev/null

commit_count=$(git log --oneline | wc -l | tr -d ' ')
if [ "$commit_count" -eq 3 ]; then
    pass "Basic --prompt creates empty commit + code commit (3 total with initial)"
else
    fail "Basic --prompt creates empty commit + code commit" "Expected 3 commits, got $commit_count"
fi

cleanup_repo "$TMPDIR_1"

# ---------------------------------------------------------------
# Test 2: Empty commit format is prompt(<agent>): <summary>
# ---------------------------------------------------------------
TMPDIR_2=$(setup_repo)
cd "$TMPDIR_2" || exit 1

echo "test2" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
CLAUDECODE=1 "$GIT_WRAPPER" commit -m "Add feature" --prompt "Build login page" 2>/dev/null

# The empty commit is the one before the AI code commit (second from top)
empty_commit_msg=$(git log --format=%s --skip=1 -1)
if [ "$empty_commit_msg" = "prompt(claude): Build login page" ]; then
    pass "Empty commit format: prompt(<agent>): <summary>"
else
    fail "Empty commit format: prompt(<agent>): <summary>" "Got: '$empty_commit_msg'"
fi

cleanup_repo "$TMPDIR_2"

# ---------------------------------------------------------------
# Test 3: Empty commit authorship is human name/email, not AI
# ---------------------------------------------------------------
TMPDIR_3=$(setup_repo)
cd "$TMPDIR_3" || exit 1

echo "test3" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
CLAUDECODE=1 "$GIT_WRAPPER" commit -m "Add feature" --prompt "Do stuff" 2>/dev/null

# The empty commit (second from top) should be authored by the human
empty_author_name=$(git log --format='%an' --skip=1 -1)
empty_author_email=$(git log --format='%ae' --skip=1 -1)

if [ "$empty_author_name" = "Human User" ] && [ "$empty_author_email" = "human@example.com" ]; then
    pass "Empty commit authored by human (name and email)"
else
    fail "Empty commit authored by human" "Got: '$empty_author_name <$empty_author_email>'"
fi

# Also verify the AI code commit is authored by AI
ai_author_name=$(git log --format='%an' -1)
if [ "$ai_author_name" = "Claude Code" ]; then
    pass "AI code commit authored by AI tool"
else
    fail "AI code commit authored by AI tool" "Got: '$ai_author_name'"
fi

cleanup_repo "$TMPDIR_3"

# ---------------------------------------------------------------
# Test 4: --prompt implies --vibe-level=prompt (trailer is Prompted-by:)
# ---------------------------------------------------------------
TMPDIR_4=$(setup_repo)
cd "$TMPDIR_4" || exit 1

echo "test4" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
CLAUDECODE=1 "$GIT_WRAPPER" commit -m "Add feature" --prompt "Build feature" 2>/dev/null

ai_commit_body=$(git log --format=%B -1)
if echo "$ai_commit_body" | grep -q "Prompted-by: Human User <human@example.com>"; then
    pass "--prompt implies --vibe-level=prompt (Prompted-by trailer)"
else
    fail "--prompt implies --vibe-level=prompt" "AI commit body: $(echo "$ai_commit_body" | tr '\n' '|')"
fi

cleanup_repo "$TMPDIR_4"

# ---------------------------------------------------------------
# Test 5: --prompt with explicit --vibe-level=co-author uses co-author trailer
# ---------------------------------------------------------------
TMPDIR_5=$(setup_repo)
cd "$TMPDIR_5" || exit 1

echo "test5" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
CLAUDECODE=1 "$GIT_WRAPPER" commit -m "Add feature" --prompt "Build feature" --vibe-level=co-author 2>/dev/null

ai_commit_body=$(git log --format=%B -1)
if echo "$ai_commit_body" | grep -q "Co-authored-by: Human User <human@example.com>"; then
    pass "--prompt with --vibe-level=co-author uses Co-authored-by trailer"
else
    fail "--prompt with --vibe-level=co-author uses Co-authored-by trailer" "AI commit body: $(echo "$ai_commit_body" | tr '\n' '|')"
fi

cleanup_repo "$TMPDIR_5"

# ---------------------------------------------------------------
# Test 6: Enforcement: ai-aligned.require-prompt = true blocks commits without --prompt
# ---------------------------------------------------------------
TMPDIR_6=$(setup_repo)
cd "$TMPDIR_6" || exit 1
git config ai-aligned.require-prompt true

echo "test6" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
if CLAUDECODE=1 "$GIT_WRAPPER" commit -m "No prompt" 2>/dev/null; then
    fail "Enforcement blocks AI commits without --prompt" "Commit succeeded but should have been blocked"
else
    pass "Enforcement blocks AI commits without --prompt"
fi

cleanup_repo "$TMPDIR_6"

# ---------------------------------------------------------------
# Test 7: Enforcement error message is factual and includes example
# ---------------------------------------------------------------
TMPDIR_7=$(setup_repo)
cd "$TMPDIR_7" || exit 1
git config ai-aligned.require-prompt true

echo "test7" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
error_output=$(CLAUDECODE=1 "$GIT_WRAPPER" commit -m "No prompt" 2>&1 || true)

has_example=false
has_factual=true
# Check for an example command in the error output
if echo "$error_output" | grep -q "\-\-prompt"; then
    has_example=true
fi
# Ensure no shaming language
if echo "$error_output" | grep -qi "shame\|lazy\|bad\|stupid"; then
    has_factual=false
fi

if [ "$has_example" = true ] && [ "$has_factual" = true ]; then
    pass "Enforcement error message is factual and includes --prompt example"
else
    fail "Enforcement error message is factual and includes --prompt example" "Output: $error_output"
fi

cleanup_repo "$TMPDIR_7"

# ---------------------------------------------------------------
# Test 8: Non-AI commits pass through unaffected
# ---------------------------------------------------------------
TMPDIR_8=$(setup_repo)
cd "$TMPDIR_8" || exit 1
git config ai-aligned.require-prompt true

echo "test8" > file.txt
git add file.txt
# Simulated human commit — detection forced to "none"
if "$HUMAN_WRAPPER" commit -m "Human commit" 2>/dev/null; then
    pass "Non-AI commits pass through unaffected (even with enforcement on)"
else
    fail "Non-AI commits pass through unaffected" "Human commit was blocked"
fi

cleanup_repo "$TMPDIR_8"

# ---------------------------------------------------------------
# Test 9: Multi-line prompt text
# ---------------------------------------------------------------
TMPDIR_9=$(setup_repo)
cd "$TMPDIR_9" || exit 1

prompt_text="Line one
Line two
Line three"

echo "test9" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
CLAUDECODE=1 "$GIT_WRAPPER" commit -m "Add feature" --prompt "$prompt_text" 2>/dev/null

empty_commit_body=$(git log --format=%B --skip=1 -1)
if echo "$empty_commit_body" | grep -q "Line one" && echo "$empty_commit_body" | grep -q "Line three"; then
    pass "Multi-line prompt text preserved in empty commit"
else
    fail "Multi-line prompt text preserved in empty commit" "Got: '$(echo "$empty_commit_body" | tr '\n' '|')'"
fi

cleanup_repo "$TMPDIR_9"

# ---------------------------------------------------------------
# Test 10: Special characters in prompt text (quotes, backticks, etc.)
# ---------------------------------------------------------------
TMPDIR_10=$(setup_repo)
cd "$TMPDIR_10" || exit 1

echo "test10" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
CLAUDECODE=1 "$GIT_WRAPPER" commit -m "Add feature" --prompt 'Fix the "bug" in `main()` & handle $PATH' 2>/dev/null

empty_commit_msg=$(git log --format=%s --skip=1 -1)
if echo "$empty_commit_msg" | grep -q 'Fix the "bug"'; then
    pass "Special characters in prompt text (quotes, backticks, \$, &)"
else
    fail "Special characters in prompt text" "Got: '$empty_commit_msg'"
fi

cleanup_repo "$TMPDIR_10"

# ---------------------------------------------------------------
# Test 11: --prompt= form (equals sign syntax)
# ---------------------------------------------------------------
TMPDIR_11=$(setup_repo)
cd "$TMPDIR_11" || exit 1

echo "test11" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
CLAUDECODE=1 "$GIT_WRAPPER" commit -m "Add feature" --prompt="Build with equals syntax" 2>/dev/null

empty_commit_msg=$(git log --format=%s --skip=1 -1)
if [ "$empty_commit_msg" = "prompt(claude): Build with equals syntax" ]; then
    pass "--prompt= equals sign syntax works"
else
    fail "--prompt= equals sign syntax works" "Got: '$empty_commit_msg'"
fi

cleanup_repo "$TMPDIR_11"

# ---------------------------------------------------------------
# Test 12: Reminder message shown for AI commit without --prompt (enforcement off)
# ---------------------------------------------------------------
TMPDIR_12=$(setup_repo)
cd "$TMPDIR_12" || exit 1
# Ensure enforcement is off (default)

echo "test12" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
stderr_output=$(CLAUDECODE=1 "$GIT_WRAPPER" commit -m "AI commit no prompt" 2>&1 >/dev/null || true)

# The reminder should mention --prompt
if echo "$stderr_output" | grep -qi "\-\-prompt"; then
    pass "Reminder message shown for AI commit without --prompt"
else
    fail "Reminder message shown for AI commit without --prompt" "stderr: '$stderr_output'"
fi

cleanup_repo "$TMPDIR_12"

# ---------------------------------------------------------------
# Test 13: Reminder is NOT shown when --prompt is provided
# ---------------------------------------------------------------
TMPDIR_13=$(setup_repo)
cd "$TMPDIR_13" || exit 1

echo "test13" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
all_output=$(CLAUDECODE=1 "$GIT_WRAPPER" commit -m "AI commit" --prompt "Summary" 2>&1)

# Filter for tip/reminder lines mentioning --prompt (not just any mention)
if echo "$all_output" | grep -qi "tip.*\-\-prompt\|reminder.*\-\-prompt"; then
    fail "Reminder NOT shown when --prompt is provided" "Found reminder in output"
else
    pass "Reminder NOT shown when --prompt is provided"
fi

cleanup_repo "$TMPDIR_13"

# ---------------------------------------------------------------
# Test 14: Reminder is NOT shown for non-AI commits
# ---------------------------------------------------------------
TMPDIR_14=$(setup_repo)
cd "$TMPDIR_14" || exit 1

echo "test14" > file.txt
git add file.txt
# Simulated human commit — detection forced to "none"
all_output=$("$HUMAN_WRAPPER" commit -m "Human commit" 2>&1)

if echo "$all_output" | grep -qi "tip.*\-\-prompt\|reminder.*\-\-prompt"; then
    fail "Reminder NOT shown for non-AI commits" "Found --prompt reminder in output"
else
    pass "Reminder NOT shown for non-AI commits"
fi

cleanup_repo "$TMPDIR_14"

# ---------------------------------------------------------------
# Test 15: --prompt with enforcement on succeeds
# ---------------------------------------------------------------
TMPDIR_15=$(setup_repo)
cd "$TMPDIR_15" || exit 1
git config ai-aligned.require-prompt true

echo "test15" > file.txt
CLAUDECODE=1 "$GIT_WRAPPER" add file.txt
if CLAUDECODE=1 "$GIT_WRAPPER" commit -m "Add feature" --prompt "Build feature" 2>/dev/null; then
    pass "--prompt with enforcement on succeeds"
else
    fail "--prompt with enforcement on succeeds" "Commit was blocked even with --prompt"
fi

cleanup_repo "$TMPDIR_15"

# ---------------------------------------------------------------
# Summary
# ---------------------------------------------------------------
echo ""
echo "=== Results ==="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "Total:  $((PASS_COUNT + FAIL_COUNT))"

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
