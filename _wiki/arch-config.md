---
layout: wiki
title: arch-config
description: my arch linux installation setup
---

# arch-config

## Mirror List
Location: `/etc/pacman.d/mirrorlist`

Select the mirror(s) you want to use for the package manager `pacman`. Delete every other entry or mark it as a comment to ensure that `pacman` is using the right mirror.

You can also install vim (if not already installed on the live disc) with pacman by typing `pacman -Sy vim` for more convenient text editing.

## UEFI or BIOS?
To check if your system is using EFI, run the command:
`ls /sys/firmware/efi`

If the directory exists and contains files then your system is using EFI. If that is not the case you are probably using BIOS and this cheatsheet will probably not work to install Arch Linux on your machine.

## Partitioning
**Attention: This process will wipe your entire harddrive!**

### Listing current drives and partitions
To check which drives are installed on the system and what partitions there are these commands might be helpful:

- `lsblk`
- `cat /proc/partitions`
- `gdisk -l`

### Partitioning your drives
**If your system is using EFI use gdisk for better compatibility**  
Make sure to memorize the partition numbers and which partition is for what purpose.

To partition your drives (your standard harddrive **should** be /dev/sda), utilize the command `gdisk`.  
`gdisk /dev/sdx` where `x` is the driver letter (e.g. "a")

#### Clear the parition table
To clear the partition table type `o` in gdisk  
`Command (? for help): o`

#### Create a new partition
Create a new partition by typing `n`  
`Command (? for help): n`

You will be asked, what number your partition should have. This will be displayed as `/dev/sdaxY` where `x` is the driver letter and `Y` is the partition number.  
After this you will be asked about the *First Sector* and the *Last sector* of the disk. For the *First Sector* you choose the default value.  
For the *Last Sector* you can either specify a number (e.g. 4196) or how big the sector/partition should be. This is done by typing a `+` followed by the size of the sector. For `gdisk` to know if you are using megabytes, gigabytes or something else, you need to specify this by a letter at the end of the line (e.g. `M` for `Megabytes` or G for `Gigabytes`).

`gdisk` now asks for the type of your partition. This is where you want to be specific.  
If you do not have a *EFI Partition* (e.g. when you cleared your partition table) you have to create one. If your drive already has an *EFI Partition* then you can skip this step.   
The *EFI Partition* should be 512 *Megabytes* big and has a hexcode of `EF00`.

You need at least one other partition for the filesystem to go.  

- Create a new partition by typing `n` in the prompt
- Select the size of your partition (depending on if you want to add a seperate `/home` or `swap` partition)
- The standard linux filesystem has a hexcode of `8300`

If you want to add a seperate `/home` partition to your drive, do the same as with the `/` filesystem.

To create a `swap` partition on your drive do the following:

- Create a new partition by typing `n` in the prompt
- Select the size of your partition (a *swap* partition should be at least as big as your *RAM*, the recommended size is 2x of your *RAM*)
- The hexcode of *swap* is `8200`

At last write the changes to the disk with `w`.  
**Make sure to check the drive with `gdisk -l /dev/sdx`!**

#### Formatting the partitions
The `mkfs` command allows you to format a partition to a desired filesystem.  
The *EFI Partition* uses `vfat`. To format it with `vfat` use `mkfs.vfat /dev/sdxY`.  
The linux filesystem uses `ext4`, so your `\` and `\home` partitions should be formatted with `mkfs.ext4 /dev/sdxY`.

To make your *swap Partition* one, use the `mkswap` command.  
To enable your *swap Partition*, use the `swapon /dev/sdxY` command.
To disable a *swap Partition*, use the `swapoff /dev/sdxY` command.

## Installing Arch Linux

### Mounting
To mount a partition, utilize the `mount /dev/sdxY /mount/point` command.  
To unmount a partition, utilize the `umount /dev/sdxY` command.

#### `/`
For convenience we mount the partition where the *root* filesystem should go to `/mnt`.  
Make sure you select the right partition!  
`mount /dev/sdxY /mnt`

#### `/home`
If you have a seperate partition for your `/home` directorys, create a directory in the already mounted *root* filesystem. This directory **NEEDS** to be called `home`.  
`mkdir /mn/home`

After the directory is created, mount the partition where your `/home` directorys should go to the newly created folder.  
`mount /dev/sdxY /mnt/home`

#### `/boot`
The *EFI Partition* goes here.  
First create a directory in the mounted *root* filesystem called `boot` to mount the *EFI Partition*.  
`mkdir /mnt/boot`

When the directory is created, mount the *EFI Partition* to the newly created folder.  
`mount /dev/sdxY /mnt/boot`

### `pacstrap`
To install the filesystem for Arch Linux, we use a tool called `pacstrap` which is included in the live disc.

Assuming you mounted the partition where your *root* filesystem should go is `/mnt`, do the following:  
`pacstrap /mnt`  
This will install all necessary files to that partition.

## `systemd-bootd`
`bootctl` is part of the systemd suite.

To configure `bootctl` we have to enter the newly installed Arch Linux system. This is done via `arch-chroot`.  
`arch-chroot /mnt`

When you are in your Arch system, use the command `bootctl install` to install `bootctl`. It should detect everything it needs by itself.

When this is done, check your `/boot` directory for the necessary files.  
If these are present, move on to the next step.

Now you have configure the `loader.conf` found in `/boot/loader`.  
*Note: The Arch Linux installation you have entered does not contain **vim** as an editor. You have to manually download it using **pacman -S vim**.*  
First, empty `loader.conf`. For now you can copy this configuration file:

	default arch
	timeout 4
	editor 0


Next you need to configure `arch.conf` located in `/boot/loader/entries`.  
Again, for now copy this configuration file:

	title Archlinux
	linux /vmlinuz-linux
	initrd /intel-ucode.img
	initrd /initramfs-linux.img
	options root=PARTUUID="YOUR DRIVE UUID" rw

The first `initrd` line is optional but should be used when using an intel CPU. This will ensure your CPU will get updated before starting the kernel.  
You can install the package by issuing the command `sudo pacman -S intel-ucode`.  
To figure out what *PARTUUID* your drive has, type in this command:  
`blkid -s PARTUUID -o value /dev/sdxY`

## Configuring Arch Linux
### fstab
`fstab` allows your PC to mount partitions on boot.

Generate a *fstab* file (without arch-chroot into the system):  
`genfstab -U /mnt >> /mnt/etc/fstab`

For fstab configuration, see [fstab](https://wiki.archlinux.org/index.php/Fstab).

### Time zone
Set  the time zone:  
`ln -sf /usr/share/zoneinfo/Region/City /etc/localtime`

Run `hwclock` to generate `/etc/adjtime`:  
`hwclock --systohc`  
This command assumes the hardware clock to be set to *UTC*.

### Locale
Uncomment `en_US.UTF-8 UTF-8` and other needed localizations in `/etc/locale.gen`, and generate them with:  
`locale-gen`

Set the **LANG** variable in `/etc/locale.conf` accordingly, for example:  
`LAND=en_US.UTF-8`

If you set the keyboard layout, make the changes persistent in `/etc/vconsole.conf` (does not keep the keyboard layout for *WM*'s or *DE*'s):  
`KEYMAP=de-latin1`

### Hostname
Create `/etc/hostname`:  
`myhostname`

Add matching entries to `/etc/hosts`:  

	127.0.0.1	localhost
	::1		localhost
	127.0.1.1	myhostname.localdomain	myhostname


### Network configuration
Here: [*netctl*](https://wiki.archlinux.org/index.php/Netctl)
Alternatives: *wpa_supplicant*

Copy the example file from `/etc/netctl/examples/wireless-wpa` to `/etc/netctl/mywirelessnetwork` and edit the file accordingly.

### Root password
Set the root password:  
`passwd`

The system is now ready for boot.

Locking the root account:  
`passwd -l root`

Unlocking the root account:  
`sudo passwd -u root`

### User management
Add a new user:  
`useradd -m -g initial_group -G additional_groups -s login_shell username`  
For later convenience with `sudo` and `xbacklight` we set the *initial_group* to `wheel` and the *additional_groups* to `video`. Shells used can be `/bin/bash` or `/usr/bin/zsh`.


### Package manager
Here: [*yay*](https://github.com/Jguer/yay)

Alternatives: [*yaourt*](https://archlinux.fr/yaourt-en), [*trizen*](https://github.com/trizen/trizen)

### Privilege escalation
To temporary grant root privileges to a user, use `sudo`:  
`pacman -S sudo`

To configure sudo to allow the just added user to escalate privileges, we uncommented a line from `/etc/sudoers`:  
`%wheel ALL=(ALL) ALL`

### Display server
Here: [*Xorg*](https://wiki.archlinux.org/index.php/Xorg)

Alternative: [*Wayland*](https://wiki.archlinux.org/index.php/Wayland)

To install *Xorg*:  
`sudo pacman -S xorg-server`

### Graphics driver
Here: [*Noveau*](https://wiki.archlinux.org/index.php/Nouveau)

Alternatives: [*Nvidia*](https://wiki.archlinux.org/index.php/NVIDIA), [*AMD*](https://wiki.archlinux.org/index.php/AMD_Catalyst)

To install the *noveau* drivers:  
`sudo pacman -S mesa`  
The *noveau* drivers should be loaded on default.

For *Nvidia* drivers, you first have to determine what graphics card you use by issuing the command `lspci -k | grep -A 2 -E "(VGA|3D)"`.  
... follow the guide linked above

**NEEDS EDITING**

### Window manager
Here: [*i3-gaps*](https://github.com/Airblader/i3)

Alternatives: [*i3*](https://wiki.archlinux.org/index.php/I3), [*bspwm*](https://wiki.archlinux.org/index.php/Bspwm), [*Awesome*](https://wiki.archlinux.org/index.php/Awesome), [*HerbstluftWM*](https://wiki.archlinux.org/index.php/Herbstluftwm)

Installing *i3-gaps*:  
`yay -S i3-gaps`

### Sound
Here: [*ALSA*](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture), [*PulseAudio*](https://wiki.archlinux.org/index.php/PulseAudio)

*ALSA* is already installed on Linux.  
To install *PulseAudio*:  
`sudo pacman -S pulseaudio pulseaudio-alsa`  
To install bluetooth support and an equalizer, use `sudo pacman -S pulseaudio-bluetooth pulseaudio-equalizer` respectively.

### Time synchronisation
Here: [*systemd-timesyncd*](https://wiki.archlinux.org/index.php/Systemd-timesyncd)

*systemd-timesyncd* is part of the *systemd* suite, which is installed by default.  
To enable *systemd-timesyncd*:  
`timedatectl set-ntp true`

### DNS Security
Here: [*DNSSEC*](https://wiki.archlinux.org/index.php/DNSSEC), [*DNSCrypt*](https://wiki.archlinux.org/index.php/DNSCrypt)

To install *DNSSEC* and *DNSCrypt*:  
`sudo pacman -S ldns`  
`yay -S dnscrypt-proxy-go`

**NEEDS EDITING**

### Firewall
Here: [*Ufw*](https://wiki.archlinux.org/index.php/Uncomplicated_Firewall)

To install *Ufw*:  
`sudo pacman -S ufw`

**NEEDS EDITING**

### MouseAcceleration
Here: with *Xorg*

To disable mouse acceleration, follow [*this*](https://wiki.archlinux.org/index.php/Mouse_acceleration#Disabling_mouse_acceleration) guide.

### Improving performance
[*Improving performance*](https://wiki.archlinux.org/index.php/Improving_performance)

**NEEDS EDITING**

### Solid State Drive
[*SSD*](https://wiki.archlinux.org/index.php/Solid_State_Drive)

**NEEDS EDITING**

### Fonts
To install fonts, use `pacman` or the *AUR*.

To refresh the font-cache:  
`fc-cache -fv`  
To list all fonts:  
`fc-list`

### Monitor brightness
By default, non-root users are not allowed to change the brightness of the screen.  
To change this, we add the user to the *video* group and allow this group to modify the file for the brightness.  
The file is located in `/etc/udev/rules.d/90-backlight.rules`:  
`SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video %S%p/brightness", RUN+="/bin/chmod g+w %S%p/brightness"`
Another option is using [*brightnessctl*](https://github.com/Hummer12007/brightnessctl/) if xbacklight is not working.
If all else fails, there is still the option to manually change the brightness (or put it in a script/write a program) with, for example: `printf "<value>\n" > /sys/class/backlight/intel_backlight/brightness` (path to *brightness* file might be different for you).

### Dipslay Manager
Here: *None*

Alternatives: [*lxdm*](https://wiki.archlinux.org/index.php/LXDM), [*LightDM*](https://wiki.archlinux.org/index.php/LightDM)

To install *lxdm* or *LightDM*:  
`sudo pacman -S lxdm`  
`sudo pacman -S lightdm`

To enable a display manager on boot:  
`sudo systemctl enable displaymanager.service`

If you do not want to use a Display Manager, you can choose to execute `startx` on login in a terminal.  
First, make sure your `~/.xserverrc` is properly configured:

	#!/bin/sh
	
	exec /usr/bin/Xorg -nolisten tcp "$@" vt$XDG_VTNR

Second, if you are using bash add the following lines to your `~/.bash_profile` or if you are using zsh add them to your `~/.zprofile`:  

 if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
   exec startx
 fi

If `startx` does not start your window manager/desktop environment, look for it with the help of the `which` command and pass the given path as a parameter of `startx` your `~/.bashrc` or `~/.zprofile`.

If you want to be automatically logged in on boot, edit the file `/etc/systemd/system/getty@tty1.service.d/override.conf`:

	[Service]
	ExecStart=
	ExecStart=-/usr/bin/agetty --autologin username --noclear %I $TERM

