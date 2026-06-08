# yocto-qemu-mini-lab

A tiny, tutor-friendly Yocto/QEMU learning lab.

This repository is a small educational workspace for learning how Yocto builds a
minimal Linux image and how QEMU can boot it without requiring real embedded
hardware.

It is intentionally small, slow-paced, and documented step by step.

## What this lab does

The lab currently shows how to:

- prepare a small Ubuntu host for Yocto
- clone Poky at a fixed Yocto tag
- build `core-image-minimal`
- boot the image with QEMU
- create a custom layer named `meta-monkey`
- create a custom recipe named `hello-monkey`
- include that package in a custom image
- boot `monkey-image-minimal` and run `hello-monkey` inside QEMU

## Current result

The custom image is:

```text
monkey-image-minimal
```

It starts from `core-image-minimal` and adds:

```text
/usr/bin/hello-monkey
```

Inside QEMU:

```text
root@qemux86-64:~# which hello-monkey
/usr/bin/hello-monkey

root@qemux86-64:~# hello-monkey
Hello from meta-monkey!
This tiny command was installed by a custom Yocto recipe.
```

## Big picture

```text
Yocto/Poky builds the Linux image.
BitBake executes recipes and tasks.
QEMU pretends to be the hardware.
runqemu boots the generated image.
meta-monkey contains our custom Yocto metadata.
monkey-image-minimal includes our hello-monkey package.
```

In monkey terms:

```text
Yocto cooks the banana.
BitBake follows the recipe graph.
QEMU pretends to be the monkey cage.
runqemu puts the banana in the cage.
meta-monkey adds our own tiny monkey trick.
```

## Version used

This lab currently uses Poky tag:

```text
yocto-5.2.4
```

Yocto series:

```text
walnascar
```

Machine target:

```text
qemux86-64
```

## Quick start

Install the required host packages first. See:

- [Host setup notes](docs/01-host-setup.md)
- [Host preflight runbook](docs/02-host-preflight.md)

Clone Poky:

```bash
git clone --branch yocto-5.2.4 --depth 1 https://git.yoctoproject.org/poky poky
```

Initialize the build directory:

```bash
source poky/oe-init-build-env build
```

Add the custom layer:

```bash
bitbake-layers add-layer ../meta-monkey
```

Recommended local settings for small hosts:

```bitbake
BB_NUMBER_THREADS = "2"
PARALLEL_MAKE = "-j2"
INHERIT += "rm_work"
```

Build the custom image:

```bash
bitbake monkey-image-minimal
```

Boot it with QEMU:

```bash
runqemu qemux86-64 monkey-image-minimal nographic
```

Login as:

```text
root
```

Test the custom command:

```sh
which hello-monkey
hello-monkey
```

## Documentation

Read the docs in order:

1. [Roadmap](docs/00-roadmap.md)
2. [Host setup notes](docs/01-host-setup.md)
3. [Host preflight runbook](docs/02-host-preflight.md)
4. [Build and boot core-image-minimal](docs/03-build-and-boot-core-image-minimal.md)
5. [Add meta-monkey and hello-monkey](docs/04-meta-monkey-hello-recipe.md)
6. [Create monkey-image-minimal](docs/05-monkey-image-minimal.md)

## Repository policy

This repository should stay small.

Do not commit generated Yocto artifacts such as:

- `poky/`
- `build/`
- `downloads/`
- `sstate-cache/`
- `tmp/`
- generated images
- build artifacts

Those directories can become very large and are intentionally ignored.

## What this lab is not

This is not a production Yocto distribution.

This is not a board support package.

This is not an optimized industrial embedded Linux setup.

This is not a claim of Yocto expertise.

It is a small learning sandbox.
