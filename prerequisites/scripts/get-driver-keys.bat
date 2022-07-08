@echo off

sc query Winmgmt | findstr "RUNNING" > NUL
if not %errorlevel% == 0 (
    echo error: WMI Service is disabled
    pause
    exit /b 1
)

for %%a in (Win32_VideoController, Win32_NetworkAdapter ) do (
    for /f "delims=" %%b in ('wmic path %%a get PnPDeviceID ^| findstr /l "PCI\VEN_"') do (
        for /f "tokens=3" %%c in ('reg query "HKLM\SYSTEM\ControlSet001\Enum\%%b" /v "Driver"') do (
            for /f %%d in ('echo %%c ^| findstr "{"') do (
                echo %%a : %%d
            )
        )
    )
    echo.
)

pause
exit /b 0