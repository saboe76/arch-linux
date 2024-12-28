
# Boot from EFI by systemd-boot or direct

Since systemd brings a small but tiny efi boot loader wecan use it 
or take advantage of recent kernels that can be directly excutel from
the EFI firmware.

## Direct / EFIstub / efibootmgr

[Arch / EFI boot stub](https://wiki.archlinux.org/title/EFI_boot_stub)

The program `efibootmgr` can modify your EFI firmware boot entries.
Thus it is possible to add an entry, to boot you kernel with a command line directly.
The command line must contail to root filesystem and the location of the initrd.

Create an entry for /dev/sda1 (ESP):
```
efibootmgr --create \
		--disk /dev/sda \
		--part 1 \
		--label "Arch Linux" \
		--loader /vmlinuz-linux \
		--unicode 'root=UUID=aaaa-cccc rw initrd=\initramfs-linux.img'
```
The file referencing is relativ to the ESP root.

By efibootmgr you can

* add entries
* delete entries
* modify/overwrite entries
* change boot order
* set next boot entrie (to test once)
* amm...

Personally, I prefer to have two entries for for regular and fall back image by efistub
and the same by systemd-boot. If something deletes the entries in the firmware -
an BIOS/FIRMWARE update e.g. - than you have no change to create that entries in the firmware.

But what you can: Select a file on the ESP to execute, the boot loader. And that is the systemd
boot loader at `/EFI/systemd/systemd-bootx64.efi`

## Systemd-boot / bootctl

