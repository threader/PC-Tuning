<# :
@echo off
setlocal EnableDelayedExpansion

:set_binary_path
echo select the main game exe you would like to configure
for /f "delims=" %%a in ('PowerShell "iex (${%~f0} | out-string)"') do set "binary_path=%%a"

if defined binary_path (
	if exist "!binary_path!" (

		for /f "usebackq delims=" %%a in ('"!binary_path!"') do (
			set "program_name=%%~na"
		)

		echo program path: "!binary_path!"
		echo program name: "!program_name!"

		choice /c yn /n /m "set DSCP 46 QoS policy? [Y/N]"
		if !errorlevel! == 1 (
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Version" /t REG_SZ /d "1.0" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Application Name" /t REG_SZ /d "!binary_path!" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Protocol" /t REG_SZ /d "*" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Local Port" /t REG_SZ /d "*" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Local IP" /t REG_SZ /d "*" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Local IP Prefix Length" /t REG_SZ /d "*" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Remote Port" /t REG_SZ /d "*" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Remote IP" /t REG_SZ /d "*" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Remote IP Prefix Length" /t REG_SZ /d "*" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "DSCP Value" /t REG_SZ /d "46" /f
			Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\!profile_name!" /v "Throttle Rate" /t REG_SZ /d "-1" /f
		)
			
		choice /c yn /n /m "disable fullscreen optimizations? (Windows 10 1703+ Only) [Y/N]"
		if !errorlevel! == 1 (
			Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "!binary_path!" /t REG_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f
		)

		pause
		exit /b 0
	)
)

echo error: invalid input
goto set_binary_path

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
