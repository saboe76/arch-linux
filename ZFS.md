# Setup ZFS on ARCH

## Add zfsarch

Add keys of archzfs repo

```
curl -O https://archzfs.com/archzfs.gpg
pacman-key -a archzfs.gpg
pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76
```

Add repo to pacman

```
tee -a /etc/pacman.conf <<-'EOF'

[archzfs]
Server = https://archzfs.com/$repo/$arch
Server = https://mirror.sum7.eu/archlinux/archzfs/$repo/$arch
Server = https://mirror.biocrafting.net/archlinux/archzfs/$repo/$arch
Server = https://mirror.in.themindsmaze.com/archzfs/$repo/$arch
EOF

```

Update pacman:

```
pacman -Syy
```

## Install lts kernel/headers ans zfs-dkms/utils

For regular building the DKMS one should consider to change
some things in `/etc/makepkg.conf`:

```
...
MAKEFLAGS="-j4"
...
OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug lto)
...
```

Install packages from archzfs

```
pacman -S linux-lts linux-lts-headers zfs-utils archzfs-dkms
```
