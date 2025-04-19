@echo off
set "GSC_COMP=gsc-tool.exe -m comp -g t6 -s pc"
set "OUT_DIR=%LocalAppData%\Plutonium\storage\t6\scripts\zm\"

REM Create the origins_menu folder if it doesn't exist
if not exist "%OUT_DIR%origins_menu" (
    mkdir "%OUT_DIR%origins_menu"
)

echo [30;103mmenu.gsc[0m
%GSC_COMP% ".\menu.gsc"
MOVE ".\compiled\t6\menu.gsc" "%OUT_DIR%"

echo [30;103mmenu_base.gsc[0m
%GSC_COMP% ".\menu_base.gsc"
MOVE ".\compiled\t6\menu_base.gsc" "%OUT_DIR%origins_menu"

echo [30;103mmenu_utility.gsc[0m
%GSC_COMP% ".\menu_utility.gsc"
MOVE ".\compiled\t6\menu_utility.gsc" "%OUT_DIR%origins_menu"

REM Compile all files in modes folder
for %%F in (modes\*.gsc) do (
    echo [30;103m%%~nxF[0m
    %GSC_COMP% "%%F"
    MOVE ".\compiled\t6\%%~nxF" "%OUT_DIR%origins_menu"
)
