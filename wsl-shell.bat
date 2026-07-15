@echo off

call "%~dp0wsl-env.bat"
if errorlevel 1 exit /b %errorlevel%

wsl -d %WSL_DISTRO_NAME%
