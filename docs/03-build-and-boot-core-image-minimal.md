# Build and boot core-image-minimal

This document records the first complete Yocto build and QEMU boot of the
`yocto-qemu-mini-lab`.

## Goal

Build the standard Yocto `core-image-minimal` image for `qemux86-64` and boot it
with QEMU.

## Key concepts

## Yocto

Yocto is the broader project and ecosystem for creating custom Linux-based
systems.

## Poky

Poky is the Yocto Project reference distribution and starter workspace.

In this lab, Poky provides:

- BitBake
- OpenEmbedded-Core metadata
- the `meta-poky` reference distro layer
- the `meta-yocto-bsp` reference BSP layer
- scripts such as `oe-init-build-env` and `runqemu`

## BitBake

BitBake is the build engine.

It reads metadata and recipes, resolves dependencies, and executes tasks.

## Recipes

Files ending in `.bb` are BitBake recipes.

A recipe describes things such as:

- what to build
- where to fetch sources from
- which license applies
- which dependencies are needed
- how to configure
- how to compile
- how to install
- how to package

During the first build, BitBake reported:

```text
Parsing of 923 .bb files complete
```

This means BitBake parsed 923 available recipes from the enabled layers.

Tasks

Recipes are split into tasks.

Common examples:

do_fetch
do_unpack
do_configure
do_compile
do_install
do_package

A Yocto build is not one single compile command. It is a dependency graph of many
recipes and tasks.

Selected Poky version

The lab uses the fixed Poky tag:

yocto-5.2.4

The tag resolves to:

d0b46a6624ec9c61c47270745dd0b2d5abbe6ac1

Reason:

A tag is more reproducible than a moving branch.

Clone Poky

Command:

git clone --branch yocto-5.2.4 --depth 1 https://git.yoctoproject.org/poky poky

Why:

Clone a small, shallow copy of Poky at a fixed Yocto release.

Observed result:

HEAD detached at d0b46a6624ec9c61c47270745dd0b2d5abbe6ac1

This is expected because a tag was checked out instead of a branch.

Verification command:

git -C poky describe --tags --exact-match

Observed result:

yocto-5.2.4
Initialize the build directory

Command:

source poky/oe-init-build-env build

Why:

Create and enter the Yocto build directory.

Observed generated files:

build/conf/bblayers.conf
build/conf/local.conf
build/conf/templateconf.cfg
Initial machine target

The default machine was already:

MACHINE ??= "qemux86-64"

The ??= operator means weak default assignment.

In practical terms:

Use qemux86-64 unless a stronger assignment sets another MACHINE.

This is suitable for a QEMU-based x86_64 learning lab.

Conservative local.conf settings

Initial setting:

BB_NUMBER_THREADS = "2"
PARALLEL_MAKE = "-j2"

Meaning:

run up to 2 BitBake tasks in parallel
run up to 2 make jobs inside compilation tasks

This was intentionally conservative for a small host.

A later experiment used 3/3, but disk usage grew too much during the first
cold build.

Final safer setting:

BB_NUMBER_THREADS = "2"
PARALLEL_MAKE = "-j2"
INHERIT += "rm_work"
rm_work

rm_work tells Yocto to remove many recipe work directories after they are no
longer needed.

This is useful on small hosts because build/tmp/work can grow very large.

In this lab, before cleanup:

build/tmp       44G
build/tmp/work  39G

After removing build/tmp, free disk space recovered significantly.

Kept directories:

build/downloads
build/sstate-cache

Reason:

downloads avoids downloading sources again
sstate-cache helps reuse completed build work

Deleted directory:

build/tmp

Reason:

tmp contains generated intermediate build output and can be regenerated.

First build attempt

Command:

bitbake core-image-minimal

Initial build configuration:

BB_VERSION           = "2.12.1"
BUILD_SYS            = "x86_64-linux"
NATIVELSBSTRING      = "ubuntu-24.04"
TARGET_SYS           = "x86_64-poky-linux"
MACHINE              = "qemux86-64"
DISTRO               = "poky"
DISTRO_VERSION       = "5.2.4"
TUNE_FEATURES        = "m64 core2"
TARGET_FPU           = ""
meta
meta-poky
meta-yocto-bsp       = "HEAD:d0b46a6624ec9c61c47270745dd0b2d5abbe6ac1"

The first cold build had no useful local cache:

Sstate summary: Wanted 1966 Local 0 Mirrors 0 Missed 1966 Current 0

Meaning:

Most work had to be done locally from scratch.

The build was interrupted when disk space became too low.

Disk diagnosis

After interruption:

build/tmp           44G
build/downloads      5.4G
build/sstate-cache   3.1G
build/cache          2.5M

Inside tmp:

build/tmp/work                  39G
build/tmp/work/core2-64...      23G
build/tmp/work/x86_64-linux     12G
build/tmp/work/qemux86_64...   6.7G

Conclusion:

The main disk consumer was build/tmp/work.

Cleanup strategy

The chosen cleanup strategy was:

rm -rf build/tmp

Kept:

build/downloads
build/sstate-cache

Result:

build size after cleanup: 8.5G
free disk after cleanup: 51G
Successful build

Command:

source poky/oe-init-build-env build
time bitbake core-image-minimal

Successful result:

NOTE: Tasks Summary: Attempted 4462 tasks of which 3133 didn't need to be rerun and all succeeded.

Sstate reuse:

Sstate summary: Wanted 1968 Local 1490 Mirrors 0 Missed 478 Current 0 (75% match, 0% complete)

Meaning:

The build did not restart from zero after cleanup. It reused downloads and
sstate cache.

Elapsed time:

real    200m28.521s
Generated image files

Generated image directory:

build/tmp/deploy/images/qemux86-64

Generated files:

core-image-minimal-qemux86-64.rootfs-20260607060930.ext4
core-image-minimal-qemux86-64.rootfs-20260607060930.manifest
core-image-minimal-qemux86-64.rootfs-20260607060930.qemuboot.conf
core-image-minimal-qemux86-64.rootfs-20260607060930.spdx.json
core-image-minimal-qemux86-64.rootfs-20260607060930.tar.bz2
core-image-minimal-qemux86-64.rootfs-20260607060930.testdata.json
Boot with QEMU

Command:

source poky/oe-init-build-env build
runqemu qemux86-64 core-image-minimal nographic

Why:

Boot the generated image in QEMU without a graphical window.

Observed boot result:

Poky (Yocto Project Reference Distro) 5.2.4 qemux86-64 /dev/ttyS0

qemux86-64 login: root

Login:

root

Observed shell:

root@qemux86-64:~#

QEMU was then terminated successfully:

QEMU: Terminated
runqemu - INFO - Cleaning up
Current result

The lab can now:

clone Poky at a fixed tag
initialize a Yocto build directory
build core-image-minimal
generate a QEMU-bootable image
boot the image with runqemu
log in as root

Phase 1 is complete.

Practical lessons learned
First Yocto builds are slow.
The BitBake percentage is not linear.
.bb files are recipes.
BitBake executes a graph of tasks, not one big compile.
downloads and sstate-cache are valuable and should be kept.
tmp/work can become huge.
rm_work is useful on small hosts.
watch is useful for monitoring disk, build size, RAM, and swap during long builds.
A public learning repo should document commands and results, but should not commit build artifacts.
