@echo off

echo nobody is responsible for damage caused to your operating system or computer, run at your own RISK
echo windows 8+ only
pause

echo info: enabling dwm
Reg.exe delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe" /v "Debugger" /f

for %%i in (UIRibbon, UIRibbonRes, Windows.UI.Logon) do (
	if exist "%windir%\System32\%%i.dlll" (

		takeown /F "%windir%\System32\%%i.dlll" /A
		icacls "%windir%\System32\%%i.dlll" /grant Administrators:F

		ren "%windir%\System32\%%i.dlll" "%%i.dll"
	)
)

shutdown /r /f /t 0
