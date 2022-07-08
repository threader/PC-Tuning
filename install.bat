@echo off
SETLOCAL EnableDelayedExpansion

pushd "%~dp0"
if not exist "sources\install.wim" (
	echo error: directory does not appear to be a windows image
	pause
	exit /b 1
)

:select_drive
set /p INSTALL_DIR="Enter the drive letter you created to install windows on: "

set "err=0"
if defined INSTALL_DIR (
	if exist "!INSTALL_DIR!:" (
		if exist "autounattend.xml" (
			DISM /Apply-Image /ImageFile:"sources\install.wim" /Apply-Unattend:"autounattend.xml" /Index:1 /ApplyDir:"!INSTALL_DIR!:"
			if not !errorlevel! == 0 (
				set "err=1"
			) else (
				copy /y "autounattend.xml" "!INSTALL_DIR!:\Windows\System32\Sysprep\unattend.xml"
			)
		) else (
			DISM /Apply-Image /ImageFile:"sources\install.wim" /Index:1 /ApplyDir:"!INSTALL_DIR!:"
			if not !errorlevel! == 0 (
				set "err=1"
			) 
		)

		if !err! == 0 (
			bcdboot "!INSTALL_DIR!:\Windows"
			echo info: reboot pc
			pause
			exit /b 0
		) else (
			echo error: dism apply-image unsuccessful
			pause
			exit /b 1
		)
	)
)

echo error: invalid input
goto select_drive