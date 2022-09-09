@echo off
color 2

:PowerShell2
pushd %~dp0

echo "STARTING POBIERAK"

powershell -ExecutionPolicy Bypass -File .\resources\pobierak.ps1

EXIT