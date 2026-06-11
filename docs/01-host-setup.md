# Host setup notes

This document records the host expectations and package setup for the
`yocto-qemu-mini-lab`.

The goal is not to create a huge Yocto workstation. The goal is to keep a small,
reproducible, educational lab that can build and boot a minimal image with QEMU.

## Host expectations

This lab was tested on Ubuntu 24.04 LTS with the `qemux86-64` machine target.

The first cold Yocto build can still be heavy. This is not a tiny `make hello`
project: BitBake has to fetch sources, build native tools, build target
packages, assemble the root filesystem, and produce deployable image artifacts.

Practical guidance for learners:

- 4 CPU cores can work, especially with conservative build settings.
- Less than 16 GiB RAM can work, but swap pressure is possible.
- Have significantly more than 30 GiB free before starting the first build.
- Around 60 GiB free is a safer target for a comfortable learning run.
- The first cold build can take hours on a small host.
- BitBake progress is not linear, so a percentage can appear slow for a while.

These numbers are practical expectations for this lab, not official Yocto
minimum requirements.

For disk recovery and QEMU notes, see:

- [Troubleshooting Yocto builds](06-troubleshooting.md)

## Conservative build settings

For small hosts, this lab recommends conservative local settings in
`build/conf/local.conf`:

```bitbake
BB_NUMBER_THREADS = "2"
PARALLEL_MAKE = "-j2"
INHERIT += "rm_work"
```

`BB_NUMBER_THREADS` limits BitBake task scheduling.

`PARALLEL_MAKE` limits parallel compilation inside recipes.

`rm_work` removes many temporary per-recipe work directories after the
corresponding tasks complete, reducing pressure on disk space.

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

Install command:

```bash
sudo apt install \
  gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio \
  python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
  python3-git python3-jinja2 python3-subunit zstd liblz4-tool file locales \
  libacl1
```

## Package purpose, roughly

Compiler and build tools:

- `gcc`
- `build-essential`

Source and version tools:

- `git`
- `wget`

Archive and file tools:

- `unzip`
- `xz-utils`
- `zstd`
- `liblz4-tool`
- `cpio`
- `file`

Yocto support tools:

- `gawk`
- `diffstat`
- `texinfo`
- `chrpath`
- `socat`

Python support:

- `python3`
- `python3-pip`
- `python3-pexpect`
- `python3-git`
- `python3-jinja2`
- `python3-subunit`

System and network helpers:

- `debianutils`
- `iputils-ping`

Locale support:

- `locales`

Filesystem ACL support:

- `libacl1`

## Locale

Yocto expects a sane UTF-8 locale.

Check current locale availability with:

```bash
locale -a | grep -E '^en_US\.utf8$|^en_US\.UTF-8$'
```

If needed, generate it with:

```bash
sudo locale-gen en_US.UTF-8
```

## First target

The first real Yocto target is:

```text
core-image-minimal
```

The first machine target is:

```text
qemux86-64
```

This lab currently uses the fixed Poky tag documented in the README.
