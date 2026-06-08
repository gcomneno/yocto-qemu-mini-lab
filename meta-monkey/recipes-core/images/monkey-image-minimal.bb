SUMMARY = "Minimal QEMU image for the Yocto QEMU mini lab"
DESCRIPTION = "A core-image-minimal based image that includes the hello-monkey package."
LICENSE = "MIT"

require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL:append = " hello-monkey"
