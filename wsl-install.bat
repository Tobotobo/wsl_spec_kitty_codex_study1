@echo off
setlocal

call "%~dp0wsl-env.bat"
if errorlevel 1 exit /b %errorlevel%

set CACHE_DIR=%~dp0.wsl-cache
set CACHE_FILE=%CACHE_DIR%\AlmaLinux-10.tar

rem 引数に --no-cache が指定されている場合は 1
set "NO_CACHE="
for %%A in (%*) do (
    if /I "%%~A"=="--no-cache" set "NO_CACHE=1"
)

rem cache フォルダが無ければ作る
if not exist "%CACHE_DIR%" (
    mkdir "%CACHE_DIR%"
)

rem --no-cache 指定、またはキャッシュファイルなし
set "CACHE_MISS="
if defined NO_CACHE set "CACHE_MISS=1"
if not exist "%CACHE_FILE%" set "CACHE_MISS=1"

if defined CACHE_MISS (

  rem キャッシュが無ければインストール後にキャッシュ
  wsl --install AlmaLinux-10 --name %WSL_DISTRO_NAME% --no-launch
  if exist "%CACHE_FILE%" del /Q "%CACHE_FILE%"
  wsl --export %WSL_DISTRO_NAME% "%CACHE_FILE%"

) else (

  rem キャッシュからインストール
  wsl --install --from-file "%CACHE_FILE%" --name %WSL_DISTRO_NAME% --no-launch

)

wsl -u root -d %WSL_DISTRO_NAME% -- ./wsl/setup.sh %*
wsl -t %WSL_DISTRO_NAME%
