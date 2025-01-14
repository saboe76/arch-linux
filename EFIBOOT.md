
# Boot from EFI directly the kernel or corner by systemd-boot

- Recent kernels can be directly executed by the EFI boot loader.
- Systemd brings a small efi boot loader with support for menu entries.

## EFI direct / EFIstub / efibootmgr

[Arch / EFI boot stub](https://wiki.archlinux.org/title/EFI_boot_stub)

In order to use this boot method, 2 conditions must by met:

- The system supports EFI boot mode.
- The kernel is compiled with EFI_STUB support.

Check the running kernel for the option `CONFIG_EFI_STUB=y`:

```
zgrep CONFIG_EFI_STUB /proc/config.gz
CONFIG_EFI_STUB=y
```

And the running system for EFI boot mode. If there are no files listed, not in EFI mode.

```
ls /sys/firmware/efi/efivars
```

The program `efibootmgr` can modify the EFI boot loader entries. Thus it
is possible to add an entry, to boot your kernel with a command line
directly. The file referencing starts relativ to the ESP root.

Create an entry for `/dev/sda1` (ESP):

```
efibootmgr --create \
	--disk /dev/sda \
	--part 1 \
	--label "Arch" \
	--loader /vmlinuz-linux \
	--unicode 'root=UUID=aaaa-cccc rw initrd=\initramfs-linux.img quiet loglevel=3 mitigations=off'
```

By `efibootmgr` you can:

* add entries
* delete entries
* modify/overwrite entries ???
* change boot order
* set next boot entrie (to test once)
* amm...

Personally, I prefer to have two entries for the regular and fall back
image by efibootmr and the same by systemd-boot. If something goes wrong
in the firmware you have no chance to re-create that entries within the
firmware!

In that case go in your firmware an create a new boot entry by selecting
the file `/EFI/systemd/systemd-bootx64.efi` from your EFI partition.
That should bring you the entry `Linux boot loader`, that is systemd-boot.

My EFI boot loader entries:

1. Kernel + initrd
2. Kernel + initrd-fallback
3. Systemd-boot
    1. Kernel + initrd
    2. Kernel + initrd-fallback



## Systemd-boot / bootctl

[Arch / systemd-boot](https://wiki.archlinux.org/title/Systemd-boot)

Pretty straight forward.

### Install

By `bootctl install` systemd will copy its bootloader from `/usr/lib/systemd/boot/efi/systemd-bootx64.efi` to:

* `/EFI/systemd/systemd-bootx64.efi`
* `/EFI/BOOT/BOOTX64.EFI`

### Configure

The relevant files in the ESP:

```tree
├── EFI
│   ├── BOOT
│   │   └── BOOTX64.EFI
│   └── systemd
│       └── systemd-bootx64.efi
├── initramfs-linux-fallback.img
├── initramfs-linux.img
├── loader
│   ├── entries
│   │   ├── arch-fallback.conf
│   │   └── arch.conf
│   ├── entries.srel
│   ├── loader.conf
│   └── random-seed
└── vmlinuz-linux
```

**DO NOT USE TABS** in any of the systemd-boot configuration files,
white space only! The main configuration file for systemd-boot
`/loader/loader.conf`:

```conf
default        arch.conf
timeout        4
console-mode   keep
editor         yes
```

The `default` value points to the conf file under `/loader/entries`
which is used on default after a timeout of 4 seconds. The resolution
from the firmware is kept and you can edit the entries before booting
them. The format of an entry file is as follows:

```conf
title         Arch
linux         /vmlinuz-linux
initrd        /initramfs-linux.img
options       root=UUID="a7a16fef-9432-4902-8257-f11fb70f8826" rw amd_pstate=active quiet loglevel=3 mitigations=off nmi_watchdog=0
```

## Scripts

A helpy script to update firmware boot entries with `efibootmgr` is [efistub.sh](efistub.sh) that takes variables
to setup the first 4 (0-3) entries. 0,1 efistub, 2 systemd-boot and 3 the default loader.

```
# ./efistub.sh
BootCurrent: 0002
Timeout: 1 seconds
BootOrder: 0000,0001,0002,0003
Boot0000* Arch RG	HD(1,GPT,85bf918f-a5a4-3445-a7ef-1969a98fbc6c,0x800,0x200000)/\vmlinuz-linuxroot=UUID=c2f6e04e-3abf-4c6a-9902-c6fdda423a30 rw initrd=\initramfs-linux.img quiet loglevel=3 mitigations=off
Boot0001* Arch FB	HD(1,GPT,85bf918f-a5a4-3445-a7ef-1969a98fbc6c,0x800,0x200000)/\vmlinuz-linuxroot=UUID=c2f6e04e-3abf-4c6a-9902-c6fdda423a30 rw initrd=\initramfs-linux-fallback.img
Boot0002* Linux Boot Manager	HD(1,GPT,85bf918f-a5a4-3445-a7ef-1969a98fbc6c,0x800,0x200000)/\EFI\systemd\systemd-bootx64.efi
Boot0003* UEFI:Default	HD(1,GPT,85bf918f-a5a4-3445-a7ef-1969a98fbc6c,0x800,0x200000)/\EFI\BOOT\BOOTX64.EFI
Boot0004* UEFI:CD/DVD Drive	BBS(129,,0x0)
Boot0005* UEFI:Removable Device	BBS(130,,0x0)
Boot0006* UEFI:Network Device	BBS(131,,0x0)
```




