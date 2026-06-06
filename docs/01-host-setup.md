# Host setup notes

This document records the host setup for the `yocto-qemu-mini-lab`.

The goal is not to create a huge Yocto workstation. The goal is to keep a small,
reproducible, educational lab that can build and boot a minimal image with QEMU.

## Host snapshot

Current machine snapshot:

- OS: Ubuntu 24.04 LTS
- CPU cores: 4
- RAM: 8.8 GiB
- Swap: 4.0 GiB
- Root filesystem:
  - available: 30G

LVM snapshot after resize:

- volume group: `ubuntu-vg`
- logical volume: `ubuntu-lv`
- LV size: `<30.00g`
- VG free: `4.00g`

This is enough for a careful mini-lab, but not a machine for large Yocto builds.

## Lab constraints

Keep this repository small.

Do not commit:

- `poky/`
- `build/`
- `downloads/`
- `sstate-cache/`
- `tmp/`
- generated images
- build artifacts

Prefer:

- small images
- explicit commands
- documented steps
- one experiment at a time

## Ubuntu/Debian host packages

Yocto requires several host packages to build an image on Ubuntu/Debian.

Planned install command:

```bash
sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 python3-subunit zstd liblz4-tool file locales libacl1```
```

## Package purpose, roughly

compiler/build tools: gcc, build-essential, make through build-essential
source/version tools: git, wget
archive/file tools: unzip, xz-utils, zstd, liblz4-tool, cpio, file
Yocto support tools: gawk, diffstat, texinfo, chrpath, socat
Python support: python3, python3-pip, python3-pexpect, python3-git, python3-jinja2, python3-subunit
system/network helpers: debianutils, iputils-ping
locale support: locales
filesystem ACL support: libacl1

## Locale

Yocto expects a sane UTF-8 locale.

Planned locale command:

```
sudo locale-gen en_US.UTF-8
```

Before generating it, check current locale availability with:

```
locale -a | grep -E '^en_US\.utf8$|^en_US\.UTF-8$'
```

## First target

The first real Yocto target will be:

- core-image-minimal

The first machine target will be QEMU-based, likely:

- qemux86-64

Version/branch/tag of Poky will be decided before cloning.
