Import-Module Dotenv
Import-Module posh-git
Enable-Dotenv

Function prompt {
    if(Test-Path function:/Update-Dotenv) { Dotenv\Update-Dotenv }
    $currentDrive = $pwd.drive.name
    $currentFolder = Split-Path -path $pwd -Leaf
    try {
        $gitRootPath = git rev-parse --show-toplevel
        $gitdir = Split-Path -Path $gitRootPath -Leaf
        
        # Calculate relative path from git root to current directory
        $relativePath = Resolve-Path -Path $pwd -Relative -RelativeBasePath $gitRootPath
        $pathParts = $relativePath -split '\\'
        # Remove empty parts and current directory marker
        $pathParts = $pathParts | Where-Object { $_ -ne "" -and $_ -ne "." }
        $depthFromRoot = $pathParts.Count - 1
    }catch{
        $gitdir = ""
        $depthFromRoot = 0
    }
    Write-Host "[$currentDrive`:]" -ForegroundColor DarkGreen -NoNewline
    if($gitdir -ne  "") {
        Write-Host " $gitdir`:$(git branch --show-current)" -ForegroundColor Magenta -NoNewline
    }
    if ($gitdir -ne $currentFolder){
        if ($depthFromRoot -gt 0) {
            Write-Host " $depthFromRoot/$currentFolder" -ForegroundColor DarkCyan -NoNewline
        } else {
            Write-Host " $currentFolder" -ForegroundColor DarkCyan -NoNewline
        }
    }
    return "> "
}

new-alias -Name np -Value notepad
# --General functions
Function prof { code $PROFILE }
Function admin { Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit", "-Command", "Set-Location '$PWD'"}
function refreshpath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}
Function wslrestart { Get-Service vmcompute | Restart-Service }
Function w {wsl ~}
Function e {explorer .}
Function c {
    param ($filepath)
    if ($null -eq $filepath) {
        code .
    }
    else {
        code $filepath
    }
}
Function which {
    param ($command)
    (Get-Command $command).Path
}
Function la {
    Get-ChildItem -Force
}
Function findenv {
    param (
        [string]$name
    )
    dir env: | findstr $name
}

# --Git
Function gtop { cd $(git rev-parse --show-toplevel)}
Function gph { git push $Args }
Function gpl { git pull $Args }
Function gf { git fetch $Args }
Function gs { git status --short $Args }
Function gas { git add * $Args }
Remove-Alias -Name gc -Force
Function gc {git checkout @Args }
Remove-Alias -Name gcb -Force
Function gcp {
    param ([string]$branch);
    gc $branch && gpl
}
Function gcb { git checkout -b @Args }
Remove-Alias -Name gcm -Force
Function gcm { git commit -m @Args }
Function gcam { git add * && git commit -m @Args }
Function gca { git commit --amend --no-edit }
Function gcaa { gas && gca }
Function gbclean {
    param(
        [string[]] $ignore = @(),
        [Alias('a')][switch]$All
    )
    $ignore += @("dev", "qa", "prod", "main")
    if($All){
        $branches = git branch
    } else {
        $branches = git branch --merged
    }
    foreach ($branch in $branches) {
        if ($branch -match '\*') { continue }
        if ($ignore -match $branch.Trim()) { continue }
        git branch -D $branch.Trim()
    }
}
Function gblist { git branch --list $Args }
Function glog { git log --graph --oneline --decorate }
Function gr {
    param(
        [Parameter(Mandatory=$True)][int]$distance
    )
    git rebase HEAD~$distance
}
Function gri {
    param(
        [Parameter(Mandatory=$True)][int]$distance
    )
    git rebase -i HEAD~$distance
}
Function grom {
    git fetch && git rebase origin/main
}
Function gsm {
    git switch -
}

# --Docker
$defaultProfile = 'local'
Function dockerstop { docker stop $(docker ps -a -q) }
# Connect to postgress. Replace variables before use
# Function dpsql {docker exec -e PGPASSWORD=<password> -it $(docker ps -q) psql -U <database-user> -d <database-name>}

# --Python
Function pm { python -m $Args }
Function pt { 
    param(
        [string] $filepath = '.',
        [parameter(position = 1, ValueFromRemainingArguments=$true)] $Remaining
    )
    python -m pytest $filepath $Remaining
}

refreshpath
