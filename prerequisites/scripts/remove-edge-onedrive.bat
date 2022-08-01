@echo off
setlocal EnableDelayedExpansion

if exist "C:\Program Files (x86)\Microsoft\Edge\Application" (
    echo info: uninstalling microsoft edge
    for /f "delims=" %%a in ('where /r "C:\Program Files (x86)\Microsoft\Edge\Application" *setup.exe*') do (
        if exist "%%a" (
            "%%a" --uninstall --system-level --verbose-logging --force-uninstall
        )
    )
)

if exist "!windir!\SysWOW64\OneDriveSetup.exe" (
    echo info: uninstalling onedrive
    "!windir!\SysWOW64\OneDriveSetup.exe" /uninstall
)

echo info: done
pause
exit /b 0
