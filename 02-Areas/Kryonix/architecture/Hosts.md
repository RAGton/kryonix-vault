---
type: architecture-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, hosts, architecture]
links:
  - "[[MOC - Architecture]]"
  - "[[MOC - Hosts]]"
---

# Hosts — Arquitetura

Hosts conhecidos do projeto. Cada um vive em `hosts/<nome>/default.nix`
no repo ou no downstream `kryonixos`.

| Host | Tipo | Status | Nota dedicada |
|------|------|--------|----------------|
| inspiron | Workstation Intel | produção | [[Inspiron]] |
| inspiron-nina | Inspiron secundário | produção | [[Inspiron Nina]] |
| glacier | Server / IA (AMD/Nvidia) | produção | [[Glacier]] |
| iso | Live CD / installer | release artifact | [[ISO]] |

## Diretrizes

- Hardware vive em `hosts/<host>/hardware-configuration.nix` (não tocar).
- Discos vivem em `hosts/<host>/disks.nix` (não tocar sem disko plan).
- Compilação pesada (Rust/CUDA) acontece no Glacier ou vem do Cachix.
- `system.stateVersion` por host é **imutável** — não trocar por branding.

Ver: `docs/ARCHITECTURE.md`, [[MOC - Hosts]]
