# Create monkey-image-minimal

This document records the creation and test of the custom Yocto image
`monkey-image-minimal`.

## Goal

Move the `hello-monkey` package inclusion from local build configuration into a
tracked image recipe.

Before this step, the package was added through:

```bitbake
IMAGE_INSTALL:append = " hello-monkey"
```

inside:

```text
build/conf/local.conf
```

That was useful for learning, but `build/conf/local.conf` is local and ignored by
Git.

The project needs a reproducible image recipe tracked in the repository.

## Create the image recipe

Recipe path:

```text
meta-monkey/recipes-core/images/monkey-image-minimal.bb
```

Content:

```bitbake
SUMMARY = "Minimal QEMU image for the Yocto QEMU mini lab"
DESCRIPTION = "A core-image-minimal based image that includes the hello-monkey package."
LICENSE = "MIT"

require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL:append = " hello-monkey"
```

## Key idea

This line:

```bitbake
require recipes-core/images/core-image-minimal.bb
```

means:

```text
Start from the standard core-image-minimal recipe.
```

This line:

```bitbake
IMAGE_INSTALL:append = " hello-monkey"
```

means:

```text
Add hello-monkey to the image package list.
```

The leading space before `hello-monkey` is intentional.

## Remove the local post-it

The temporary local image tweak was removed from:

```text
build/conf/local.conf
```

After cleanup, the remaining local knobs were only host/build related:

```text
BB_NUMBER_THREADS = "2"
PARALLEL_MAKE = "-j2"
INHERIT += "rm_work"
```

This ensures that `hello-monkey` is included by the image recipe, not by local
configuration.

## Check that BitBake sees the image recipe

Command:

```bash
source poky/oe-init-build-env build
bitbake-layers show-recipes monkey-image-minimal
```

Observed result:

```text
monkey-image-minimal:
  meta-monkey          1.0
```

Note:

The recipe file is named:

```text
monkey-image-minimal.bb
```

Since it does not include an explicit version in the filename, BitBake reports
the default version:

```text
1.0
```

## Build the custom image

Command:

```bash
time bitbake monkey-image-minimal
```

Observed result:

```text
NOTE: Tasks Summary: Attempted 4481 tasks of which 4457 didn't need to be rerun and all succeeded.
```

Elapsed time:

```text
real    1m6.671s
```

Meaning:

The custom image was built successfully. Most tasks were reused from previous
builds.

## Boot the custom image

Command:

```bash
runqemu qemux86-64 monkey-image-minimal nographic
```

Login:

```text
qemux86-64 login: root
```

## Test hello-monkey inside QEMU

Commands inside the emulated system:

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

This proves that:

- the custom image recipe was used
- the image contains the `hello-monkey` package
- the generated image boots in QEMU
- the custom command runs inside the emulated Linux system

## Minimal image note

This command failed:

```sh
cat /etc/os-release
```

Observed result:

```text
cat: can't open '/etc/os-release': No such file or directory
```

This is not a failure of `hello-monkey`.

It simply shows that `core-image-minimal` is very small and does not necessarily
contain convenience files expected on larger Linux distributions.

## Current result

The lab can now build and boot:

```text
monkey-image-minimal
```

This image:

- starts from `core-image-minimal`
- includes `hello-monkey`
- boots on `qemux86-64`
- can be tested with `runqemu`

## Practical lessons learned

- Adding a package to `local.conf` is useful for quick learning.
- A tracked image recipe is better for reproducibility.
- `require` can reuse an existing image recipe.
- `IMAGE_INSTALL:append` can extend the package list of an image.
- A recipe can be valid, a package can be built, and an image can still omit it unless the image explicitly includes it.
- The final proof is always inside the booted system.
