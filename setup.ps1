$ProfilePath = $PROFILE
$ProfileDir = Split-Path -Path $ProfilePath

if (!(Test-Path -Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force
}
`
$ProjectDirectory = Read-Host "Where is your project folder? (C:\Users\MyUsername\MyProjects)" -Default '.\'
$BloodhoundAlias = Read-Host "Enter the alias you want for BloodHound (default is 'bh')" -Default 'bh'
$OpenCode = Read-Host "Automatically open the project folder in VS Code (y/n)" -Default 'True'

$BackupPath = "$ProfilePath.bak"
if (Test-Path -Path $ProfilePath) {
    Copy-Item -Path $ProfilePath -Destination $BackupPath -Force
    Write-Output "Backup of the profile created at $BackupPath"
}

$BloodhoundConfig = @"
# ========== Bloodhound Config ==========

# ↓ Setup Variables ↓
`$ProjectDirectory = '$ProjectDirectory'
`$BloodhoundAlias = '$BloodhoundAlias'
`$OpenCode = '$OpenCode' # (y/n)
# ↑ Setup Variables ↑

Import-Module -Name `"$($ProfileDir)\BloodHound.ps1`" -Force
Set-Alias -Name `$BloodhoundAlias -Value BloodHound

# =======================================
"@

Add-Content -Path $ProfilePath -Value $BloodhoundConfig

$BloodhoundFilePath = Join-Path -Path $ProfileDir -ChildPath "BloodHound.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/BradyHodge/projectBloodhound/refs/heads/main/Bloodhound.ps1" -OutFile $BloodhoundFilePath

Write-Output "Bloodhound configuration added to profile and BloodHound.ps1 downloaded to $ProfileDir"
