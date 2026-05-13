# IDEA.md — WHAT

This file answers **what** this project is and what it contains.
How things are done: see `AI.md`.
Rules: see the rules file in the repo root.

---

## Project Overview

A curated collection of bash scripts for system administration, development
tooling, and personal automation. Scripts are designed to be self-contained,
portable across Linux distributions, and installable as a dotfiles suite.

---

## Goals

- One script per concern — no monolithic tools
- Self-contained scripts with no runtime dependencies beyond bash and standard POSIX utilities
- Consistent UX: every script supports `--help`, `--version`, `--debug`, `--raw`
- Portable across amd64, arm64, and arm (armv7l)
- Installable system-wide or per-user via `install.sh`

---

## Directory Structure

```
bin/                  executable scripts (one per tool)
functions/            shared function libraries (sourced by scripts during migration)
completions/          bash completions: _{script}_completions.bash
man/                  man pages: {script}.1
templates/            script generation templates (gen-script output)
tests/                test scripts
containers/           Dockerfiles + docker-compose.yml for distro testing
```

---

## Script Categories

### System Administration
- `pkmgr` — unified package manager wrapper (apt/dnf/pacman/apk/brew/etc.)
- `sysusage` — system resource usage summary
- `setupmgr` — install third-party tools not in distro repos (binary/archive/npm/pip)
- `detectostype` — OS/distro/arch detection (safe to source)
- `captive-auth` — captive portal detection and login automation
- `update-lecerts` — Let's Encrypt certificate renewal automation
- `proxmox-cli` — Proxmox VE management helpers

### Development Tooling
- `gitcommit` — sign + commit + push wrapper (the only commit path)
- `gitadmin` — git repository administration helpers
- `gen-changelog` — generate changelogs from git history
- `buildx` — multi-arch container image builder (Docker BuildKit wrapper)
- `dockermgr` — Docker image/container management
- `apimgr` — multi-provider container registry + git forge API client
- `gen-script` — scaffold new scripts from templates
- `gen-playlist` — generate media playlists

### Networking & Security
- `anonymize` — anonymity tooling (Tor, I2P, Freenet, Lokinet, VPN, MAC randomization)
- `cloudflare` — Cloudflare DNS/tunnel management
- `captive-auth` — captive portal automation
- `pastebin` — upload snippets to pastebin services

### Environment & Desktop
- `dotfiles` — unified dotfiles manager (delegates to dfmgr, desktopmgr, etc.)
- `randomwallpaper` — rotating desktop wallpaper daemon
- `tmux-new` — tmux session/window launcher with config templates
- `zellij-new` — zellij session launcher
- `notifications` — desktop notification helper

### Utilities
- `dictionary` — offline word lookup
- `reqpkgs` — check/install required packages for a script
- `gen-nginx` — generate nginx vhost configs
- `latest-iso` — fetch latest distro ISO URLs

---

## Configuration Layout

```
~/.config/myscripts/{scriptname}/     per-user config
~/.local/log/{scriptname}/            per-user logs
/etc/casjaysdev/{scriptname}/         system-wide config (root installs)
```

---

## Installation

```bash
bash install.sh
```

Copies `bin/*` to `/usr/local/bin/`, man pages to `/usr/local/man/man1/`,
completions to `/etc/bash_completion.d/`.

---

## Supported Architectures

- `linux/amd64` (x86_64)
- `linux/arm64` (aarch64)
- `linux/arm` (armv7l)

---

## Script Header Format

Every script begins with:

```bash
#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  YYYYMMDDHHMM-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  LICENSE.md
# @@ReadME           :  {script} --help
# @@Copyright        :  Copyright: (c) {year} Jason Hempstead, Casjays Developments
# @@Created          :  {date}
# @@File             :  {script}
# @@Description      :  {one-line description}
# @@Changelog        :  {what changed}
# @@TODO             :  Better documentation
# @@Template         :  bash/{type}
```

---

## Key External Dependencies

Scripts detect and adapt to whatever is available:
- Package managers: apt, dnf, pacman, apk, brew, zypper, xbps
- Init systems: systemd, openrc, s6, runit
- Container runtimes: docker, podman, incus, lxc
- Display servers: X11, Wayland, headless

No hard runtime dependencies beyond bash 4+ and standard POSIX utilities.
