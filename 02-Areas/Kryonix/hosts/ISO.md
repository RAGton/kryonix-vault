---
type: host-spec
project: Kryonix
status: release-artifact
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, host, iso, installer]
links:
  - "[[MOC - Hosts]]"
  - "[[MOC - Installer]]"
  - "[[Boot Identity]]"
---

# ISO — Live CD / installer

Host efêmero que gera a imagem instalável do KryonixOS.

## Definição

`hosts/iso/default.nix`. Importa:

- `installation-cd-minimal.nix` (NixOS base)
- `inputs.self.nixosModules.installer-core`
- `modules/nixos/installer/web-kiosk.nix`
- `modules/nixos/meta`
- `modules/nixos/branding/kryonix/default.nix`
- `+ inputs.self.nixosModules.full-profile` (modo offline)

## Identidade

```nix
system.nixos.distroName    = lib.mkForce "Kryonix";          # P3 → "KryonixOS"
system.nixos.label         = lib.mkForce "Kryonix-Installer";# P3 → "KryonixOS-Installer"
image.baseName             = lib.mkForce "kryonix";
isoImage.volumeID          = lib.mkForce "KRYONIX";
isoImage.appendToMenuLabel = lib.mkForce "Installer";
networking.hostName        = lib.mkForce "kryonix";
```

## Plymouth e boot

- `boot.plymouth.enable = lib.mkForce true` (cd-minimal desabilita).
- `boot.initrd.verbose = false`, `boot.consoleLogLevel = 0`.
- `boot.kernelParams = lib.mkAfter [ "quiet" "splash" ... ]` —
  **mkAfter NUNCA mkForce** (mkForce sobrescreve root=LABEL e causa
  kernel panic).

## Build

```bash
nix build .#nixosConfigurations.iso.config.system.build.toplevel \
  --no-link -L --show-trace

kryonix iso              # build CLI wrapper
```

## ISO release

Procedimento em [[Runbooks]] / `docs/operations/RELEASE_ISO.md`.

ISO **nunca** vai para o Git normal — só como asset de Release.

## Pendências P3 / P4

- [[Boot Identity]] — GRUB label, system.nixos.distroName, KryonixOS.
- Plymouth logo (P4) — substituir avatar pessoal.

Ver: [[Boot Identity]]
