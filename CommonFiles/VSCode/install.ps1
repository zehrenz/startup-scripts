# Make this script run from it's own directory
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    winget install Microsoft.VisualStudioCode --source winget
}

# Ensure code is available in path
refreshpath

$vscodeUserDir = "$env:APPDATA\Code\User"
New-Item -ItemType Directory -Path $vscodeUserDir -Force 1> $null

# Copy over the settings.json
Copy-Item -Path ./settings.json -Destination "$vscodeUserDir\settings.json" -Force 1> $null

# Copy over the keybindings.json
Copy-Item -Path ./keybindings.json -Destination "$vscodeUserDir\keybindings.json" -Force 1> $null

# Install extensions
$extensions = @(
    "vscodevim.vim",
    "ms-vscode-remote.remote-wsl",
    "bierner.markdown-preview-github-styles",
    "bierner.markdown-mermaid",
    "DavidAnson.vscode-markdownlint",
    "esbenp.prettier-vscode",
    "eamodio.gitlens",
    "streetsidesoftware.code-spell-checker"
)
foreach ($ext in $extensions) {
    code --install-extension $ext
}