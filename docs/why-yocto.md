# Why Yocto?

This lab starts with commands, recipes, layers, and images. Before building
anything, it helps to understand the problem Yocto is designed to solve.

## First: Yocto is not a Linux distribution

The Yocto Project provides tools, metadata, and development practices for
creating a custom Linux-based system.

Its main building blocks include:

- BitBake, which executes the task graph
- OpenEmbedded-Core metadata, which provides recipes and classes
- Poky, a reference distribution and integration repository
- layers, which organize reusable metadata
- recipes, which describe how software is fetched, configured, built, packaged,
  and installed

The result can be a complete Linux distribution made for one product, board, or
family of devices.

## Two different starting points

A general-purpose Linux distribution usually starts with a pre-built operating
system. The team then installs packages, removes unwanted components, changes
configuration, and deploys the adapted system.

A Yocto-based workflow starts with versioned metadata and source inputs. The
build describes the operating system that should be produced for the target.

A simplified comparison looks like this:

| Concern | General-purpose distribution | Yocto-based system |
| --- | --- | --- |
| Starting point | Pre-built distribution | Recipes, layers, configuration, and source inputs |
| Main goal | Support many workloads and users | Produce a controlled system for a defined product |
| Image contents | Broad package set, later adapted | Selected during the image build |
| Hardware integration | Distribution packages and local configuration | Machine configuration, BSP layers, kernel and bootloader metadata |
| Repeatability | Depends heavily on repositories, package versions, and deployment scripts | Build inputs and configuration can be pinned and versioned |
| Customization | Usually strongest above the distribution boundary | Can extend from bootloader and kernel through user space |
| Update model | Commonly follows distribution package feeds and release cycles | Product team defines image, package, container, or OTA strategy |
| Initial effort | Usually lower | Usually higher |
| Long-term ownership | Shared with the distribution vendor or community | More responsibility belongs to the product team |

Neither approach is universally better. They optimize for different problems.

## What Yocto gives a product team

### Control over image contents

The image recipe defines what is installed. This helps reduce accidental
components, unused services, unnecessary dependencies, and avoidable attack
surface.

Small images are possible, but they are not automatic. The result still depends
on recipe choices, features, debug options, packaging policy, and product
requirements.

### A versioned build description

Layers, recipes, configuration, patches, and selected revisions can live in
version control. This makes the operating system part of the product source,
rather than a machine that was configured manually and then forgotten.

### Hardware-specific integration

Yocto can describe the machine, bootloader, kernel configuration, device tree,
firmware, and user-space image in one build environment. BSP layers keep
hardware support separate from product and application policy.

### Reproducibility as an engineering goal

Yocto provides mechanisms that support repeatable builds, but using Yocto does
not make a build reproducible by magic.

A team still needs to control inputs such as:

- layer and source revisions
- configuration files
- network-fetched artifacts
- host requirements or containerized build environments
- mirrors and source availability
- timestamps and other non-deterministic inputs

The advantage is that these inputs can be made explicit and managed as part of
the build.

### Product-oriented security maintenance

Yocto supports workflows for license manifests, software bills of materials,
CVE analysis, package data, signed artifacts, read-only filesystems, secure boot
integration, and controlled update mechanisms.

These are capabilities, not guarantees. The product team must still define its
threat model, patch policy, key management, update process, testing, and support
lifetime.

### Long product lifecycles

Embedded products often remain deployed longer than desktop or server
installations. Yocto lets a team choose a supported release line, control
upgrades, preserve product-specific patches, and rebuild complete images when
maintenance is required.

That control also creates responsibility: unsupported layers and private patches
must be maintained by somebody.

## Package managers are not the dividing line

A Yocto image may include a runtime package manager, or it may deliberately omit
one. Yocto itself can generate packages in formats such as RPM, DEB, or IPK.

The important distinction is not "packages versus no packages". It is whether
the deployed system is assembled from a general-purpose distribution or built
from product-controlled metadata and policy.

## When Yocto is a strong fit

Yocto is often a good choice when several of these are true:

- the hardware needs a custom BSP, kernel, bootloader, or firmware integration
- image size and enabled services must be tightly controlled
- builds must be repeated across product versions or manufacturing runs
- the device needs a defined secure boot or OTA update flow
- software composition, licenses, SBOMs, and vulnerability handling must be
  tracked
- the product has a long maintenance or regulatory lifecycle
- multiple related devices should share reusable layers and product policy

Typical examples include gateways, routers, industrial controllers, automotive
systems, robotics platforms, appliances, and edge devices.

## When Yocto may be the wrong tool

A general-purpose distribution may be the better choice when:

- the goal is a quick prototype or proof of concept
- the target behaves like a normal server or workstation
- users need a large, dynamic package ecosystem on the deployed machine
- hardware support already works well in a maintained distribution
- the team cannot fund build infrastructure and long-term platform maintenance
- product requirements do not justify owning a custom operating-system build

Starting with Ubuntu, Debian, Fedora, or another maintained distribution is not
a failure. It can be the more responsible engineering decision.

## The cost of control

Yocto normally requires more:

- learning time
- disk space and build time
- CI capacity
- layer compatibility work
- release planning
- source and mirror management
- security monitoring
- testing across images and hardware

The useful question is therefore not "Is Yocto powerful?" It is:

> Does this product need enough control to justify owning the build and its
> lifecycle?

## Release context for this lab

Release status changes over time, so always verify it against the official Yocto
Project release information.

At the time this note was written, in July 2026:

- Wrynose 6.0 was the current LTS line, supported until April 2030
- Scarthgap 5.0 was also an LTS line, supported until April 2028
- Blacksail 6.1 was the next development release, planned for October 2026
- Walnascar 5.2 was end-of-life

Wrynose 6.0 also introduced a newer kernel and toolchain plus additional SBOM and
CVE-analysis capabilities.

This lab currently pins Poky `yocto-5.2.4`, from the Walnascar series. That makes
the exercises repeatable as originally tested, but it is not a recommendation
for a new production product. Migrating the lab to a supported release is a
separate technical exercise that requires its own build and boot verification.

## Official references

- [Yocto Project releases](https://www.yoctoproject.org/development/releases/)
- [Yocto Project release activity and support table](https://wiki.yoctoproject.org/wiki/Releases)
- [Yocto Project 6.0 Wrynose release notes](https://docs.yoctoproject.org/6.0/migration-guides/release-notes-6.0.html)
- [Yocto Project overview and concepts manual](https://docs.yoctoproject.org/overview-manual/)
