# meta-monkey

Custom Yocto layer for the `yocto-qemu-mini-lab`.

This layer is intentionally small and educational.

Planned contents:

- a tiny `hello-monkey` recipe
- a minimal custom image recipe
- small examples for learning how Yocto layers are structured

## Layer compatibility

This layer was created for the Yocto/Poky series:

```text
walnascar
```

The lab currently uses the fixed Poky tag:

yocto-5.2.4
Important files
conf/layer.conf: declares the layer to BitBake
recipes-*: future recipe directories
Notes

Generated build artifacts do not belong in this layer.

Only metadata, recipes, small source files, and documentation should be tracked.
