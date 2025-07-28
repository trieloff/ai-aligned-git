# Contributing Guidelines

Thank you for your interest in contributing to this project! Please follow these guidelines to ensure smooth collaboration.

## Shell Script Best Practices

When writing or modifying shell scripts in this repository, please follow these best practices to ensure robustness, portability, and maintainability.

### 1. Use Strict Error Handling

Always start your shell scripts with:
```bash
#!/bin/bash
set -euo pipefail
```

- `set -e`: Exit immediately if a command fails
- `set -u`: Treat unset variables as an error
- `set -o pipefail`: Ensure pipeline failures are caught

### 2. Proper Variable Quoting

Always quote variable expansions to prevent word splitting and globbing:
```bash
# Good
echo "$variable"
cp "$source_file" "$destination"

# Bad
echo $variable
cp $source_file $destination
```

### 3. Use Double Brackets for Tests

Prefer `[[ ]]` over `[ ]` for more robust conditional tests:
```bash
# Good
if [[ -z "${variable:-}" ]]; then
    echo "Variable is empty or unset"
fi

# Less robust
if [ -z "$variable" ]; then
    echo "Variable is empty"
fi
```

### 4. Handle Unset Variables

Use parameter expansion to provide defaults:
```bash
# Good - provides empty string default
name="${NAME:-}"

# Good - provides specific default
port="${PORT:-8080}"

# Good - exits with error message if required variable is unset
db_host="${DB_HOST:?Error: DB_HOST is required}"
```

### 5. Use Local Variables in Functions

Always declare function variables as local:
```bash
function process_file() {
    local file="$1"
    local output_dir="${2:-/tmp}"
    
    # Process the file
}
```

### 6. Use Readonly for Constants

Declare constants with readonly:
```bash
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly DEFAULT_PORT=8080
```

### 7. Proper Command Substitution

Always quote command substitutions:
```bash
# Good
current_dir="$(pwd)"
files="$(find . -name "*.txt")"

# Bad
current_dir=$(pwd)
files=$(find . -name "*.txt")
```

### 8. Handle cd Failures

Always handle directory change failures:
```bash
# Good
cd "$target_dir" || exit 1

# Better - saves and restores directory
pushd "$target_dir" >/dev/null || exit 1
# do work
popd >/dev/null
```

### 9. Avoid Useless Use of Cat

```bash
# Bad
cat file.txt | grep pattern

# Good
grep pattern file.txt

# Bad
cat file.txt | while read line; do
    echo "$line"
done

# Good
while IFS= read -r line; do
    echo "$line"
done < file.txt
```

### 10. Use ShellCheck

Before committing any shell scripts:

1. Run shellcheck locally:
   ```bash
   make shellcheck
   ```

2. Install shellcheck if needed:
   ```bash
   make install-shellcheck
   ```

3. The pre-commit hook will automatically check your scripts

### 11. Array Handling

When working with arrays:
```bash
# Declare arrays properly
declare -a my_array=("element1" "element2" "element3")

# Access array elements
echo "${my_array[0]}"

# Iterate over array
for element in "${my_array[@]}"; do
    echo "$element"
done

# Get array length
echo "${#my_array[@]}"
```

### 12. Intentional ShellCheck Suppressions

If you need to suppress a shellcheck warning for a valid reason, add an inline comment:
```bash
# shellcheck disable=SC2086
# Intentionally unquoted to allow word splitting
for file in $files; do
    process "$file"
done
```

## Code Review Process

All shell scripts must:
1. Pass shellcheck validation without errors
2. Follow the best practices outlined above
3. Include appropriate error handling
4. Be tested on both Linux and macOS (when applicable)

## Testing

When modifying shell scripts:
1. Test on multiple shells if the script claims portability
2. Test error conditions and edge cases
3. Verify the script works with filenames containing spaces
4. Check behavior with unset variables

## Questions?

If you have questions about these guidelines or need clarification, please open an issue for discussion.