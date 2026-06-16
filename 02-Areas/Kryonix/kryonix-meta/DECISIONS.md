---
type: decisions
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags:
  - kryonix
  - decision
  - governança
links:
  - "[[MOC - Kryonix]]"
  - "[[CURRENT_STATE]]"
---

# Decisões — Kryonix

Decisões importantes do projeto. **Não negociáveis** sem registro novo
em nota dedicada (`_templates/decision.md`).

## D-001 · DEV vs PROD físico

- DEV-MOTOR = `/home/rocha/kryonix/kryonix`
- DEV-SITE  = `/home/rocha/kryonix/kryonixos`
- PROD-MOTOR = `/etc/kryonix`
- PROD-SITE  = `/etc/kryonixos`

Desenvolvimento acontece **apenas** no DEV-MOTOR.
PROD recebe via `git pull --ff-only origin main` e validações leves.

Registrado em PR #62 (`docs(ops): define git dev-prod workflow`).

## D-002 · PRs pequenos por tema

Cada feature/fix vira PR isolado. **Não misturar**:
- branding × backend
- backend × CI
- ISO firewall × audio × qdbus
- Plymouth × GRUB × channel labels

Origem prática: salvou retrabalho em #65–#69 (preservação histórica
de worktrees) e simplificou o merge train #70 → #71 → #72 → #78 → #80.

## D-003 · `ID=nixos` preservado

`/etc/os-release` mantém `ID=nixos` mesmo após branding KryonixOS, por
compatibilidade com tooling Nix e desktop apps que detectam a família
da distro por esse campo. O branding visível vive em `NAME` e
`PRETTY_NAME`.

PR #71.

## D-004 · KryonixOS é o branding visível

- `kryonix.branding.prettyName` default = `"KryonixOS"`
- `/etc/issue`, `/etc/motd`, fastfetch logo, zsh welcome, GRUB label
  (P3 em curso) — todos KryonixOS.
- Edição específica (ex.: `"Kryonix Glacier"`) sobrescreve por host.

PR #71 / #80.

## D-005 · `system.stateVersion` é intocável por branding

Nunca trocar `system.stateVersion` para alinhar com `versionId`. São
contratos distintos: stateVersion é compatibilidade técnica, versionId
é cosmético em `/etc/os-release`.

## D-006 · ISO sai do HOME, vai como GitHub Release

Build em `/home/rocha/kryonix/kryonix` via `kryonix iso`. Asset sobe em
`gh release create`. **Nunca** commitar ISO no repo.

`docs/operations/RELEASE_ISO.md` é canônico.

## D-007 · `nix flake update` é proibido em PROD

`kryonix update` em PROD-MOTOR faz apenas `git pull --ff-only` +
`check` + `diff`. Atualizar `flake.lock` é decisão DEV.

Implementado em PR #62, validado em uso desde junho/2026.

## D-008 · `gh pr merge` sem `--squash`

Preservamos commits pequenos no merge commit. Estratégia padrão:
`gh pr merge <n> --merge --delete-branch`.

## D-009 · Checks CI vermelhos pré-existentes não bloqueiam

Workflows do GitHub Actions têm débito documentado em issue #79.
Quando o diff de um PR não toca arquivos do workflow e as validações
locais passam, **pode** mergear apesar dos FAILs. Política tácita aceita
pelo dono.

## D-010 · Obsidian Vault como memória do projeto

Esta sessão estabeleceu `/home/rocha/Documents/Obsidian Vault` como
fonte oficial de memória operacional dos agentes. Protocolo em
[[Aura]] e em `docs/ai/skills/OBSIDIAN_MEMORY_PROTOCOL.md`.

Tags: #kryonix #decision


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]