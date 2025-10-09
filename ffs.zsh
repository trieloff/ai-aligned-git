#!/usr/bin/env zsh
# ffs - "Friendly Following Sudo" - Execute the previous command with sudo
# Usage:
#   $ rm /etc/somefile
#   Permission denied
#   $ ffs
# Or on the same line:
#   $ rm /etc/somefile; ffs

ffs() {
    local commands_to_sudo

    # First, check if this was run on the same line (semicolon-separated)
    # Get the current command line from history
    local current_line=$(fc -ln -1)

    # Check if current line contains "; ffs" or ";ffs"
    if [[ "$current_line" =~ ^(.+)[[:space:]]*;[[:space:]]*ffs[[:space:]]*$ ]]; then
        # Extract everything before "; ffs"
        commands_to_sudo="${match[1]}"
    else
        # Not on same line, get the previous command from history
        commands_to_sudo=$(fc -ln -2 | head -1)
    fi

    # Trim leading/trailing whitespace
    commands_to_sudo="${commands_to_sudo#"${commands_to_sudo%%[![:space:]]*}"}"
    commands_to_sudo="${commands_to_sudo%"${commands_to_sudo##*[![:space:]]}"}"

    # Check if we got a valid command
    if [[ -z "$commands_to_sudo" || "$commands_to_sudo" == "ffs" ]]; then
        echo "Error: No valid previous command found"
        return 1
    fi

    # Execute all commands with sudo
    # Use a subshell to execute the entire command chain under sudo
    echo "$ sudo sh -c '$commands_to_sudo'"
    sudo sh -c "$commands_to_sudo"
}
