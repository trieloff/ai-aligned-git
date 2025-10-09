#!/usr/bin/env zsh
# ffs - "For F*ck's Sake" - Execute the previous command with sudo
# Usage:
#   $ rm /etc/somefile
#   Permission denied
#   $ ffs
# Or on the same line:
#   $ rm /etc/somefile; ffs

ffs() {
    local last_command

    # First, check if this was run on the same line (semicolon-separated)
    # Get the current command line from history
    local current_line=$(fc -ln -1)

    # Check if current line contains "; ffs" or ";ffs"
    if [[ "$current_line" =~ ^(.+)[[:space:]]*;[[:space:]]*ffs[[:space:]]*$ ]]; then
        # Extract everything before "; ffs"
        last_command="${match[1]}"
    else
        # Not on same line, get the previous command from history
        last_command=$(fc -ln -2 | head -1)
    fi

    # Trim leading/trailing whitespace
    last_command="${last_command#"${last_command%%[![:space:]]*}"}"
    last_command="${last_command%"${last_command##*[![:space:]]}"}"

    # Check if we got a valid command
    if [[ -z "$last_command" || "$last_command" == "ffs" ]]; then
        echo "Error: No valid previous command found"
        return 1
    fi

    # Execute with sudo
    echo "$ sudo $last_command"
    eval "sudo $last_command"
}
