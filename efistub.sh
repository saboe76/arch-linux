#!/usr/bin/env bash
#

DISK="/dev/mmcblk0"
PART="1"
ROOT_UUID="c2f6e04e-3abf-4c6a-9902-c6fdda423a30"
OPTIONS_MNT="root=UUID=$ROOT_UUID rw"
OPTIONS_INITRD="initrd=\\initramfs-linux.img"
OPTIONS_INITRD_FALLBACK="initrd=\\initramfs-linux-fallback.img"
OPTIONS_KRNL="quiet loglevel=3 mitigations=off"

# delete entries 0,1,2
efibootmgr	--quiet --bootnum 0000 --delete-bootnum
efibootmgr	--quiet --bootnum 0001 --delete-bootnum
efibootmgr	--quiet --bootnum 0002 --delete-bootnum
efibootmgr	--quiet --bootnum 0003 --delete-bootnum

# efistub arch
efibootmgr	--quiet \
		--unicode \
		--bootnum 0000 \
		--create \
		--disk $DISK \
		--part $PART \
		--label "Arch RG" \
		--loader /vmlinuz-linux \
		--unicode "$OPTIONS_MNT $OPTIONS_INITRD $OPTIONS_KRNL"

# efistub arch fallback
efibootmgr	--quiet \
		--unicode \
		--bootnum 0001 \
		--create \
		--disk $DISK \
		--part $PART \
		--label "Arch FB" \
		--loader /vmlinuz-linux \
		--unicode "$OPTIONS_MNT $OPTIONS_INITRD_FALLBACK"

# systemd-boot
efibootmgr	--quiet \
		--unicode \
		--bootnum 0002 \
		--create \
		--disk $DISK \
		--part $PART \
		--label "Linux Boot Manager" \
		--loader "/EFI/systemd/systemd-bootx64.efi"

# efi default loader
efibootmgr	--quiet \
		--unicode \
		--bootnum 0003 \
		--create \
		--disk $DISK \
		--part $PART \
		--label "UEFI:Default" \
		--loader "/EFI/BOOT/BOOTX64.EFI"

# boot order
efibootmgr	--quiet \
		--bootorder 0000,0001,0002,0003

# show result
efibootmgr	--unicode
