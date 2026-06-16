---
type: branding-note
project: Kryonix
status: in-progress
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, branding, boot, grub, plymouth, iso, p3]
links:
  - "[[MOC - Branding]]"
  - "[[KryonixOS Identity]]"
  - "[[ISO]]"
---

# Boot Identity — KryonixOS

P3 em curso. Cobre GRUB, Plymouth e label do sistema/ISO.

## P3 — escopo aprovado e em curso

| # | Arquivo | Mudança | Status |
|---|---------|---------|--------|
| 1 | `assets/grub-theme/theme.txt` | label `K R Y O N I X` → `KryonixOS` | aplicado em working tree (stashed) |
| 2 | `modules/nixos/meta/version.nix` | fix `KRYONIX_PRETTY_NAME` duplicado | aplicado em working tree (stashed) |
| 3 | `hosts/iso/default.nix` | `distroName = "KryonixOS"`, `label = "KryonixOS-Installer"` | aplicado em working tree (stashed) |

Branch: `branding/boot-identity-p3` no DEV-MOTOR. Aguardando retomar
após a tarefa Vault concluir.

## P4 — Plymouth logo (próximo PR)

- Logo atual: `assets/avatar/ragton.jpeg` (avatar pessoal!).
- Substituir por logo KryonixOS dedicado (PNG 120×120 ou SVG → PNG).
- Branch sugerida: `branding/plymouth-logo-p4`.

## P5 — System label opt-in (futuro)

- `kryonix.branding.systemLabel = { enable, distroName }`.
- Aplicar em [[Inspiron]], [[Glacier]] via downstream.
- Opt-in para não quebrar hosts existentes.

## GRUB theme atual

`assets/grub-theme/theme.txt`:

```
+ label {
  text    = "K R Y O N I X"
  font    = "Unifont Regular 24"
  color   = "#00d4ff"      # cyan accent
}
```

Itens não mudam neste P3: cores GRUB, hint texto, progress bar.

## Plymouth atual

`pkgs.runCommand "kryonix-plymouth-theme" { ... }`:
- Background: wallpaper blurrado.
- Logo: `assets/avatar/ragton.jpeg`. ← problema (P4).
- Animação: fade in/out simples.

## Validações pós-P3

```bash
nix build .#nixosConfigurations.iso.config.system.build.toplevel --no-link -L
nix build .#kryonix-installer --no-link -L

TOP="$(nix build ... --print-out-paths --no-link)"
cat "$TOP/nixos-version"          # esperado: KryonixOS-Installer
cat "$TOP/etc/kryonix-version"    # NÃO conter "KryonixOS KryonixOS"
cat "$TOP/etc/os-release"         # KryonixOS preservado, ID=nixos
```

Smoke-test visual real (ISO em VM libvirt) fica como pendência manual.

Ver: [[Branding KryonixOS]] · [[ISO]] · [[ACTIVE_WORK]]
