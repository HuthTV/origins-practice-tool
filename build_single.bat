@echo off
rem Builds the menu and installs it in Plutonium. -Source installs the plain sources,
rem -Check only builds, -Tools adds tools\*.gsc. See build.ps1.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" %*
exit /b %errorlevel%
