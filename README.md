# EVA

A highly structured & technical hardware, BIOS & Windows optimization guide dedicated for performance, privacy & latency enthusiasts.

Contact: https://twitter.com/amitxv


[![Discord](https://discord.com/api/guilds/994887453599076422/widget.png?style=shield)](https://discord.gg/yrAnChXXZw)

## Content Overview

- [Introduction](#introduction)
- [Abstract](#abstract)
- [Requirements](#requirements)
- [Physical Setup](#physical-setup)
- [Pre-Installation Instructions](#pre-installation-instructions)
- [Post-Installation Instructions](#post-installation-instructions)
- [Research](#research)

## Introduction

EVA is no longer a custom Windows ISO. Instead, i have created a guide in hope of teaching you how to create your own image & optimize other aspects of your setup. Nothing in this guide is branded, i have chosen to use the old project's name so that it acts as a direct replacement. On that note, i advise against using the custom images from the old project as they have been recreated with malicious content by other people.

The setup & build process is similar to [AME's](https://ameliorated.info) in terms of debloating via Linux, i have used elements of their shell script in my own.

You should follow this guide with the mindset of configuring something (e.g usb port layout, graphics driver etc) once & do not intend on re-configuring it later on. The guide is structured so that modifications can be made without reverting other changes in the future. Configure everything once in stone & leave as is. 

It is important to note that you should be comfortable with reinstalling Windows if anything goes wrong.

## Abstract

[What is System Latency | NVIDIA GeForce](https://www.youtube.com/watch?v=h69JR51pZbU)

[Why System Latency Matters - ft n0thing | NVIDIA GeForce](https://www.youtube.com/watch?v=muvToLXJSks)

[Applied Sciences Group: High Performance Touch | Microsoft Research](https://youtu.be/vOvQCPLkPt4?t=51)

The objective is to end up with a relatively *bare*, reliable & consistent system by tuning the BIOS & operating system to reduce unnecessary interrupts & [context switching](https://en.wikipedia.org/wiki/Context_switch), prevent other applications from stealing execution time from our realtime application (games) & most importantly, correctly configuring our hardware.

Some elements of this guide are not directly performance related & are just personalization related as i cover configuring the operating system from start to finish. Very rarely, some elements may also be highly opinionated however i have tried my best to provide technical references, evidence, my own research & a valid justification to the information provided to prevent making changes that would otherwise make your system perform worse than stock. Feel free to challange any given information so that it can be reviewed.

The guidance is currently updated & have been tested on the following versions of Windows:

- Windows 7 SP1

- Windows 10 21H2


## Requirements

- USB Storage Device (8gb minimum)
- [Ventoy]
- [Linux Mint Xfce Edition]
- Familiarity with the command-line interface (or the will to learn!)
- Ethernet & at least one SSD/NVME (wake up, it's not 2006 anymore)

## Physical Setup

- See [docs/physical-setup.md]

## Pre-Installation Instructions

- See [docs/pre-install.md]

## Post-Installation Instructions

- See [docs/post-install.md]
## Research

- See [docs/research.md]

## Credits

The following projects & people deserve recognition for their research, knowledge & overall contribution to the community. Please note that this guide may contain information similar to those of the projects listed below however it is not my intention to directly copy from them, in some circumstance it is unavoidable.

- [AME](https://ameliorated.info/)
- [Bored](https://github.com/BoringBoredom/PC-Optimization-Hub)
- [Calypto](https://docs.google.com/document/d/1c2-lUJq74wuYK1WrA_bIvgb89dUN0sj8-hO3vqmrau4/edit)
- [Phlegm](https://twitter.com/getggos)
- [Revision](https://sites.google.com/view/meetrevision)
- [Timecard](https://github.com/djdallmann/GamingPCSetup/)

[Ventoy]: https://github.com/ventoy/Ventoy/releases

[Linux Mint Xfce Edition]: https://linuxmint.com/edition.php?id=294

[docs/physical-setup.md]: ./docs/physical-setup.md

[docs/pre-install.md]: ./docs/pre-install.md

[docs/post-install.md]: ./docs/building.md

[docs/research.md]: ./docs/research.md
