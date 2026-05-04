# Make this script run from it's own directory
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir

winget install Microsoft.VisualStudioCode

# Ensure code is available in path
refreshpath

# Copy over the settings.json
$settingsPath = "$env:APPDATA\Code\User\settings.json"
if(Test-Path $settingsPath -PathType Leaf){
    New-Item $settingsPath -Type File -Force
}
Copy-Item -Path ./settings.json -Destination $settingsPath -Force 1> $null

# Install extensions
code --install-extension vscodevim.vim
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension bierner.markdown-preview-github-styles
code --install-extension bierner.markdown-mermaid
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension esbenp.prettier-vscode
code --install-extension eamodio.gitlens
code --install-extension streetsidesoftware.code-spell-checker