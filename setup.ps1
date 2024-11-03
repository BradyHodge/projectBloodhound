if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script should be run as administrator. Some operations may fail."
}

$ProfilePath = $PROFILE
$ProfileDir = Split-Path -Path $ProfilePath
$BloodhoundFilePath = Join-Path -Path $ProfileDir -ChildPath "BloodHound.ps1"

if (Test-Path -Path $BloodhoundFilePath) {
    Write-Error "BloodHound has alredy been installed!"
    Write-Output "======================================="
    Write-Warning "If there is a problem with the program, try the manual install instructions."
    Write-Output "You can find them at https://github.com/BradyHodge/projectBloodhound"
    Write-Output "======================================="

    exit
}
if (!(Test-Path -Path $ProfileDir)) {
    try {
        New-Item -ItemType Directory -Path $ProfileDir -Force
        Write-Output "Created PowerShell profile directory at $ProfileDir"
    }
    catch {
        Write-Error "Failed to create PowerShell profile directory: $_"
        exit
    }
}
Write-Output "========== Bloodhound Config =========="

$ProjectDirectory = Read-Host "Where is your project folder? (C:\Users\MyUsername\MyProjects)"
if ([string]::IsNullOrWhiteSpace($ProjectDirectory)) {
    $CurrentDirectory = Get-Location
    Write-Warning "No directory specified. Using current directory: $CurrentDirectory"
    $ProjectDirectory = $CurrentDirectory
}
elseif (!(Test-Path -Path $ProjectDirectory -ErrorAction SilentlyContinue)) {
    $CurrentDirectory = Get-Location
    Write-Warning "Specified directory does not exist. Using current directory: $CurrentDirectory"
    $ProjectDirectory = $CurrentDirectory
}

$BloodhoundAlias = Read-Host "Enter the alias you want for BloodHound" -Default 'bh'
if ([string]::IsNullOrWhiteSpace($BloodhoundAlias) -or $BloodhoundAlias -match '[^\w\-]') {
    Write-Warning "Invalid alias or blank input. Using default."
    $BloodhoundAlias = 'bh'
}

$OpenCode = Read-Host "Automatically open the project folder in VS Code (y/n)" -Default 'y'
if ($OpenCode -notmatch '^[yn]$') {
    Write-Warning "Invalid input. Using default."
    $OpenCode = 'y'
}
Write-Output "(Note: To change any of these values, open $ProfilePath in a text editor.)"

Write-Output "======================================="
$BackupPath = "$ProfilePath.bak"
if (Test-Path -Path $ProfilePath) {
    try {
        Copy-Item -Path $ProfilePath -Destination $BackupPath -Force
        Write-Output "Backup of the profile created at $BackupPath"
    }
    catch {
        Write-Error "Failed to create profile backup: $_"
        exit
    }
}
$BloodhoundConfig = @"
# ========== Bloodhound Config ==========

# ↓ Setup Variables ↓
`$ProjectDirectory = '$ProjectDirectory'
`$BloodhoundAlias = '$BloodhoundAlias'
`$OpenCode = '$OpenCode' # (y/n)
# ↑ Setup Variables ↑

Import-Module -Name `"$BloodhoundFilePath`" -Force
Set-Alias -Name `$BloodhoundAlias -Value BloodHound

# =======================================
"@
try {
    Add-Content -Path $ProfilePath -Value $BloodhoundConfig
    Write-Output "Added BloodHound configuration to profile"
}
catch {
    Write-Error "Failed to update profile: $_"
    exit
}
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/BradyHodge/projectBloodhound/refs/heads/main/Bloodhound.ps1" -OutFile $BloodhoundFilePath
    Write-Output "Successfully downloaded BloodHound.ps1 to $BloodhoundFilePath"
}
catch {
    Write-Error "Failed to download BloodHound.ps1: $_"
    exit
}
try {
    . $PROFILE
    Write-Output "Successfully reloaded profile configuration"
}
catch {
    Write-Warning "Failed to reload profile: $_"
    Write-Output "Please restart your PowerShell session to apply changes"
}

Pause