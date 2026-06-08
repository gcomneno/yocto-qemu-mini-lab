# Add meta-monkey and hello-monkey

This document records the creation of the custom `meta-monkey` Yocto layer and
the first custom recipe, `hello-monkey`.

## Goal

Create a custom Yocto layer and install a tiny command into the generated image.

Final result:

```text
root@qemux86-64:~# which hello-monkey
/usr/bin/hello-monkey

root@qemux86-64:~# hello-monkey
Hello from meta-monkey!
This tiny command was installed by a custom Yocto recipe.
```

## Create the custom layer

Command:

```bash
source poky/oe-init-build-env build
bitbake-layers create-layer ../meta-monkey
```

Why:

A Yocto layer is a directory containing metadata such as:

- recipes
- image definitions
- configuration
- classes
- append files

The layer was created at repository root:

```text
meta-monkey/
```

Generated files:

```text
meta-monkey/conf/layer.conf
meta-monkey/COPYING.MIT
meta-monkey/README
meta-monkey/recipes-example/example/example_0.1.bb
```

The generated `example` recipe was removed because it was only scaffolding.

## layer.conf

Important file:

```text
meta-monkey/conf/layer.conf
```

Key contents:

```bitbake
BBPATH .= ":${LAYERDIR}"

BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"

BBFILE_COLLECTIONS += "meta-monkey"
BBFILE_PATTERN_meta-monkey = "^${LAYERDIR}/"
BBFILE_PRIORITY_meta-monkey = "6"

LAYERDEPENDS_meta-monkey = "core"
LAYERSERIES_COMPAT_meta-monkey = "walnascar"
```

Meaning:

- `BBPATH` lets BitBake find metadata from this layer.
- `BBFILES` tells BitBake where recipe files live.
- `BBFILE_COLLECTIONS` names this layer collection.
- `BBFILE_PRIORITY` controls priority when metadata overlaps.
- `LAYERDEPENDS` says this layer depends on `core`.
- `LAYERSERIES_COMPAT` declares compatibility with the Yocto series used by this lab.

The lab uses Poky tag:

```text
yocto-5.2.4
```

This belongs to the Yocto series:

```text
walnascar
```

## Add the layer to the local build

Command:

```bash
source poky/oe-init-build-env build
bitbake-layers add-layer ../meta-monkey
bitbake-layers show-layers
```

Observed result:

```text
layer                 path                                                                    priority
========================================================================================================
core                  .../poky/meta                                                           5
yocto                 .../poky/meta-poky                                                      5
yoctobsp              .../poky/meta-yocto-bsp                                                 5
meta-monkey           .../yocto-qemu-mini-lab/meta-monkey                                     6
```

Important:

`bitbake-layers add-layer` modifies the local build configuration:

```text
build/conf/bblayers.conf
```

That file is intentionally ignored by Git.

## Create hello-monkey

Recipe source file:

```text
meta-monkey/recipes-monkey/hello-monkey/files/hello-monkey
```

Content:

```sh
#!/bin/sh
echo "Hello from meta-monkey!"
echo "This tiny command was installed by a custom Yocto recipe."
```

Recipe file:

```text
meta-monkey/recipes-monkey/hello-monkey/hello-monkey_0.1.bb
```

Content:

```bitbake
SUMMARY = "Tiny hello command for the Yocto QEMU mini lab"
DESCRIPTION = "Installs a small hello-monkey shell command into the target image."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://hello-monkey"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${UNPACKDIR}/hello-monkey ${D}${bindir}/hello-monkey
}
```

## Recipe concepts

`SRC_URI = "file://hello-monkey"` tells BitBake to use the local file from the
recipe's `files/` directory.

`do_install()` installs files into `${D}`, the temporary destination directory
used during packaging.

`${bindir}` usually maps to:

```text
/usr/bin
```

So this line:

```bitbake
install -m 0755 ${UNPACKDIR}/hello-monkey ${D}${bindir}/hello-monkey
```

installs the script as:

```text
/usr/bin/hello-monkey
```

## Check that BitBake sees the recipe

Command:

```bash
bitbake-layers show-recipes hello-monkey
```

Observed result:

```text
hello-monkey:
  meta-monkey          0.1
```

Meaning:

BitBake can see the recipe from the custom layer.

## Build only the recipe

Command:

```bash
bitbake hello-monkey
```

Observed result:

```text
NOTE: Tasks Summary: Attempted 1143 tasks of which 1122 didn't need to be rerun and all succeeded.
```

Meaning:

The recipe built successfully.

## Verify package contents

Command:

```bash
oe-pkgdata-util list-pkg-files hello-monkey || true
```

Observed result:

```text
hello-monkey:
        /usr/bin/hello-monkey
```

Meaning:

The generated package contains the expected command.

At this point the package exists, but it is not necessarily inside the image yet.

## Add hello-monkey to the image

Local build configuration:

```text
build/conf/local.conf
```

Added line:

```bitbake
IMAGE_INSTALL:append = " hello-monkey"
```

Important:

The leading space before `hello-monkey` is intentional.

Without that space, BitBake could concatenate values incorrectly.

## Rebuild the image

Command:

```bash
source poky/oe-init-build-env build
time bitbake core-image-minimal
```

Observed result:

```text
Sstate summary: Wanted 282 Local 274 Mirrors 0 Missed 8 Current 1696 (97% match, 99% complete)
NOTE: Tasks Summary: Attempted 4481 tasks of which 4459 didn't need to be rerun and all succeeded.
```

Elapsed time:

```text
real    2m13.965s
```

Meaning:

The rebuild was much faster than the first full build because the existing
downloads and sstate cache were reused.

## Boot and test in QEMU

Command:

```bash
source poky/oe-init-build-env build
runqemu qemux86-64 core-image-minimal nographic
```

Login:

```text
qemux86-64 login: root
```

Test commands inside QEMU:

```sh
which hello-monkey
hello-monkey
```

Observed result:

```text
/usr/bin/hello-monkey

Hello from meta-monkey!
This tiny command was installed by a custom Yocto recipe.
```

This confirms that the custom recipe was not only built, but also included in
the booted image and executed inside the emulated system.

## Current result

The lab can now:

- use a custom layer named `meta-monkey`
- build a custom recipe named `hello-monkey`
- include the resulting package in `core-image-minimal`
- boot the image with QEMU
- execute the custom command inside the emulated Linux system

## Practical lessons learned

- Creating a layer does not automatically make it active.
- A layer must be added to `bblayers.conf`.
- A recipe can build successfully without being included in an image.
- `oe-pkgdata-util list-pkg-files` is useful to inspect generated package contents.
- `IMAGE_INSTALL:append = " package-name"` is a simple way to add a package to an image during learning.
- The leading space in `IMAGE_INSTALL:append` matters.
- Testing in QEMU proves that the package is really present in the final image.
