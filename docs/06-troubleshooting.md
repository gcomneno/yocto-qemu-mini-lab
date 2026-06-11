# Troubleshooting Yocto builds

This page collects the real issues observed while building this mini lab.

Yocto is powerful, but the first build can feel suspiciously quiet, very slow,
and unexpectedly hungry for disk space. This is normal. Do not panic, and do not
start deleting random directories before checking what is actually using space.

## First build is slow

A cold Yocto build can take hours on a small host.

BitBake has to fetch sources, prepare sysroots, build native tools, build target
packages, assemble the root filesystem, and generate deploy artifacts.

The progress percentage is not linear. A build can appear stuck for a while and
then continue normally.

Useful command while the build is running:

```bash
df -h .
```

This shows how much free space is left on the current filesystem.

## Disk usage can grow quickly

The build directory can become large, especially during the first build.

Useful diagnostic commands:

```bash
df -h .
du -h --max-depth=1 build/tmp 2>/dev/null | sort -h
du -sh build/tmp build/downloads build/sstate-cache build/cache 2>/dev/null || true
```

Typical large directories are:

```text
build/tmp
build/tmp/work
build/downloads
build/sstate-cache
```

## What to keep

Try to keep these directories when possible:

```text
build/downloads
build/sstate-cache
```

`build/downloads` contains downloaded source archives and Git fetches.

`build/sstate-cache` contains shared state cache artifacts. Keeping it can make
future builds much faster.

Deleting these directories is possible, but it usually means BitBake will need
to download or rebuild much more.

## What can be regenerated

`build/tmp` can be regenerated.

If disk space becomes a problem, deleting `build/tmp` is often a reasonable
recovery step, especially when `downloads` and `sstate-cache` are kept.

Before deleting anything, inspect disk usage first:

```bash
df -h .
du -sh build/tmp build/downloads build/sstate-cache build/cache 2>/dev/null || true
```

Then, only if needed:

```bash
rm -rf build/tmp
```

After that, source the build environment again and rerun BitBake:

```bash
source poky/oe-init-build-env build
bitbake monkey-image-minimal
```

BitBake will rebuild the missing temporary work, but it can reuse downloads and
sstate cache where possible.

## build/tmp/work can become huge

The `build/tmp/work` directory contains per-recipe work directories.

During large builds, this can grow quickly. On small learning hosts, this lab
recommends enabling `rm_work` in `build/conf/local.conf`:

```bitbake
INHERIT += "rm_work"
```

This tells Yocto to remove many temporary per-recipe work directories after the
corresponding tasks complete.

For small hosts, these settings are also recommended:

```bitbake
BB_NUMBER_THREADS = "2"
PARALLEL_MAKE = "-j2"
INHERIT += "rm_work"
```

They reduce pressure on CPU, RAM, and disk.

## QEMU serial terminal can print kernel messages

When booting with:

```bash
runqemu qemux86-64 monkey-image-minimal nographic
```

kernel messages may appear in the same serial terminal while commands are being
typed or executed.

For example, timer or interrupt messages can appear in the console. This does
not necessarily mean the image is broken.

The useful check is whether the shell still works:

```sh
which hello-monkey
hello-monkey
```

Expected output:

```text
/usr/bin/hello-monkey
Hello from meta-monkey!
This tiny command was installed by a custom Yocto recipe.
```

## /etc/os-release may be missing

Very small images can omit files that are common on larger Linux distributions.

In this lab, `core-image-minimal` and `monkey-image-minimal` are intentionally
tiny. If this command fails:

```sh
cat /etc/os-release
```

that does not automatically mean the image is broken.

The important lab result is that QEMU boots and the custom command is available:

```sh
hello-monkey
```

## Exiting QEMU

When using `nographic`, exit QEMU with:

```text
Ctrl+A, then X
```

## Safe recovery checklist

When a build looks wrong, use this order:

1. Check free disk space.
2. Check which build directory is large.
3. Keep `downloads` if possible.
4. Keep `sstate-cache` if possible.
5. Delete `build/tmp` only when needed.
6. Source the build environment again.
7. Rerun the BitBake command.

Useful commands:

```bash
df -h .
du -h --max-depth=1 build/tmp 2>/dev/null | sort -h
du -sh build/tmp build/downloads build/sstate-cache build/cache 2>/dev/null || true
source poky/oe-init-build-env build
bitbake monkey-image-minimal
```

## Rule of thumb

Do not treat Yocto build directories as mysterious black magic.

Treat them as generated state:

```text
downloads      expensive to redownload, keep if possible
sstate-cache   expensive to rebuild, keep if possible
tmp            generated build work, can be regenerated
tmp/work       often huge, reduced by rm_work
```

The monkey survives if the banana cache survives.

## Related cleanup guide

For a focused explanation of generated Yocto directories and what to keep or
remove, see:

- [Cleanup guide for generated Yocto directories](08-cleanup-guide.md)
