#!/usr/bin/sh

set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

SCRIPT_LOCATION="$SCRIPT_DIR/LinuxFiles/Scripts"

#make sure apt-get is installed
command -v apt-get > /dev/null || { echo "apt-get is required to run this script."; exit 1; }

# Install all the commands from apt
sudo apt-get update
sudo apt install -y fish neovim zip build-essential curl

# Set fish and neovim as the defaults
chsh -s "$(command -v fish)"
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

# exec fish
