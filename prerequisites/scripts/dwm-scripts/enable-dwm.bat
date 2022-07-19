@echo off

echo nobody is responsible for damage caused to your operating system or computer, run at your own RISK
echo windows 8+ only
pause

echo info: enabling dwm
Reg.exe delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe" /v "Debugger" /f

set "system32=%windir%\System32"
for %%i in ("UIRibbon", "UIRibbonRes", "Windows.UI.Logon") do (
	if exist "%system32%\%%i.dlll" (
		ren "%system32%\%%i.dlll" "%%i.dll"
	) else (
		echo info: %%i.dlll not exist
	)
)

shutdown /r /f /t 0
