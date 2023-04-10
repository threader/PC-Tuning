New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" `
    -Name "Update Windows and applications" `
    -Value "C:\Path\To\MyApplication.exe"

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Application" -Value "C:\Path\To\MyApplication.exe"  -PropertyType "String"
