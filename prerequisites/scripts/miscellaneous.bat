@echo off
setlocal EnableDelayedExpansion

dism > nul 2>&1 || echo error: administrator privileges required && pause && exit /b 1

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

echo info: disabling sleepstudy
wevtutil sl Microsoft-Windows-SleepStudy/Diagnostic /e:false
wevtutil sl Microsoft-Windows-Kernel-Processor-Power/Diagnostic /e:false
wevtutil sl Microsoft-Windows-UserModePowerService/Diagnostic /e:false

echo info: done
echo info: press any key to continue
pause > nul 2>&1
exit /b 0
