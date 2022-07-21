@echo off
setlocal EnableDelayedExpansion

set "aria2c=C:\prerequisites\aria2c.exe"
set "link=https://github.com/abbodi1406/vcredist/releases/download/v0.61.0/VisualCppRedist_AIO_x86_x64_61.zip"
set "sha1=0d35097f6f7a1b7b98e720d395ae4dd1c7c64f35"
set "working_dir=!temp!\vcredists"

ping archlinux.org
if not !errorlevel! == 0 (
    echo error: no internet connection
    pause
    exit /b 1
)

if not exist "!aria2c!" (
    echo error: !aria2c! not exists
    pause
    exit /b 1
)

if exist !working_dir! (
    rd /s /q "!working_dir!"
)
mkdir "!working_dir!"

echo info: downloading vcredists
"!aria2c!" "!link!" -d "!working_dir!" -o "vcredists.zip"

if not exist "!working_dir!\vcredists.zip" (
    echo error: download unsuccessful, please download vcredists manually
    pause
    exit /b 1
)

for /f "delims=" %%a in ('certutil -hashfile "!working_dir!\vcredists.zip" SHA1 ^| find /i /v "SHA1" ^| find /i /v "Certutil"') do (
    set "file_sha1=%%a"
)

if not "!file_sha1!" == "!sha1!" (
    echo error: sha1 mismatch, binary may be corrupted
)

start "" "!working_dir!\vcredists.zip"

pause
exit /b 0

