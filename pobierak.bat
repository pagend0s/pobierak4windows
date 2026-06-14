@echo off
setlocal EnableExtensions EnableDelayedExpansion

pushd "%~dp0"

set "rc=1"
set "ROOT=%~dp0"
set "RES=%ROOT%resources"
set "ERRDIR=%RES%\Error"

if not exist "%ERRDIR%" mkdir "%ERRDIR%"

set "STAMP=%date%_%time%"
set "STAMP=%STAMP::=-%"
set "STAMP=%STAMP:/=-%"
set "STAMP=%STAMP:.=-%"
set "STAMP=%STAMP: =_%"

set "ERRLOG=%ERRDIR%\error_%STAMP%.txt"
set "LATESTLOG=%ERRDIR%\error_latest.txt"

echo ================================================== > "%ERRLOG%"
echo Pobierak launcher started: %date% %time% >> "%ERRLOG%"
echo ROOT=%ROOT% >> "%ERRLOG%"
echo RES=%RES% >> "%ERRLOG%"
echo ERRLOG=%ERRLOG% >> "%ERRLOG%"
echo ================================================== >> "%ERRLOG%"
echo. >> "%ERRLOG%"

copy /Y "%ERRLOG%" "%LATESTLOG%" >nul 2>&1

call :Log "Checking environment"

if not exist "%RES%" (
    call :Log "ERROR: Resources directory does not exist: %RES%"
    goto EXIT
)

if not exist "%RES%\pobierak.ps1" (
    call :Log "ERROR: Missing file: %RES%\pobierak.ps1"
    goto EXIT
)

call :Log "PowerShell version:"
powershell.exe -NoLogo -NoProfile -Command "$PSVersionTable" >> "%ERRLOG%" 2>&1

call :ReadVersion

call :RunScript "MAIN" "%RES%\pobierak.ps1"
set "rc=%ERRORLEVEL%"

if "%rc%"=="0" goto EXIT
if "%rc%"=="3" goto AFTER_UPDATE
if "%rc%"=="1" goto AFTER_ERROR
goto EXIT


:AFTER_ERROR
call :Log "WARN: pobierak.ps1 failed with rc=%rc%. Starting backup..."

if not exist "%RES%\pobierak_bak.ps1" (
    call :Log "ERROR: Missing backup file: %RES%\pobierak_bak.ps1"
    goto EXIT
)

call :RunScript "BACKUP" "%RES%\pobierak_bak.ps1"
set "rc=%ERRORLEVEL%"

if "%rc%"=="0" goto EXIT
if "%rc%"=="3" goto AFTER_UPDATE
if "%rc%"=="1" goto AFTER_ERROR2
goto EXIT


:AFTER_ERROR2
call :Log "WARN: backup failed with rc=%rc%. Starting primary backup..."

if not exist "%RES%\pobierak_primary.ps1" (
    call :Log "ERROR: Missing primary backup file: %RES%\pobierak_primary.ps1"
    goto EXIT
)

call :RunScript "PRIMARY_BACKUP" "%RES%\pobierak_primary.ps1"
set "rc=%ERRORLEVEL%"

if "%rc%"=="0" goto EXIT
if "%rc%"=="3" goto AFTER_UPDATE
goto EXIT


:AFTER_UPDATE
call :Log "INFO: Update flow detected rc=3. Restarting pobierak.ps1..."

call :RunScript "MAIN_AFTER_UPDATE" "%RES%\pobierak.ps1"
set "rc=%ERRORLEVEL%"

if "%rc%"=="0" goto EXIT
if "%rc%"=="3" goto AFTER_UPDATE
if "%rc%"=="1" goto AFTER_ERROR
goto EXIT


:ReadVersion
set "version=unknown"
set "file=%RES%\pobierak.ps1"

for /f "delims=" %%A in ('findstr /I "$pobierak_v" "%file%" 2^>nul') do (
    set "version=%%A"
    goto :ReadVersionDone
)

:ReadVersionDone
call :Log "Detected version line: %version%"
exit /b 0


:RunScript
set "RUNLABEL=%~1"
set "SCRIPT=%~2"

call :Log "=================================================="
call :Log "START %RUNLABEL%"
call :Log "SCRIPT=%SCRIPT%"
call :Log "=================================================="

call :ValidateScript "%SCRIPT%"
set "parse_rc=%ERRORLEVEL%"

if not "%parse_rc%"=="0" (
    call :Log "ERROR: PowerShell parse validation failed for %SCRIPT%"
    exit /b 1
)

rem IMPORTANT:
rem Do NOT redirect stdout here.
rem The menu needs stdout to stay visible in the console.
rem Only stderr is appended to the error log.

powershell.exe -STA -NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -Command ^
    "$ErrorActionPreference='Stop';" ^
    "$log='%ERRLOG%';" ^
    "try {" ^
    "  & '%SCRIPT%';" ^
    "  if ($LASTEXITCODE -ne $null) { exit $LASTEXITCODE } else { exit 0 }" ^
    "} catch {" ^
    "  $msg = @();" ^
    "  $msg += '';" ^
    "  $msg += '===== POWERSHELL FATAL ERROR =====';" ^
    "  $msg += $_.Exception.Message;" ^
    "  $msg += '';" ^
    "  $msg += '===== FULL ERROR =====';" ^
    "  $msg += ($_ | Format-List * -Force | Out-String);" ^
    "  $msg += '';" ^
    "  $msg += '===== SCRIPT STACK TRACE =====';" ^
    "  $msg += $_.ScriptStackTrace;" ^
    "  $msg | ForEach-Object { Write-Host $_ };" ^
    "  $msg | Add-Content -Path $log -Encoding UTF8;" ^
    "  exit 1" ^
    "}" 2>> "%ERRLOG%"

set "run_rc=%ERRORLEVEL%"
call :Log "END %RUNLABEL%, rc=%run_rc%"
exit /b %run_rc%


:ValidateScript
set "SCRIPT_TO_VALIDATE=%~1"

call :Log "Validating PowerShell syntax: %SCRIPT_TO_VALIDATE%"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
    "$tokens=$null;" ^
    "$errors=$null;" ^
    "[System.Management.Automation.Language.Parser]::ParseFile('%SCRIPT_TO_VALIDATE%', [ref]$tokens, [ref]$errors) | Out-Null;" ^
    "if ($errors.Count -gt 0) {" ^
    "  Write-Host '===== PARSE ERRORS =====';" ^
    "  foreach ($e in $errors) {" ^
    "    Write-Host '';" ^
    "    Write-Host ('Message : ' + $e.Message);" ^
    "    Write-Host ('ErrorId : ' + $e.ErrorId);" ^
    "    Write-Host ('Line    : ' + $e.Extent.StartLineNumber);" ^
    "    Write-Host ('Column  : ' + $e.Extent.StartColumnNumber);" ^
    "    Write-Host ('Text    : ' + $e.Extent.Text);" ^
    "  }" ^
    "  exit 1;" ^
    "} else {" ^
    "  Write-Host 'Syntax OK';" ^
    "  exit 0;" ^
    "}" >> "%ERRLOG%" 2>&1

exit /b %ERRORLEVEL%


:Log
echo [%date% %time%] %~1
echo [%date% %time%] %~1 >> "%ERRLOG%"
copy /Y "%ERRLOG%" "%LATESTLOG%" >nul 2>&1
exit /b 0


:EXIT
call :Log "Launcher finished with rc=%rc%"
call :Log "Log file: %ERRLOG%"
copy /Y "%ERRLOG%" "%LATESTLOG%" >nul 2>&1

popd
endlocal
exit /b %rc%
