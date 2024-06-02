@echo off

:PowerShell2
pushd %~dp0

IF exist ".\resources\Error" ( 
		GOTO StartPobierak
		)	ELSE	(
		mkdir ".\resources\Error"
		)
:StartPobierak
echo "STARTING POBIERAK"
powershell -WindowStyle Normal -ExecutionPolicy Bypass -File .\resources\pobierak.ps1 2>.\resources\Error\error.txt

IF %ERRORLEVEL% == 0 (GOTO EXIT)


IF %ERRORLEVEL% == 1 (GOTO after_error)

IF %ERRORLEVEL% == 3 (GOTO after_update) ELSE (GOTO EXIT)

:after_error

echo "STARTING POBIERAK BAKUP"

powershell -WindowStyle Maximized -ExecutionPolicy Bypass -File .\resources\pobierak_bak.ps1

IF %ERRORLEVEL% EQU 0 (GOTO EXIT) ELSE (GOTO after_error2)

:after_error2

echo "STARTING POBIERAK BAKUP PRIMARY"

powershell -WindowStyle Maximized -ExecutionPolicy Bypass -File .\resources\pobierak_primary.ps1

:after_update

powershell -WindowStyle Normal -ExecutionPolicy Bypass -File .\resources\pobierak.ps1 2>.\resources\Error\error.txt

:EXIT
