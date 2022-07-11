@echo off
setlocal EnableDelayedExpansion

:: this script is used to download the prerequisites directly from the github repository
:: it is only used in prebuilt base images which are available in the pre-installation instructions

pushd "%~dp0"

set "working_dir=%temp%\EVA"

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

set "extract_err=0"
for %%i in ("prerequisites", "debloat.sh") do (
    if exist "!working_dir!\EVA-main\%%i" (
        move /y "!working_dir!\EVA-main\%%i" "C:\"
    ) else (
        error: %%i does not exist
        set "extract_err=1"
    )
)

if not !extract_err! == 0 (
    pause
    exit /b 1
)

rd /s /q "!working_dir!"

pause
exit /b 0
