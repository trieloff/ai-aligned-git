#!/bin/bash

# Test JUST environment variable detection

# Source the functions and test them independently  
# Extract the ami_check_env function and the check_env_vars alias from executable_git
eval "$(sed -n '/^_ami_debug()/,/^}/p' executable_git)"
eval "$(sed -n '/^ami_check_env()/,/^}/p' executable_git)"
eval "$(sed -n '/^check_env_vars()/p' executable_git)"

echo "=== Testing Environment Variable Detection Only ==="

echo "Testing CURSOR_AGENT=1:"
CURSOR_AGENT=1 check_env_vars

echo "Testing CODEX_CLI=1:"
CODEX_CLI=1 check_env_vars

echo "Testing OR_APP_NAME=Aider:"
OR_APP_NAME=Aider check_env_vars

echo "Testing OPENCODE_AI=1:"
OPENCODE_AI=1 check_env_vars

echo "Testing QWEN_CODE=1:"
QWEN_CODE=1 check_env_vars

echo "Testing multiple vars:"
CURSOR_AGENT=1 OPENCODE_AI=1 check_env_vars
