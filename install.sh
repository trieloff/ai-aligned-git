#!/bin/bash

# AI-Aligned-Git Installer Script
# Installs the git wrapper to ~/.local/bin
# Supports both local installation and curl | sh
#
# Usage with curl:
#   curl -fsSL https://raw.githubusercontent.com/trieloff/ai-aligned-git/main/install.sh | sh
#   UPGRADE=true curl -fsSL https://raw.githubusercontent.com/trieloff/ai-aligned-git/main/install.sh | sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Installation directory
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="git"
SOURCE_SCRIPT="executable_git"
# REPO_URL="https://github.com/trieloff/ai-aligned-git"  # Currently unused
RAW_BASE_URL="https://raw.githubusercontent.com/trieloff/ai-aligned-git/main"

# Verbose mode flag
VERBOSE=${VERBOSE:-false}
# Upgrade mode flag
UPGRADE=${UPGRADE:-false}

# Function to print colored output
print_color() {
    local color=$1
    shift
    printf "${color}%s${NC}\n" "$*"
}

# Function to print verbose output
print_verbose() {
    if [ "$VERBOSE" = true ]; then
        print_color "$BLUE" "[VERBOSE] $*"
    fi
}

# Function to check if a command exists
command_exists() {
    local cmd="$1"
    print_verbose "Checking if command '$cmd' exists..."
    if command -v "$cmd" >/dev/null 2>&1; then
        print_verbose "Command '$cmd' found at: $(command -v "$cmd")"
        return 0
    else
        print_verbose "Command '$cmd' not found"
        return 1
    fi
}

# Function to check if directory is in PATH
is_in_path() {
    local dir=$1
    print_verbose "Checking if '$dir' is in PATH..."
    print_verbose "Current PATH: $PATH"
    if [[ ":$PATH:" == *":$dir:"* ]]; then
        print_verbose "Directory '$dir' is in PATH"
        return 0
    else
        print_verbose "Directory '$dir' is NOT in PATH"
        return 1
    fi
}

# Function to detect the user's shell
detect_shell() {
    print_verbose "Detecting shell..."
    if [ -n "$SHELL" ]; then
        local shell_name
        shell_name=$(basename "$SHELL")
        print_verbose "Detected shell: $shell_name (from SHELL=$SHELL)"
        echo "$shell_name"
    else
        print_verbose "SHELL variable not set, defaulting to bash"
        echo "bash"  # Default to bash
    fi
}

# Function to detect OS
detect_os() {
    local uname_output
    uname_output=$(uname -s)
    print_verbose "Detecting OS from uname: $uname_output"
    case "$uname_output" in
        Darwin*)
            print_verbose "Detected macOS"
            echo "macos"
            ;;
        Linux*)
            print_verbose "Detected Linux"
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            print_verbose "Detected Windows (Cygwin/MinGW/MSYS)"
            echo "windows"
            ;;
        *)
            print_verbose "Unknown OS: $uname_output"
            echo "unknown"
            ;;
    esac
}

# Function to get shell config file
get_shell_config() {
    local shell_name
    shell_name=$(detect_shell)
    case "$shell_name" in
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        zsh)
            if [ -f "$HOME/.zshrc" ]; then
                echo "$HOME/.zshrc"
            else
                echo "$HOME/.zshrc"
            fi
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Function to show OS-specific PATH instructions
show_path_instructions() {
    local dir=$1
    local os_type
    os_type=$(detect_os)
    local shell_name
    shell_name=$(detect_shell)
    
    print_color "$YELLOW" "To add $dir to your PATH, follow these instructions:"
    echo
    
    case "$os_type" in
        macos)
            print_color "$BLUE" "=== macOS Instructions ==="
            echo
            print_color "$YELLOW" "Option 1: For ALL applications (recommended):"
            print_color "$YELLOW" "Create a Launch Agent to set PATH system-wide:"
            echo
            print_color "$GREEN" "  1. Create the plist file:"
            print_color "$WHITE" "     sudo tee /Library/LaunchDaemons/setpath.plist > /dev/null << 'EOF'"
            print_color "$WHITE" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            print_color "$WHITE" "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
            print_color "$WHITE" "<plist version=\"1.0\">"
            print_color "$WHITE" "<dict>"
            print_color "$WHITE" "  <key>Label</key>"
            print_color "$WHITE" "  <string>setpath</string>"
            print_color "$WHITE" "  <key>ProgramArguments</key>"
            print_color "$WHITE" "  <array>"
            print_color "$WHITE" "    <string>/bin/launchctl</string>"
            print_color "$WHITE" "    <string>setenv</string>"
            print_color "$WHITE" "    <string>PATH</string>"
            print_color "$WHITE" "    <string>$dir:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>"
            print_color "$WHITE" "  </array>"
            print_color "$WHITE" "  <key>RunAtLoad</key>"
            print_color "$WHITE" "  <true/>"
            print_color "$WHITE" "</dict>"
            print_color "$WHITE" "</plist>"
            print_color "$WHITE" "EOF"
            echo
            print_color "$GREEN" "  2. Load the Launch Agent:"
            print_color "$WHITE" "     sudo launchctl load /Library/LaunchDaemons/setpath.plist"
            echo
            print_color "$GREEN" "  3. Restart your Mac or log out and back in"
            echo
            print_color "$YELLOW" "Option 2: For terminal only:"
            ;;
        linux)
            print_color "$BLUE" "=== Linux Instructions ==="
            echo
            print_color "$YELLOW" "For system-wide PATH (all users):"
            print_color "$WHITE" "  sudo tee /etc/profile.d/local-bin.sh > /dev/null << 'EOF'"
            print_color "$WHITE" "export PATH=\"$dir:\$PATH\""
            print_color "$WHITE" "EOF"
            echo
            print_color "$YELLOW" "For current user only:"
            ;;
        windows)
            print_color "$BLUE" "=== Windows (WSL) Instructions ==="
            echo
            print_color "$YELLOW" "For WSL terminal:"
            ;;
    esac
    
    # Shell-specific instructions
    local config_file
    config_file=$(get_shell_config)
    case "$shell_name" in
        bash)
            print_color "$WHITE" "  echo 'export PATH=\"$dir:\$PATH\"' >> $config_file"
            print_color "$WHITE" "  source $config_file"
            ;;
        zsh)
            print_color "$WHITE" "  echo 'export PATH=\"$dir:\$PATH\"' >> $config_file"
            print_color "$WHITE" "  source $config_file"
            ;;
        fish)
            print_color "$WHITE" "  echo 'set -gx PATH $dir \$PATH' >> $config_file"
            print_color "$WHITE" "  source $config_file"
            ;;
        *)
            print_color "$WHITE" "  echo 'export PATH=\"$dir:\$PATH\"' >> ~/.profile"
            print_color "$WHITE" "  source ~/.profile"
            ;;
    esac
    echo
}

# Function to add directory to PATH in shell config
add_to_path() {
    local dir=$1
    local config_file=$2
    local shell_name
    shell_name=$(detect_shell)
    
    print_color "$YELLOW" "Adding $dir to PATH in $config_file..."
    
    # Create config file if it doesn't exist
    mkdir -p "$(dirname "$config_file")"
    touch "$config_file"
    
    # Check if PATH export already exists
    if grep -q "export PATH.*$dir" "$config_file" 2>/dev/null || grep -q "set -gx PATH.*$dir" "$config_file" 2>/dev/null; then
        print_color "$GREEN" "✓ $dir already in PATH configuration"
        return 0
    fi
    
    # Add PATH export based on shell
    case "$shell_name" in
        fish)
            echo "set -gx PATH $dir \$PATH" >> "$config_file"
            ;;
        *)
            echo "export PATH=\"$dir:\$PATH\"" >> "$config_file"
            ;;
    esac
    
    print_color "$GREEN" "✓ Added $dir to PATH"
}

# Function to prompt user (handles non-interactive mode)
prompt_yes_no() {
    local prompt=$1
    local default=${2:-n}
    
    # In non-interactive mode, use default
    if [ ! -t 0 ]; then
        [ "$default" = "y" ]
        return $?
    fi
    
    read -p "$prompt" -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Function to verify git is installed
check_git_installed() {
    print_color "$BLUE" "Checking for git installation..."
    
    if ! command_exists git; then
        print_color "$RED" "✗ Git is not installed"
        print_color "$YELLOW" "Please install git first:"
        case "$(uname -s)" in
            Darwin*)
                print_color "$YELLOW" "  brew install git"
                ;;
            Linux*)
                if command_exists apt-get; then
                    print_color "$YELLOW" "  sudo apt-get install git"
                elif command_exists yum; then
                    print_color "$YELLOW" "  sudo yum install git"
                elif command_exists pacman; then
                    print_color "$YELLOW" "  sudo pacman -S git"
                fi
                ;;
        esac
        return 1
    fi
    
    local git_version
    git_version=$(git --version | awk '{print $3}')
    print_color "$GREEN" "✓ Git version $git_version found"
    return 0
}

# Function to create ~/.local/bin if it doesn't exist
ensure_install_dir() {
    print_color "$BLUE" "Checking installation directory..."
    print_verbose "Installation directory: $INSTALL_DIR"
    
    if [ ! -d "$INSTALL_DIR" ]; then
        print_color "$YELLOW" "Creating $INSTALL_DIR..."
        print_verbose "Directory does not exist, creating it"
        if mkdir -p "$INSTALL_DIR"; then
            print_color "$GREEN" "✓ Created $INSTALL_DIR"
            print_verbose "Directory created successfully"
        else
            print_color "$RED" "✗ Failed to create $INSTALL_DIR"
            print_verbose "Failed to create directory"
            return 1
        fi
    else
        print_color "$GREEN" "✓ $INSTALL_DIR exists"
        print_verbose "Directory already exists"
    fi
    
    # Check if directory is writable
    print_verbose "Checking if directory is writable..."
    if [ ! -w "$INSTALL_DIR" ]; then
        print_color "$RED" "✗ $INSTALL_DIR is not writable"
        print_verbose "Directory permissions: $(ls -ld "$INSTALL_DIR" 2>/dev/null)"
        return 1
    fi
    
    print_color "$GREEN" "✓ $INSTALL_DIR is writable"
    return 0
}

# Function to download file
download_file() {
    local url=$1
    local output=$2
    
    print_verbose "Attempting to download: $url -> $output"
    
    if command_exists curl; then
        print_verbose "Using curl for download"
        if [ "$VERBOSE" = true ]; then
            curl -fL "$url" -o "$output"
        else
            curl -fsSL "$url" -o "$output"
        fi
    elif command_exists wget; then
        print_verbose "Using wget for download"
        if [ "$VERBOSE" = true ]; then
            wget "$url" -O "$output"
        else
            wget -q "$url" -O "$output"
        fi
    else
        print_color "$RED" "✗ Neither curl nor wget found. Please install one of them."
        return 1
    fi
    
    local result=$?
    if [ $result -eq 0 ]; then
        print_verbose "Download successful"
    else
        print_verbose "Download failed with exit code: $result"
    fi
    return $result
}

# Function to install the script
install_script() {
    local dest_path="$INSTALL_DIR/$SCRIPT_NAME"
    local temp_file
    
    print_color "$BLUE" "Installing AI-Aligned-Git..."
    
    # Check if git wrapper already exists
    if [ -f "$dest_path" ] && [ "$UPGRADE" != "true" ]; then
        print_color "$YELLOW" "⚠ Git wrapper already exists at $dest_path"
        if ! prompt_yes_no "Do you want to overwrite it? [y/N] " "n"; then
            print_color "$YELLOW" "Installation cancelled"
            return 1
        fi
    elif [ -f "$dest_path" ] && [ "$UPGRADE" = "true" ]; then
        print_color "$YELLOW" "Upgrading existing git wrapper at $dest_path"
    fi
    
    # Remove existing file if upgrading
    if [ "$UPGRADE" = "true" ] && [ -f "$dest_path" ]; then
        print_verbose "Removing existing wrapper for upgrade"
        if ! rm -f "$dest_path"; then
            print_color "$RED" "✗ Failed to remove existing wrapper for upgrade"
            return 1
        fi
    fi
    
    # Check if we're running from a local checkout or via curl
    if [ -t 0 ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/$SOURCE_SCRIPT" ]; then
        # Local installation
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local source_path="$script_dir/$SOURCE_SCRIPT"
        print_verbose "Running from local checkout at: $script_dir"
        
        if [ ! -f "$source_path" ]; then
            print_color "$RED" "✗ Source script not found: $source_path"
            return 1
        fi
        
        # Copy the script
        if ! cp "$source_path" "$dest_path"; then
            print_color "$RED" "✗ Failed to copy script to $dest_path"
            return 1
        fi
    else
        # Remote installation via curl | sh
        print_color "$YELLOW" "Downloading executable_git from GitHub..."
        temp_file=$(mktemp)
        print_verbose "Created temporary file: $temp_file"
        print_verbose "Downloading from: $RAW_BASE_URL/$SOURCE_SCRIPT"
        
        if ! download_file "$RAW_BASE_URL/$SOURCE_SCRIPT" "$temp_file"; then
            print_color "$RED" "✗ Failed to download executable_git"
            rm -f "$temp_file"
            return 1
        fi
        
        # Move to destination
        if ! mv "$temp_file" "$dest_path"; then
            print_color "$RED" "✗ Failed to install script"
            return 1
        fi
    fi
    
    # Make it executable
    if ! chmod +x "$dest_path"; then
        print_color "$RED" "✗ Failed to make script executable"
        return 1
    fi
    
    print_color "$GREEN" "✓ Installed git wrapper to $dest_path"
    return 0
}

# Function to check PATH precedence
check_path_precedence() {
    local wrapper_path="$INSTALL_DIR/$SCRIPT_NAME"
    local system_git_locations=(
        "/usr/bin/git"
        "/usr/local/bin/git"
        "/opt/homebrew/bin/git"
        "/opt/local/bin/git"
    )
    
    print_verbose "Checking PATH precedence for git wrapper..."
    print_verbose "Wrapper location: $wrapper_path"
    
    # Find which git would be used
    local which_git
            which_git=$(which git 2>/dev/null)
    print_verbose "Current git resolves to: $which_git"
    
    # If wrapper is already the default, we're good
    if [ "$which_git" = "$wrapper_path" ]; then
        print_verbose "Wrapper has correct precedence"
        return 0
    fi
    
    # Check if any system git location comes before our install dir in PATH
    local IFS=:
    local path_dirs
    IFS=: read -ra path_dirs <<< "$PATH"
    local install_dir_index=-1
    local system_git_index=-1
    
    # Find index of our install dir in PATH
    for i in "${!path_dirs[@]}"; do
        if [ "${path_dirs[$i]}" = "$INSTALL_DIR" ]; then
            install_dir_index=$i
            print_verbose "Found $INSTALL_DIR at PATH index $i"
            break
        fi
    done
    
    # Find index of system git in PATH
    for location in "${system_git_locations[@]}"; do
        if [ -x "$location" ]; then
            local git_dir
            git_dir=$(dirname "$location")
            for i in "${!path_dirs[@]}"; do
                if [ "${path_dirs[$i]}" = "$git_dir" ]; then
                    if [ "$system_git_index" -eq -1 ] || [ "$i" -lt "$system_git_index" ]; then
                        system_git_index=$i
                    fi
                fi
            done
        fi
    done
    
    # If install dir not in PATH, it needs to be added
    if [ "$install_dir_index" -eq -1 ]; then
        return 1
    fi
    
    # If system git found and comes before our install dir, we have a problem
    if [ "$system_git_index" -ne -1 ] && [ "$system_git_index" -lt "$install_dir_index" ]; then
        return 2
    fi
    
    return 0
}

# Function to verify installation
verify_installation() {
    print_color "$BLUE" "Verifying installation..."
    
    local wrapper_path="$INSTALL_DIR/$SCRIPT_NAME"
    
    # Check if wrapper exists and is executable
    if [ ! -x "$wrapper_path" ]; then
        print_color "$RED" "✗ Git wrapper not found or not executable at $wrapper_path"
        return 1
    fi
    
    # Check PATH precedence
    check_path_precedence
    local precedence_result=$?
    
    case $precedence_result in
        0)
            print_color "$GREEN" "✓ AI-Aligned-Git wrapper will be used by default"
            ;;
        1)
            print_color "$YELLOW" "⚠ $INSTALL_DIR is not in current PATH"
            print_color "$YELLOW" "  You need to restart your shell or run:"
            local shell_config
            shell_config=$(get_shell_config)
            print_color "$YELLOW" "  source $shell_config"
            ;;
        2)
            local which_git
            which_git=$(which git 2>/dev/null)
            print_color "$RED" "✗ System git at $which_git has PATH precedence over wrapper"
            print_color "$RED" "  $INSTALL_DIR must come BEFORE $(dirname "$which_git") in PATH"
            print_color "$YELLOW" ""
            print_color "$YELLOW" "  To fix this, edit your shell config and ensure ~/.local/bin comes first:"
            local shell_name
            shell_name=$(detect_shell)
            case "$shell_name" in
                fish)
                    print_color "$YELLOW" "  set -gx PATH ~/.local/bin $PATH"
                    ;;
                *)
                    print_color "$YELLOW" "  export PATH=\"~/.local/bin:\$PATH\""
                    ;;
            esac
            return 1
            ;;
    esac
    
    print_color "$GREEN" "✓ Installation verified"
    return 0
}

# Main installation function
main() {
    if [ "$UPGRADE" = "true" ]; then
        print_color "$BLUE" "=== AI-Aligned-Git Upgrade ==="
    else
        print_color "$BLUE" "=== AI-Aligned-Git Installer ==="
    fi
    echo
    print_color "$YELLOW" "This installer will:"
    if [ "$UPGRADE" = "true" ]; then
        print_color "$YELLOW" "  • Upgrade the git wrapper at ~/.local/bin/git"
    else
        print_color "$YELLOW" "  • Install the git wrapper to ~/.local/bin/git"
        print_color "$YELLOW" "  • Ensure ~/.local/bin is in your PATH"
        print_color "$YELLOW" "  • Verify the wrapper will intercept git commands"
    fi
    echo
    
    if [ "$UPGRADE" != "true" ] && ! prompt_yes_no "Do you want to continue? [Y/n] " "y"; then
        print_color "$YELLOW" "Installation cancelled."
        exit 0
    fi
    echo
    
    # Check prerequisites
    if ! check_git_installed; then
        exit 1
    fi
    
    # Ensure installation directory exists
    if ! ensure_install_dir; then
        exit 1
    fi
    
    # Check PATH and precedence
    if ! is_in_path "$INSTALL_DIR"; then
        print_color "$YELLOW" "⚠ $INSTALL_DIR is not in PATH"
        echo
        local shell_config
        shell_config=$(get_shell_config)
        local os_type
    os_type=$(detect_os)
        
        if [ "$os_type" = "macos" ]; then
            print_color "$YELLOW" "On macOS, you should configure PATH system-wide for GUI applications."
            show_path_instructions "$INSTALL_DIR"
            echo
            if prompt_yes_no "Would you like to add it to $shell_config for terminal use? [Y/n] " "y"; then
                add_to_path "$INSTALL_DIR" "$shell_config"
                print_color "$YELLOW" "⚠ Note: This only affects terminal sessions. For GUI apps, use the launchctl method above."
            fi
        else
            if prompt_yes_no "Do you want to add it to $shell_config? [Y/n] " "y"; then
                add_to_path "$INSTALL_DIR" "$shell_config"
            else
                echo
                show_path_instructions "$INSTALL_DIR"
            fi
        fi
    else
        print_color "$GREEN" "✓ $INSTALL_DIR is already in PATH"
        
        # Check if it has proper precedence
        check_path_precedence
        local precedence_result=$?
        
        if [ "$precedence_result" -eq 2 ]; then
            local which_git
            which_git=$(which git 2>/dev/null)
            print_color "$RED" "✗ WARNING: System git at $which_git has PATH precedence"
            print_color "$RED" "  The AI-aligned git wrapper will NOT work until you fix your PATH"
            print_color "$YELLOW" ""
            print_color "$YELLOW" "  Your current PATH order will use system git instead of the wrapper."
            print_color "$YELLOW" "  To fix: ensure ~/.local/bin comes BEFORE $(dirname "$which_git") in PATH"
            echo
            if ! prompt_yes_no "Continue installation anyway? [y/N] " "n"; then
                print_color "$YELLOW" "Installation cancelled. Please fix your PATH first."
                exit 1
            fi
        fi
    fi
    
    # Final confirmation before installing
    echo
    if [ "$UPGRADE" = "true" ]; then
        print_color "$BLUE" "Ready to upgrade AI-Aligned-Git"
    else
        print_color "$BLUE" "Ready to install AI-Aligned-Git"
        if ! prompt_yes_no "Proceed with installation? [Y/n] " "y"; then
            print_color "$YELLOW" "Installation cancelled."
            exit 0
        fi
    fi
    
    # Install the script
    if ! install_script; then
        exit 1
    fi
    
    # Verify installation
    verify_installation
    
    echo
    print_color "$GREEN" "=== Installation Complete ==="
    print_color "$BLUE" "AI-Aligned-Git has been installed successfully!"
    echo
    print_color "$YELLOW" "Next steps:"
    if ! is_in_path "$INSTALL_DIR"; then
        print_color "$YELLOW" "1. Reload your shell configuration:"
        local shell_name
        shell_name=$(detect_shell)
        case "$shell_name" in
            fish)
                print_color "$YELLOW" "   source $(get_shell_config)"
                ;;
            *)
                print_color "$YELLOW" "   source $(get_shell_config)"
                ;;
        esac
        print_color "$YELLOW" "   Or start a new terminal session"
        echo
    fi
    print_color "$YELLOW" "2. Verify the wrapper is working:"
    print_color "$YELLOW" "   which git"
    print_color "$YELLOW" "   (Should show: $INSTALL_DIR/git)"
    echo
    print_color "$YELLOW" "3. Test with an AI tool like Claude"
    echo
    print_color "$BLUE" "To uninstall, run:"
    print_color "$BLUE" "  rm ~/.local/bin/git"
}

# Uninstall function
uninstall() {
    print_color "$BLUE" "=== AI-Aligned-Git Uninstaller ==="
    echo
    
    local wrapper_path="$INSTALL_DIR/$SCRIPT_NAME"
    
    if [ -f "$wrapper_path" ]; then
        print_color "$YELLOW" "Removing git wrapper..."
        if rm -f "$wrapper_path"; then
            print_color "$GREEN" "✓ Removed $wrapper_path"
        else
            print_color "$RED" "✗ Failed to remove $wrapper_path"
            exit 1
        fi
    else
        print_color "$YELLOW" "Git wrapper not found at $wrapper_path"
    fi
    
    echo
    print_color "$GREEN" "=== Uninstall Complete ==="
    print_color "$YELLOW" "Note: PATH modifications in your shell config were not removed"
    local shell_config
    shell_config=$(get_shell_config)
    print_color "$YELLOW" "You may want to manually remove the PATH export from $shell_config"
}

# Parse command line arguments
for arg in "$@"; do
    case "$arg" in
        --verbose|-v)
            VERBOSE=true
            print_verbose "Verbose mode enabled"
            ;;
        --upgrade|-U)
            UPGRADE=true
            ;;
    esac
done

case "${1:-}" in
    --uninstall|-u)
        uninstall
        ;;
    --verbose|-v)
        # If only --verbose is passed, run main
        if [ $# -eq 1 ]; then
            main
        fi
        ;;
    --upgrade|-U)
        # Run main in upgrade mode
        main
        ;;
    --help|-h)
        echo "AI-Aligned-Git Installer"
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h      Show this help message"
        echo "  --verbose, -v   Enable verbose output"
        echo "  --upgrade, -U   Upgrade existing installation"
        echo "  --uninstall, -u Uninstall AI-Aligned-Git"
        echo "  (no options)    Install AI-Aligned-Git"
        echo ""
        echo "Examples:"
        echo "  $0              # Install normally"
        echo "  $0 --verbose    # Install with detailed output"
        echo "  $0 -v           # Same as --verbose"
        echo "  $0 --upgrade    # Upgrade existing installation"
        echo "  $0 --uninstall  # Remove AI-Aligned-Git"
        ;;
    *)
        main
        ;;
esac