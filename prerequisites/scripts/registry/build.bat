@echo off

:: Requirements
::
:: - Python 3.8.6 preferred
:: - 7-Zip

set "path_err=0"
for %%i in (
    "python.exe",
    "pip.exe",
) do (
    where %%i
    if not %errorlevel% == 0 (
        set "path_err=1"
        echo error: %%i not found in path
    )
)
if not %path_err% == 0 exit /b

set "CURRENT_DIR=%~dp0"
set "CURRENT_DIR=%CURRENT_DIR:~0,-1%"

set "BUILD_ENV=%CURRENT_DIR%\BUILD_ENV"
set "PROJECT_DIR=%BUILD_ENV%\main"
set "PUBLISH_DIR=%BUILD_ENV%\apply-registry"

if exist "%BUILD_ENV%" (
    rd /s /q "%BUILD_ENV%"
)
mkdir "%BUILD_ENV%"
mkdir "%PROJECT_DIR%"

python -m venv "%BUILD_ENV%"
call "%BUILD_ENV%\Scripts\activate.bat"

copy /y "%CURRENT_DIR%\apply-registry.py" "%PROJECT_DIR%"
cd "%PROJECT_DIR%"

pyinstaller "apply-registry.py" --onefile --uac-admin

call "%BUILD_ENV%\Scripts\deactivate.bat"

cd "%CURRENT_DIR%"

if exist "apply-registry.exe" (
    del /f /q "apply-registry.exe"
)

move "%PROJECT_DIR%\dist\apply-registry.exe" "%CURRENT_DIR%"

rd /s /q "%BUILD_ENV%"

exit /b
