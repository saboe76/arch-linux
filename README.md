# arch-linux

this is an install script / guide to c'n'p most things and not to forget something.

## Installation

setup your system and get the arch linux live system up.
from that point, I prefer to set a root password, get the ip address
and do the following by ssh and copy and paste.
```
ssh -o StrictHostKeychecking=no -o PreferredAuthentications=password root@192.168.0.86
```

### Disk Partitions

use cfdisk `cfdisk /dev/vda` and init the disk for GPT.

| type |   size |
| :--- | -----: |
| EFI  | `1G`   |
| SWAP | `2G`   |
| EXT4 | `xG`   |

or whatever other layout you prefer.

### Format

| type | command                     |
| :--- | :-------------------------- |
| EFI  | `mkfs.vfat -F 32 /dev/vda1` |
| SWAP | `mkswap /dev/vda2`          |
| EXT4 | `mkfs.ext4 /dev/vda3`       |

### Mount

now mount the root fs under `/mnt`
and create the dirs for the other mountpoints,
like `/mnt/boot` or `/mnt/home`
so you can mount the other file systems to these points.
swapon the swap partition, so everything is mounted.

### Install

`pacstrap` will install to the `/mnt` with a fresh system.
I usually prefer to have Midnight Commander, OpenSSH and efibootmgr along base and linux
```
pacstrap -K /mnt base linux linux-firmware mc openssh efibootmgr
```

append mountpoints in `/mnt` without `/mnt` to fstab
```
genfstab -U /mnt >> /mnt/etc/fstab
```

call Scotty to beam us into our new root file system
```
arch-chroot /mnt
```


### Setup

#### !!! ROOT !!! Password !!!

```
echo a | passwd -s
```

#### Time / Zone / Sync

timezone
```
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
```

time sync service
```
systemctl enable --now systemd-timesyncd
```

#### Locales

```
echo "en_US.UTF-8 UTF-8"    >> /etc/locale.gen
locale-gen
echo "LANG="C.UTF-8"        >  /etc/locale.conf
echo "LC_TIME="de_DE.UTF-8" >> /etc/locale.conf
echo "TIME_STYLE=iso8"      >> /etc/locale.conf
```

#### Keyboard

```
echo KEYMAP=de-latin1 > /etc/vconsole.conf
```

#### Network

find interface name
```
ip link show
```

edit interface config
```
mcedit /etc/systemd/network/ethernet.network
```

like
```
[Match]
Name=en*
Name=eth*

[Network]
DHCP=yes
```

enable systemd-network service
```
systemctl enable --now systemd-networkd
```

enable systemd-resolve service
```
systemctl enable --now systemd-resolved
ls -sf /var/run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

config and enable ssh service
```
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl enable --now sshd
```

#### Boot

enable the uki generation and change the path from `/efi/...` to `/boot/...`
```
mcedit /etc/mkinitcpio.d/linux.preset
```

create the path for
```
mkdir -p /boot/EFI/Linux
```

get the rootfs uuid
```
findmnt / -o UUID -n
```

edit
```
mkdir -p /etc/kernel; mcedit /etc/kernel/cmdline
```

and fillup like
```
echo -e "root=UUID=$(findmnt / -o UUID -n)\nrw\nquiet\nloglevel=3\nmitigations=off" > /etc/kernel/cmdline
```

rebuild the initrds and the UKI kernels
```
mkinitcpio -P
```

dont reboot! first, check if a bootloader is required at your platform.
if you can create boot entries from your firmware, you good to reboot.

else have to create them with efibootmgr.

install systemd-boot to auto-detect the UKI images
```
bootctl install
```

### All in One

before chroot
```
export DISK=/dev/vda

# part
cfdisk ${DISK}

# format
mkfs.vfat -F 32 ${DISK}1
mkswap ${DISK}2
mkfs.ext4 ${DISK}3

# mount
mount ${DISK}3 /mnt
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot
swapon ${DISK}2

# install
pacstrap -K /mnt base linux linux-firmware mc openssh efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab

```

chroot
```
arch-chroot /mnt

```

after chrooted
```
# root passwd
echo a | passwd -s

# time
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
systemctl enable --now systemd-timesyncd

# l18n and keyb
echo "en_US.UTF-8 UTF-8"    >> /etc/locale.gen
echo "KEYMAP=de-latin1"     >  /etc/vconsole.conf
echo "LANG="C.UTF-8"        >  /etc/locale.conf
echo "LC_TIME="de_DE.UTF-8" >> /etc/locale.conf
echo "TIME_STYLE=iso8"      >> /etc/locale.conf
locale-gen

# network
echo -e "[Match]\nName=en*\nName=eth*\n\n[Network]\nDHCP=yes" > /etc/systemd/network/ethernet.network

# network services
systemctl enable --now systemd-networkd
systemctl enable --now systemd-resolved
ls -sf /var/run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# network services ssh
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl enable --now sshd

# mkinitcpio
mkdir -p /boot/EFI/Linux
mkdir -p /etc/kernel
echo -e "root=UUID=$(findmnt / -o UUID -n)\nrw\nquiet\nloglevel=3\nmitigations=off" > /etc/kernel/cmdline
mcedit /etc/mkinitcpio.d/linux.preset
mkinitcpio -P

# bootloader systemd-boot
bootctl install

# bootloader direct entries
efibootmgr -u -b 0 -B
efibootmgr -u -b 0 -c -d /dev/vda -p 1 -L "Arch UKI"    -l "/EFI/Linux/arch-linux.efi"
efibootmgr -u -b 1 -B
efibootmgr -u -b 1 -c -d /dev/vda -p 1 -L "Arch UKI FB" -l "/EFI/Linux/arch-linux-fallback.efi"

```
