@echo on

IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set nsarchbit=x64)
else (set nsarchbit=Win32)

set "uacadmuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLG.exe -Priority:AboveNormal -M:S -U:S -P:E --wait"
set "powshcmd=PowerShell -WindowStyle Normal -NoProfile -Command" 
 %uacadmuser% %powshcmd% Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
  
%uacadmuser% %powshcmd% "Get-AppPackage | Remove-AppPackage"


 %uacadmuser% %powshcmd% Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 2