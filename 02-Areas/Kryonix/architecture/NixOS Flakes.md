---
type: architecture-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, nixos, flake, architecture]
links:
  - "[[MOC - Architecture]]"
  - "[[DEV PROD Flow]]"
---

# NixOS Flakes — Kryonix

## flake.nix (roteador fino)

- Define inputs, exporta `nixosConfigurations`, `homeConfigurations`,
  `packages`, `nixosModules`, `homeManagerModules`, `overlays`, `checks`.
- `flake/lib.nix` provê `mkNixosConfiguration` consumido pelo downstream.

## Convenções

- Opções públicas no namespace `kryonix.*` (`lib/options.nix`).
- Default seguro `enable = false`.
- Condicionais via `lib.mkIf`; opções via `lib.mkOption` com `type`
  explícito.
- Pacotes consumidos via overlay (`pkgs.kryonix.<comp>`).
- Formatação: `nix fmt` (formatter da flake).

## Validações canônicas

```bash
nix flake check --keep-going --impure
nix flake show --all-systems
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link -L
nix build .#homeConfigurations."rocha@inspiron".activationPackage --no-link -L
```

## flake.lock

- DEV: pode mudar via `nix flake update` ou via [[Safe Git Workflow]].
- PROD: **resultado de pull**, nunca escrita local. Ver [[DEV PROD Flow]].

Ver: `docs/ARCHITECTURE.md`, [[Installer]]


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]