---
type: branding-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, branding, kryonixos, os-release, issue, motd]
links:
  - "[[MOC - Branding]]"
  - "[[Branding KryonixOS]]"
  - "[[Terminal Identity]]"
  - "[[Boot Identity]]"
---

# KryonixOS Identity

Identidade do sistema entregue até PR #80. Cobre superfícies básicas
do Linux desktop.

## Superfícies

### `/etc/os-release`

```ini
NAME="KryonixOS"
PRETTY_NAME=KryonixOS               # (sai como displayName: prettyName + edition)
ID=nixos                            # ← mantido por compatibilidade técnica
ID_LIKE=nixos
VERSION_ID=25.11
LOGO=nix-snowflake
HOME_URL="https://nixos.org/"
```

### `/etc/issue` (TTY/getty)

```txt
Welcome to KryonixOS
Kernel: \r \m
Host: \n
```

### `/etc/motd` (pós-login)

```txt
Welcome to KryonixOS.
Run `kryonix --help` for system commands.
```

### `/etc/kryonix-version`

```ini
KRYONIX_REV=<sha>
KRYONIX_BUILD_TIME=<timestamp>
KRYONIX_PRETTY_NAME="KryonixOS KryonixOS (v<sha>)"   # ← bug detectado em P3
```

## Pendência ativa (P3)

Bug em `modules/nixos/meta/version.nix:30`:

```nix
prettyName = "KryonixOS ${brandingPrettyName} (v...)";  # duplica
# →
prettyName = "${brandingPrettyName} (v...)";            # correto
```

## Opções declarativas

```nix
kryonix.branding.enable      # bool, default false
kryonix.branding.prettyName  # str, default "KryonixOS" (PR #71)
kryonix.branding.edition     # str, ex: "Glacier"
kryonix.branding.versionId   # str, default "25.11"
kryonix.branding.issueText   # nullOr lines
kryonix.branding.motd        # nullOr lines  (PR #80)
```

## Hosts que customizam

- [[Glacier]]: `prettyName = "Kryonix Glacier"`, `edition = "Server/Workstation"`.
- [[Inspiron]]: defaults.

Ver: [[Terminal Identity]] · [[Boot Identity]]
