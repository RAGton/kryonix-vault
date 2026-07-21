---
type: project-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-15
tags:
  - kryonix
  - active-work
  - wip
links:
  - "[[MOC - Kryonix]]"
  - "[[CURRENT_STATE]]"
  - "[[ROADMAP]]"
  - "[[Externalize-Roadmap]]"
---

# Active Work — Kryonix

## Em curso — Externalização do installer (P0)

**Sprint 1** (ver [[Externalize-Roadmap]]):

1. ⏳ Mergear [PR #1 RAGton/kryxd](https://github.com/RAGton/kryxd/pull/1)
   — `initial-flake-and-ci`. MERGEABLE, validações verde
   (fmt + clippy -D + 42 cargo tests + 47 npm tests + nix build + flake check).
2. ⏳ Abrir PR `installer/externalize-input-p1` no motor após merge do #1.
3. ⏳ PR `installer/exclude-installer-from-target-p2` (denylist).
4. ⏳ PR `installer/remove-internal-source-p3` (remoção interna).

Auditoria que motivou: `packages/kryxd/` é copiado para
`/mnt/etc/kryonixos/engine/packages/kryxd/` durante o install
(`COPY_DENYLIST` filtra caches, não o pacote em si).

## Recém concluído

- ✅ **Auditoria externalização installer** (2026-06-14) —
  mapa de acoplamentos, denylist gap, estratégia flake input direto.
- ✅ **PR #1 standalone** (`RAGton/kryxd#1`) — bootstrap do
  repo standalone via subtree split (50 commits preservados) + flake +
  CI + README. Validações 100% verde local.
- ✅ **P3** boot identity — PR #82 mergeado em `6f52a084`.
- ✅ **Vault P1** Obsidian protocol — PR #81 mergeado em `28ceb401`.
- ✅ **PROD-MOTOR** sincronizado em
  [[09-Logs/sessions/2026-06-15/2026-06-15-0250-sync-prod-after-boot-identity]]
  — sem `kryonix switch/boot`.

## Próximas frentes (após externalização)

- ISO RC1 — build `.iso` real + smoke VM libvirt.
- Backend hardening P2 — `deny_unknown_fields`, payload guards.
- UI final — error/success screens, export `install-plan.json`.
- Segurança UI remota — token + opt-in.
- CI #79 — sub-PRs por workflow.
- P4 — Plymouth logo dedicado (substituir `ragton.jpeg`).
- P5 — `kryonix.branding.systemLabel` opt-in para hosts não-ISO.

Ver: [[Externalize-Roadmap]] · [[ROADMAP]] · [[CURRENT_STATE]] · [[Boot Identity]]


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]