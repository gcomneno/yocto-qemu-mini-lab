# vscode-bitbake workspace walkthrough

This document explains how to open this lab in VS Code and observe it with the
`yoctoproject/vscode-bitbake` extension.

It is not a vscode-bitbake bug report, extension manual, or production setup
guide. It is a practical observation note for this small Yocto/QEMU learning
workspace.

## What to open in VS Code

Open the repository root:

```text
yocto-qemu-mini-lab/
```

Do not open only `poky/`, only `build/`, or only `meta-monkey/`.

The repository root is the useful learning context because it shows:

- the lab documentation
- the generated Yocto source checkout
- the build configuration
- the custom layer
- the custom recipe
- the cleanup and troubleshooting notes

## Expected local workspace shape

After following the previous lab steps, the workspace should contain generated
Yocto directories such as:

```text
poky/
build/
meta-monkey/
```

The important files and directories to inspect are:

```text
poky/
build/conf/local.conf
build/conf/bblayers.conf
meta-monkey/conf/layer.conf
meta-monkey/recipes-*/
```

Generated directories are intentionally ignored by Git. They are local build
state, not repository source files.

## Check that `meta-monkey` is enabled

The custom layer should be present in `build/conf/bblayers.conf`.

From the repository root, check with:

```bash
grep -n 'meta-monkey' build/conf/bblayers.conf
```

Expected result:

```text
meta-monkey
```

The exact line can vary, but the path should point to the local `meta-monkey`
layer.

If `meta-monkey` is missing, re-run the layer setup step from the custom layer
lesson before expecting the image recipe to include `hello-monkey`.

## Files worth opening first

Start with these files:

- `build/conf/local.conf`
- `build/conf/bblayers.conf`
- `meta-monkey/conf/layer.conf`
- `meta-monkey/recipes-example/hello-monkey/hello-monkey_0.1.bb`
- `meta-monkey/recipes-core/images/monkey-image-minimal.bb`

These files show the basic relationship between:

- the build configuration
- the enabled layers
- the custom layer compatibility metadata
- the recipe that installs `hello-monkey`
- the image that includes the package

## What vscode-bitbake should make easier

For this lab, vscode-bitbake is useful as an observation tool.

It can help with:

- navigating BitBake files
- reading recipe syntax
- inspecting layer and recipe structure
- reducing the friction of moving between `conf`, `recipes-*`, and image files

The first learning goal is not to configure every extension feature. The first
goal is to look at a real, small Yocto workspace and understand what the
extension can detect or make easier.

## What this lab does not require

This lab does not require committing a `.vscode/` directory.

A local `.vscode/` folder can be useful for personal editor settings, but those
settings are user-specific and should not be committed unless there is a clear
reason.

This lab also does not require modifying vscode-bitbake itself.

## Useful terminal checks

These commands are read-only and useful while observing the workspace:

```bash
git status -sb
test -d poky && echo "poky exists"
test -d build && echo "build exists"
test -f build/conf/local.conf && echo "local.conf exists"
test -f build/conf/bblayers.conf && echo "bblayers.conf exists"
grep -n 'meta-monkey' build/conf/bblayers.conf
find meta-monkey -maxdepth 3 -type f | sort
```

They help confirm that VS Code is looking at the same workspace that the command
line is using.

## Observed limitations

This lab is intentionally small and local.

That means:

- generated directories can be large
- `poky/` and `build/` are ignored by Git
- some extension behavior may depend on local VS Code settings
- this repository does not provide a committed `.vscode/` configuration
- the lab does not try to model a full production Yocto workspace

That is acceptable. The point is to have a compact, understandable workspace for
learning and observation.

## Cleanup note

If the workspace becomes too large, do not delete caches blindly.

See:

- [Cleanup guide for generated Yocto directories](08-cleanup-guide.md)
