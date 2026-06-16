---
type: moc
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, architecture, moc]
links:
  - "[[MOC - Kryonix]]"
---

# MOC — Architecture

Visão geral de arquitetura do Kryonix.

## Notas

- [[NixOS Flakes]]
- [[DEV PROD Flow]]
- [[Hosts]]
- [[Installer]]
- [[Branding KryonixOS]]
- [[Security Model]]

## Camadas (modelo conceitual)

```txt
hosts/      ← hardware + identidade do host real
profiles/   ← papéis: glacier-ai, inspiron-workstation, etc.
features/   ← combinações coesas de módulos (ai, gaming)
modules/    ← peças atômicas (services/brain, branding/kryonix, etc.)
flake.nix   ← roteador fino → flake/lib.nix mkNixosConfiguration
```

## Integração upstream → downstream

```nix
mkNixosConfiguration = hostname: username: inputs.nixpkgs.lib.nixosSystem {
  modules = [
    inputs.kryonix.nixosModules.default       # 1. motor (upstream)
    "${inputs.self}/hosts/${hostname}"        # 2. hardware/role (downstream)
  ];
};
```

Detalhe em `docs/ARCHITECTURE.md` no repo.

## Tags principais

#kryonix #architecture #nixos #flake
