# LVA-OS

Lva-os (Linux Voice Assistant Operating System) is a Linux-based operating system optimized to host voice assistants and their services.

Lva-os(lva-os) uses Docker as its container engine. By default it deploys the LVA Supervisor as a container, which in turn manages the voice assistant core and supporting services in separate containers. Lva-os is not based on a regular Linux distribution like Ubuntu. It is built using [Buildroot](https://buildroot.org/) and is purpose-built to run a voice assistant stack efficiently. It targets single-board computers (SBC) like the Raspberry Pi but also supports generic x86-64 and AArch64 systems.

## Features

- Lightweight and memory-efficient
- Minimized I/O
- Over The Air (OTA) A/B updates via [RAUC](https://rauc.io/)
- Offline updates
- Web-based management portal (LVA Portal)
- Modular architecture using Docker containers
- AppArmor security profiles

## Supported Hardware

| Board | Architecture |
|---|---|
| Raspberry Pi Zero 2W |   AArch64 |
| Raspberry Pi 3 (64-bit) | AArch64 |
| Raspberry Pi 4 (64-bit) | AArch64 |
| Raspberry Pi 5 (64-bit) | AArch64 |
| Generic x86-64 (UEFI) | x86-64 |
| Generic AArch64 | AArch64 |

## Getting Started
It is recommended to use [lva-installer](https://github.com/aryanhasgithub/lva-installer), which packages the image flasher+downloading steps and allows for injecting WIFI credentials before first-boot in case you do not use ethernet.
Additional instructions for using the os are available at [getting_started.md](docs/getting_started.md).

## Components

- **Bootloader**
  - [GRUB2](https://www.gnu.org/software/grub/) — x86-64 UEFI systems
  - [U-Boot](https://www.denx.de/wiki/U-Boot) — Raspberry Pi 3/4 and Zero 2W
  - tryboot — Raspberry Pi 5
- **Operating System** — [Buildroot](https://buildroot.org/) LTS Linux
- **Container Platform** — [Docker Engine](https://docs.docker.com/engine/)
- **Updates** — [RAUC](https://rauc.io/) for OTA and offline A/B updates
- **Security** — [AppArmor](https://apparmor.net/) Linux kernel security module

## OTA Updates

LVA-OS uses RAUC with an A/B partition scheme for reliable over-the-air updates. Updates are delivered as versioned bundles via a central manifest and can be applied through the LVA Portal. The inactive partition is always updated first, so your system remains fully functional if anything goes wrong.
