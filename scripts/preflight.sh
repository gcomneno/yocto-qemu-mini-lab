#!/usr/bin/env bash

# Read-only host preflight checks for yocto-qemu-mini-lab.
#
# This script does not install packages, delete files, modify configuration, or
# clone repositories. It only prints information and warnings.

warnings=0

info() {
  printf '[INFO] %s\n' "$1"
}

ok() {
  printf '[ OK ] %s\n' "$1"
}

warn() {
  warnings=$((warnings + 1))
  printf '[WARN] %s\n' "$1"
}

section() {
  printf '\n== %s ==\n' "$1"
}

bytes_to_gib() {
  awk -v bytes="$1" 'BEGIN { printf "%.1f", bytes / 1024 / 1024 / 1024 }'
}

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"

section "Repository"
info "Current directory: $PWD"
info "Detected repository root: $repo_root"

if [ -d "$repo_root/.git" ]; then
  ok "Repository metadata found"
else
  warn "No .git directory found at detected repository root"
fi

section "Operating system"

if [ -r /etc/os-release ]; then
  os_pretty="$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
  if [ -n "$os_pretty" ]; then
    info "OS: $os_pretty"
  else
    warn "Could not read PRETTY_NAME from /etc/os-release"
  fi
else
  warn "/etc/os-release is not readable"
fi

section "Disk space"

df -h "$repo_root" || warn "Could not run df for repository filesystem"

available_kib="$(df -Pk "$repo_root" 2>/dev/null | awk 'NR == 2 { print $4 }')"

if [ -n "$available_kib" ]; then
  available_bytes=$((available_kib * 1024))
  available_gib="$(bytes_to_gib "$available_bytes")"
  info "Available space near repository: ${available_gib} GiB"

  if [ "$available_kib" -lt $((30 * 1024 * 1024)) ]; then
    warn "Less than 30 GiB available. A first Yocto build may fail or require cleanup."
  elif [ "$available_kib" -lt $((60 * 1024 * 1024)) ]; then
    warn "Less than 60 GiB available. This can work, but it may be tight for a comfortable first build."
  else
    ok "Disk space looks comfortable for this learning lab"
  fi
else
  warn "Could not determine available disk space"
fi

section "Memory and swap"

if [ -r /proc/meminfo ]; then
  mem_kib="$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)"
  swap_kib="$(awk '/^SwapTotal:/ { print $2 }' /proc/meminfo)"

  if [ -n "$mem_kib" ]; then
    mem_bytes=$((mem_kib * 1024))
    mem_gib="$(bytes_to_gib "$mem_bytes")"
    info "RAM: ${mem_gib} GiB"

    if [ "$mem_kib" -lt $((16 * 1024 * 1024)) ]; then
      warn "Less than 16 GiB RAM. This can work, but swap pressure is possible."
    else
      ok "RAM is at or above the practical 16 GiB comfort threshold"
    fi
  else
    warn "Could not determine RAM size"
  fi

  if [ -n "$swap_kib" ]; then
    swap_bytes=$((swap_kib * 1024))
    swap_gib="$(bytes_to_gib "$swap_bytes")"
    info "Swap: ${swap_gib} GiB"

    if [ "$swap_kib" -eq 0 ]; then
      warn "No swap detected. Small hosts may benefit from swap during Yocto builds."
    fi
  else
    warn "Could not determine swap size"
  fi
else
  warn "/proc/meminfo is not readable"
fi

section "Required commands"

required_commands=(
  git
  python3
  gcc
  make
  gawk
  wget
  tar
  xz
  zstd
  file
  diffstat
  unzip
  chrpath
  socat
  cpio
  locale
)

for command_name in "${required_commands[@]}"; do
  if command -v "$command_name" >/dev/null 2>&1; then
    ok "$command_name found: $(command -v "$command_name")"
  else
    warn "$command_name not found in PATH"
  fi
done

section "Locale"

if locale -a 2>/dev/null | grep -E '^en_US\.utf8$|^en_US\.UTF-8$' >/dev/null; then
  ok "en_US.UTF-8 locale is available"
else
  warn "en_US.UTF-8 locale not found. Generate it before building if Yocto complains."
fi

section "Summary"

if [ "$warnings" -eq 0 ]; then
  ok "Preflight completed without warnings"
else
  warn "Preflight completed with $warnings warning(s)"
  info "Warnings are practical guidance, not absolute failures."
fi

exit 0
