@echo off
setlocal EnableDelayedExpansion

DISM > nul 2>&1 || echo error: administrator privileges required && pause && exit /b 1

echo info: windows 8+ only - nobody is responsible for damage caused to your system or computer, run at your own risk
echo info: press any key to continue
pause > nul 2>&1

echo info: enabling dwm
reg.exe delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe" /v "Debugger" /f

for %%a in ("UIRibbon" "UIRibbonRes" "Windows.UI.Logon") do (
    if exist "!windir!\System32\%%~a.dlll" (
        takeown /F "!windir!\System32\%%~a.dlll" /A
        icacls "!windir!\System32\%%~a.dlll" /grant Administrators:F
        ren "!windir!\System32\%%~a.dlll" "%%~a.dll"
    )
)

shutdown /r /f /t 0
