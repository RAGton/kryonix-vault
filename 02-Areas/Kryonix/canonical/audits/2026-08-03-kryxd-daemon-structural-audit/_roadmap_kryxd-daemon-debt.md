---
title: Roadmap kryxd-daemon debt
date: 2026-08-04
updated: 2026-08-04
tags: [kryonix, kryxd, roadmap, debt, in-progress]
status: in-progress
ssot: Kanban Hermes (este arquivo é espelho)
ultima_sync: 2026-08-04
---

# Roadmap kryxd-daemon debt

> Espelho do Kanban Hermes. SSOT é o Kanban.
> Última sincronização: 2026-08-04 (pós KCR-TESTS-FIX)

## Status pós KCR-TESTS-FIX (commit 96e6ebb)

Build compila ✅. Test majoritariamente verde ✅ (165/166 passando). 2 falhas pré-existentes (drift capabilities).

| KCR | Status | Esforço | Bloqueado por | Notas |
|-----|--------|---------|---------------|-------|
| **KCR-TESTS-FIX** | ✅ **completed** | 30min (real) | — | commit `96e6ebb`. 4 fixtures atualizados. |
| **KCR-CAPS-DRIFT** (NOVO) | ready | 30-60min | — | Drift 50 caps (registry) vs 43 caps (JSON). Ver `90-errata.md`. |
| KCR-ROUTER-1 | ready | 1-2h | — (tests majoritariamente verdes) | Próximo payoff alto. |
| KCR-TRANSLATOR-1 | ready | 30-60min | — | `translator.rs` morto confirmado por warning de build. |
| KCR-V1-DEPRECATE | ready | 2h | — (processo puro) | |
| KCR-PARTITIONER-1 | blocked | 2-3h | KCR-CAPS-DRIFT (para tests 100% verdes) | |
| KCR-TARGETTREE-1 | blocked | 1 dia | PARTITIONER-1 + CAPS-DRIFT | |
| KCR-REFACTOR-1 | blocked | 2-3 dias | TARGETTREE-1 + tests 100% | |

## KCRs prontos pra atacar (em ordem de payoff)

1. **KCR-CAPS-DRIFT** — fechar 2 falhas pré-existentes (baselines limpos antes de qualquer refactor).
2. **KCR-ROUTER-1** — fechar bug latente do router v2 (achado 🔴 do audit, confirmado por warning de build).
3. **KCR-TRANSLATOR-1** — deletar 455 LoC de dead code confirmado.
4. **KCR-V1-DEPRECATE** — marcar API v1 como deprecated, evitar mais debt.

## KCRs ainda bloqueados

| KCR | Por que bloqueado |
|---|---|
| KCR-PARTITIONER-1 | Precisa de `cargo test` 100% verde pra validar que migração de callers não quebra pipeline |
| KCR-TARGETTREE-1 | Depende de PARTITIONER-1 + tests 100% |
| KCR-REFACTOR-1 | Depende de TARGETTREE-1 + tests 100% |

## Mudanças de ambiente (commit `1db9077`, registradas em `20-build-baseline.md`)

- `nix/ui.nix`: `npmDepsHash` corrigido
- `flake.nix`: adicionado bloco `devShells.default` com llvm/clang + `LIBCLANG_PATH` + `LLVM_CONFIG_PATH`

## Sincronização com Kanban

Cartões Kanban correspondentes: _a cruzar via `hermes kanban list | grep kryxd`_

## Próximo passo imediato

**Atacar KCR-CAPS-DRIFT.** Investigar se o canônico é o registry (50) ou o JSON (43). Atualizar o lado perdedor. Re-rodar `cargo test --workspace` até 100%.

Não recomendado começar por KCR-ROUTER-1 sem fechar CAPS-DRIFT primeiro — misturar escopos dificulta bisect se algo regressar.