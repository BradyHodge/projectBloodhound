function BloodHound {
    param (
        [string]$folder
    )
    $bypassOpenCode = $false
    if (Test-Path "$ProjectDirectory/$folder") {
        Set-Location "$ProjectDirectory/$folder"
    }
    else {
        $closestMatch = Get-ChildItem -Path $ProjectDirectory -Directory | Where-Object {
            $_.Name -like "*$folder*" -or $_.Name -match $folder
        } | Sort-Object { ($_ -replace '[^a-zA-Z]', '').Length - $_.Name.Length } | Select-Object -First 1

        if ($closestMatch) {
            Write-Host "Couldn't find $folder."
            Write-Host "How about $($closestMatch.Name)? (y/n)"
            $confirmation = Read-Host

            if ($confirmation -eq 'y') {
                Set-Location "$($closestMatch.FullName)"
            }
            else {
                Write-Host "Defaulting to project root."
                Set-Location $ProjectDirectory
                $bypassOpenCode = $true
            }
        }
        else {
            Write-Host "Couldn't find $folder."
            Write-Host "Defaulting to project root."
            Set-Location $ProjectDirectory
        }
    }
    Get-ChildItem
    if ($OpenCode -eq 'y' -and ![string]::IsNullOrEmpty($folder) -and !$bypassOpenCode) {
        code .
    }
}