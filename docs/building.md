# Build Instructions

## Build Requirements

- [7-Zip](https://www.7-zip.org)
- [win-wallpaper](https://github.com/amitxv/win-wallpaper/releases)
    - Place the ``win-wallpaper.exe`` in ``C:\Windows``
- Deployment Tools from the [Windows ADK](https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install)

## Downloading an Image

- Use the [download links spreadsheet](https://docs.google.com/spreadsheets/d/1zTF5uRJKfZ3ziLxAZHh47kF85ja34_OFB5C5bVSPumk/edit#gid=0) to download stock Windows images.

    - For Windows 7 i recommend ``en_windows_7_professional_with_sp1_x64_dvd_u_676939.iso``

    - Ensure to cross-check the hashes for the image with other online sources such as the [adguard hash database](https://files.rg-adguard.net/version/f0bd8307-d897-ef77-dbd6-216fefbe94c5?lang=en-us) to verify that the image is genuine & not corrupted

## Preparing the Build Environment

- Extract the image to a directory of your choice with 7-Zip. In the examples below, i am using ``C:\Win10_21H2_English_x64``

- Open CMD as Administrator & configure these variables below. These variables are temporary for this session & will be discarded if you close the terminal window so ensure to keep it open throughout the build process.

    ```bat
    set "EXTRACTED_IMAGE=C:\Win10_21H2_English_x64"

    set "MOUNT_DIR=C:\temp"

    set "OSCDIMG=C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"

    if exist "%MOUNT_DIR%" (rd /s /q "%MOUNT_DIR%")

    mkdir "%MOUNT_DIR%"
    ```

- If the environment was configured correctly, the commands below should return ``true``.

    ```bat
    if exist "%EXTRACTED_IMAGE%" (echo true) else (echo false)

    if exist "%MOUNT_DIR%" (echo true) else (echo false)

    if exist "%OSCDIMG%" (echo true) else (echo false)
    ```

## Stripping Non-Essential Editions

- Remove every edition except the pro edition, by retrieving the indexes of every other edition & removing it with the commands below.

    ```bat
    DISM /Get-WimInfo /WimFile:"%EXTRACTED_IMAGE%\sources\install.wim"
    DISM /Delete-Image /ImageFile:"%EXTRACTED_IMAGE%\sources\install.wim" /Index:[INDEX]
    ```

- Once completed, the only edition available should be the pro edition at index 1.

## Mounting the Image

- Mounting the image with the command below will allow us to carry out a few tasks.

    ```bat
    DISM /Mount-Wim /WimFile:"%EXTRACTED_IMAGE%\sources\install.wim" /Index:1 /MountDir:"%MOUNT_DIR%"
    ```

## Integrating Updates

- Windows 7 Recommended Updates:

    ```
    KB2670838 - platform update + directX 11.1
    KB2864202 - required for the generic USB driver (if you use it)
    KB4474419 - SHA signing update
    KB4490628 - SHA signing update
    KB2990941 - NVME/M.2
    KB3087873 - NVME/M.2
    ```

- Windows 10 Recommended Updates:

    - Download the latest non-security update along with the servicing stack for that specific update. Use the official [Windows Update history page](https://support.microsoft.com/en-us/topic/windows-10-update-history-93345c32-4ae1-6d1c-f885-6c0b718adf3b) to get the relevant updates

- Download the updates from the [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/Home.aspx) by searching for the KB identifier. Place the updates somewhere easily accessible such as ``C:\updates``.

- Integrate the updates into the install wim with the command below.

    - Note: The Servicing Stack must be installed before installing the Cumulative Update, this generally only applies to Windows 10

    ```bat
    DISM /Image:"%MOUNT_DIR%" /Add-Package /PackagePath="C:\updates\KB2670838.msu"
    ```

## Enable .NET 3.5

- Windows 10+ Only:

```bat
DISM /Image:"%MOUNT_DIR%" /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:"%EXTRACTED_IMAGE%\sources\sxs"
```

## Enable Legacy Components for older games

- Windows 10+ Only:

```bat
DISM /Image:"%MOUNT_DIR%" /Enable-Feature /FeatureName:DirectPlay /All
 ```

 ## Integrating & Obtaining Drivers

 - This is generally required for users installing Windows 7 to integrate USB/ NVME drivers so that setup can proceed.

 - Place all of the drivers to be integrated somewhere easily accessible such as ``C:\drivers`` & use the command below to integrate them into the install wim.

```bat
DISM /Image:"%MOUNT_DIR%" /Add-Driver /Driver:"C:\drivers" /Recurse
```

## Integrating Required Files

- Open the mounted directory with the command below.

    ```bat
    explorer "%MOUNT_DIR%"
    ```

- Clone the repository & place the ``prerequisites`` folder & ``debloat.sh`` in the mounted directory.

## Remove Provisioned Appx Bloatware

- Windows 10+ Only.

- This command removes the majority of Windows Apps such as Microsoft Store, Maps, Camera etc that nobody uses & potentially jeopardizes privacy.

    ```bat
    for /f "tokens=3" %i in ('DISM /Image:"%MOUNT_DIR%" /Get-ProvisionedAppxPackages ^| findstr "PackageName"') do (DISM /Image:"%MOUNT_DIR%" /Remove-ProvisionedAppxPackage /PackageName:%i)
    ```

## Replacing Wallpapers

- Run the command below to replace all backgrounds & user profile images with solid black images.

    - Note: Also use the ``--win7`` argument if building Windows 7

    ```bat
    win-wallpaper.exe --dir "%MOUNT_DIR%" --rgb #000000
    ```

## Unmount & Commit

- Run the command below to save the changes to the image.

    ```bat
    DISM /Unmount-wim /MountDir:"%MOUNT_DIR%" /Commit
    ```

## Replace Windows 7 Boot Wim

- Windows 7 Only:

    - As you are aware, Windows 7 lacks driver support for modern hardware & you should have already integrated drivers into the install.wim however we have not yet touched the boot.wim (installer). We *could* integrate the same drivers into the boot.wim as we did before but in my experience this still leads to a problematic installation. Instead, we can use the Windows 10 boot.wim which already has modern hardware support to install our Windows 7 install.wim.

    - The process is quite simple:

        - Download the [latest Windows 10 image](https://www.microsoft.com/en-gb/software-download/windows10) & extract it, i would recommend renaming the extracted folder to avoid confusion. In the examples below, i have extracted it to ``C:\W10_image``

        - Replace ``sources\install.wim`` in the extracted Windows 10 image with the Windows 7 ``install.wim``

    - We need to update a variable since our extracted directory has changed. Enter the path of your new extracted directory, mine is ``C:\W10_image``.

        ```bat
        set "EXTRACTED_IMAGE=C:\W10_image"
        ```

## Insert DISM Apply-Image Script

- Open the extracted directory with the command below.

    ```bat
    explorer "%EXTRACTED_IMAGE%"
    ```

- Place the ``install.bat`` script in the directory.

## Convert to ISO

- Use the following commands to convert the extracted image to a ISO which will be created on the desktop:

```bat
"%OSCDIMG%" -m -o -u2 -udfver102 -l"final_iso" -bootdata:2#p0,e,b"%EXTRACTED_IMAGE%\boot\etfsboot.com"#pEF,e,b"%EXTRACTED_IMAGE%\efi\microsoft\boot\efisys.bin" "%EXTRACTED_IMAGE%" "%userprofile%\Desktop\final_iso.iso"
```
