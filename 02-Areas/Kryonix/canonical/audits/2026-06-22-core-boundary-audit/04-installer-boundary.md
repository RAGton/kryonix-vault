# Fronteira do Installer

## Itens de ISO no core

| Item | Caminho | Deve ir para installer? | Status |
|---|---|---|---|
| Host ISO | `hosts/iso/default.nix` | ✅ Sim | Resíduo — já há repo installer |
| ISO wrapper | `iso.nix` | ✅ Sim | Wrapper na raiz |
| Installer module | `modules/nixos/installer/default.nix` | ✅ Sim | Módulo completo |
| Web kiosk | `modules/nixos/installer/web-kiosk.nix` | ✅ Sim | Kiosk Cage/Chromium |
| TUI scripts | `modules/nixos/installer/kryonix-install-tui.sh` | ✅ Sim | Script TUI |
| TUI lib | `modules/nixos/installer/tui-lib.sh` | ✅ Sim | Lib TUI |

## Itens de web-kiosk encontrados

- `modules/nixos/installer/web-kiosk.nix` (138 linhas)
- Serviço systemd `kryonix-installer-backend`
- Usuário `installer` com autologin
- Cage como kiosk Wayland
- Chromium em modo kiosk

## Itens de disk planner encontrados

- `packages/kryonix-disk-planner.nix` — package
- `packages/kryonix-disk-planner/` — source Rust
- `packages/kryonix-hardware-probe.nix` — package
- `packages/kryonix-hardware-probe/` — source Rust

## O que deve ir para kryonix-installer

- `hosts/iso/` — ISO build completo
- `iso.nix` — wrapper ISO
- `modules/nixos/installer/` — módulos NixOS do installer (TUI, kiosk, backend)
- `packages/kryonix-disk-planner*` — disk planner
- `packages/kryonix-hardware-probe*` — hardware probe
- Scripts relacionados: `scripts/test-installer-*.sh`, `scripts/test-iso-boot.sh`, `scripts/publish-installer.sh`

## O que pode permanecer como lib compartilhada

- `lib/options.nix` — opções do installer referenciam `kryonix.installer.*` (manter no core)
- Referências em `overlays/default.nix` ao `kryonix-installer-tools` overlay (manter)

## Como validar

1. `nix build .#nixosConfigurations.iso.config.system.build.toplevel --no-link -L` — build atual
2. Verificar se o flake outputs ainda expõe `nixosConfigurations.iso`
3. Após mover, o downstream e o installer repo devem ser as fontes de verdade
