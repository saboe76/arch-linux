# arch-linux

this is an install script / guide to c'n'p most things and not to forget something.

## Installation

setup your system and get the arch linux live system up.
from that point, I prefer to set a root password, get the ip address
and do the following by ssh and copy and paste.

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

and call Scotty to beam us into our new root file system
```
arch-chroot /mnt
```


### Setup

#### !!! ROOT !!! Password !!!

```
passwd
```

#### Time / Zone / Sync

timezone
```
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
```

time sync service
```
systemctl enable systemd-timesyncd
```

#### Locales

```
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
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
mcedit /etc/systemd/network/enp1s0.network
```

like
```
[Match]
Name=enp1s0

[Network]
DHCP=yes
```

enable systemd-network service
```
systemctl enable systemd-networkd
```

enable systemd-resolve service
```
systemctl enable systemd-resolved
```

config and enable ssh service
```
sed -i 's/^.*PermitRootLogin.*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl enable sshd
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
mkdir /etc/kernel; mcedit /etc/kernel/cmdline
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

##### EFI Boot

##### efibootmgr UKI

TBD

##### efibootmgr efistub

TBD

##### efibootmgr systemd-boot

TBD

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

#mount
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
# passwd
echo a | passwd

# time
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd

# l18n
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# keyboard
echo KEYMAP=de-latin1 > /etc/vconsole.conf

# network
export IPIF=$(ip -4 route show default | awk '{print $5}')
echo -e "[Match]\nName=$IPIF\n\n[Network]\nDHCP=yes" > /etc/systemd/network/$IPIF.network
mcedit /etc/systemd/network/$IPIF.network

# network services
systemctl enable systemd-networkd
enable systemd-resolve service
systemctl enable systemd-resolved

# network services ssh
sed -i 's/^.*PermitRootLogin.*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl enable sshd

# mkinitcpio
mcedit /etc/mkinitcpio.d/linux.preset
mkdir -p /boot/EFI/Linux
mkdir -p /etc/kernel
echo -e "root=UUID=$(findmnt / -o UUID -n)\nrw\nquiet\nloglevel=3\nmitigations=off" > /etc/kernel/cmdline
mkinitcpio -P

# bootloader
efibootmgr -u -c -b 0000 -d /dev/vda -p 1 -L "Arch UKI" -l "/EFI/Linux/arch-linux.efi"

```
