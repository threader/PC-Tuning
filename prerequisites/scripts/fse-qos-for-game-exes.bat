<# :
@echo off
SETLOCAL EnableDelayedExpansion

:set_application_path
echo select the main game exe you would like to configure
for /f "delims=" %%a in ('PowerShell "iex (${%~f0} | out-string)"') do set application_path=%%a

if defined application_path (
	for %%a in ("!application_path!") do (
		if /i "%%~xa"==".exe" (
			for /f "usebackq delims=" %%a in ('"!application_path!"') do set profile_name=%%~na
			echo info: !profile_name! selected
			choice /c yn /n /m "set DSCP 46 QoS policy? [Y/N]"
			if "!errorlevel!"=="1" (
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Version" /t REG_SZ /d "1.0" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Application Name" /t REG_SZ /d "!application_path!" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Protocol" /t REG_SZ /d "*" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Local Port" /t REG_SZ /d "*" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Local IP" /t REG_SZ /d "*" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Local IP Prefix Length" /t REG_SZ /d "*" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Remote Port" /t REG_SZ /d "*" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Remote IP" /t REG_SZ /d "*" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Remote IP Prefix Length" /t REG_SZ /d "*" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "DSCP Value" /t REG_SZ /d "46" /f > NUL 2>&1
				Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Throttle Rate" /t REG_SZ /d "-1" /f > NUL 2>&1
			)
			
			choice /c yn /n /m "disable fullscreen optimizations? (Windows 10 1703+ Only) [Y/N]"
			if "!errorlevel!"=="1" (
				Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "!application_path!" /t REG_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE DPIUNAWARE" /f > NUL 2>&1
			)

			pause
			exit /b 0
		)
	)
)

echo error: invalid input.
goto set_application_path

goto :EOF
PS #>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.InitialDirectory = pwd
$f.Filter = "Image Files (*.exe)|*.exe|All Files (*.*)|*.*"
$f.ShowHelp = $true
$f.Multiselect = $true
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }
