@echo off

echo nobody is responsible for damage caused to your operating system or computer, run at your own RISK
echo windows 8+ only
pause

echo info: disabling dwm
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe" /v "Debugger" /t REG_SZ /d "\"C:\WINDOWS\SYSTEM32\RUNDLL32.EXE\"" /f

for %%i in (UIRibbon, UIRibbonRes, Windows.UI.Logon) do (
	if exist "%windir%\System32\%%i.dll" (

		takeown /F "%windir%\System32\%%i.dll" /A
		icacls "%windir%\System32\%%i.dll" /grant Administrators:F

		ren "%windir%\System32\%%i.dll" "%%i.dlll"
	)
)

shutdown /r /f /t 0
