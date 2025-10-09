#!/usr/bin/env zsh
# ffs - "For F*ck's Sake" - Execute the previous command with sudo
# Usage: After a command fails with permission denied, just run: ffs

ffs() {
    # Get the last command from history
    local last_command=$(fc -ln -1)

    # Trim leading/trailing whitespace
    last_command="${last_command#"${last_command%%[![:space:]]*}"}"
    last_command="${last_command%"${last_command##*[![:space:]]}"}"

    # Check if the last command is 'ffs' itself to prevent infinite loops
    if [[ "$last_command" == "ffs" ]]; then
        echo "Error: Cannot sudo the ffs command itself"
        return 1
    fi

    # Execute with sudo
    echo "$ sudo $last_command"
    eval "sudo $last_command"
}
