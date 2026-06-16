---
type: entity
entity-type: issue
project: Kryonix
status: open
created: 2026-06-14
updated: 2026-06-14
tags:
  - kryonix
  - issue
  - ci
  - debt
links:
  - "[[Validation Matrix]]"
  - "[[CURRENT_STATE]]"
---

# Issue #79 · chore(ci): fix pre-existing failing workflows

**URL**: <https://github.com/RAGton/kryonix/issues/79>

## Estado

OPEN. Documenta workflows quebrados há tempos no `main`.

## Workflows afetados

- Build & Test ISO
- Nix Validation
- Rust Audit (Home)
- Security Scan
- Claude Code Action

## Política de merge

[[DECISIONS]] D-009: PRs podem ser mergeados mesmo com esses fails,
**se** validações locais passam e diff não toca arquivos do workflow.

## Plano sugerido

5 sub-PRs (um por workflow). Não misturar com features.

## Referências

- Aberta após merge do PR #78.
- Reproduzido em PRs #71/#72/#78/#80 sem regressão.

Ver: [[CURRENT_STATE]] · [[Validation Matrix]]
