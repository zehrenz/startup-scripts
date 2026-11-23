#!/bin/sh

set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

echo "Setting up VSCode..."

# Check if brew is available
command -v brew > /dev/null || { echo "Homebrew is required to install VSCode"; exit 1; }

# Install VSCode if not already installed
if ! command -v code &> /dev/null; then
    echo "Installing Visual Studio Code..."
    yes | brew install --cask visual-studio-code
else
    echo "Visual Studio Code is already installed"
fi

# Set up VSCode configuration
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER_DIR"

# Copy settings and keybindings
if test -f "$SCRIPT_DIR/settings.json"; then
    cp "$SCRIPT_DIR/settings.json" "$VSCODE_USER_DIR/settings.json"
    echo "Copied VSCode settings.json"
else
    echo "Missing VSCode settings.json"
fi

if test -f "$SCRIPT_DIR/keybindings.json"; then
    cp "$SCRIPT_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
    echo "Copied VSCode keybindings.json"
else
    echo "Missing VSCode keybindings.json"
fi

# Install VSCode extensions
echo "Installing VSCode extensions..."
EXTENSIONS=(
    "vscodevim.vim"
    "bierner.markdown-preview-github-styles"
    "bierner.markdown-mermaid"
    "DavidAnson.vscode-markdownlint"
    "esbenp.prettier-vscode"
    "eamodio.gitlens"
    "streetsidesoftware.code-spell-checker"
)

for ext in "${EXTENSIONS[@]}"; do
    if code --list-extensions 2>/dev/null | grep -q "^${ext}$"; then
        echo "$ext is already installed"
    else
        echo "Installing $ext..."
        yes | code --install-extension "$ext" 2>/dev/null
    fi
done

echo "VSCode setup complete!"
