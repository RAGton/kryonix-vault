---
type: architecture-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, installer, architecture]
links:
  - "[[MOC - Architecture]]"
  - "[[MOC - Installer]]"
  - "[[Target Flake v2]]"
---

# Installer — Arquitetura

```txt
UI (React/Vite)
  ─→ Backend (Rust + Axum)
       ─→ Executor (Rust)
            ─→ disko / nixos-install
                 ─→ target flake autocontido em /mnt/etc/kryonixos
                      ─→ KryonixOS instalado
```

## Estrutura no repo

```txt
packages/kryonix-installer/
├── src/                # backend Rust
│   ├── main.rs         # 27 rotas axum
│   ├── network.rs      # /network/{status, apply, wifi/*}
│   ├── auth.rs         # GitHub Device Flow
│   ├── disk.rs
│   ├── detection.rs
│   ├── profiles.rs
│   └── executor/
│       ├── mod.rs
│       ├── kryonixos.rs
│       ├── nixos.rs
│       ├── partition.rs
│       ├── safety.rs
│       ├── target_tree.rs   ← coração do Target Flake v2
│       └── verify.rs
└── ui/                 # frontend
    ├── src/
    │   ├── App.jsx
    │   ├── pages/      # Welcome, Network, Disks, Summary, Install...
    │   ├── components/
    │   ├── utils/
    │   │   ├── installerApi.js
    │   │   ├── installPlan.js
    │   │   └── network.js
    │   └── tests/
    └── ...
```

## Notas vinculadas

- [[UI Flow]]
- [[Backend Routes]]
- [[Target Flake v2]]
- [[Network Flow]]
- [[Testing]]

## Estado atual

- Backend: 42 testes unitários (cargo) — após PR #72.
- Frontend: 47 testes (node test runner) — após PR #70.
- clippy `-D warnings` é gate real após PR #78.
- Target Flake v2 mergeado e validado em PR #70 + commits anteriores.


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]