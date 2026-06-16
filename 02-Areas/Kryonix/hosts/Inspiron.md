---
type: host-spec
project: Kryonix
status: production
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, host, inspiron, workstation, intel]
links:
  - "[[MOC - Hosts]]"
  - "[[Glacier]]"
---

# Inspiron

Workstation Intel (cliente do Brain remoto).

## Identidade

- Hostname: `inspiron`
- Role: Client / Workstation
- CPU: Intel
- GPU: iGPU Intel (`videoDrivers = [ "modesetting" ]`)

## stateVersion

- `system.stateVersion = "26.05"` ← imutável por branding.

## Boot

- `boot.loader.grub` enable + EFI (`efiSupport = true`).
- Sem `system.nixos.distroName` custom (default NixOS).
- Após branding KryonixOS: superfícies visíveis (issue, motd, fastfetch,
  zsh) mostram KryonixOS; GRUB ainda mostra "K R Y O N I X" (P3 fix).

## Profile

- Importa `inputs.self.nixosModules.full-profile`.
- `kryonix.branding.enable = true`.
- `kryonix.installer.kiosk.enable = false` (ISO-only).

## Networking

- `networkmanager.enable = true`.
- Brain access via Tailscale para [[Glacier]].

## Build

```bash
nix build .#nixosConfigurations.inspiron.config.system.build.toplevel \
  --no-link -L --show-trace
```

## Pendências relacionadas

- Validar `fastfetch` + `zsh` welcome após próximo `kryonixos rebuild`
  (PR #80).

Ver: [[Glacier]] · [[Hosts]]


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]