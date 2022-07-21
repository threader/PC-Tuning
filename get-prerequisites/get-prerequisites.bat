@echo off
setlocal EnableDelayedExpansion

:: this script is used to download the prerequisites directly from the github repository
:: it is only used in prebuilt base images which are available in the pre-installation instructions

pushd "%~dp0"

set "path_err=0"
for %%a in (
    "7z.exe",
    "7z.dll",
    "aria2c.exe"
) do (
    where %%a
    if not !errorlevel! == 0 (
        set "path_err=1"
        echo error: %%a not found in path
    )
)
if not !path_err! == 0 exit /b

ping archlinux.org
if not !errorlevel! == 0 (
    echo error: no internet connection
    pause
    exit /b 1
)

set "working_dir=!temp!\EVA"

if exist !working_dir! (
    rd /s /q "!working_dir!"
)
mkdir "!working_dir!"

echo info: cloning github.com/amitxv/EVA

aria2c.exe "https://github.com/amitxv/EVA/archive/refs/heads/main.zip" -d "!working_dir!"

if not exist "!working_dir!\EVA-main.zip" (
    echo error: download unsuccessful
    pause
    exit /b 1
)

7z x "!working_dir!\EVA-main.zip" -o"!working_dir!"

if exist "C:\prerequisites" (rd /s /q "C:\prerequisites")
if exist "C:\debloat.sh" (del /f /q "C:\debloat.sh")

set "extract_err=0"
for %%a in ("prerequisites", "debloat.sh") do (
    if exist "!working_dir!\EVA-main\%%a" (
        move /y "!working_dir!\EVA-main\%%a" "C:\"
    ) else (
        echo error: %%a does not exist
        set "extract_err=1"
    )
)

if not !extract_err! == 0 (
    pause
    exit /b 1
)

if exist "!working_dir!" rd /s /q "!working_dir!"
if exist "!windir!\7z.exe" del /f /q "!windir!\7z.exe"
if exist "!windir!\7z.dll" del /f /q "!windir!\7z.dll"
if exist "!windir!\aria2c.exe" del /f /q "!windir!\7z.exe"

echo info: done

pause
exit /b 0
