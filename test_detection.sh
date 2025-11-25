#!/bin/bash

# Test script for AI detection functions

# Function to check if a process name contains a pattern (case-insensitive)
process_contains() {
    local pid=$1
    local pattern=$2
    # Get process command and name
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        ps -p "$pid" -o comm= 2>/dev/null | grep -qi "$pattern" || \
        ps -p "$pid" -o command= 2>/dev/null | grep -qi "$pattern"
    else
        # Linux
        ps -p "$pid" -o comm= 2>/dev/null | grep -qi "$pattern" || \
        ps -p "$pid" -o cmd= 2>/dev/null | grep -qi "$pattern"
    fi
}

# Generic function to check environment variables for AI detection
check_env_vars() {
    local detected=""

    # Claude Code detection
    if [ -n "$CLAUDECODE" ] && [ "$CLAUDE_CODE_ENTRYPOINT" = "cli" ]; then
        if pgrep -f "claude" >/dev/null 2>&1; then
            detected="$detected claude"
        fi
    fi

    # Codex CLI detection (env opt-in)
    if [ -n "$CODEX_CLI" ]; then
        detected="$detected codex"
    fi

    # Zed detection
    if [ "$TERM_PROGRAM" = "zed" ] || [ "$ZED_TERM" = "true" ]; then
        detected="$detected zed"
    fi

    # Kimi CLI detection
    if [ -n "$KIMI_CLI" ]; then
        detected="$detected kimi"
    fi

    # Auggie detection
    if [ -n "$AUGMENT_SESSION_AUTH" ]; then
        detected="$detected auggie"
    fi

    echo "$detected"
}

# Generic function to walk process tree and detect AI tools
check_ps_tree() {
    local detected=""
    local current_pid=$$
    local max_depth=10
    local depth=0

    echo "=== Walking Process Tree ===" >&2

    while [ $depth -lt $max_depth ]; do
        # Get parent PID
        if [[ "$OSTYPE" == "darwin"* ]]; then
            current_pid=$(ps -p "$current_pid" -o ppid= 2>/dev/null | tr -d ' ')
        fi

        # Check if we've reached the top
        if [ -z "$current_pid" ] || [ "$current_pid" -eq 1 ] || [ "$current_pid" -eq 0 ]; then
            break
        fi

        # Show current process
        process_info=$(ps -p "$current_pid" -o pid=,comm=,command= 2>/dev/null | head -1)
        echo "Depth $depth: $process_info" >&2

        # Check for AI tool patterns
        if process_contains "$current_pid" "claude"; then
            echo "  -> Found CLAUDE at depth $depth" >&2
            detected="$detected claude"
        fi
        if process_contains "$current_pid" "codex"; then
            echo "  -> Found CODEX at depth $depth" >&2
            detected="$detected codex"
        fi
        if process_contains "$current_pid" "zed"; then
            echo "  -> Found ZED at depth $depth" >&2
            detected="$detected zed"
        fi
        if process_contains "$current_pid" "cursor"; then
            echo "  -> Found CURSOR at depth $depth" >&2
            detected="$detected cursor"
        fi
        if process_contains "$current_pid" "kimi"; then
            echo "  -> Found KIMI at depth $depth" >&2
            detected="$detected kimi"
        fi
        if process_contains "$current_pid" "crush"; then
            echo "  -> Found CRUSH at depth $depth" >&2
            detected="$detected crush"
        fi

        depth=$((depth + 1))
    done

    echo "$detected"
}

# Main detection function
detect_ai_tool() {
    local env_detected
    env_detected=$(check_env_vars)

    local ps_detected
    ps_detected=$(check_ps_tree)

    local all_detected="$env_detected $ps_detected"
    echo "All detected: '$all_detected'" >&2

    # Priority order: Codex > Claude > Cursor > Kimi > Crush > Zed
    if [[ "$all_detected" =~ "codex" ]]; then
        echo "codex"
    elif [[ "$all_detected" =~ "claude" ]]; then
        echo "claude"
    elif [[ "$all_detected" =~ "cursor" ]]; then
        echo "cursor"
    elif [[ "$all_detected" =~ "kimi" ]]; then
        echo "kimi"
    elif [[ "$all_detected" =~ "crush" ]]; then
        echo "crush"
    elif [[ "$all_detected" =~ "zed" ]]; then
        echo "zed"
    else
        echo "none"
    fi
}

echo "=== AI Detection Test ==="
echo "Current PID: $$"

echo -e "\n=== Environment Variables ==="
echo "CLAUDECODE: '$CLAUDECODE'"
echo "CLAUDE_CODE_ENTRYPOINT: '$CLAUDE_CODE_ENTRYPOINT'"
echo "TERM_PROGRAM: '$TERM_PROGRAM'"
echo "KIMI_CLI: '$KIMI_CLI'"

echo -e "\n=== Environment Detection ==="
env_result=$(check_env_vars)
echo "Environment detected: '$env_result'"

echo -e "\n=== Process Tree Detection ==="
ps_result=$(check_ps_tree)
echo "Process tree detected: '$ps_result'"

echo -e "\n=== Final Detection ==="
final=$(detect_ai_tool)
echo "Final result: '$final'"
