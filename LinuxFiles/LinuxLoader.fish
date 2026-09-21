# Resolve paths from this file so the loader can run from any directory.
set SCRIPT_DIR (dirname (status filename))

# Install the fish config file
if test -f "$SCRIPT_DIR/config.fish"
    mkdir -p "$HOME/.config/fish"
    cp -f "$SCRIPT_DIR/config.fish" "$HOME/.config/fish/config.fish"
end

# Install Homebrew
if not command -q brew; and not test -x /home/linuxbrew/.linuxbrew/bin/brew
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
end
