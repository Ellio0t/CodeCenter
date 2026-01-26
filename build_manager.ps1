param (
    [string]$Flavor = "all",
    [string]$Note = "General update",
    [switch]$BumpVersion,
    [switch]$DryRun
)

# Configuration
$pubspecPath = "pubspec.yaml"
$validFlavors = @("winit", "perks", "swag", "codblox", "crypto")

# Helper to read Pubspec Version
function Get-PubspecVersion {
    $content = Get-Content $pubspecPath
    foreach ($line in $content) {
        if ($line -match "^version:\s*(.+)") {
            return $matches[1]
        }
    }
    return $null
}

# Helper to write Pubspec Version
function Set-PubspecVersion {
    param ([string]$newVersion)
    $content = Get-Content $pubspecPath
    $newContent = @()
    foreach ($line in $content) {
        if ($line -match "^version:\s*.+") {
            $newContent += "version: $newVersion"
        } else {
            $newContent += $line
        }
    }
    $newContent | Set-Content $pubspecPath -Encoding UTF8
}

# 1. Handle Version Bumping
$currentVersionStr = Get-PubspecVersion
if ($BumpVersion) {
    if ($currentVersionStr -match "(\d+\.\d+\.\d+)\+(\d+)") {
        $versionName = $matches[1]
        $buildNumber = [int]$matches[2]
        $newBuildNumber = $buildNumber + 1
        $newVersionStr = "$versionName+$newBuildNumber"
        
        Write-Host "Bumping version: $currentVersionStr -> $newVersionStr" -ForegroundColor Cyan
        if (-not $DryRun) {
            Set-PubspecVersion $newVersionStr
            $currentVersionStr = $newVersionStr
        }
    } else {
        Write-Error "Could not parse version format in pubspec.yaml"
        exit 1
    }
} else {
    Write-Host "Current Version: $currentVersionStr (No bump requested)" -ForegroundColor Gray
}

# Parse Version Name and Build Number for Notes
if ($currentVersionStr -match "(\d+\.\d+\.\d+)\+(\d+)") {
    $vName = $matches[1]
    $vBuild = $matches[2]
    $headerVersion = "v$vName ($vBuild)"
} else {
    $headerVersion = "v$currentVersionStr"
}

# 2. Determine Flavors to Process
$flavorsToProcess = @()
if ($Flavor -eq "all") {
    $flavorsToProcess = $validFlavors
} elseif ($validFlavors -contains $Flavor) {
    $flavorsToProcess = @($Flavor)
} else {
    Write-Error "Invalid flavor: $Flavor"
    exit 1
}

# 3. Process Each Flavor
foreach ($f in $flavorsToProcess) {
    Write-Host "`nProcessing Flavor: $f" -ForegroundColor Green
    # Try to find the file using wildcard to avoid encoding mismatch
    $noteFilePattern = "Notas Versi*n_$f.txt"
    $files = Get-ChildItem -Path . -Filter $noteFilePattern
    if ($files.Count -eq 0) {
        Write-Warning "File pattern $noteFilePattern not found (looking for flavor $f). Skipping notes update."
        continue
    }
    $noteFile = $files[0].Name
    Write-Host "  Found file: $noteFile" -ForegroundColor Gray

        # Read existing notes
        $notesContent = Get-Content $noteFile -Raw
        $newNoteEntry = "- $Note"
        
        # Check if the header already exists at the top
        if ($notesContent.Trim().StartsWith($headerVersion)) {
            Write-Host "  Header $headerVersion exists. Appending note." -ForegroundColor Gray
            # Insert after the header line (simple text manipulation)
            # Find first newline
            $firstLineEnd = $notesContent.IndexOf("`n")
            if ($firstLineEnd -ge 0) {
                 # It has multiple lines
                 $updatedContent = $notesContent.Substring(0, $firstLineEnd) + "`n" + $newNoteEntry + $notesContent.Substring($firstLineEnd)
            } else {
                 # Single line file? Unlikely but handle it
                 $updatedContent = $headerVersion + "`n" + $newNoteEntry
            }
        } else {
            Write-Host "  New version header $headerVersion required." -ForegroundColor Yellow
            $updatedContent = "$headerVersion`n$newNoteEntry`n`n" + $notesContent
        }

        if (-not $DryRun) {
            $updatedContent | Set-Content $noteFile -Encoding UTF8
            Write-Host "  Updated $noteFile" -ForegroundColor White
        } else {
            Write-Host "  [DryRun] Would write to $noteFile" -ForegroundColor DarkGray
        }


    # 4. Build
    $buildSpec = "flutter build appbundle --flavor $f"
    if (-not $DryRun) {
        Write-Host "  Executing: $buildSpec" -ForegroundColor Cyan
        # Invoke-Expression $buildSpec 
        # Using Start-Process to ensure we see output or handle it properly, 
        # but generic Invoke-Expression is arguably simpler for a script wrapper.
        # Let's use direct invocation for simplicity in the shell context.
        & flutter build appbundle --flavor $f
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Build failed for $f"
            # Decide if we stop or continue. Usually stop.
            exit $LASTEXITCODE
        }
    } else {
        Write-Host "  [DryRun] Would execute: $buildSpec" -ForegroundColor DarkGray
    }
}

Write-Host "`nDone." -ForegroundColor Green
