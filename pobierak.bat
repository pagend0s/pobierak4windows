@echo off
setlocal EnableExtensions

rem Jump to the .bat script directory
pushd "%~dp0"

rem Base variable for resources paths
set "RES=%~dp0resources"
set "ERRDIR=%RES%\Error"
set "ERRLOG=%ERRDIR%\error.txt"

rem Ensure the error-log directory exists
if not exist "%ERRDIR%" mkdir "%ERRDIR%"

:Read_ver
setlocal
set "file=%RES%\pobierak.ps1"
set "search=$pobierak_v"
for /f "delims=" %%A in ('findstr /I "%search%" "%file%"') do (
    set "version=%%A"
    goto :done
)
:done

:StartPobierak
echo [INFO] Starting pobierak.ps1
echo ==== %date% %time% %version% : START pobierak.ps1 ====> "%ERRLOG%"
powershell.exe -NoLogo -NoProfile -WindowStyle Normal -ExecutionPolicy Bypass -File "%RES%\pobierak.ps1" 2>>"%ERRLOG%"
set "rc=%ERRORLEVEL%"

if "%rc%"=="0" goto EXIT
if "%rc%"=="1" goto after_error
if "%rc%"=="3" goto after_update
goto EXIT

:after_error
echo [WARN] pobierak.ps1 failed (rc=%rc%). Starting BACKUP...
echo ==== %date% %time% : START pobierak_bak.ps1 ====> "%ERRLOG%"
powershell.exe -NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -File "%RES%\pobierak_bak.ps1" 2>>"%ERRLOG%"
set "rc=%ERRORLEVEL%"

if "%rc%"=="0" goto EXIT
if "%rc%"=="1" goto after_error2
if "%rc%"=="3" goto after_update
goto EXIT

:after_error2
echo [WARN] backup failed (rc=%rc%). Starting BACKUP PRIMARY...
echo ==== %date% %time% : START pobierak_primary.ps1 ====> "%ERRLOG%"
powershell.exe -NoLogo -NoProfile -WindowStyle Maximized -ExecutionPolicy Bypass -File "%RES%\pobierak_primary.ps1" 2>>"%ERRLOG%"
set "rc=%ERRORLEVEL%"

if "%rc%"=="0" goto EXIT
if "%rc%"=="3" goto after_update
goto EXIT

:after_update
echo [INFO] Update flow (rc=3). Restarting pobierak.ps1...
echo ==== %date% %time% : RESTART pobierak.ps1 (after update) ====> "%ERRLOG%"
powershell.exe -NoLogo -NoProfile -WindowStyle Normal -ExecutionPolicy Bypass -File "%RES%\pobierak.ps1" 2>>"%ERRLOG%"
set "rc=%ERRORLEVEL%"

if "%rc%"=="0" goto EXIT
if "%rc%"=="1" goto after_error
if "%rc%"=="3" goto after_update
goto EXIT

:EXIT
echo [INFO] Exit rc=%rc%
popd
endlocal
