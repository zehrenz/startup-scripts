param(
    [Parameter(position=0)][string]$Mode
)

# install new powershell
winget install --id Microsoft.Powershell --source winget

# run install script in new powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
pwsh .\WindowsFiles\install.ps1 $Mode