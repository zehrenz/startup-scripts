param(
    [Parameter(position=0)][string]$Mode
)

# install new powershell
winget install --id Microsoft.Powershell --source winget

# run install script in new powershell
pwsh -Command "& 'C:\Program Files\PowerShell\7\pwsh.exe' .\WindowsFiles\install.ps1 $Mode"