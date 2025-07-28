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
    if grep -q "export PATH.*$dir" "$config_file" 2>/dev/null; then
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
    
    # Check if git wrapper already exists
    if [ -f "$dest_path" ]; then
        print_color $YELLOW "⚠ Git wrapper already exists at $dest_path"
        if ! prompt_yes_no "Do you want to overwrite it? [y/N] " "n"; then
            print_color $YELLOW "Installation cancelled"
            return 1
        fi
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

# Function to verify installation
verify_installation() {
    print_color $BLUE "Verifying installation..."
    
    local wrapper_path="$INSTALL_DIR/$SCRIPT_NAME"
    
    # Check if wrapper exists and is executable
    if [ ! -x "$wrapper_path" ]; then
        print_color $RED "✗ Git wrapper not found or not executable at $wrapper_path"
        return 1
    fi
    
    # Check if wrapper is in PATH
    if ! is_in_path "$INSTALL_DIR"; then
        print_color $YELLOW "⚠ $INSTALL_DIR is not in current PATH"
        print_color $YELLOW "  You may need to restart your shell or run:"
        local shell_name=$(detect_shell)
        case "$shell_name" in
            fish)
                print_color $YELLOW "  source $(get_shell_config)"
                ;;
            *)
                print_color $YELLOW "  source $(get_shell_config)"
                ;;
        esac
    else
        # Check if our wrapper will be found first
        local which_git=$(which git 2>/dev/null)
        if [ "$which_git" = "$wrapper_path" ]; then
            print_color $GREEN "✓ AI-Aligned-Git wrapper will be used by default"
        else
            print_color $YELLOW "⚠ System git at $which_git will be used instead of wrapper"
            print_color $YELLOW "  Make sure $INSTALL_DIR comes before $(dirname "$which_git") in PATH"
        fi
    fi
    
    print_color $GREEN "✓ Installation verified"
    return 0
}

# Main installation function
main() {
    print_color $BLUE "=== AI-Aligned-Git Installer ==="
    echo
    
    # Check prerequisites
    if ! check_git_installed; then
        exit 1
    fi
    
    # Ensure installation directory exists
    if ! ensure_install_dir; then
        exit 1
    fi
    
    # Check PATH
    if ! is_in_path "$INSTALL_DIR"; then
        print_color $YELLOW "⚠ $INSTALL_DIR is not in PATH"
        local shell_config=$(get_shell_config)
        if prompt_yes_no "Do you want to add it to $shell_config? [Y/n] " "y"; then
            add_to_path "$INSTALL_DIR" "$shell_config"
        else
            print_color $YELLOW "⚠ You'll need to manually add $INSTALL_DIR to your PATH"
        fi
    else
        print_color $GREEN "✓ $INSTALL_DIR is already in PATH"
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