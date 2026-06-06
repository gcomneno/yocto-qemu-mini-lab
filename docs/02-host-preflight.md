# Host preflight runbook

This document records the concrete host preparation steps executed for the
`yocto-qemu-mini-lab`.

Each step includes:

- the command
- why it is needed
- the expected result
- the observed result

## 1. Check repository status

Command:

```bash
git status --short --branch
```

Why:

Before changing files, check the current Git branch and working tree state.

Expected result:

```text
## main
```

Observed result:

```text
## main
```

## 2. Check recent commits

Command:

```bash
git log --oneline --decorate -5
```

Why:

Confirm that the repository is at the expected starting point.

Expected result:

A short commit history showing the initial repository commit.

Observed result:

```text
0fb95c0 (HEAD -> main) chore: initialize Yocto QEMU mini lab
```

Later, after adding host setup notes:

```text
7cfc67f docs: record Yocto host setup notes
```

## 3. Check tracked files

Command:

```bash
git ls-files
```

Why:

Confirm that only source documentation files are tracked.

Expected result:

The repository should track only small text files, not Yocto build artifacts.

Observed result:

```text
.gitignore
README.md
docs/00-roadmap.md
```

## 4. Update APT package metadata

Command:

```bash
sudo apt update
```

Why:

Refresh the local package index before installing Yocto host dependencies.

Expected result:

APT completes without errors.

Observed result:

```text
Tutti i pacchetti sono aggiornati.
```

## 5. Simulate Yocto host package installation

Command:

```bash
sudo apt install --simulate gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 python3-subunit zstd liblz4-tool file locales libacl1
```

Why:

Check what APT would install before changing the system.

Expected result:

APT should propose a small and reasonable set of packages, without removing
important packages or dragging in an unexpected large dependency set.

Observed result:

APT proposed 9 new packages:

```text
liblz4-tool
python3-extras
python3-fixtures
python3-git
python3-gitdb
python3-pbr
python3-smmap
python3-subunit
python3-testtools
```

## 6. Install Yocto host packages

Command:

```bash
sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 python3-subunit zstd liblz4-tool file locales libacl1
```

Why:

Install the Ubuntu/Debian packages required to build a minimal Yocto image.

Expected result:

APT installs the missing packages and reports no critical system issues.

Observed result:

```text
kernel aggiornato
microcode aggiornato
nessun servizio da riavviare
nessuna VM QEMU obsoleta
```

## 7. Check UTF-8 locale availability

Command:

```bash
locale -a | grep -E '^en_US\.utf8$|^en_US\.UTF-8$' || true
```

Why:

Yocto expects a sane UTF-8 locale. If `en_US.UTF-8` is missing, it should be
generated before building.

Expected result:

One of these values should appear:

```text
en_US.utf8
en_US.UTF-8
```

Observed result:

```text
en_US.utf8
```

Conclusion:

`en_US.UTF-8` is already available. No `locale-gen` step is needed.
