# Pre-Installation Instructions

## Activation

Consider activating before configuring the image as the key will be permanently linked to your motherboard & you will not be forced to run activation scripts once booted into the image. This can be done with a legitimate key or with [massgravel's scripts](https://github.com/massgravel/Microsoft-Activation-Scripts).

## Configure Partitions

It is recommended to configure at least a [dual-boot](https://en.wikipedia.org/wiki/Multi-booting) to separate work & gaming environments. This way you will not be forced to install bloatware on your gaming partition & full functionality of the operating system will be guaranteed for when you need it. You can do this by [shrinking a volume](https://docs.microsoft.com/en-us/windows-server/storage/disk-management/shrink-a-basic-volume) in disk management.

## Obtaining a Base Image

- ## The Nature of Windows

    Generally, Windows 7 & 8 are superior for real-time tasks compared to it's successors but lacks USB & NVME driver support for newer hardware. Earlier versions of Windows lack GPU driver & anticheat support so some users are forced on newer builds. Microsoft implemented a fixed 10mhz QueryPerformanceFrequency on Windows 10 1809+ which was intended to make developing applications easier but many users reported worse performance. Windows 10 1903+ has an updated scheduler for multi CCX Ryzen CPUs [[1](https://i.redd.it/y8nxtm08um331.png)]. Microsoft changed the way timer resolution functions as explained in [this article](https://randomascii.wordpress.com/2020/10/04/windows-timer-resolution-the-great-rule-change/) on Windows 10 2004+ & was [further developed in Windows 11](https://twitter.com/amitxv/status/1491357305535070211) which I assume is an attempt to improve power efficiency. However it's not all doom and gloom with newer builds, there are a few noteworthy improvements such as newer WDDMs & improvements to the flip model [[1](https://devblogs.microsoft.com/directx/dxgi-flip-model/)]. 


The post-installation instructions are based on configuring a stock Windows image along a few modifications made to the image beforehand.

- See [docs/building.md](../docs/building.md) to create the base image.

## Preparing the USB

- Download [Ventoy](https://github.com/ventoy/Ventoy/releases) & [Linux Mint Xfce Edition](https://linuxmint.com/edition.php?id=294) if you have not already.

- Insert your USB stick into a USB port & extract Ventoy.

- Open ``Ventoy2Disk.exe``. Go to ``Option > Partition Style`` & select GPT (UEFI) or MBR (Legacy).

    - See [media/identify-bios-mode.png](../media/identify-bios-mode.png)

- Select your USB storage & press install.

- Once Ventoy has installed on your USB storage device, simply drag & drop the linux mint iso file into the USB in file explorer. This will be used for debloating in the post-installation instructions.

## Booting Into the Image

For the next steps, it is *vital* that you unplug your ethernet cable & are not connected to the internet. This will allow us to bypass the otherwise forced microsoft login during OOBE & will prevent Windows from fetching updates. 

You can either:

- Use a USB

    - Drag & drop the iso into the same location where linux mint is & select the USB storage device in the boot options in BIOS.

    - Note: When installing Windows 8 pro with a USB, you may be required to enter a key. Use the generic key ``GCRJD-8NW9H-F2CDX-CCM8D-9D6T9`` to get past this step.

        
    OR

- Use DISM Apply-Image

    - Create a new partition by [shrinking a volume](https://docs.microsoft.com/en-us/windows-server/storage/disk-management/shrink-a-basic-volume) & assign it a drive letter. Extract the image & run ``install.bat.`` Enter the drive letter for the partition you just created & reboot your PC.
