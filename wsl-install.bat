@echo off

call "%~dp0wsl-env.bat"
if errorlevel 1 exit /b %errorlevel%

set CACHE_DIR=%~dp0cache
set CACHE_FILE=%CACHE_DIR%\AlmaLinux-10_inited.tar

rem cache フォルダが無ければ作る
if not exist "%CACHE_DIR%" (
    mkdir "%CACHE_DIR%"
)

if not exist "%CACHE_FILE%" (

  rem cache ファイルが無ければ、AlmaLinux-10 をインストールして初期化する
  wsl --install AlmaLinux-10 --name %WSL_DISTRO_NAME% --no-launch
  wsl -u root -d %WSL_DISTRO_NAME% -- sh -c ^
    "mkdir -p /mnt/workspace && mount -t drvfs '%~dp0' /mnt/workspace"
  wsl -u root -d %WSL_DISTRO_NAME% -- /mnt/workspace/wsl/init.sh
  wsl -u root -d %WSL_DISTRO_NAME% -- umount -l /mnt/workspace
  wsl -t %WSL_DISTRO_NAME%
  wsl --export %WSL_DISTRO_NAME% "%CACHE_FILE%"

) else (

  wsl --install --from-file "%CACHE_FILE%" --name %WSL_DISTRO_NAME% --no-launch

)

rem setup.sh を実行する
wsl -u root -d %WSL_DISTRO_NAME% -- sh -c ^
  "mkdir -p /mnt/workspace && mount -t drvfs '%~dp0' /mnt/workspace"
wsl -u root -d %WSL_DISTRO_NAME% -- /mnt/workspace/wsl/setup.sh
wsl -u root -d %WSL_DISTRO_NAME% -- umount -l /mnt/workspace

wsl -t %WSL_DISTRO_NAME%
