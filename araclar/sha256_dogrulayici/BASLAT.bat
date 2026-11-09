@echo off
setlocal
title AZiL - Kucuk Yardimci Araclar
where powershell.exe >nul 2>&1
if errorlevel 1 (
  echo PowerShell bulunamadi.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0sha256_dogrulayici.ps1"
set "RESULT=%ERRORLEVEL%"
echo.
echo Cikis kodu: %RESULT%
pause
exit /b %RESULT%
