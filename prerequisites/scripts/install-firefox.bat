@echo off
setlocal EnableDelayedExpansion

dism > nul 2>&1 || echo error: administrator privileges required && pause && exit /b 1

set "aria2c=C:\prerequisites\aria2c.exe"
set "link=https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-GB"
set "setup=FirefoxSetup.exe"
set "install_dir=C:\Program Files\Mozilla Firefox"
set "policies=!install_dir!\distribution\policies.json"

echo info: checking for an internet connection
ping archlinux.org > nul 2>&1
if not !errorlevel! == 0 (
    echo error: no internet connection
    echo info: press any key to continue
    pause > nul 2>&1
    exit /b 1
)

if not exist "!aria2c!" (
    echo error: !aria2c! not exists
    echo info: press any key to continue
    pause > nul 2>&1
    exit /b 1
)

if exist "!setup!" (
    del /f /q "!setup!"
)

echo info: downloading firefox
"!aria2c!" "!link!" -d "!temp!" -o "!setup!"

if not exist "!temp!\!setup!" (
    echo error: download unsuccessful
    echo info: press any key to continue
    pause > nul 2>&1
    exit /b 1
)

taskkill /F /IM "Firefox.exe" > nul 2>&1

echo info: installing firefox
"!temp!\!setup!" /S /MaintenanceService=false

del /f /q "!temp!\!setup!"

echo info: removing bloatware
for %%a in (
    "crashreporter.exe"
    "crashreporter.ini"
    "defaultagent.ini"
    "defaultagent_localized.ini"
    "default-browser-agent.exe"
    "maintenanceservice.exe"
    "maintenanceservice_installer.exe"
    "pingsender.exe"
    "updater.exe"
    "updater.ini"
    "update-settings.ini"
) do (
    del /f /q "!install_dir!\%%~a" > nul 2>&1
)

echo info: importing policies
del /f /q "!policies!" > nul 2>&1
mkdir "!install_dir!\distribution" > nul 2>&1

>> "!policies!" echo {
>> "!policies!" echo     "policies": {
>> "!policies!" echo         "DisableAppUpdate": true,
>> "!policies!" echo         "OverrideFirstRunPage": "",
>> "!policies!" echo         "DisableFirefoxStudies": true,
>> "!policies!" echo         "DisableTelemetry": true,
>> "!policies!" echo         "Extensions": {
>> "!policies!" echo             "Install": [
>> "!policies!" echo                 "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
>> "!policies!" echo             ]
>> "!policies!" echo         }
>> "!policies!" echo     }
>> "!policies!" echo }

echo info: done
echo info: press any key to continue
pause > nul 2>&1
exit /b 0
