---
type: architecture-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, branding, kryonixos, architecture]
links:
  - "[[MOC - Architecture]]"
  - "[[MOC - Branding]]"
  - "[[KryonixOS Identity]]"
---

# Branding KryonixOS — Arquitetura

Módulo `kryonix.branding` no upstream centraliza identidade visível.

## Superfícies cobertas

- `/etc/os-release` (`NAME`, `PRETTY_NAME`)
- `/etc/issue` (TTY/getty)
- `/etc/motd` (pós-login, opcional)
- Plymouth (tema script-mode)
- GRUB (theme + cores)
- GDM wallpaper (org.gnome.desktop.background)
- `kryonix.meta.version` (`/etc/kryonix-version`)

## Opções declarativas

```nix
kryonix.branding.enable      # bool, default false
kryonix.branding.prettyName  # str, default "KryonixOS"
kryonix.branding.edition     # str, default "" (ex.: "Glacier")
kryonix.branding.versionId   # str, default "25.11"
kryonix.branding.issueText   # nullOr lines
kryonix.branding.motd        # nullOr lines  ← novo no PR #80
```

## Home Manager (PR #80)

```nix
kryonix.programs.fastfetch.logo.enable        # bool, default true
kryonix.programs.zsh.welcomeBanner.enable     # bool, default true
```

Env runtime opt-outs:
- `KRYONIX_NO_WELCOME=1`
- `RAG_ZSH_STARTUP_BANNER=1` (gate do fastfetch completo opt-in)

## Restrições

- `ID=nixos` em `/etc/os-release` é **inviolável** (compat).
- Hosts customizam `prettyName` (ex.: "Kryonix Glacier") sem trocar
  default global.
- `system.stateVersion` nunca muda por branding.
- Assets visuais ficam em `assets/` no repo.

Ver: [[KryonixOS Identity]] · [[Terminal Identity]] · [[Boot Identity]]
