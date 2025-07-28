#!/bin/bash

# AI-Aligned-Git Installer Script
# Installs the git wrapper to ~/.local/bin
# Supports both local installation and curl | sh

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
REPO_URL="https://github.com/trieloff/ai-aligned-git"
RAW_BASE_URL="https://raw.githubusercontent.com/trieloff/ai-aligned-git/main"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if directory is in PATH
is_in_path() {
    local dir=$1
    [[ ":$PATH:" == *":$dir:"* ]]
}

# Function to detect the user's shell
detect_shell() {
    if [ -n "$SHELL" ]; then
        basename "$SHELL"
    else
        echo "bash"  # Default to bash
    fi
}

# Function to detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Function to get shell config file
get_shell_config() {
    local shell_name=$(detect_shell)
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
    local os_type=$(detect_os)
    local shell_name=$(detect_shell)
    
    print_color $YELLOW "To add $dir to your PATH, follow these instructions:"
    echo
    
    case "$os_type" in
        macos)
            print_color $BLUE "=== macOS Instructions ==="
            echo
            print_color $YELLOW "Option 1: For ALL applications (recommended):"
            print_color $YELLOW "Create a Launch Agent to set PATH system-wide:"
            echo
            print_color $GREEN "  1. Create the plist file:"
            print_color $WHITE "     sudo tee /Library/LaunchDaemons/setpath.plist > /dev/null << 'EOF'"
            print_color $WHITE "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            print_color $WHITE "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
            print_color $WHITE "<plist version=\"1.0\">"
            print_color $WHITE "<dict>"
            print_color $WHITE "  <key>Label</key>"
            print_color $WHITE "  <string>setpath</string>"
            print_color $WHITE "  <key>ProgramArguments</key>"
            print_color $WHITE "  <array>"
            print_color $WHITE "    <string>/bin/launchctl</string>"
            print_color $WHITE "    <string>setenv</string>"
            print_color $WHITE "    <string>PATH</string>"
            print_color $WHITE "    <string>$dir:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>"
            print_color $WHITE "  </array>"
            print_color $WHITE "  <key>RunAtLoad</key>"
            print_color $WHITE "  <true/>"
            print_color $WHITE "</dict>"
            print_color $WHITE "</plist>"
            print_color $WHITE "EOF"
            echo
            print_color $GREEN "  2. Load the Launch Agent:"
            print_color $WHITE "     sudo launchctl load /Library/LaunchDaemons/setpath.plist"
            echo
            print_color $GREEN "  3. Restart your Mac or log out and back in"
            echo
            print_color $YELLOW "Option 2: For terminal only:"
            ;;
        linux)
            print_color $BLUE "=== Linux Instructions ==="
            echo
            print_color $YELLOW "For system-wide PATH (all users):"
            print_color $WHITE "  sudo tee /etc/profile.d/local-bin.sh > /dev/null << 'EOF'"
            print_color $WHITE "export PATH=\"$dir:\$PATH\""
            print_color $WHITE "EOF"
            echo
            print_color $YELLOW "For current user only:"
            ;;
        windows)
            print_color $BLUE "=== Windows (WSL) Instructions ==="
            echo
            print_color $YELLOW "For WSL terminal:"
            ;;
    esac
    
    # Shell-specific instructions
    local config_file=$(get_shell_config)
    case "$shell_name" in
        bash)
            print_color $WHITE "  echo 'export PATH=\"$dir:\$PATH\"' >> $config_file"
            print_color $WHITE "  source $config_file"
            ;;
        zsh)
            print_color $WHITE "  echo 'export PATH=\"$dir:\$PATH\"' >> $config_file"
            print_color $WHITE "  source $config_file"
            ;;
        fish)
            print_color $WHITE "  echo 'set -gx PATH $dir \$PATH' >> $config_file"
            print_color $WHITE "  source $config_file"
            ;;
        *)
            print_color $WHITE "  echo 'export PATH=\"$dir:\$PATH\"' >> ~/.profile"
            print_color $WHITE "  source ~/.profile"
            ;;
    esac
    echo
}

# Function to add directory to PATH in shell config
add_to_path() {
    local dir=$1
    local config_file=$2
    local shell_name=$(detect_shell)
    
    print_color $YELLOW "Adding $dir to PATH in $config_file..."
    
    # Create config file if it doesn't exist
    mkdir -p "$(dirname "$config_file")"
    touch "$config_file"
    
    # Check if PATH export already exists
    if grep -q "export PATH.*$dir" "$config_file" 2>/dev/null || grep -q "set -gx PATH.*$dir" "$config_file" 2>/dev/null; then
        print_color $GREEN "✓ $dir already in PATH configuration"
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
    
    print_color $GREEN "✓ Added $dir to PATH"
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
    print_color $BLUE "Checking for git installation..."
    
    if ! command_exists git; then
        print_color $RED "✗ Git is not installed"
        print_color $YELLOW "Please install git first:"
        case "$(uname -s)" in
            Darwin*)
                print_color $YELLOW "  brew install git"
                ;;
            Linux*)
                if command_exists apt-get; then
                    print_color $YELLOW "  sudo apt-get install git"
                elif command_exists yum; then
                    print_color $YELLOW "  sudo yum install git"
                elif command_exists pacman; then
                    print_color $YELLOW "  sudo pacman -S git"
                fi
                ;;
        esac
        return 1
    fi
    
    local git_version=$(git --version | awk '{print $3}')
    print_color $GREEN "✓ Git version $git_version found"
    return 0
}

# Function to create ~/.local/bin if it doesn't exist
ensure_install_dir() {
    print_color $BLUE "Checking installation directory..."
    
    if [ ! -d "$INSTALL_DIR" ]; then
        print_color $YELLOW "Creating $INSTALL_DIR..."
        mkdir -p "$INSTALL_DIR"
        if [ $? -eq 0 ]; then
            print_color $GREEN "✓ Created $INSTALL_DIR"
        else
            print_color $RED "✗ Failed to create $INSTALL_DIR"
            return 1
        fi
    else
        print_color $GREEN "✓ $INSTALL_DIR exists"
    fi
    
    # Check if directory is writable
    if [ ! -w "$INSTALL_DIR" ]; then
        print_color $RED "✗ $INSTALL_DIR is not writable"
        return 1
    fi
    
    print_color $GREEN "✓ $INSTALL_DIR is writable"
    return 0
}

# Function to download file
download_file() {
    local url=$1
    local output=$2
    
    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -q "$url" -O "$output"
    else
        print_color $RED "✗ Neither curl nor wget found. Please install one of them."
        return 1
    fi
}

# Function to install the script
install_script() {
    local dest_path="$INSTALL_DIR/$SCRIPT_NAME"
    local temp_file
    
    print_color $BLUE "Installing AI-Aligned-Git..."
    
    # Check if git wrapper already exists
    if [ -f "$dest_path" ]; then
        print_color $YELLOW "⚠ Git wrapper already exists at $dest_path"
        if ! prompt_yes_no "Do you want to overwrite it? [y/N] " "n"; then
            print_color $YELLOW "Installation cancelled"
            return 1
        fi
    fi
    
    # Check if we're running from a local checkout or via curl
    if [ -t 0 ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/$SOURCE_SCRIPT" ]; then
        # Local installation
        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local source_path="$script_dir/$SOURCE_SCRIPT"
        
        if [ ! -f "$source_path" ]; then
            print_color $RED "✗ Source script not found: $source_path"
            return 1
        fi
        
        # Copy the script
        cp "$source_path" "$dest_path"
    else
        # Remote installation via curl | sh
        print_color $YELLOW "Downloading executable_git from GitHub..."
        temp_file=$(mktemp)
        
        if ! download_file "$RAW_BASE_URL/$SOURCE_SCRIPT" "$temp_file"; then
            print_color $RED "✗ Failed to download executable_git"
            rm -f "$temp_file"
            return 1
        fi
        
        # Move to destination
        mv "$temp_file" "$dest_path"
    fi
    
    if [ $? -ne 0 ]; then
        print_color $RED "✗ Failed to install script"
        return 1
    fi
    
    # Make it executable
    chmod +x "$dest_path"
    if [ $? -ne 0 ]; then
        print_color $RED "✗ Failed to make script executable"
        return 1
    fi
    
    print_color $GREEN "✓ Installed git wrapper to $dest_path"
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
    
    # Find which git would be used
    local which_git=$(which git 2>/dev/null)
    
    # If wrapper is already the default, we're good
    if [ "$which_git" = "$wrapper_path" ]; then
        return 0
    fi
    
    # Check if any system git location comes before our install dir in PATH
    local IFS=:
    local path_dirs=($PATH)
    local install_dir_index=-1
    local system_git_index=-1
    
    # Find index of our install dir in PATH
    for i in "${!path_dirs[@]}"; do
        if [ "${path_dirs[$i]}" = "$INSTALL_DIR" ]; then
            install_dir_index=$i
            break
        fi
    done
    
    # Find index of system git in PATH
    for location in "${system_git_locations[@]}"; do
        if [ -x "$location" ]; then
            local git_dir=$(dirname "$location")
            for i in "${!path_dirs[@]}"; do
                if [ "${path_dirs[$i]}" = "$git_dir" ]; then
                    if [ $system_git_index -eq -1 ] || [ $i -lt $system_git_index ]; then
                        system_git_index=$i
                    fi
                fi
            done
        fi
    done
    
    # If install dir not in PATH, it needs to be added
    if [ $install_dir_index -eq -1 ]; then
        return 1
    fi
    
    # If system git found and comes before our install dir, we have a problem
    if [ $system_git_index -ne -1 ] && [ $system_git_index -lt $install_dir_index ]; then
        return 2
    fi
    
    return 0
}

# Function to verify installation
verify_installation() {
    print_color $BLUE "Verifying installation..."
    
    local wrapper_path="$INSTALL_DIR/$SCRIPT_NAME"
    
    # Check if wrapper exists and is executable
    if [ ! -x "$wrapper_path" ]; then
        print_color $RED "✗ Git wrapper not found or not executable at $wrapper_path"
        return 1
    fi
    
    # Check PATH precedence
    check_path_precedence
    local precedence_result=$?
    
    case $precedence_result in
        0)
            print_color $GREEN "✓ AI-Aligned-Git wrapper will be used by default"
            ;;
        1)
            print_color $YELLOW "⚠ $INSTALL_DIR is not in current PATH"
            print_color $YELLOW "  You need to restart your shell or run:"
            print_color $YELLOW "  source $(get_shell_config)"
            ;;
        2)
            local which_git=$(which git 2>/dev/null)
            print_color $RED "✗ System git at $which_git has PATH precedence over wrapper"
            print_color $RED "  $INSTALL_DIR must come BEFORE $(dirname "$which_git") in PATH"
            print_color $YELLOW ""
            print_color $YELLOW "  To fix this, edit your shell config and ensure ~/.local/bin comes first:"
            local shell_name=$(detect_shell)
            case "$shell_name" in
                fish)
                    print_color $YELLOW "  set -gx PATH ~/.local/bin $PATH"
                    ;;
                *)
                    print_color $YELLOW "  export PATH=\"~/.local/bin:\$PATH\""
                    ;;
            esac
            return 1
            ;;
    esac
    
    print_color $GREEN "✓ Installation verified"
    return 0
}

# Main installation function
main() {
    print_color $BLUE "=== AI-Aligned-Git Installer ==="
    echo
    print_color $YELLOW "This installer will:"
    print_color $YELLOW "  • Install the git wrapper to ~/.local/bin/git"
    print_color $YELLOW "  • Ensure ~/.local/bin is in your PATH"
    print_color $YELLOW "  • Verify the wrapper will intercept git commands"
    echo
    
    if ! prompt_yes_no "Do you want to continue? [Y/n] " "y"; then
        print_color $YELLOW "Installation cancelled."
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
        print_color $YELLOW "⚠ $INSTALL_DIR is not in PATH"
        echo
        local shell_config=$(get_shell_config)
        local os_type=$(detect_os)
        
        if [ "$os_type" = "macos" ]; then
            print_color $YELLOW "On macOS, you should configure PATH system-wide for GUI applications."
            show_path_instructions "$INSTALL_DIR"
            echo
            if prompt_yes_no "Would you like to add it to $shell_config for terminal use? [Y/n] " "y"; then
                add_to_path "$INSTALL_DIR" "$shell_config"
                print_color $YELLOW "⚠ Note: This only affects terminal sessions. For GUI apps, use the launchctl method above."
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
        print_color $GREEN "✓ $INSTALL_DIR is already in PATH"
        
        # Check if it has proper precedence
        check_path_precedence
        local precedence_result=$?
        
        if [ $precedence_result -eq 2 ]; then
            local which_git=$(which git 2>/dev/null)
            print_color $RED "✗ WARNING: System git at $which_git has PATH precedence"
            print_color $RED "  The AI-aligned git wrapper will NOT work until you fix your PATH"
            print_color $YELLOW ""
            print_color $YELLOW "  Your current PATH order will use system git instead of the wrapper."
            print_color $YELLOW "  To fix: ensure ~/.local/bin comes BEFORE $(dirname "$which_git") in PATH"
            echo
            if ! prompt_yes_no "Continue installation anyway? [y/N] " "n"; then
                print_color $YELLOW "Installation cancelled. Please fix your PATH first."
                exit 1
            fi
        fi
    fi
    
    # Final confirmation before installing
    echo
    print_color $BLUE "Ready to install AI-Aligned-Git"
    if ! prompt_yes_no "Proceed with installation? [Y/n] " "y"; then
        print_color $YELLOW "Installation cancelled."
        exit 0
    fi
    
    # Install the script
    if ! install_script; then
        exit 1
    fi
    
    # Verify installation
    verify_installation
    
    echo
    print_color $GREEN "=== Installation Complete ==="
    print_color $BLUE "AI-Aligned-Git has been installed successfully!"
    echo
    print_color $YELLOW "Next steps:"
    if ! is_in_path "$INSTALL_DIR"; then
        print_color $YELLOW "1. Reload your shell configuration:"
        local shell_name=$(detect_shell)
        case "$shell_name" in
            fish)
                print_color $YELLOW "   source $(get_shell_config)"
                ;;
            *)
                print_color $YELLOW "   source $(get_shell_config)"
                ;;
        esac
        print_color $YELLOW "   Or start a new terminal session"
        echo
    fi
    print_color $YELLOW "2. Verify the wrapper is working:"
    print_color $YELLOW "   which git"
    print_color $YELLOW "   (Should show: $INSTALL_DIR/git)"
    echo
    print_color $YELLOW "3. Test with an AI tool like Claude"
    echo
    print_color $BLUE "To uninstall, run:"
    print_color $BLUE "  rm ~/.local/bin/git"
}

# Uninstall function
uninstall() {
    print_color $BLUE "=== AI-Aligned-Git Uninstaller ==="
    echo
    
    local wrapper_path="$INSTALL_DIR/$SCRIPT_NAME"
    
    if [ -f "$wrapper_path" ]; then
        print_color $YELLOW "Removing git wrapper..."
        rm -f "$wrapper_path"
        if [ $? -eq 0 ]; then
            print_color $GREEN "✓ Removed $wrapper_path"
        else
            print_color $RED "✗ Failed to remove $wrapper_path"
            exit 1
        fi
    else
        print_color $YELLOW "Git wrapper not found at $wrapper_path"
    fi
    
    echo
    print_color $GREEN "=== Uninstall Complete ==="
    print_color $YELLOW "Note: PATH modifications in your shell config were not removed"
    print_color $YELLOW "You may want to manually remove the PATH export from $(get_shell_config)"
}

# Parse command line arguments
case "${1:-}" in
    --uninstall|-u)
        uninstall
        ;;
    --help|-h)
        echo "AI-Aligned-Git Installer"
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h      Show this help message"
        echo "  --uninstall, -u Uninstall AI-Aligned-Git"
        echo "  (no options)    Install AI-Aligned-Git"
        ;;
    *)
        main
        ;;
esac