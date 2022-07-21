@echo off
setlocal EnableDelayedExpansion

echo info: setting powershell executionpolicy to unrestricted
PowerShell Set-ExecutionPolicy Unrestricted -force

echo info: setting the password to never expire, resolves some bugs despite no password being set
net accounts /maxpwage:unlimited

echo info: disable automatic repair, does more harm than good in our use case
bcdedit /set {current} recoveryenabled no
fsutil repair set C: 0

echo info: cleaning the winsxs folder
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

echo info: disabling reserved storage, ignore errors
DISM /Online /Set-ReservedStorageState /State:Disabled

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
