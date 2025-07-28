.PHONY: help shellcheck install-shellcheck

# Default target
help:
	@echo "Available targets:"
	@echo "  shellcheck        - Run shellcheck on all shell scripts"
	@echo "  install-shellcheck - Install shellcheck (requires sudo)"

# Find all shell scripts in the repository
SHELL_SCRIPTS := $(shell find . -name "*.sh" -o -name "executable_git" -type f | grep -v node_modules)

# Run shellcheck on all shell scripts
shellcheck:
	@echo "Running shellcheck on shell scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		for script in $(SHELL_SCRIPTS); do \
			echo "Checking $$script..."; \
			shellcheck -x $$script || exit 1; \
		done; \
		echo "All shell scripts passed shellcheck!"; \
	else \
		echo "Error: shellcheck is not installed."; \
		echo "Run 'make install-shellcheck' to install it."; \
		exit 1; \
	fi

# Install shellcheck
install-shellcheck:
	@echo "Installing shellcheck..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		if command -v brew >/dev/null 2>&1; then \
			brew install shellcheck; \
		else \
			echo "Error: Homebrew is not installed. Please install Homebrew first."; \
			exit 1; \
		fi \
	elif [ "$$(uname)" = "Linux" ]; then \
		if command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get update && sudo apt-get install -y shellcheck; \
		elif command -v yum >/dev/null 2>&1; then \
			sudo yum install -y shellcheck; \
		elif command -v dnf >/dev/null 2>&1; then \
			sudo dnf install -y shellcheck; \
		elif command -v pacman >/dev/null 2>&1; then \
			sudo pacman -S --noconfirm shellcheck; \
		else \
			echo "Error: No supported package manager found."; \
			echo "Please install shellcheck manually: https://github.com/koalaman/shellcheck#installing"; \
			exit 1; \
		fi \
	else \
		echo "Error: Unsupported operating system."; \
		echo "Please install shellcheck manually: https://github.com/koalaman/shellcheck#installing"; \
		exit 1; \
	fi