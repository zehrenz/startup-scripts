param(
    [Parameter(position = 0)][string]$Mode
)

# Make this script run from it's own directory
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir

$profile_location = ".\profile.ps1"
$modules_location = ".\Modules"

$mode_home = "home"
$mode_work = "work"

Function Assign-Mode {
    param([Parameter(Position = 0)][string] $mode)
    if (($null -eq $mode) -or ($mode -eq "")) {
        return $null
    }
    if (($mode -eq "work") -or ($mode -eq "w")) {
        return $mode_work
    }
    elseif (($mode -eq "home") -or ($mode -eq "h")) {
        return $mode_home
    }
    else {
        & { Write-Host "[$mode] is not a valid Mode" }
        return $null
    }
}

$installMode = Assign-Mode $Mode
while ($null -eq $installMode) {
    $Mode = Read-Host -Prompt "Is this for work or home"
    $installMode = Assign-Mode $Mode
}

# Install posh-git if not already installed
if (-not (Get-Module -ListAvailable -Name posh-git)) {
    PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
}

# Install ps-dotenv if not already installed
if (-not (Get-Module -ListAvailable -Name Dotenv)) {
    $dotenvZip = Join-Path $env:TEMP "Dotenv.zip"
    $moduleDestination = $env:PSModulePath.Split(";")[0]
    Invoke-WebRequest -Uri "https://github.com/insomnimus/ps-dotenv/releases/latest/download/Dotenv.zip" -OutFile $dotenvZip
    Expand-Archive -Path $dotenvZip -DestinationPath $moduleDestination -Force
    Remove-Item $dotenvZip
}

# Install the profile
if (Test-Path $profile_location -PathType Leaf) {
    if (-not (Test-Path $PROFILE -PathType Leaf)) {
        New-Item $PROFILE -ItemType File -Force 1> $null
        Copy-Item $profile_location $PROFILE 1> $null
    }
}
else {
    Write-Output "Could not find $profile_location"
}

# Copy .gitconfig if one isn't already in place
$gitconfigDest = Join-Path $HOME ".gitconfig"
if (-not (Test-Path $gitconfigDest -PathType Leaf)) {
    Copy-Item -Path "..\CommonFiles\git\.gitconfig" -Destination $gitconfigDest
}

# Install any modules in ./WindowsFiles/Modules
if (Test-Path $modules_location -PathType Container) {
    $module_destination = $env:PSModulePath.Split(";")[0]
    New-Item $module_destination -ItemType Directory -Force 1> $null
    Copy-Item -Path "$modules_location\*" -Destination $module_destination -Recurse
    Unblock-File -Path "$module_destination\*"
}

# Run other install packages
pwsh ../CommonFiles/VSCode/install.ps1

# Install other winget modules
$wingetPackages = @(
    # For all machines
    "Microsoft.VisualStudioCode",
    "Microsoft.PowerToys"
)

if ($installMode -eq $mode_home) {
    $wingetPackages += @(
        # On personal machines only
        "Discord.Discord",
        "Valve.Steam"
    )
}
elseif ($installMode -eq $mode_work) {
    $wingetPackages += @(
        # On work machines only
    )
}
foreach ($package in $wingetPackages) {
    winget install -e --id $package --accept-source-agreements --accept-package-agreements --source winget
}