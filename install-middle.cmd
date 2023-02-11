
@echo on
cls
echo Setting up and updating DO NOT CLOSE THIS WINDOW!
pause

:: set other variables
set "currentuser=.\bin\NSudo_9.0_Preview1_9.0.2676.0\x64\NSudoLC.exe  -Priority:AboveNormal -UseCurrentConsole -M:S -U:E -P:E --wait"
set "uwpuser=.\bin\NSudo_9.0_Preview1_9.0.2676.0\x64\NSudoLG.exe  -Priority:AboveNormal -UseCurrentConsole -M:S -U:E -P:E --wait"
set "wingetinstdcmd=winget install --disable-interactivity --accept-source-agreements"
set "powshcmd=PowerShell -WindowStyle Normal -NoProfile -Command" 

SETLOCAL EnableDelayedExpansion

echo Will need net for this 
:: ping -n 6 8.8.8.8
pause

:: make certain applications in request UAC
:: although these applications may already request UAC, setting this compatibility flag ensures they are ran as administrator
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "bin/NSudo_9.0_Preview1_9.0.2676.0\x64\NSudoLC.exe" /t REG_SZ /d "~ RUNASADMIN" /f


:: disable autoplay and autorun
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d "255" /f 
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoAutoplayfornonVolume" /t REG_DWORD /d "1" /f

:: disable USB autorun/play
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d "1" /f

:: change ntp server from windows server to pool.ntp.org
w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"
sc queryex "w32time" | find "STATE" | find /v "RUNNING" || (
    net stop w32time
    net start w32time
)

:: disable netbios over tcp/ip
:: works only when services are enabled
for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" /s /f "NetbiosOptions" ^| findstr "HKEY"') do (
     reg add "%%b" /v "NetbiosOptions" /t REG_DWORD /d "2" /f
)

:: netbios hardening
:: netbios is disabled. if it manages to become enabled, protect against NBT-NS poisoning attacks
%currentuser% %powshcmd% reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" /v "NodeType" /t REG_DWORD /d "2" /f

:: restrict anonymous access to named pipes and shares
:: https://www.stigviewer.com/stig/windows_10/2021-03-10/finding/V-220932
%currentuser% %powshcmd% reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v "RestrictNullSessAccess" /t REG_DWORD /d "1" /f

:: block anonymous enumeration of sam accounts
:: https://www.stigviewer.com/stig/windows_10/2021-03-10/finding/V-220929
%currentuser% %powshcmd% reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "RestrictAnonymousSAM" /t REG_DWORD /d "1" /f

:: restrict anonymous enumeration of shares
:: https://www.stigviewer.com/stig/windows_10/2021-03-10/finding/V-220930
%currentuser% %powshcmd% reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "RestrictAnonymous" /t REG_DWORD /d "1" /f

:: set strong cryptography on 64 bit and 32 bit .net framework (version 4 and above) to fix a scoop installation issue
:: https://github.com/ScoopInstaller/Scoop/issues/2040#issuecomment-369686748
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\.NetFramework\v4.0.30319" /v "SchUseStrongCrypto" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" /v "SchUseStrongCrypto" /t REG_DWORD /d "1" /f

:: mitigate against hivenightmare/serious sam
icacls %WinDir%\system32\config\*.* /inheritance:e

:: disable nagle's algorithm
:: https://en.wikipedia.org/wiki/Nagle%27s_algorithm
for /f %%i in ('wmic path win32_networkadapter get GUID ^| findstr "{"') do (
     reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f
     reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t REG_DWORD /d "0" /f
     reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
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
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d "1" /f

:: configure file explorer settings
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveSearch" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveTrack" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f

:: disable remote assistance
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fEnableChatControl" /t REG_DWORD /d "0" /f

:: disable audio excludive mode on all devices
for /f "delims=" %%a in ('%uwpuser% reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture"') do (
   %uwpuser% reg add "%%a\Properties" /v "{b3f8fa53-0004-438e-9003-51a46e139bfc},3" /t REG_DWORD /d "0" /f
   %uwpuser% reg add "%%a\Properties" /v "{b3f8fa53-0004-438e-9003-51a46e139bfc},4" /t REG_DWORD /d "0" /f
)

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
%uwpuser% reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /

:: disable devicecensus.exe telemetry process
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\'DeviceCensus.exe'" /v "Debugger" /t REG_SZ /d "%WinDir%\System32\taskkill.exe" /f

:: do not allow pinning microsoft store app to taskbar
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoPinningStoreToTaskbar" /t REG_DWORD /d "1" /f

:: restrict windows' access to internet resources
:: enables various other GPOs that limit access on specific windows services
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\InternetManagement" /v "RestrictCommunication" /t REG_DWORD /d "1" /f

:: disable text/ink/handwriting telemetry
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d "1" /f 

:: disable data collection
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MaxTelemetryAllowed" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowDeviceNameInTelemetry" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitEnhancedDiagnosticDataWindowsAnalytics" /t REG_DWORD /d "0" /f

:: miscellaneous
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" /v "ScenarioExecutionEnabled" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\.\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f

:: disable experimentation
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation" /v "Value" /t REG_DWORD /d "0" /f

:: configure voice activation settings
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationOnLockScreenEnabled" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationEnabled" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationLastUsed" /t REG_DWORD /d "0" /f

:: disable advertising info
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f

:: disable nvidia telemetry
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f

:: disable typing insights
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Input\Settings" /v "InsightsEnabled" /t REG_DWORD /d "0" /f

:: disable cloud optimized taskbars
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableCloudOptimizedContent" /t REG_DWORD /d "1" /f

:: disable annoying keyboard features
%currentuser% reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\C ontrol Panel\Accessibility\MouseKeys" /v "Flags" /t REG_DWORD /d "0" /f

:: hide meet now button on taskbar
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f

:: disable shared experiences
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableCdp" /t REG_DWORD /d "0" /f

:: disable news and interests
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "2" /f

:: location tracking
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice" /v "AllowFindMyDevice" /t REG_DWORD /d "0" /f
%currentuser% %powshcmd% reg add "HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice" /v "LocationSyncEnabled" /t REG_DWORD /d "0" /f

:: do not show hidden/disconnected devices in sound settings
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Multimedia\Audio\DeviceCpl" /v "ShowHiddenDevices" /t REG_DWORD /d "0" /f

:: merge as trusted installer for registry files
reg add "HKCR\regfile\Shell\RunAs" /ve /t REG_SZ /d "Merge As TrustedInstaller" /f
reg add "HKCR\regfile\Shell\RunAs" /v "HasLUAShield" /t REG_SZ /d "1" /f
reg add "HKCR\regfile\Shell\RunAs\Command" /ve /t REG_SZ /d "NSudoLC.exe -U:T -P:E reg import "%%1"" /f

:: install cab context menu
reg delete "HKCR\CABFolder\Shell\RunAs" /f > nul 2>nul
reg add "HKCR\CABFolder\Shell\RunAs" /ve /t REG_SZ /d "Install" /f
reg add "HKCR\CABFolder\Shell\RunAs" /v "HasLUAShield" /t REG_SZ /d "" /f       
reg add "HKCR\CABFolder\Shell\RunAs\Command" /ve /t REG_SZ /d "cmd /k DISM /online /add-package /packagepath:\"%%1\"" /f

:: remove '- Shortcut' text added onto shortcuts
%currentuser% %powshcmd% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d "00000000" /f

echo Removing all installed non-required Windows Packages. Enter to continue

%uwpuser% %powshcmd% "Get-AppPackage | Remove-AppPackage"
pause
:: cls 

echo Adding various utilities using winget - NEED LAN!
pause

%powshcmd% add-appxpackage -Path ".\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
%uwpuser% %powshcmd% winget search Microsoft.PowerShell
%uwpuser% %powshcmd% %wingetinstdcmd% --id Microsoft.Powershell --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id Mozilla.Firefox --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id 7zip.7zip --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id VideoLAN.VLC --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id GIMP.GIMP --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id TheDocumentFoundation.LibreOffice --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id Piriform.Recuva --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id Piriform.Defraggler --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id Notepad++.Notepad++ --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id Nlitesoft.NTLite --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id Malwarebytes.Malwarebytes --source winget
%uwpuser% %powshcmd% %wingetinstdcmd% --id SaferNetworking.SpybotAntiBeacon --source winget
%uwpuser% %powshcmd% winget remove --id Microsoft.Edge --accept-source-agreements --disable-interactivity


echo  Updating Windows. DO NOT CLOSE THIS WINDOW!
%allsuer% %powshcmd% winget upgrade --accept-source-agreements --disable-interactivity --include-unknown -r

echo Setting up PSWindowsUpdate for unattended upgrades

%uwpuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Bypass
%uwpuser% %powshcmd% Install-Module PSWindowsUpdate
%uwpuser% %powshcmd% Import-Module PSWindowsUpdate
%uwpuser% %powshcmd% Get-WindowsUpdate -AcceptAll -Install
%uwpuser% %powshcmd% Install-WindowsUpdate
%uwpuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Restricted

echo Setting up finishing .reg.
%uwpuser% %powshcmd% reg load .\bin\registry\clean.reg

pause
exit
