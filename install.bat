@echo off
echo Rext Text Editor - Windows Installer
echo.

:: Check for Lua
where lua >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Lua was not found on your system!
    echo Please download and install Lua for Windows first: https://github.com/rjpetersn/lua-for-windows/releases
    pause
    exit /b
)

:: Copy rext.lua to C:\Windows
copy /y "%~dp0rext.lua" "C:\Windows\rext.lua" >nul

:: Create rext.bat executable wrapper for CMD/PowerShell
echo @echo off > "C:\Windows\rext.bat"
echo lua C:\Windows\rext.lua %%* >> "C:\Windows\rext.bat"

echo.
echo [SUCCESS] Rext successfully installed!
echo Open CMD or PowerShell and type 'rext filename.txt' to start editing.
pause
