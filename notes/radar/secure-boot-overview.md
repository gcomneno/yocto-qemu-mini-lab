# Secure Boot for embedded Linux

Study notes based on Roy Jamil's talk:

- Title: Secure Boot for Embedded Linux: Explained in Simple Words
- Speaker: Roy Jamil, Ac6
- Event: Embedded Linux Conference
- Video: https://www.youtube.com/watch?v=HqiG6kvHhyQ

Status: study notes only. No implementation yet.

## Core idea

Secure Boot means: only run software approved by the device owner or product vendor.

A normal embedded Linux boot chain is:

- Boot ROM
- Bootloader, often U-Boot
- Linux kernel and device tree
- Root filesystem
- Applications

Without Secure Boot, the device loads the next stage without asking many questions.

With Secure Boot, each stage verifies the next one before running it.

## Threat model

If an attacker can access or replace storage, they may replace the kernel, patch the bootloader, insert a backdoor, modify the device tree, or change the root filesystem.

Secure Boot tries to stop this by refusing to execute untrusted boot components.

## Secure Boot is not disk encryption

Secure Boot checks authenticity and integrity.

Encryption protects confidentiality.

Signing answers: is this software approved and unchanged?

Encryption answers: can someone read this data without the key?

They can work together, but one does not replace the other.

## Hashes

A hash is a fingerprint of data.

The same input always gives the same hash.

If one bit changes, the hash changes completely.

Hashes are useful for detecting tampering.

## Public and private keys

Secure Boot usually uses asymmetric cryptography.

The private key signs.

The public key verifies.

The private key must stay secret. If it leaks, game over.

The public key can be shared because it only verifies signatures.

## Signatures

A simplified signing flow is:

1. Take the image.
2. Calculate its hash.
3. Sign the hash with the private key.
4. Store the image together with the signature and metadata.

A simplified verification flow is:

1. Extract image and signature.
2. Calculate the image hash again.
3. Use the public key to verify the signature.
4. Compare the hashes.
5. Boot only if verification succeeds.

## Root of trust

A chain of trust must start somewhere.

That starting point is the root of trust.

In embedded systems, this is usually hardware-backed:

- Boot ROM
- OTP fuses

The Boot ROM runs first and is provided by the silicon vendor.

OTP means one-time programmable. These fuses can be burned once and then read.

## Public key hashes in fuses

Devices often store the hash of a public key, not the whole public key.

Reason: public keys are large and fuse storage is small.

At boot:

1. The image provides a public key.
2. The ROM hashes that public key.
3. The ROM compares it with the hash burned in fuses.
4. If it matches, the public key is trusted.
5. That public key verifies the signed image.

## Key slots and revocation

Devices may support several trusted key slots.

If one key is compromised, the device may revoke that slot and continue trusting another slot.

This is vendor-specific and operationally painful.

Key management is one of the hard parts of Secure Boot.

## Chain of trust

Each stage verifies the next one.

Typical chain:

- Boot ROM verifies first stage loader.
- First stage loader verifies trusted firmware and U-Boot.
- U-Boot verifies Linux kernel and device tree.
- Linux can extend verification to the root filesystem.

If any link is broken, the whole chain is broken.

Signing only the kernel is not enough if the bootloader is not trusted.

Signing the kernel but forgetting the device tree is also dangerous.

## FIT images

In U-Boot systems, Linux boot artifacts are often packaged as FIT images.

A FIT image can contain:

- kernel image
- device tree blob
- initramfs or ramdisk
- metadata
- signatures

U-Boot can verify a signed FIT image before booting Linux.

But a signed FIT image alone is not enough if U-Boot itself was not verified first.

## Root filesystem verification

The root filesystem is harder to verify than a single binary because it contains many files.

One common solution is DM-Verity.

DM-Verity can extend integrity checking to the root filesystem.

It usually fits read-only root filesystems, such as SquashFS-based embedded systems.

## Secure Boot vs secure world

Secure Boot and secure world are different concepts.

Secure Boot happens during boot.

It verifies that each boot stage is approved before it runs.

Secure world is a runtime isolation mechanism, commonly associated with Arm TrustZone.

Secure world can host secure firmware, secure monitor code, OP-TEE, trusted applications, secure services, secure storage, and access to secure peripherals.

Secure Boot asks: is this code allowed to run?

Secure world asks: can sensitive runtime services be isolated from normal Linux?

## Arm Trusted Firmware and boot levels

On Arm systems, the boot process may involve Arm Trusted Firmware.

Common boot level names:

- BL1: Boot ROM or first boot stage
- BL2: early setup, secure peripherals, memory setup
- BL31: secure monitor, handles secure monitor calls
- BL32: secure operating system, often OP-TEE
- BL33: normal-world bootloader, often U-Boot

Simplified view:

- Secure world: Boot ROM -> BL2 -> BL31 -> OP-TEE
- Normal world: Boot ROM -> BL2 -> BL31 -> U-Boot -> Linux

## OP-TEE

OP-TEE is an open source secure operating system.

It is not a full Linux-like OS.

It hosts trusted applications and provides secure services.

It can manage secure memory, secure peripherals, cryptographic engines, trusted applications, and communication between Linux and secure services.

Linux can communicate with OP-TEE through drivers and client APIs.

## Vendor-specific examples

Different vendors use different names and signing formats.

STM32MP typically uses:

- Boot ROM
- FSBL, often Trusted Firmware-A
- SSBL, often U-Boot
- Linux kernel and DTB

NXP i.MX 9 uses AHAB, Advanced High Assurance Boot.

AHAB containers can hold image, signature, and key information.

NXP platforms may include EdgeLock Secure Enclave, an isolated security component inside the chip that can protect keys and provide secure operations.

## What Secure Boot guarantees

Secure Boot can guarantee that:

- the boot code is the code you signed;
- the bootloader or kernel was not silently replaced;
- tampered boot artifacts are refused;
- the system starts from a known trusted boot state.

## What Secure Boot does not guarantee

Secure Boot does not guarantee that:

- your code has no bugs;
- Linux cannot be exploited after boot;
- applications are safe;
- your private keys are safe;
- runtime data cannot be attacked;
- your update process is secure.

Secure Boot is necessary in many products, but it is not magic powder.

## Common mistakes

Common mistakes include:

- signing the kernel but not the device tree;
- verifying only the kernel while leaving U-Boot untrusted;
- leaving the U-Boot console open in production;
- not burning fuses;
- storing private keys carelessly;
- testing only the successful boot path;
- not testing tampered images;
- confusing encryption with signing;
- assuming Secure Boot also means runtime security.

## Practical test mindset

A Secure Boot setup should be tested in both directions.

Happy path:

- valid signed image boots successfully.

Failure path:

- tampered image must not boot.

If the tampered image still boots, Secure Boot is not actually protecting the device.

## Connection to this Yocto lab

For this lab, Secure Boot is not implemented yet.

The topic is useful for later stages after the basic Yocto/QEMU image works.

Possible future learning path:

1. Build a minimal Yocto image.
2. Boot it in QEMU.
3. Add a custom layer.
4. Add U-Boot.
5. Study FIT images.
6. Sign kernel and device tree.
7. Explore root filesystem integrity with DM-Verity.
8. Study OTA update signing.

## Current status

This document is a study note.

No Secure Boot implementation is present in this repository yet.

Do not treat this as a production Secure Boot guide.
