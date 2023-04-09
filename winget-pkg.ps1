
Write-Output "Removing non-essential packages and installing some bare minimums"
 Get-AppPackage | Remove-AppPackage
 Get-AppxPackage -allusers Microsoft.VCLibs* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.NET.CoreRuntime* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.NET.Native* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.NET.Native.Runtime* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.NET.Native.Framework.1.7* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.NET.Native.Framework.2.2* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.UI.Xaml* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.PackageManagement.NuGetProvider* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.UI.Xaml.2.7* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.WindowsStore* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.StorePurchaseApp* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
## Get-AppxPackage -allusers Microsoft.MicrosoftOfficeHub* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
## Get-AppxPackage -allusers Microsoft.Windows.Search* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.WindowsCalculator* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.MSPaint* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
 Get-AppxPackage -allusers Microsoft.MicrosoftSolitaireCollection* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

$DesktopPath = [Environment]::GetFolderPath("Desktop")
# Invoke-WebRequest -uri https://globalcdn.nuget.org/packages/microsoft.ui.xaml.2.8.2.nupkg -OutFile $DesktopPath\AltanOS.inst\microsoft.ui.xaml.2.8.2.nupkg
if (-not (Test-Path "$DesktopPath\AltanOS.inst\Microsoft.DesktopAppInstaller.msixbundle")) {
Invoke-WebRequest -uri https://github.com/microsoft/winget-cli/releases/download/v1.4.10173/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile $DesktopPath\AltanOS.inst\Microsoft.DesktopAppInstaller.msixbundle
# Install-Package https://globalcdn.nuget.org/packages/microsoft.ui.xaml.2.8.2.nupkg
}
add-appxpackage -Path "$DesktopPath\AltanOS.inst\Microsoft.DesktopAppInstaller.msixbundle"

Write-Output "Installing a set of applications and updating all recognized by 'winget'"
pause
winget install --disable-interactivity --accept-source-agreements --id Git.Git --source winget
winget install --disable-interactivity --accept-source-agreements --id Microsoft.Sysinternals.ProcessMonitor --source winget
winget install --disable-interactivity --accept-source-agreements --id Microsoft.Sysinternals.ProcessExplorer --source winget
winget install --disable-interactivity --accept-source-agreements --id Microsoft.Powershell --source winget
winget install --disable-interactivity --accept-source-agreements --id Mozilla.Firefox --source winget
winget install --disable-interactivity --accept-source-agreements --id 7zip.7zip --source winget
winget install --disable-interactivity --accept-source-agreements --id VideoLAN.VLC --source winget
winget install --disable-interactivity --accept-source-agreements --id GIMP.GIMP --source winget
winget install --disable-interactivity --accept-source-agreements --id TheDocumentFoundation.LibreOffice --source winget
winget install --disable-interactivity --accept-source-agreements --id Piriform.Recuva --source winget
winget install --disable-interactivity --accept-source-agreements --id Piriform.Defraggler --source winget
winget install --disable-interactivity --accept-source-agreements --id Notepad++.Notepad++ --source winget
winget install --disable-interactivity --accept-source-agreements --id Nlitesoft.NTLite --source winget
winget install --disable-interactivity --accept-source-agreements --id Malwarebytes.Malwarebytes --source winget
winget install --disable-interactivity --accept-source-agreements --id SaferNetworking.SpybotAntiBeacon --source winget
# winget remove --id Microsoft.Edge --accept-source-agreements --disable-interactivity
# winget remove --id Microsoft.OneDrive --accept-source-agreements --disable-interactivity
winget upgrade --accept-source-agreements --disable-interactivity --include-unknown -r

Write-output "Installing PSWindowsUpdate and running Win Update, warnings will ensue"
Set-ExecutionPolicy -ExecutionPolicy Bypass
Install-Module PSWindowsUpdate
Import-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install
# Install-WindowsUpdate
Set-ExecutionPolicy -ExecutionPolicy Restricted
pause