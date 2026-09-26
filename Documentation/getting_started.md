# Getting Started with lva-os

## Installing lva-os

Firstly, you have to install lva-os to a storage medium, which you will need to plug into the host machine for lva-os. **Keep in mind lva-os is directly installed and will be ran off that storage medium and not run another installer(ie like how HAOS is installed).**

### A) Use lva-installer(recommended)

Lva-os has a dedicated os-installer called [lva-installer](https://github.com/aryanhasgithub/lva-installer), and instructions to use it can be found [here](https://github.com/aryanhasgithub/lva-installer/blob/main/docs/use_lva_installer.md).

### B) Use your own flasher
**With a custom flasher you wont be able to write wifi and password credentials to the os.**

If you want to use a custom installer, you can download the right image for your board from the GitHub release pages.

## Getting Started with Running lva-os

Now, once your storage medium is ready plug it in to the host machine and if all goes well you should be booted into lva-os. Keep in mind it might take some time to get everything set-up initially before you can see the cli.

### The first boot

On the first boot, lva-os pulls the latest portal and lva images, you can track this progress by going to the ip displayed in the CLI, once pulled you should be redirected to the portal ip.

### Using lva-os

To get started with lva with Home Assistant, you need to visit your HA instance's "Devices and services" section, where you should see your satellite ready to be set-up, in case this dosen't work you can add the esphome integration and enter in the ip address for your satellite.

Further docs on how to use lva itself, and config options(which you can change using the portal with lva-os instead of env) can be found [here](https://github.com/OHF-Voice/linux-voice-assistant/tree/main/docs).

The part you will interact the most with lva-os will be the lva-portal, the portal gives you config options for lva, system stats, update management, logs and networking, allowing you to manage your satellite with a neat web interface.

All updates are triggered manually, so when you want to update you can!

