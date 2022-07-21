@echo off
setlocal EnableDelayedExpansion

pushd "%~dp0"

set "install_wim="
if exist "sources\install.wim" (
	set "install_wim=sources\install.wim"
) else (
	if exist "sources\install.esd" (
		set "install_wim=sources\install.esd"
	) else (
		echo error: directory does not appear to be a windows image
		pause
		exit /b 1
	)
)

:select_drive
set /p install_dir="Enter the drive letter you created to install windows on: "

set "err=0"
if defined install_dir (
	if exist "!install_dir!:" (
		if exist "autounattend.xml" (
			DISM /Apply-Image /ImageFile:"!install_wim!" /Apply-Unattend:"autounattend.xml" /Index:1 /ApplyDir:"!install_dir!:"
			if not !errorlevel! == 0 (
				set "err=1"
			) else (
				copy /y "autounattend.xml" "!install_dir!:\Windows\System32\Sysprep\unattend.xml"
			)
		) else (
			DISM /Apply-Image /ImageFile:"!install_wim!" /Index:1 /ApplyDir:"!install_dir!:"
			if not !errorlevel! == 0 (
				set "err=1"
			) 
		)

		if !err! == 0 (
			bcdboot "!install_dir!:\Windows"
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
goto :select_drive