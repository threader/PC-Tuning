@echo on

IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set nsarchbit=x64
ELSE (set nsarchbit=Win32)

set "usedir=%HOMEDRIVE%%HOMEPATH%\Desktop\AltanOS.inst" 
if exist %usedir% (set "currentuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLC.exe -Priority:AboveNormal -U:C -P:E --wait")
ELSE (echo %usedir% does not exist! & pause & exit /b 1)
set "admuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLC.exe -Priority:AboveNormal -M:S -U:S -P:E --wait"
set "uacuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLG.exe -Priority:AboveNormal -U:C -P:E --wait"
set "uacadmuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLG.exe -Priority:AboveNormal -M:S -U:S -P:E --wait"
set "powshcmd=PowerShell -WindowStyle Normal -NoProfile -Command" 

echo  DO NOT CLOSE THIS WINDOW!

 %uacadmuser% %powshcmd% Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
  
echo  Updating Windows.

echo Setting up PSWindowsUpdate for unattended upgrades

  %uacadmuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Bypass
 :: %uacadmuser% %powshcmd% Install-Module PSWindowsUpdate
 :: %uacadmuser% %powshcmd% Import-Module PSWindowsUpdate
  %uacadmuser% %powshcmd% Get-WindowsUpdate -AcceptAll -Install
  %uacadmuser% %powshcmd% Install-WindowsUpdate
  %uacadmuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Restricted
  
  
echo Updating all applications
  %uacadmuser% %powshcmd% winget upgrade --accept-source-agreements --disable-interactivity --include-unknown -r


 %uacadmuser% %powshcmd% Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 2