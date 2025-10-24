#!/bin/bash

# Debug script to test AI detection

# Load only the detection functions from executable_git to avoid exec side effects
eval "$(sed -n '/^process_contains()/,/^}/p' executable_git)"
eval "$(sed -n '/^check_env_vars()/,/^}/p' executable_git)"
eval "$(sed -n '/^check_ps_tree()/,/^}/p' executable_git)"
eval "$(sed -n '/^detect_ai_tool()/,/^}/p' executable_git)"

echo "=== Debug AI Detection ==="
echo "Current PID: $$"
echo "Current PPID: $(ps -p $$ -o ppid= | tr -d ' ')"

echo -e "\n=== Environment Variables ==="
echo "CLAUDECODE: $CLAUDECODE"
echo "CLAUDE_CODE_ENTRYPOINT: $CLAUDE_CODE_ENTRYPOINT"
echo "TERM_PROGRAM: $TERM_PROGRAM"
echo "ZED_TERM: $ZED_TERM"

echo -e "\n=== Process Tree ==="
current_pid=$$
depth=0
while [ $depth -lt 5 ]; do
    if [[ "$OSTYPE" == "darwin"* ]]; then
        parent_pid=$(ps -p "$current_pid" -o ppid= 2>/dev/null | tr -d ' ')
    fi

    if [ -z "$parent_pid" ] || [ "$parent_pid" -eq 1 ]; then
        break
    fi

    process_info=$(ps -p "$parent_pid" -o pid=,comm=,command= 2>/dev/null)
    echo "Depth $depth: $process_info"

    current_pid=$parent_pid
    depth=$((depth + 1))
done

echo -e "\n=== Detection Results ==="
env_detected=$(check_env_vars)
echo "Environment detected: '$env_detected'"

ps_detected=$(check_ps_tree)
echo "Process tree detected: '$ps_detected'"

final_result=$(detect_ai_tool)
echo "Final result: '$final_result'"
