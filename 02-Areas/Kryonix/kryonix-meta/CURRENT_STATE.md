---
type: project-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-15
tags:
  - kryonix
  - state
  - current
links:
  - "[[MOC - Kryonix]]"
  - "[[ACTIVE_WORK]]"
  - "[[DECISIONS]]"
  - "[[Externalize-Roadmap]]"
---

# Estado atual — Kryonix

> Snapshot operacional vivo. Reler no começo de toda sessão.

## main em produção

- HEAD: `6f52a084` Merge pull request #82 (boot identity P3)
- DEV-MOTOR e PROD-MOTOR ambos em `6f52a084` (sincronizados em 2026-06-15)
- Política DEV/PROD oficial via [[Safe Git Workflow]]

## DEV-MOTOR vs PROD-MOTOR

- DEV = `/home/rocha/kryonix/kryonix`
- PROD = `/etc/kryonix`
- DEV-SITE = `/home/rocha/kryonix/kryonixos`
- PROD-SITE = `/etc/kryonixos`

Detalhes em [[DEV PROD Flow]] · regra de ouro: **nunca tocar `/etc`
durante dev**.

## PRs recentes mergeados (junho/2026)

| # | Título | Merge |
|---|--------|-------|
| #62 | ops: define git dev-prod workflow | 2b322b24 |
| #70 | feat(installer-ui): polish network flow + summary | e84ec73b |
| #71 | fix(branding): default to KryonixOS identity | aa70d669 |
| #72 | fix(installer): network apply tests + hostname guard | 395adaec |
| #78 | chore(installer): clippy sweep | a83590e2 |
| #80 | feat(branding): KryonixOS terminal identity | 30d84ad6 |
| #81 | docs(ai): add Obsidian memory protocol skill | 28ceb401 |
| #82 | feat(branding): align boot identity with KryonixOS | 6f52a084 |

## PRs / branches em aberto

| Item | Status |
|------|--------|
| [RAGton/kryonix-installer#1](https://github.com/RAGton/kryonix-installer/pull/1) `initial-flake-and-ci` | aberto, MERGEABLE — bootstrap repo standalone (subtree split + flake + CI) |
| `installer/externalize-input-p1` (Kryonix) | a abrir após merge do #1 |
| `installer/exclude-installer-from-target-p2` (Kryonix) | planejado |
| `installer/remove-internal-source-p3` (Kryonix) | planejado |
| #65–#69 (draft) | preservação histórica, não mergear |

## Repos relacionados

- **Motor**: <https://github.com/RAGton/kryonix> (este repo).
- **Installer (NOVO)**: <https://github.com/RAGton/kryonix-installer>
  — privado; bootstrap em PR #1; será consumido como flake input.
- **kryonix-home**: <https://github.com/RAGton/KRYONIX-HOME> (submodule).
- **kryonix-brain-lightrag**: <https://github.com/RAGEnterprise/kryonix-brain-lightrag> (submodule).
- **kryonix-vault**: <https://github.com/RAGton/kryonix-vault> (submodule `.ai/kryonix-vault`).

## Sincronização DEV ↔ PROD

- 2026-06-15 02:50 — PROD-MOTOR (/etc/kryonix) atualizado de `2b322b24`
  para `6f52a084` via `git pull --ff-only` (23 commits). Sem
  `kryonix switch/boot/rebuild` — apenas atualização de árvore Git.
  Geração de runtime continua sendo a anterior até decisão humana.
  Ver [[09-Logs/sessions/2026-06-15/2026-06-15-0250-sync-prod-after-boot-identity]].

## Issues abertas

- #77 — clippy sweep → **fechada** pelo PR #78 ✅
- #79 — chore(ci): fix pre-existing failing workflows ← em aberto

## Estado de identidade KryonixOS (acumulado)

- `/etc/os-release`: `NAME="KryonixOS"`, `PRETTY_NAME=KryonixOS`,
  `ID=nixos` (técnico, preservado).
- `/etc/issue`: `Welcome to KryonixOS …`
- `/etc/motd`: `Welcome to KryonixOS. Run \`kryonix --help\` …`
- `fastfetch`: logo ASCII Kryonix (cyan/magenta) — opt-out via opção HM.
- `zsh`: welcome banner curto — opt-out via `KRYONIX_NO_WELCOME=1`.
- GRUB theme: label atualizado para `KryonixOS` ✅ (PR #82).
- ISO: `nixos-version=KryonixOS-Installer`,
  system drv `nixos-system-kryonix-KryonixOS-Installer` ✅ (PR #82).
- `/etc/kryonix-version`: `KryonixOS (v<sha>)` ✅
  (sem duplicação após PR #82).
- Plymouth: logo ainda é `assets/avatar/ragton.jpeg` (P4 fila).

## Validações de CI (status conhecido)

- Workflows quebrados há tempos (issue [[02-Areas/Kryonix/entities/Issues/Issue 79]]):
  - Build & Test ISO
  - Nix Validation
  - Rust Audit (Home)
  - Security Scan
  - Claude Code Action
- Validações **locais** dos PRs continuam verdes (`cargo test`,
  `nix build .#nixosConfigurations.iso...`).

## Pendências operacionais

- Validar Home Manager (fastfetch+zsh) no downstream após próximo
  `kryonixos rebuild` (PRs #80).
- Smoke-test visual GRUB/Plymouth em VM libvirt (após P3+P4).
- Fechar PRs draft #65–#69 quando confortável.
- Limpar minha worktree em `/etc/kryonix/.claude/worktrees/aura-git-dev-prod-skill`
  quando sessão do agente terminar.

Ver: [[ACTIVE_WORK]] · [[02 PRs Mergeados]] em `03-Projetos/Kryonix-Aura-2026-06/`
