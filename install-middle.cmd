@echo on
cls
echo Setting up and updating DO NOT CLOSE THIS WINDOW!

:: set other variables
set "usedir=%HOMEDRIVE%%HOMEPATH%\AltanOS.inst" :: Altan means porch in Norwegian
set "currentuser=%usedir%\bin\Nsudo\x64\NSudoLC.exe  -Priority:AboveNormal -UseCurrentConsole -U:C -P:E --wait"
set "uacuser=%usedir%\bin\Nsudo\x64\NSudoLG.exe  -Priority:AboveNormal -UseCurrentConsole -U:C -P:E --wait"
set "admuser=%usedir%\bin\Nsudo\x64\NSudoLC.exe  -Priority:AboveNormal -UseCurrentConsole -M:S -U:S -P:E --wait"
set "uacadmuser=%usedir%\bin\Nsudo\x64\NSudoLG.exe  -Priority:AboveNormal -UseCurrentConsole -M:S -U:E -P:E --wait"
set "wingetinstdcmd=winget install --disable-interactivity --accept-source-agreements"
set "powshcmd=PowerShell -WindowStyle Normal -NoProfile -Command" 
set "bitsadminget=bitsadmin /transfer /Download /priority HIGH"
set "webreqget=%powshcmd% Invoke-WebRequest -uri "%geturl%" -OutFile %geturlout% -v"
set "dismpkg=DISM /online /add-package"
set "msipkg=msiexec.exe /quiet /norestart /passive /package"
set "gitget=%ProgramFiles%\Git\bin\git.exe"
IF "%PROCESSOR_ARCHITECTURE%"=="x64" (set niarchbit=-64)

SETLOCAL EnableDelayedExpansio

echo Will need net for this 
:: ping -n 6 8.8.8.8
 ipconfig /flushdns :: Fixed winget InternetOpenUrl() failed.
pause
mkdir %usedir%
 %bitsadminget% https://github.com/M2Team/NSudo/releases/download/9.0-Preview1/NSudo_9.0_Preview1_9.0.2676.0.zip  %usedir%\Nsudo.zip 
 %bitsadminget% https://github.com/microsoft/winget-cli/releases/download/v1.4.10173/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle %usedir%\Microsoft.DesktopAppInstaller.msixbundle
 %bitsadminget% https://github.com/PowerShell/PowerShell/releases/download/v7.3.2/PowerShell-7.3.2-win-x64.msi  %usedir%\PowerShell-7.3.2-win-x64.msi 
 %bitsadminget% https://tinywall.pados.hu/files/TinyWall-v3-Installer.msi %usedir%\TinyWall-v3-Installer.msi 
 %bitsadminget% https://privazer.com/en/PrivaZer.exe %usedir%\bin\PrivaZer.exe
 %bitsadminget% http://www.itsamples.com/downloads/network-activity-indicator-setup%niarchbit%.zip %usedir%\network-indicator%niarchbit%.zip
 %uacadmuser% %msipkg% %usedir%\PowerShell-7.3.2-win-x64.msi
 %powshcmd% "Expand-Archive -Force '%usedir%\Nsudo.zip' '%usedir%\bin\Nsudo'"
 %powshcmd% "Expand-Archive -Force '%usedir%\network-indicator%niarchbit%.zip' '%usedir%\bin\network-indicator%niarchbit%'"

:: make certain applications in request UAC
:: although these applications may already request UAC, setting this compatibility flag ensures they are ran as administrator
%admuser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%usedir%\bin\Nsudo\x64\NSudoLC.exe" /t REG_SZ /d "~ RUNASADMIN" /f
%admuser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%usedir%\bin\Nsudo\x64\NSudoLG.exe" /t REG_SZ /d "~ RUNASADMIN" /f

:: enable ASLR
%admuser% reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "MoveImages" /t REG_DWORD /d 1 /f

:: disable autoplay and autorun
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t REG_DWORD /d "1" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d "255" /f 
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d "1" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoAutoplayfornonVolume" /t REG_DWORD /d "1" /f

:: disable USB autorun/play
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d "1" /f

:: change ntp server from windows server to pool.ntp.org
%admuser% w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"
sc queryex "w32time" | find "STATE" | find /v "RUNNING" || (
    net stop w32time
    net start w32time
)

:: disable netbios over tcp/ip
:: works only when services are enabled
for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" /s /f "NetbiosOptions" ^| findstr "HKEY"') do (
    %admuser% reg add "%%b" /v "NetbiosOptions" /t REG_DWORD /d "2" /f
)

:: netbios hardening
:: netbios is disabled. if it manages to become enabled, protect against NBT-NS poisoning attacks
%admuser% %powshcmd% reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" /v "NodeType" /t REG_DWORD /d "2" /f

:: restrict anonymous access to named pipes and shares
:: https://www.stigviewer.com/stig/windows_10/2021-03-10/finding/V-220932
%admuser% %powshcmd% reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v "RestrictNullSessAccess" /t REG_DWORD /d "1" /f

:: block anonymous enumeration of sam accounts
:: https://www.stigviewer.com/stig/windows_10/2021-03-10/finding/V-220929
%admuser% %powshcmd% reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "RestrictAnonymousSAM" /t REG_DWORD /d "1" /f

:: restrict anonymous enumeration of shares
:: https://www.stigviewer.com/stig/windows_10/2021-03-10/finding/V-220930
%admuser% %powshcmd% reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "RestrictAnonymous" /t REG_DWORD /d "1" /f

:: set strong cryptography on 64 bit and 32 bit .net framework (version 4 and above) to fix a scoop installation issue
:: https://github.com/ScoopInstaller/Scoop/issues/2040#issuecomment-369686748
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\.NetFramework\v4.0.30319" /v "SchUseStrongCrypto" /t REG_DWORD /d "1" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" /v "SchUseStrongCrypto" /t REG_DWORD /d "1" /f

:: mitigate against hivenightmare/serious sam
%admuser% icacls %WinDir%\system32\config\*.* /inheritance:e

:: disable nagle's algorithm
:: https://en.wikipedia.org/wiki/Nagle%27s_algorithm
for /f %%i in ('wmic path win32_networkadapter get GUID ^| findstr "{"') do (
    %admuser% reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f
    %admuser% reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t REG_DWORD /d "0" /f
    %admuser% reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
)

:: configure search settings
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsAADCloudSearchEnabled" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsMSACloudSearchEnabled" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsDeviceSearchHistoryEnabled" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v "SafeSearchMode" /t REG_DWORD /d "0" /f

:: disable search suggestions
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d "1" /f

:: configure file explorer settings
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveSearch" /t REG_DWORD /d "1" /f
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveTrack" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f

:: disable lock screen camera
%admuser% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d "1" /f

:: disable remote assistance
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fEnableChatControl" /t REG_DWORD /d "0" /f

:: disable audio excludive mode on all devices
for /f "delims=" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture"') do (
   %uacadmuser% reg add "%%a\Properties" /v "{b3f8fa53-0004-438e-9003-51a46e139bfc},3" /t REG_DWORD /d "0" /f
   %uacadmuser% reg add "%%a\Properties" /v "{b3f8fa53-0004-438e-9003-51a46e139bfc},4" /t REG_DWORD /d "0" /f
)
pause

:: enable legacy photo viewer
for %%i in (tif tiff bmp dib gif jfif jpe jpeg jpg jxr png) do (
     reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".%%~i" /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f
)

:: set legacy photo viewer as default
for %%i in (tif tiff bmp dib gif jfif jpe jpeg jpg jxr png) do (
     reg add "HKCU\SOFTWARE\Classes\.%%~i" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f
     reg add "HKCU\SOFTWARE\Classes\.wdp" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f
)

:: set .ps1 file types to open with PowerShell by default
reg add "HKCR\Microsoft.PowerShellScript.1\Shell\Open\Command" /ve /t REG_SZ /d "\"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe\" -NoLogo -File \"%1\"" /f

:: add about:blank as start page in internet explorer
%uacuser% reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /

:: disable devicecensus.exe telemetry process
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\'DeviceCensus.exe'" /v "Debugger" /t REG_SZ /d "%WinDir%\System32\taskkill.exe" /f

:: do not allow pinning microsoft store app to taskbar
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoPinningStoreToTaskbar" /t REG_DWORD /d "1" /f

:: restrict windows' access to internet resources
:: enables various other GPOs that limit access on specific windows services
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\InternetManagement" /v "RestrictCommunication" /t REG_DWORD /d "1" /f

:: disable text/ink/handwriting telemetry
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d "1" /f 

:: disable data collection
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MaxTelemetryAllowed" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowDeviceNameInTelemetry" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitEnhancedDiagnosticDataWindowsAnalytics" /t REG_DWORD /d "0" /f

:: miscellaneous
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" /v "ScenarioExecutionEnabled" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\.\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f

:: disable experimentation
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation" /v "Value" /t REG_DWORD /d "0" /f

:: configure voice activation settings
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationOnLockScreenEnabled" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationEnabled" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationLastUsed" /t REG_DWORD /d "0" /f

:: disable advertising info
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f

:: disable nvidia telemetry
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f

:: disable typing insights
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Input\Settings" /v "InsightsEnabled" /t REG_DWORD /d "0" /f

:: disable cloud optimized taskbars
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableCloudOptimizedContent" /t REG_DWORD /d "1" /f

:: disable annoying keyboard features
%admuser% reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_DWORD /d "0" /f
%admuser% reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_DWORD /d "0" /f
%admuser% reg add "HKCU\C ontrol Panel\Accessibility\MouseKeys" /v "Flags" /t REG_DWORD /d "0" /f

:: hide meet now button on taskbar
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f

:: disable shared experiences
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableCdp" /t REG_DWORD /d "0" /f

:: disable news and interests
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d "0" /f
%admuser% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "2" /f

:: location tracking
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice" /v "AllowFindMyDevice" /t REG_DWORD /d "0" /f
%admuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice" /v "LocationSyncEnabled" /t REG_DWORD /d "0" /f

:: do not show hidden/disconnected devices in sound settings
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Multimedia\Audio\DeviceCpl" /v "ShowHiddenDevices" /t REG_DWORD /d "0" /f

echo The spooler will not accept client connections nor allow users to share printers.
:: reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /v "RegisterSpoolerRemoteRpcEndPoint" /t REG_DWORD /d "2" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v "RestrictDriverInstallationToAdministrators" /t REG_DWORD /d "1" /f
:: reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v "Restricted" /t REG_DWORD /d "1" /f

:: merge as trusted installer for registry files
reg add "HKCR\regfile\Shell\RunAs" /ve /t REG_SZ /d "Merge As TrustedInstaller" /f
reg add "HKCR\regfile\Shell\RunAs" /v "HasLUAShield" /t REG_SZ /d "1" /f
reg add "HKCR\regfile\Shell\RunAs\Command" /ve /t REG_SZ /d "NSudoLC.exe -U:T -P:E reg import "%%1"" /f
reg add "HKCR\regfile\Shell\RunAs\Command" /ve /t REG_SZ /d "NSudoLG.exe -U:T -P:E reg import "%%1"" /f

:: install cab context menu
reg delete "HKCR\CABFolder\Shell\RunAs" /f > nul 2>nul
reg add "HKCR\CABFolder\Shell\RunAs" /ve /t REG_SZ /d "Install" /f
reg add "HKCR\CABFolder\Shell\RunAs" /v "HasLUAShield" /t REG_SZ /d "" /f       
reg add "HKCR\CABFolder\Shell\RunAs\Command" /ve /t REG_SZ /d "cmd /k DISM /online /add-package /packagepath:\"%%1\"" /f

:: - open scripts in notepad to preview instead of executing when clicking
for %%a in (
    "batfile"
    "chmfile"
    "cmdfile"
    "htafile"
    "jsefile"
    "jsfile"
	"jsonfile"
    "regfile"
    "sctfile"
    "shfile"
    "inifile"
    "pyfile"
    "urlfile"
    "vbefile"
    "vbsfile"
    "wscfile"
    "wsffile"
    "wsfile"
    "wshfile"
    "xmlfile"
) do (
    ftype %%a="%ProgramFiles%\Notepad++\Notepad++.exe" "%1"
)

:: remove '- Shortcut' text added onto shortcuts
%admuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d "00000000" /f

:: - harden process mitigations (lower compatibilty for legacy apps)
:: %powshcmd% "Set-ProcessMitigation -System -Enable DEP, EmulateAtlThunks, RequireInfo, BottomUp, HighEntropy, StrictHandle, CFG, StrictCFG, SuppressExports, SEHOP, AuditSEHOP, SEHOPTelemetry, ForceRelocateImages"

echo Removing all installed non-required Windows Packages. Enter to continue

pause
%uacadmuser% %powshcmd% "Get-AppPackage | Remove-AppPackage"
:: cls 

echo Adding various utilities using winget - NEED LAN!
pause

  %uacadmuser% %powshcmd% add-appxpackage -Path "%usedir%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id Git.Git --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id  Microsoft.Sysinternals.ProcessMonitor --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id  Microsoft.Sysinternals.ProcessExplorer --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id Microsoft.Powershell --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id Mozilla.Firefox --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id 7zip.7zip --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id VideoLAN.VLC --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id GIMP.GIMP --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id TheDocumentFoundation.LibreOffice --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id Piriform.Recuva --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id Piriform.Defraggler --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id Notepad++.Notepad++ --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id Nlitesoft.NTLite --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id Malwarebytes.Malwarebytes --source winget
  %uacadmuser% %powshcmd% %wingetinstdcmd% --id SaferNetworking.SpybotAntiBeacon --source winget
  %uacadmuser% %powshcmd% winget remove --id Microsoft.Edge --accept-source-agreements --disable-interactivity
  %uacadmuser% %powshcmd% winget remove --id Microsoft.OneDrive --accept-source-agreements --disable-interactivity

echo  Updating Windows. DO NOT CLOSE THIS WINDOW!
  %uacadmuser% %powshcmd% winget upgrade --accept-source-agreements --disable-interactivity --include-unknown -r

echo Setting up PSWindowsUpdate for unattended upgrades

  %uacadmuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Bypass
  %uacadmuser% %powshcmd% Install-Module PSWindowsUpdate
  %uacadmuser% %powshcmd% Import-Module PSWindowsUpdate
  %uacadmuser% %powshcmd% Get-WindowsUpdate -AcceptAll -Install
  %uacadmuser% %powshcmd% Install-WindowsUpdate
  %uacadmuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Restricted

  %gitget% clone -b middle https://github.com/threader/AltanOS %usedir%\..

echo Setting up finishing .reg.
  %admuser% %powshcmd% reg load %usedir%\..\AltanOS\bin\registry\clean.reg

%admuser% %powshcmd% DISM /Online /Disable-Feature /FeatureName:WindowsMediaPlayer /norestart
%admuser% %powshcmd% DISM /Online /Disable-Feature /FeatureName:Internet-Explorer-Optional-amd64 /norestart
%admuser% %powshcmd% DISM /Online /Disable-Feature /FeatureName:Internet-Explorer-Optional-x86 /norestart
 %admuser% %powshcmd% DISM /online /enable-feature /featurename:HypervisorPlatform /all /norestart
 %admuser% %powshcmd% DISM /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
:: %admuser% %powshcmd% DISM /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
:: %admuser% %powshcmd% Enable-WindowsOptionalFeature applicaonalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
:: %admuser% %powshcmd% wsl --set-default-version 2

 %uacadmuser% %msipkg% %usedir%\TinyWall-v3-Installer.msi

 echo info: cleaning the winsxs folder
 %admuser% %powshcmd% DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase
:: %admuser% %powshcmd% sfc /SCANNOW
:: %admuser% %powshcmd% DISM /Online /Cleanup-Image /RestoreHealth

pause
exit
