param (
    [string]$Flavor = "all",
    [string]$Note = "",
    [string]$CommitMessage = "",
    [switch]$BumpVersion,
    [switch]$Auto,
    [switch]$DryRun
)

# Configuration
$pubspecPath = "pubspec.yaml"
$validFlavors = @("winit", "perks", "swag", "codblox", "crypto")

# --- Helper Functions ---

function Get-PubspecVersion {
    $content = Get-Content $pubspecPath
    foreach ($line in $content) {
        if ($line -match "^version:\s*(.+)") {
            return $matches[1]
        }
    }
    return $null
}

function Set-PubspecVersion {
    param ([string]$newVersion)
    $content = Get-Content $pubspecPath -Encoding UTF8
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

function Get-GitChangedFiles {
    # 1. Try to get localized changes (staged and unstaged)
    $status = git status --porcelain
    $files = @()
    foreach ($line in $status) {
        if ($line.Length -gt 3) {
            $files += $line.Substring(3).Trim()
        }
    }

    # 2. If no local changes, check the last commit
    if ($files.Count -eq 0) {
        Write-Host "  No uncommitted changes. Checking last commit..." -ForegroundColor DarkGray
        $diff = git diff --name-only HEAD~1 HEAD
        foreach ($line in $diff) {
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                $files += $line.Trim()
            }
        }
    }

    return $files
}

function Get-LastCommitMessage {
    $msg = git log -1 --pretty=%B
    if ($msg) { return $msg.Trim() }
    return $null
}

function Get-SmartScope {
    param ([string[]]$changedFiles)
    
    $scope = @()
    $isGlobal = $false

    foreach ($file in $changedFiles) {
        # Global paths
        if ($file -match "^lib/" -or $file -match "^pubspec.yaml" -or $file -match "^assets/images/") {
            $isGlobal = $true
            break 
        }
        
        # Specific paths
        if ($file -match "android/app/src/winit" -or $file -match "assets/winit") { if ($scope -notcontains "winit") { $scope += "winit" } }
        if ($file -match "android/app/src/perks" -or $file -match "assets/perks") { if ($scope -notcontains "perks") { $scope += "perks" } }
        if ($file -match "android/app/src/swag" -or $file -match "assets/swag") { if ($scope -notcontains "swag") { $scope += "swag" } }
        if ($file -match "android/app/src/codblox" -or $file -match "assets/codblox") { if ($scope -notcontains "codblox") { $scope += "codblox" } }
        if ($file -match "android/app/src/crypto" -or $file -match "assets/crypto") { if ($scope -notcontains "crypto") { $scope += "crypto" } }
    }

    if ($isGlobal -or ($scope.Count -eq 0 -and $changedFiles.Count -gt 0)) {
        return "all"
    } elseif ($scope.Count -gt 0) {
        return $scope
    } else {
        return "all" # Default to all if analysis fails but logic implies changes
    }
}

# --- Main Logic ---

Write-Host "Build Manager v2.1 (Smart Git Integration)" -ForegroundColor Cyan

# 0. Auto-Detection Logic
if ($Auto) {
    Write-Host "Analyzing Git changes..." -ForegroundColor Gray
    $changedFiles = Get-GitChangedFiles
    
    if ($changedFiles.Count -eq 0) {
        Write-Warning "No changes detected in Git (Local or Last Commit). Nothing to process."
        exit 0
    }

    Write-Host "Detected changes in:" -ForegroundColor Gray
    $changedFiles | ForEach-Object { Write-Host "  - $_" }

    $detectedScope = Get-SmartScope -changedFiles $changedFiles
    
    $Flavor = $detectedScope
    Write-Host "Detected Build Scope: $Flavor" -ForegroundColor Yellow

    # Determine Note automatically if not provided
    if (-not $Note -and -not $CommitMessage) {
        $Note = Get-LastCommitMessage
        if (-not $Note) {
            Write-Error "Could not auto-detect commit message. Please provide -Note or -CommitMessage."
            exit 1
        }
        Write-Host "Auto-Detected Note: $Note" -ForegroundColor Cyan
    } elseif ($CommitMessage) {
        $Note = $CommitMessage
    }
}

if (-not $Note) {
    Write-Error "Note is required."
    exit 1
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
    Write-Host "Current Version: $currentVersionStr" -ForegroundColor Gray
}

# Parse Version Name and Build Number for Notes Header
if ($currentVersionStr -match "(\d+\.\d+\.\d+)\+(\d+)") {
    $vName = $matches[1]
    $vBuild = $matches[2]
    $headerVersion = "v$vName ($vBuild)"
} else {
    $headerVersion = "v$currentVersionStr"
}

# 2. Determine Flavors to Process
$flavorsToProcess = @()
if ($Flavor -contains "all") {
    $flavorsToProcess = $validFlavors
} else {
    # flavor can be an array/list
    foreach ($f in $Flavor) {
        if ($validFlavors -contains $f) {
            $flavorsToProcess += $f
        } else {
            Write-Warning "Skipping invalid flavor: $f"
        }
    }
}

if ($flavorsToProcess.Count -eq 0) {
    Write-Error "No valid flavors to process."
    exit 1
}

# 3. Process Each Flavor
foreach ($f in $flavorsToProcess) {
    Write-Host "`nProcessing Flavor: $f" -ForegroundColor Green
    
    # Try to find the file using wildcard
    $noteFilePattern = "Notas Versi*n_$f.txt"
    $files = Get-ChildItem -Path . -Filter $noteFilePattern
    if ($files.Count -eq 0) {
        Write-Warning "File pattern $noteFilePattern not found. Skipping notes update."
        continue
    }
    $noteFile = $files[0].Name
    Write-Host "  Found file: $noteFile" -ForegroundColor Gray

    # Read existing notes
    $notesContent = Get-Content $noteFile -Raw
    $newNoteEntry = "- $Note"
    
    # Check if header exists
    if ($notesContent.Trim().StartsWith($headerVersion)) {
        Write-Host "  Header $headerVersion exists. Appending note." -ForegroundColor Gray
        $firstLineEnd = $notesContent.IndexOf("`n")
        if ($firstLineEnd -ge 0) {
                # Ensure we handle \r\n vs \n
                $rest = $notesContent.Substring($firstLineEnd)
                if ($rest.StartsWith("`n") -or $rest.StartsWith("`r`n")) {
                     # normalize
                }
                $updatedContent = $notesContent.Substring(0, $firstLineEnd) + "`n" + $newNoteEntry + $rest
        } else {
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
        & flutter build appbundle --flavor $f
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Build failed for $f"
            # exit $LASTEXITCODE # Optional: Stop or continue
        }
    } else {
        Write-Host "  [DryRun] Would execute: $buildSpec" -ForegroundColor DarkGray
    }
}

Write-Host "`nDone." -ForegroundColor Green
