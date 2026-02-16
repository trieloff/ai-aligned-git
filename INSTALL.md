# Installation Guide for AI-Aligned-Git

This guide provides detailed instructions for installing AI-Aligned-Git on your system.

## Table of Contents
- [Quick Install](#quick-install)
- [Requirements](#requirements)
- [Installation Methods](#installation-methods)
- [PATH Configuration](#path-configuration)
- [Verifying Installation](#verifying-installation)
- [Troubleshooting](#troubleshooting)
- [Uninstalling](#uninstalling)

## Quick Install

The easiest way to install AI-Aligned-Git is using our automated installer:

```bash
curl -fsSL https://raw.githubusercontent.com/trieloff/ai-aligned-git/main/install.sh | sh
```

Or with wget:
```bash
wget -qO- https://raw.githubusercontent.com/trieloff/ai-aligned-git/main/install.sh | sh
```

The installer will:
- Check that git is installed
- Create `~/.local/bin` if it doesn't exist
- Install the git wrapper to `~/.local/bin/git`
- Check if `~/.local/bin` is in your PATH
- Verify the wrapper has precedence over system git

## Requirements

- **Git**: The system git must be installed before installing the wrapper
- **Git 2.32+**: Required for `--trailer` support (released June 2021, widely available)
- **Unix-like OS**: macOS, Linux, or WSL on Windows
- **Shell**: Bash, Zsh, or Fish shell
- **curl or wget**: For the automated installer (or you can clone the repo)

## Installation Methods

### Method 1: Automated Installer (Recommended)

The automated installer handles all configuration for you:

```bash
curl -fsSL https://raw.githubusercontent.com/trieloff/ai-aligned-git/main/install.sh | sh
```

### Method 2: Clone and Install

```bash
# Clone the repository
git clone https://github.com/trieloff/ai-aligned-git.git
cd ai-aligned-git

# Run the installer
./install.sh
```

### Method 3: Manual Installation

If you prefer to install manually:

```bash
# Clone the repository
git clone https://github.com/trieloff/ai-aligned-git.git

# Create ~/.local/bin directory
mkdir -p ~/.local/bin

# Copy and rename the wrapper
cp ai-aligned-git/executable_git ~/.local/bin/git
chmod +x ~/.local/bin/git

# Add ~/.local/bin to PATH (see PATH Configuration below)
```

## PATH Configuration

For the wrapper to work, `~/.local/bin` must be in your PATH **before** the system git location.

### Understanding PATH Precedence

The wrapper intercepts git commands by being found first in your PATH. Common system git locations include:
- `/usr/bin/git`
- `/usr/local/bin/git`
- `/opt/homebrew/bin/git` (macOS with Homebrew)

Your PATH must have `~/.local/bin` listed **before** these directories.

### macOS Configuration

On macOS, there are two ways to configure PATH:

#### Option 1: System-wide (Recommended for GUI apps)

This method ensures all applications (including GUI apps like VS Code) use the wrapper:

1. Create a Launch Agent plist file:
```bash
sudo tee /Library/LaunchDaemons/setpath.plist > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>setpath</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/launchctl</string>
    <string>setenv</string>
    <string>PATH</string>
    <string>/Users/YOUR_USERNAME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF
```

2. Load the Launch Agent:
```bash
sudo launchctl load /Library/LaunchDaemons/setpath.plist
```

3. Restart your Mac or log out and back in

#### Option 2: Terminal only

Add to your shell configuration file:

**For Bash** (`~/.bashrc` or `~/.bash_profile`):
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**For Zsh** (`~/.zshrc`):
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**For Fish** (`~/.config/fish/config.fish`):
```fish
set -gx PATH $HOME/.local/bin $PATH
```

### Linux Configuration

#### System-wide (all users)
Create a file `/etc/profile.d/local-bin.sh`:
```bash
sudo tee /etc/profile.d/local-bin.sh > /dev/null << 'EOF'
export PATH="$HOME/.local/bin:$PATH"
EOF
```

#### User-specific
Add to your shell configuration file (same as macOS terminal configuration above).

### Windows (WSL) Configuration

In WSL, configure your shell the same as Linux user-specific configuration.

## Verifying Installation

After installation, verify everything is working:

1. **Check the wrapper is installed:**
   ```bash
   ls -la ~/.local/bin/git
   ```

2. **Check PATH order:**
   ```bash
   echo $PATH | tr ':' '\n' | grep -n -E "(local/bin|bin/git)"
   ```
   Ensure `~/.local/bin` appears before system git locations.

3. **Check which git will be used:**
   ```bash
   which git
   ```
   This should show `~/.local/bin/git`

4. **Test the wrapper:**
   ```bash
   # Run git to see if the wrapper is active
   git --version
   ```

5. **Test with an AI tool:**
   If you're using Claude, Cursor, or another supported AI tool, try:
   ```bash
   git add .
   ```
   You should see an error message about AI tools needing to add files individually.

## Troubleshooting

### "Git wrapper not being used"

**Symptom**: `which git` shows `/usr/bin/git` instead of `~/.local/bin/git`

**Solution**: 
1. Ensure `~/.local/bin` is in your PATH
2. Ensure it comes BEFORE system directories
3. Reload your shell configuration or start a new terminal

### "PATH changes not taking effect"

**Symptom**: PATH looks correct but wrapper isn't being used

**Solution**:
- On macOS: GUI applications may need system-wide PATH configuration (see macOS Option 1)
- Try logging out and back in
- For immediate effect in current terminal: `source ~/.bashrc` (or appropriate config file)

### "Permission denied"

**Symptom**: Can't create `~/.local/bin` or install the wrapper

**Solution**:
- Ensure you own your home directory: `sudo chown -R $USER:$USER ~/.local`
- Check disk space: `df -h ~`

### "Git not found"

**Symptom**: Installer reports git is not installed

**Solution**:
- macOS: `brew install git`
- Ubuntu/Debian: `sudo apt-get install git`
- Fedora/RHEL: `sudo yum install git`
- Arch: `sudo pacman -S git`

## Uninstalling

### Using the installer:
```bash
./install.sh --uninstall
```

### Manual uninstall:
```bash
rm ~/.local/bin/git
```

Note: PATH modifications in your shell configuration files are not automatically removed. You may want to remove the `export PATH="$HOME/.local/bin:$PATH"` line from your shell config if you added it solely for this tool.

## Getting Help

If you encounter issues not covered here:

1. Check the [GitHub Issues](https://github.com/trieloff/ai-aligned-git/issues)
2. Run the installer with verbose output: `./install.sh --verbose` or `./install.sh -v`
3. Verify your shell and OS are supported

The verbose mode will show:
- Detected OS and shell information
- PATH analysis and precedence checks
- Download progress (when using curl/wget)
- Directory creation and permission details
- Each step of the installation process

Remember: The wrapper must be found in PATH before the system git for it to work correctly!