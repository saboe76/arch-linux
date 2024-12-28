
# Boot from EFI by systemd-boot or direct

Systemd brings a small efi boot loader with support for menu entries.
Recent kernels can be directly executed by the EFI firmware.

## Direct / EFIstub / efibootmgr

[Arch / EFI boot stub](https://wiki.archlinux.org/title/EFI_boot_stub)

The program `efibootmgr` can modify the EFI firmware boot entries.
Thus it is possible to add an entry, to boot your kernel with a command line directly.

Create an entry for /dev/sda1 (ESP):
```
efibootmgr --create \
	--disk /dev/sda \
	--part 1 \
	--label "Arch" \
	--loader /vmlinuz-linux \
	--unicode 'root=UUID=aaaa-cccc rw initrd=\initramfs-linux.img quiet loglevel=3 mitigations=off'
```
The referencing of files starts relativ to the ESP root.

By efibootmgr you can

* add entries
* delete entries
* modify/overwrite entries
* change boot order
* set next boot entrie (to test once)
* amm...

Personally, I prefer to have two entries for the regular and fall back image by efistub
and the same by systemd-boot.
If something goes wrong in the firmware you have no chance to re-create that entries in the firmware.

To switch to the systemd-boot loader, just select `/EFI/systemd/systemd-bootx64.efi` from your EFI partition.

My boot entries:

1. Kernel + initrd
2. Kernel + initrd-fallback
3. Systemd-boot
    1. Systemd-boot kernel + initrd
    2. Systemd-boot kernel + initrd-fallback


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

**DO NOT USE TABS** in any of the systemd-boot configuration files, white space only!

The configuration file for systemd-boot `/loader/loader.conf`:

```conf
default        arch.conf
timeout        4
console-mode   keep
editor         yes
```

The `default` value points to the conf file under `loader/entries` which is used on default
after a timeout of 4 seconds. The resolution from the firmware is kept and you can edit the entries before booting them.

The format of an entry file is as follows:

```conf
title         Arch
linux         /vmlinuz-linux
initrd        /initramfs-linux.img
options       root=UUID="a7a16fef-9432-4902-8257-f11fb70f8826" rw amd_pstate=active quiet loglevel=3 mitigations=off nmi_watchdog=0
```

Finally, you should find an auto detected entrie in your firmware.

## Scripts

A helpy script to update firmware boot entries.

```bash
#!/usr/bin/env bash
#

# delete entries 0, 1
efibootmgr	--quiet --bootnum 0 --delete-bootnum
efibootmgr	--quiet --bootnum 1 --delete-bootnum

# create new entries 0, 1
efibootmgr	--quiet \
		--unicode \
		--create \
		--bootnum 0000 \
		--disk /dev/nvme0n1 \
		--part 1 \
		--label "Arch" \
		--loader "/vmlinuz-linux" \
		'root=UUID="a7a16fef-9432-4902-8257-f11fb70f8826" rw initrd=\initramfs-linux.img quiet loglevel=3 mitigations=off nmi_watchdog=0'

efibootmgr	--quiet \
		--unicode \
		--create \
		--bootnum 0001 \
		--disk /dev/nvme0n1 \
		--part 1 \
		--label "Arch Fallback" \
		--loader "/vmlinuz-linux" \
		'root=UUID="a7a16fef-9432-4902-8257-f11fb70f8826" rw initrd=\initramfs-linux-fallback.img'

# show result
efibootmgr --unicode
```
