@echo off
setlocal EnableDelayedExpansion

echo nobody is responsible for damage caused to your operating system or computer, run at your own RISK
echo windows 8+ only
pause

echo info: enabling dwm
Reg.exe delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe" /v "Debugger" /f

for %%a in (UIRibbon, UIRibbonRes, Windows.UI.Logon) do (
	if exist "!windir!\System32\%%a.dlll" (

		takeown /F "!windir!\System32\%%a.dlll" /A
		icacls "!windir!\System32\%%a.dlll" /grant Administrators:F

		ren "!windir!\System32\%%a.dlll" "%%a.dll"
	)
)

shutdown /r /f /t 0
