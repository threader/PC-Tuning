@echo off
setlocal EnableDelayedExpansion

echo info: setting PowerShell executionpolicy to unrestricted
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

echo info: done
pause
exit /b 0
