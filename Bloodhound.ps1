function BloodHound {
    param (
        [string]$folder
    )

    $basePath = "D:/stuff/projects"

    if (Test-Path "$basePath/$folder") {
        Set-Location "$basePath/$folder"
    }
    else {
        $closestMatch = Get-ChildItem -Path $basePath -Directory | Where-Object {
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
                Set-Location $basePath
            }
        }
        else {
            Write-Host "Couldn't find $folder."
            Write-Host "Defaulting to project root."
            Set-Location $basePath
        }
    }
        Get-ChildItem
    }