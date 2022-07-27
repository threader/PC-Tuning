# Configure the AMD Driver

- To be expanded in the future, follow [this guide](https://docs.google.com/document/d/1Vd5WKWhm77sG8o9xBoSNRuAWRTavLqynJ7aQhVrsa8Y/edit#heading=h.hgpjx6g7xmp6) for now.

- Disable HDCP in the Display section under overrides in the radeon software.

- Disable FreeSync, it's poorly implemented compared to NVIDIA's G-Sync.

- Open CMD and run the commands below. Ensure to change the driver key to suit your needs.

    - Run ``C:\prerequisites\scripts\get-driver-keys.bat`` to get the driver keys on your system

        ```bat
        set "key=0000"
        set "path=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"

        Reg.exe add "%path%\%key%" /v "DisableDMACopy" /t REG_DWORD /d "1" /f
        Reg.exe add "%path%\%key%" /v "DisableBlockWrite" /t REG_DWORD /d "0" /f
        Reg.exe add "%path%\%key%" /v "StutterMode" /t REG_DWORD /d "0" /f
        Reg.exe add "%path%\%key%" /v "EnableUlps" /t REG_DWORD /d "0" /f
        Reg.exe add "%path%\%key%" /v "PP_SclkDeepSleepDisable" /t REG_DWORD /d "1" /f
        Reg.exe add "%path%\%key%" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d "0" /f
        Reg.exe add "%path%\%key%" /v "DisableDrmdmaPowerGating" /t REG_DWORD /d "1" /f
        Reg.exe add "%path%\%key%\UMD" /v "Main3D_DEF" /t REG_SZ /d "1" /f
        Reg.exe add "%path%\%key%\UMD" /v "Main3D" /t REG_BINARY /d "3100" /f
        Reg.exe add "%path%\%key%\UMD" /v "FlipQueueSize" /t REG_BINARY /d "3100" /f
        Reg.exe add "%path%\%key%\UMD" /v "ShaderCache" /t REG_BINARY /d "3200" /f
        Reg.exe add "%path%\%key%\UMD" /v "Tessellation_OPTION" /t REG_BINARY /d "3200" /f
        Reg.exe add "%path%\%key%\UMD" /v "Tessellation" /t REG_BINARY /d "3100" /f
        Reg.exe add "%path%\%key%\UMD" /v "VSyncControl" /t REG_BINARY /d "3000" /f
        Reg.exe add "%path%\%key%\UMD" /v "TFQ" /t REG_BINARY /d "3200" /f
        ```
