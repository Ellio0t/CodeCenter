@echo off
REM Wrapper for build_manager.ps1
REM Usage: build [Commit Message] [release]
REM - If no message is provided, it attempts to Auto-Detect it from Git.

set MSG=%~1
set OPTION=%~2

set ARGS=-Auto

if NOT "%MSG%"=="" (
  set ARGS=%ARGS% -CommitMessage "%MSG%"
)

if /I "%OPTION%"=="release" (
  set ARGS=%ARGS% -BumpVersion
)
REM Verify if MSG was actually "release" (argument shifting)
if /I "%MSG%"=="release" (
  set ARGS=-Auto -BumpVersion
)


echo Starting Intelligent Build Process...
if "%MSG%"=="" (
    echo Mode: AUTO-DETECT (Git History)
) else (
    echo Note: "%MSG%"
)

powershell -ExecutionPolicy Bypass -File "%~dp0build_manager.ps1" %ARGS%
