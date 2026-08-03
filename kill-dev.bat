@echo off
setlocal EnableDelayedExpansion

set PORT=8081
if not "%1"=="" set PORT=%1

echo === Proceso(s) que ocupan el puerto %PORT% ===
echo.

set PIDS=
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":%PORT% " ^| findstr /c:"LISTENING"') do (
    if "%%p" neq "0" (
        set ISNEW=1
        for %%q in (!PIDS!) do if "%%q"=="%%p" set ISNEW=0
        if !ISNEW!==1 set PIDS=!PIDS! %%p
    )
)

if not defined PIDS (
    echo [OK] El puerto %PORT% esta libre. No hay nada que matar.
    echo.
    pause
    exit /b 0
)

echo El puerto %PORT% esta ocupado por:
echo.
for %%p in (%PIDS%) do (
    tasklist /fi "PID eq %%p" /fo table /nh
    powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter 'ProcessId=%%p' | ForEach-Object { if ($_.CommandLine) { Write-Host '    Comando:' $_.CommandLine } }" 2>nul
    echo.
)

set /p CONFIRM=Matar estos procesos para liberar el puerto (S/N)? 
if /i not "%CONFIRM%"=="S" (
    echo [OK] No se mato ningun proceso. El puerto %PORT% sigue ocupado.
    echo.
    pause
    exit /b 0
)

for %%p in (%PIDS%) do (
    taskkill /F /PID %%p >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] No se pudo terminar el proceso %%p.
    ) else (
        echo [OK] Proceso %%p terminado.
    )
)
echo.
echo Puerto %PORT% liberado. Ya puedes iniciar tu propio proceso.
pause
