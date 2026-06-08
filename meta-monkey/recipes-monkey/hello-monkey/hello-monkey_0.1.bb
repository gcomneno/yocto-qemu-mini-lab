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
