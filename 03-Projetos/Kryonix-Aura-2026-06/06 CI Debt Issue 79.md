---
title: CI Debt — Issue #79
date: 2026-06-14
type: issue-log
status: open
tags: [kryonix, ci, github-actions, débito-técnico, issue]
related:
  - "[[00 Index]]"
  - "[[05 Backlog P3 P4 P5]]"
---

# CI Debt — Issue #79

**URL**: <https://github.com/RAGton/kryonix/issues/79>

## Contexto

Os workflows `Build & Test ISO`, `Nix Validation`, `Rust Audit (Home)`,
`Security Scan` e `Claude Code Action` falham de forma **pré-existente**
em PRs e no `main`. Todos os PRs da sessão Aura 2026-06 (#70, #71, #72,
#78, #80) reproduzem os mesmos FAILs.

Validações locais do escopo de cada PR passaram limpas:
- `cargo test`
- `cargo clippy -D warnings` (após PR #78)
- `nix build .#kryxd`
- `nix build .#nixosConfigurations.iso.config.system.build.toplevel`

## Tabela atual de workflows

| Workflow              | Status | Observação                                          |
|-----------------------|--------|------------------------------------------------------|
| Build & Test ISO      | FAIL   | mesmo fail desde antes de #62                       |
| Nix Validation        | FAIL   | mesmo fail recorrente                               |
| Rust Audit (Home)     | FAIL   | sobre `packages/kryonix-home`, fora do escopo dos PRs|
| Security Scan         | FAIL   | duração suspeita ~8s — possível erro de setup       |
| Claude Code Action    | FAIL   | automation, possivelmente token/secret              |
| Python Audit (Brain)  | PASS   | ✅                                                  |
| Shell & Documentation | PASS   | ✅                                                  |

## Decisão de política tácita

Os PRs #71/#72/#78/#80 foram mergeados **mesmo com esses fails** porque
ficou provado em cada PR que:

- Os mesmos workflows falhavam em `main` no commit imediatamente anterior;
- O diff de cada PR não toca arquivos relacionados aos workflows;
- As validações locais cobriram o escopo real.

## Plano sugerido (sub-PRs)

1. `chore(ci/iso-build)` — investigar **Build & Test ISO**. Reproduzir
   localmente com `nix build .#nixosConfigurations.iso.config.system.build.toplevel`
   (passa localmente; pode ser timeout / runner do GitHub).
2. `chore(ci/nix-validation)` — identificar qual check exato dentro do
   workflow falha. Diferenciar de `nix flake check --keep-going` (que
   passa localmente).
3. `chore(ci/rust-audit-home)` — reproduzir o que esse workflow faz no
   `packages/kryonix-home`. Provavelmente desatualizado.
4. `chore(ci/security-scan)` — ver por que falha em 8s. Pode ser
   secret/token ausente.
5. `chore(ci/claude-action)` — avaliar se o workflow tem propósito
   ou se deve ser removido.

## Critério geral de aceitação

- `gh pr checks <n>` num PR limpo retorna 0 FAILs em workflows
  **Required**, ou os Required passam a ser intencionalmente não-Required.
- `gh pr merge --auto` volta a ser confiável.

## Regras de execução (do issue)

- Não fazer correção em massa sem ler cada log primeiro.
- Cada workflow vira PR isolado.
- Não misturar com features de installer/branding/backend.

## Referência

Issue documentada após o merge do PR #78 (clippy sweep). Aberta como
sinalização explícita de débito técnico — não bloqueia entregas de
feature enquanto a política tácita acima for respeitada.

Ver: [[05 Backlog P3 P4 P5]] · [[02 PRs Mergeados]]
