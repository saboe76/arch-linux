# arch-linux

some notes around arch and linux in general

one line more

## Installation

Setup your system and get the arch linux live system up. From that
point, I prefer to set a root password, get the IP address and do the
following by ssh and copy and paste.

### Disk Partitions

Use cfdisk and init the disk for GPT.

* Choose your EFI partition, I'm used to make it 1G.
* Choose your swap, I'm used to no more than 4G.
  If you need more swap than 4G, you have a serious problem and should fix that :-)
* Choose you root partition.
* Decide if you want to use a separate for `/home`.

### Format

EFI:
```
mkfs.vfat -F 32 /dev/foo1
```

SWAP:
```
mkswap /dev/foo2
```

EXT4:
```
mkfs.ext4 /dev/foo3
```

### Mount

Now mount the root fs under /mnt and create the dirs for the other mountpoints, like `/mnt/boot` or `/mnt/home` and
mount the other file systems to these points. Swapon the swap partition, so everything is mount.

Pacstrap will / install fill the `/mnt` with a running system. I usually prefer to have Midnight Commander and
the efibootmgr, hence:

### Install


```
pacstrap -K /mnt base linux linux-firmware mc openssh efibootmgr
```

Now we need to have have a valid fstab for booting:

```
genfstab -U /mnt >> /mnt/etc/fstab
```

And we can beam into our new root file system

```
arch-chroot /mnt
```


### Setup

#### Password !!!

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

#### Locale

```
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
```

#### Keyboard

```
echo KEYMAP=de-latin1 > /etc/vconsole.conf
```

#### mkinitcpio

enable the uki generation and change the path from `/efi/...` to `/boot/...`
```
mcedit /etc/mkinitcpio.d/linux.preset
```

and create the path
```
mkdir -p /boot/EFI/Linux
```

we build the initrds later

#### Network

find interface name
```
ip l
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

since we have the UKI build enabled, we need to have the kernel command
line setup.

copy the rootfs uuid from
```
findmnt / -o UUID -n
```

edit
```
mkdir /etc/kernel; mcedit /etc/kernel/cmdline
```

and fill in like
```
root=UUID=
rw
quiet
loglevel=3
mitigations=off
```

or oneline
```
echo -e "root=UUID=$(findmnt / -o UUID -n)\nrw\nquiet\nloglevel=3\nmitigations=off" > /etc/kernel/cmdline
```

rebuild the initrds and the UKI kernels
```
mkinitcpio -P
```

dont reoot, check if boot load is neccessary and when, install and
configure.

##### EFI Boot entry

Either you can setup an entry (boot file) from your firmware - not always possible -
or use create these entries by `efibootmgr` or use systemd-boot

##### efibootmgr UKI

TBD

##### efibootmgr efistub

TBD

##### efibootmgr systemd-boot

TBD
