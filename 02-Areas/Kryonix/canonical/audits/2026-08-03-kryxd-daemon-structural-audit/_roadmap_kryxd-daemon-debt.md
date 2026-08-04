---
title: Roadmap kryxd-daemon debt
date: 2026-08-04
tags: [kryonix, kryxd, roadmap, debt, in-progress]
status: in-progress
ssot: Kanban Hermes (este arquivo é espelho)
ultima_sync: 2026-08-04
---

# Roadmap kryxd-daemon debt

> Espelho do Kanban Hermes. SSOT é o Kanban.
> Última sincronização: 2026-08-04

## Status após Gate A.1 (baseline 2026-08-04)

Build compila ✅. Test NÃO compila ❌ (4 inicializadores quebrados de `InstallPlanV2`).

KCRs atualizados:

| KCR | Status | Esforço | Bloqueado por |
|-----|--------|---------|---------------|
| **KCR-TESTS-FIX** (NOVO) | ready | ~30min | nada — corrigir 4 inicializadores |
| KCR-ROUTER-1 | ready | 1-2h | nada (build compila) |
| KCR-TRANSLATOR-1 | ready | 30-60min | nada (build compila) |
| KCR-V1-DEPRECATE | ready | 2h | nada (processo puro) |
| KCR-PARTITIONER-1 | blocked | 2-3h | KCR-TESTS-FIX |
| KCR-TARGETTREE-1 | blocked | 1 dia | KCR-TESTS-FIX + KCR-PARTITIONER-1 |
| KCR-REFACTOR-1 | blocked | 2-3 dias | baseline + KCR-TARGETTREE-1 |

## KCRs prontos pra atacar (em ordem de payoff)

1. **KCR-TESTS-FIX** — desbloquear test suite. Sem isso, todo KCR posterior voa cego.
2. **KCR-ROUTER-1** — fechar bug latente do router v2 (achado 🔴 do audit).
3. **KCR-TRANSLATOR-1** — deletar 455 LoC de dead code confirmado.
4. **KCR-V1-DEPRECATE** — marcar API v1 como deprecated, evitar mais debt.

## KCRs ainda bloqueados

| KCR | Por que bloqueado |
|---|---|
| KCR-PARTITIONER-1 | Precisa de `cargo test` verde pra validar que migrar callers não quebra pipeline |
| KCR-TARGETTREE-1 | Depende de PARTITIONER-1 + tests verdes |
| KCR-REFACTOR-1 | Depende de TARGETTREE-1 + tests verdes |

## Mudanças de ambiente necessárias (já aplicadas, registradas em `20-build-baseline.md`)

- `nix/ui.nix`: `npmDepsHash` corrigido (commit `1db9077`)
- `flake.nix`: adicionado bloco `devShells.default` com llvm/clang (commit `1db9077`)

## Sincronização com Kanban

Cartões Kanban correspondentes: _a cruzar via `hermes kanban list | grep kryxd`_

## Próximo passo imediato

**Atacar KCR-TESTS-FIX.** Corrigir os 4 inicializadores de `InstallPlanV2` em:
- `src/api/install.rs:887`
- `src/services/migration.rs:119`
- `src/services/target_tree.rs:1058`
- `src/services/mod.rs:24`

Adicionar os campos `network` e `node_think` (com defaults razoáveis ou `..Default::default()`). Re-rodar `cargo test --workspace` até passar.
