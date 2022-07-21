@echo off
setlocal EnableDelayedExpansion

set "aria2c=C:\prerequisites\aria2c.exe"
set "link=https://gitlab.com/librewolf-community/browser/windows/uploads/d38454411b712bef93312c8dc2ef98b7/librewolf-102.0.1-1.en-US.win64-setup.exe"
set "sha1=b63be6feaaaaa7d50d51e94aa2ace3821e38aad6"
set "working_dir=!temp!\librewolf"

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

echo info: downloading librewolf
"!aria2c!" "!link!" -d "!working_dir!" -o "librewolf.exe"

if not exist "!working_dir!\librewolf.exe" (
    echo error: download unsuccessful, please download librewolf manually
    pause
    exit /b 1
)

for /f "delims=" %%i in ('certutil -hashfile "!working_dir!\librewolf.exe" SHA1 ^| find /i /v "SHA1" ^| find /i /v "Certutil"') do (
    set "file_sha1=%%i"
)

if not "!file_sha1!" == "!sha1!" (
    echo error: sha1 mismatch, binary may be corrupted
)

start "" "!working_dir!\librewolf.exe"

pause
exit /b 0

