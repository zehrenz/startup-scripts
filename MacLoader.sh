#!/bin/sh

set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

SCRIPT_LOCATION="$SCRIPT_DIR/LinuxFiles/Scripts"

# Make sure brew is installed
command -v brew > /dev/null || { echo "Homebrew is required to run this script. Install from https://brew.sh"; exit 1; }

# Install packages only if not already installed
install_if_missing() {
    local package=$1
    if ! brew list "$package" &> /dev/null; then
        echo "Installing $package..."
        yes | brew install "$package"
    else
        echo "$package is already installed"
    fi
}

# Update brew
brew update

# Install all required packages
install_if_missing fish
install_if_missing neovim
install_if_missing curl
install_if_missing direnv
install_if_missing zoxide
install_if_missing visual-studio-code

# Set fish as the default shell if not already set
if [ "$SHELL" != "$(command -v fish)" ]; then
    echo "Setting fish as default shell..."
    FISH_PATH="$(command -v fish)"
    
    # Add fish to /etc/shells if not already there
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "Adding $FISH_PATH to /etc/shells..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    
    chsh -s "$FISH_PATH"
else
    echo "fish is already the default shell"
fi

# Set SELECTED_EDITOR
echo "SELECTED_EDITOR=\"$(command -v nvim)\"" > "$HOME/.selected_editor"

if test -f "$SCRIPT_DIR/LinuxFiles/LinuxLoader.fish"; then
    fish "$SCRIPT_DIR/LinuxFiles/LinuxLoader.fish"
else
    echo "Missing file '$SCRIPT_DIR/LinuxFiles/LinuxLoader.fish'"
fi

NVIM_CONF="$SCRIPT_DIR/LinuxFiles/config/nvim"
if test -d "$NVIM_CONF"; then
    mkdir -p "$HOME/.config/nvim"
    cp -R "$NVIM_CONF"/. "$HOME/.config/nvim/"
else
    echo "Missing neovim config files"
fi

if test -d "$SCRIPT_LOCATION"; then
    mkdir -p "$HOME/bin"

    for file in "$SCRIPT_LOCATION"/*; do
        test -f "$file" || continue
        cp "$file" "$HOME/bin/"
    done
fi


# Run VSCode setup
if test -f "$SCRIPT_DIR/CommonFiles/VSCode/install_mac.sh"; then
    bash "$SCRIPT_DIR/CommonFiles/VSCode/install_mac.sh"
else
    echo "Missing VSCode install script"
fi

echo "Setup complete!"
