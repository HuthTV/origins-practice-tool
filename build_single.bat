@echo off
setlocal

REM -------- paths --------
set "PROJECT_PATH=%~dp0"
if "%PROJECT_PATH:~-1%"=="\" set "PROJECT_PATH=%PROJECT_PATH:~0,-1%"
set "BUILD_DIR=%PROJECT_PATH%\build"
set "SCRIPTS_PATH=%LocalAppData%\Plutonium\storage\t6\scripts\zm"

REM -------- create folders --------
if not exist "%SCRIPTS_PATH%" mkdir "%SCRIPTS_PATH%"
if not exist "%SCRIPTS_PATH%\origins_menu" mkdir "%SCRIPTS_PATH%\origins_menu"
if not exist "%SCRIPTS_PATH%\zm_tomb" mkdir "%SCRIPTS_PATH%\zm_tomb"
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

REM -------- flatten scripts --------
echo Flattening scripts...
powershell -ExecutionPolicy Bypass -NoProfile -File "%BUILD_DIR%\flatten.ps1" -ProjectRoot "%PROJECT_PATH%" -BuildDir "%BUILD_DIR%"
if errorlevel 1 goto :error

REM -------- compile GSC --------
echo Compiling GSC...
pushd "%BUILD_DIR%"
if not exist "gsc-tool.exe" (
    echo ERROR: gsc-tool.exe not found in "%BUILD_DIR%"
    popd
    goto :error
)
gsc-tool.exe --mode comp --game t6 --system pc "menu_flat.gsc"
if errorlevel 1 (
    popd
    goto :error
)
popd

REM -------- deploy compiled script --------
set "COMPILED_FILE=%BUILD_DIR%\compiled\t6\menu_flat.gsc"
if exist "%COMPILED_FILE%" (
    copy /Y "%COMPILED_FILE%" "%SCRIPTS_PATH%\menu.gsc"
) else (
    echo ERROR: compiled file not found: "%COMPILED_FILE%"
    goto :error
)

echo.
echo Release build complete!
goto :eof

:error
echo.
echo BUILD FAILED
exit /b 1
