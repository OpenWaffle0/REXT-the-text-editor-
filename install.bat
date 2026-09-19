@echo off
echo Rext Text Editor - Windows Kurulumu
echo.

:: Lua kontrol et
where lua >nul 2>nul
if %errorlevel% neq 0 (
    echo [HATA] Sistemde Lua bulunamadi!
    echo Lutfen once Windows icin Lua indirip kurun: https://github.com/rjpetersn/lua-for-windows/releases
    pause
    exit /b
)

:: Rext.lua'yi C:\Windows'a kopyala
copy /y "%~dp0rext.lua" "C:\Windows\rext.lua" >nul

:: CMD/PowerShell için rext komutu olustur
echo @echo off > "C:\Windows\rext.bat"
echo lua C:\Windows\rext.lua %%* >> "C:\Windows\rext.bat"

echo.
echo [BASARILI] Rext basariyla kuruldu!
echo CMD veya PowerShell acip 'rext dosya.txt' yazarak kullanabilirsin.
pause
