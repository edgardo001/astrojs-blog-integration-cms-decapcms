@echo off
setlocal

set PORT=8081
set LOG=%TEMP%\decap-server-%RANDOM%.log

echo === Entorno de desarrollo: Astro + Decap CMS ===
echo.

netstat -ano | findstr ":%PORT% " | findstr /c:"LISTENING" >nul
if %errorlevel%==1 goto start_proxy

set HOLDER=
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":%PORT% " ^| findstr /c:"LISTENING"') do if not defined HOLDER if "%%p" neq "0" set HOLDER=%%p
echo [ERROR] El puerto %PORT% ya esta en uso.
echo Sin el proxy local de Decap CMS en ese puerto, /admin/ pedira login
echo de GitHub, asi que el entorno de desarrollo NO se iniciara.
echo.
echo El proceso que lo ocupa es:
echo.
tasklist /fi "PID eq %HOLDER%" /fo table /nh
echo.
echo Opciones:
echo   - Ejecuta kill-dev.bat para ver el detalle y liberar el puerto.
echo   - Deten el proceso manualmente.
echo   - Si solo quieres el sitio sin el CMS: npm run dev
echo.
echo Despues de liberar el puerto, vuelve a ejecutar start-dev.bat.
pause
exit /b 1

:start_proxy
start "decap-server" /b npx decap-server > "%LOG%" 2>&1

set N=0
:wait_proxy
netstat -ano | findstr ":%PORT% " | findstr /c:"LISTENING" >nul
if %errorlevel%==0 goto proxy_up
set /a N+=1
if %N% geq 10 goto proxy_fail
timeout /t 1 /nobreak >nul
goto wait_proxy

:proxy_up
echo [OK] Proxy de Decap CMS escuchando en localhost:%PORT%
echo [OK] Abre http://localhost:4321/admin/ cuando el dev server este arriba.
echo [OK] Iniciando Astro dev server...
echo.
npm run dev

set KILLPID=
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":%PORT% " ^| findstr /c:"LISTENING"') do if not defined KILLPID if "%%p" neq "0" set KILLPID=%%p
if defined KILLPID (
    taskkill /F /PID %KILLPID% >nul 2>&1
    echo [OK] Proxy de Decap CMS detenido.
)
exit /b 0

:proxy_fail
echo [ERROR] decap-server no arranco en el puerto %PORT% tras 10 intentos.
echo Ultimas lineas del log %LOG%:
echo.
type "%LOG%" 2>nul
echo.
echo Si el puerto seguia ocupado, ejecuta kill-dev.bat para liberarlo.
pause
exit /b 1
