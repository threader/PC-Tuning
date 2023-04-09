@echo on
set "powshcmd=PowerShell -WindowStyle Normal"
set "usedir=%HOMEDRIVE%%HOMEPATH%\Desktop\AltanOS.inst"
set "bitsadminget=bitsadmin /transfer /Download /priority HIGH"
set "webgetps=%powshcmd% Invoke-WebRequest -uri "%geturl%" -OutFile %geturlout% -v"
set "admuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLC.exe -UseCurrentConsole -Priority:AboveNormal -M:S -U:S -P:E --wait"
:: set "uacadmuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLG.exe -UseCurrentConsole -Priority:AboveNormal -M:S -U:S -P:E --wait"


mkdir %usedir%

IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set nsarchbit=x64
) ELSE (set nsarchbit=Win32)

set "uacadmuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLG.exe -Priority:AboveNormal -M:S -U:S -P:E --wait"

if exist %usedir%\bin\Nsudo\%nsarchbit%\NSudoLG.exe goto skipnsudo
:: %bitsadminget% https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1 %usedir%\dotnet-install.ps1
:: %bitsadminget% https://globalcdn.nuget.org/packages/microsoft.ui.xaml.2.8.2.nupkg %usedir%\microsoft.ui.xaml.2.8.2.nupkg
:: %bitsadminget% https://globalcdn.nuget.org/packages/microsoft.web.webview2.1.0.1661.34.nupkg  %usedir%\microsoft.web.webview2.1.0.1661.34.nupkg
 %bitsadminget% https://github.com/M2Team/NSudo/releases/download/9.0-Preview1/NSudo_9.0_Preview1_9.0.2676.0.zip %usedir%\Nsudo.zip 
 %powshcmd% "Expand-Archive -Force '%usedir%\Nsudo.zip' '%usedir%\bin\Nsudo'"
:skipnsudo

:: %uacadmuser% %powshcmd% add-appxpackage -Path %usedir%\Microsoft.DesktopAppInstaller.msixbundle

 %uacadmuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Bypass
:: powershell Start-process powershell -Verb RunAS %cd%\dotnet-install.ps1
:: %admuser% dotnet add package Microsoft.UI.Xaml 
powershell Start-process powershell -Verb RunAS  %cd%\winget-pkg.ps1
 %uacadmuser% "%cd%\bootstrap-AltanOS.cmd"
 %uacadmuser% reg load %usedir%\AltanOS\bin\registry\clean.reg
 %uacadmuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Restricted
pause

