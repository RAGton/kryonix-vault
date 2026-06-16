---
type: moc
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-15
tags: [kryonix, installer, moc]
links:
  - "[[MOC - Kryonix]]"
  - "[[Installer]]"
  - "[[Externalize-Roadmap]]"
---

# MOC — Installer

## Notas

- [[Externalize-Roadmap]] — **direção atual**: externalizar + fechar ISO RC1
- [[UI Flow]]
- [[Backend Routes]]
- [[Target Flake v2]]
- [[Network Flow]]
- [[Testing]]

## Externalização em curso (2026-06-15)

Mudança estrutural: o installer está sendo movido para repo próprio
<https://github.com/RAGton/kryonix-installer> e passará a ser consumido
pelo motor Kryonix como **flake input direto** (não submodule). Auditoria
confirmou vazamento de source para `/mnt/etc/kryonixos/engine/` — ver
[[Externalize-Roadmap]] para o plano dos 4 PRs.

Status: PR #1 (`RAGton/kryonix-installer#1`) aberto e MERGEABLE — bootstrap
do standalone via `git subtree split --prefix=packages/kryonix-installer`
(50 commits preservados) + flake.nix próprio + CI.

## Componentes (durante a transição)

```txt
packages/kryonix-installer/         ← interno (será removido em PR 3)
├── src/   ← Rust + Axum (backend)
└── ui/    ← React + Vite (frontend)

github:RAGton/kryonix-installer/    ← externo (canônico após PR 2)
├── nix/{package,ui}.nix
└── flake.nix                       ← consumido por inputs.kryonix-installer
```

## Estado em main

- Backend Rust: 42 testes unit (`cargo test`) + clippy gate (PR #78).
- Frontend: 47 testes + Vite build verde.
- PR #70 mergeado: polish UI/network.
- PR #72 mergeado: hardening backend + validação rede + anti-injection.
- PR #78 mergeado: clippy sweep.
- **PR #1 externo** aberto: bootstrap standalone — ver [[Externalize-Roadmap]].

Tags: #kryonix #installer #moc


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]