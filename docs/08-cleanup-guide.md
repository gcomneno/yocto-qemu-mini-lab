# Cleanup guide for generated Yocto directories

Yocto builds generate a lot of data.

This guide explains what is safe to remove, what is usually worth keeping, and
how to inspect disk usage before deleting anything.

The goal is to avoid two bad outcomes:

- filling the disk until the build fails
- deleting useful caches and wasting hours on the next build

## Generated directories are not committed

This lab intentionally does not commit generated Yocto directories or artifacts.

They are ignored by Git because they are local build outputs, machine-specific,
large, and reproducible.

Common generated directories include:

- `poky/`
- `build/`
- `build/tmp/`
- `build/downloads/`
- `build/sstate-cache/`
- generated images and deploy artifacts

Keep the repository focused on source files, documentation, recipes, layers, and
small scripts.

## What `poky/` is

`poky/` contains the Yocto reference distribution checkout used by this lab.

It is not committed because it is an external upstream source tree. The lab
documents which version to use, but does not vendor the whole Poky checkout.

Removing `poky/` is usually safe from a Git point of view, but it means you must
fetch or restore the Yocto sources again before building.

## What `build/` is

`build/` is the local Yocto build directory.

It contains configuration, caches, intermediate build outputs, package work
directories, and deployable images.

Do not commit it.

Inside `build/`, different directories have very different cleanup value.

## Important build subdirectories

### `build/tmp`

`build/tmp` contains most task output and intermediate build state.

It can become very large.

Deleting it is a common way to recover disk space, but the next build may take a
long time because many tasks need to run again.

### `build/tmp/work`

`build/tmp/work` contains per-recipe work directories.

This is often one of the largest areas inside `build/tmp`.

The `rm_work` feature removes many work directories automatically after tasks
complete, reducing disk pressure.

### `build/downloads`

`build/downloads` contains downloaded source archives and Git mirrors.

Keeping it usually saves time and network traffic.

Deleting it is safe only if you accept that sources may need to be downloaded
again.

### `build/sstate-cache`

`build/sstate-cache` contains shared-state cache artifacts.

Keeping it can save a lot of rebuild time.

Deleting it is safe only if you accept a slower future build.

### `build/cache`

`build/cache` contains BitBake cache data.

It is usually smaller than `tmp`, `downloads`, or `sstate-cache`.

Deleting it may force BitBake to re-parse metadata.

## Inspect before deleting

Before deleting anything, inspect disk usage.

```bash
df -h .
du -sh build build/tmp build/downloads build/sstate-cache 2>/dev/null || true
du -h --max-depth=1 build/tmp 2>/dev/null | sort -h
```

These commands are read-only.

They help decide whether the pressure is coming from `tmp`, downloads, sstate,
or something else.

## Recommended cleanup strategy

Prefer this order:

1. Keep `downloads` if possible.
2. Keep `sstate-cache` if possible.
3. Delete `build/tmp` only when you need to recover significant disk space.
4. Delete all of `build/` only when you want a fresh build environment.
5. Delete `poky/` only when you intentionally want to refetch the Yocto source tree.

This keeps expensive caches alive for as long as possible.

## When deleting `build/tmp` is reasonable

Deleting `build/tmp` is reasonable when:

- the disk is nearly full
- a build was interrupted and left a large temporary state
- you want to force Yocto to rebuild task outputs
- `rm_work` was not enabled and work directories grew too large

Before deleting, stop any running BitBake process.

Then inspect usage again.

## Destructive cleanup commands

Warning: the following commands delete generated files.

Read the command carefully before running it. Make sure you are in the lab
repository root and not in a different project.

To remove the main temporary build output:

```bash
rm -rf build/tmp
```

To remove the whole build directory:

```bash
rm -rf build
```

To remove the Poky checkout:

```bash
rm -rf poky
```

These commands should not affect committed Git files in this lab, but they can
remove many gigabytes of local build state.

## Why `rm_work` helps

This lab recommends the following conservative setting for small hosts:

```bitbake
INHERIT += "rm_work"
```

`rm_work` removes many per-recipe work directories after the corresponding build
tasks complete.

It reduces disk usage, but it can make some debugging workflows less convenient
because recipe work directories may no longer be available after the build.

For a learning lab on a small host, that tradeoff is usually acceptable.

## Quick decision table

| Need | Prefer |
| --- | --- |
| Recover temporary build space | Remove `build/tmp` |
| Keep rebuilds faster | Keep `build/sstate-cache` |
| Avoid re-downloading sources | Keep `build/downloads` |
| Start the build environment from scratch | Remove `build/` |
| Refetch Yocto sources from scratch | Remove `poky/` |

## Final rule

When in doubt, inspect first and delete less.

For this lab, `downloads` and `sstate-cache` are often more valuable than they
look: they are quiet little time-savers hiding under boring directory names.
