@echo off

:PowerShell2
pushd %~dp0

echo "STARTING POBIERAK"

powershell -WindowStyle Normal -ExecutionPolicy Bypass -File .\resources\pobierak.ps1 2>.\resources\Error\error.txt

IF %ERRORLEVEL% EQU 0 (GOTO EXIT) ELSE (GOTO after_error)

:after_error

echo "STARTING POBIERAK BAKUP"

powershell -WindowStyle Maximized -ExecutionPolicy Bypass -File .\resources\pobierak_bak.ps1

IF %ERRORLEVEL% EQU 0 (GOTO EXIT) ELSE (GOTO after_error2)

:after_error2

echo "STARTING POBIERAK BAKUP PRIMARY"

powershell -WindowStyle Maximized -ExecutionPolicy Bypass -File .\resources\pobierak_primary.ps1

:EXIT
