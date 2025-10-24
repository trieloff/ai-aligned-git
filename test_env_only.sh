#!/bin/bash

# Test JUST environment variable detection

# Source the functions and test them independently  
eval "$(sed -n '/^check_env_vars()/,/^}/p' executable_git)"

echo "=== Testing Environment Variable Detection Only ==="

echo "Testing CURSOR_AI=1:"
CURSOR_AI=1 check_env_vars

echo "Testing CODEX_CLI=1:"
CODEX_CLI=1 check_env_vars

echo "Testing OPENCODE_AI=1:"
OPENCODE_AI=1 check_env_vars

echo "Testing QWEN_CODE=1:"
QWEN_CODE=1 check_env_vars

echo "Testing multiple vars:"
CURSOR_AI=1 OPENCODE_AI=1 check_env_vars
