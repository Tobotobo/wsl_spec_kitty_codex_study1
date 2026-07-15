@echo off

call "%~dp0wsl-env.bat"
if errorlevel 1 exit /b %errorlevel%

choice /c YN /n /m "%WSL_DISTRO_NAME% ‚ğíœ‚µ‚Ü‚·B‚æ‚ë‚µ‚¢‚Å‚·‚©H [Y/N]: "

if errorlevel 2 (
    echo ˆ—‚ğ’†~‚µ‚Ü‚µ‚½B
    exit /b 1
)

wsl --unregister %WSL_DISTRO_NAME%
