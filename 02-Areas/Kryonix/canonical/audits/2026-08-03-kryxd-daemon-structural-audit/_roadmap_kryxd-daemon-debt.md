---
title: Roadmap kryxd-daemon debt
date: 2026-08-04
updated: 2026-08-04
tags: [kryonix, kryxd, roadmap, debt, in-progress]
status: in-progress
ssot: Kanban Hermes (este arquivo é espelho)
ultima_sync: 2026-08-04 (pós rebase contra origin/main)
---

# Roadmap kryxd-daemon debt

> Espelho do Kanban Hermes. SSOT é o Kanban.
> Última sincronização: 2026-08-04 (pós rebase)

## Lição da sessão 2026-08-04

KCR-TESTS-FIX **virou KCR-NOOP**. O trabalho que ele faria já foi entregue em main pelo commit `6d929bd` (KCR-TEST-1: round-trip idempotente + capabilities atualizadas pra 50). O commit `9ba58ec` que criei nessa sessão foi droppado após rebase.

**Sempre:** `git fetch origin && git log origin/main..HEAD` antes de qualquer commit em branch não-main.

## Status pós rebase (commit `9baf8b6` pushed em `fix/kcr-ui4-wizard-allowlists`)

Build compila ✅. Test 217/220 passando (98.6%). 3 falhas pré-existentes em main.

| KCR | Status | Esforço | Bloqueado por | Notas |
|-----|--------|---------|---------------|-------|
| KCR-TESTS-FIX | ✅ **completed (NOOP)** | — | — | Trabalho entregue upstream via KCR-TEST-1 (`6d929bd`). |
| KCR-DESKTOP-ZFS-TEST (NOVO) | ready | 15-30min | — | Atualizar `desktop_with_zfs_auto_creates_host_id_even_without_node_think` pra refletir KCR-TEST-1. Test atual espera `node_think = Some(...)` mas round-trip agora é idempotente. |
| KCR-CAPS-HARDCODE (NOVO) | ready | 15-30min | — | Derivar número de caps no test em vez de hardcodar 43. Drift entre registry (50) e JSON (43). |
| KCR-ROUTER-1 | ready | 1-2h | — (build compila) | PITFALL L18 confirmado por warning de build (`unused_imports` em `src/api/v2/kve.rs:26`). |
| KCR-TRANSLATOR-1 | ready | 30-60min | — | `translator.rs` morto (455 LoC + 6 testes). |
| KCR-V1-DEPRECATE | ready | 2h | — (processo puro) | |
| KCR-PARTITIONER-1 | blocked | 2-3h | tests 100% verdes | |
| KCR-TARGETTREE-1 | blocked | 1 dia | PARTITIONER-1 + tests 100% | |
| KCR-REFACTOR-1 | blocked | 2-3 dias | TARGETTREE-1 + tests 100% | |

## KCRs prontos pra atacar (em ordem de payoff)

1. **KCR-DESKTOP-ZFS-TEST** + **KCR-CAPS-HARDCODE** — fechar as 3 falhas pré-existentes em main (baselines limpos).
2. **KCR-ROUTER-1** — fechar PITFALL L18 do audit (router v2 não montado).
3. **KCR-TRANSLATOR-1** — deletar 455 LoC de dead code confirmado.
4. **KCR-V1-DEPRECATE** — marcar API v1 como deprecated.

## KCRs ainda bloqueados

| KCR | Por que bloqueado |
|---|---|
| KCR-PARTITIONER-1 | Precisa de `cargo test` 100% verde |
| KCR-TARGETTREE-1 | Depende de PARTITIONER-1 + tests 100% |
| KCR-REFACTOR-1 | Depende de TARGETTREE-1 + tests 100% |

## Mudanças de ambiente (commit `1db9077`, registradas em `20-build-baseline.md`)

- `nix/ui.nix`: `npmDepsHash` corrigido
- `flake.nix`: adicionado bloco `devShells.default` com llvm/clang + `LIBCLANG_PATH` + `LLVM_CONFIG_PATH`

## Sincronização com Kanban

Cartões Kanban correspondentes: **nenhum**. A sessão 2026-08-04 fechou KCR-TESTS-FIX como NOOP sem criar cartão. **Próximo passo:** criar 4 cartões (`KCR-DESKTOP-ZFS-TEST`, `KCR-CAPS-HARDCODE`, `KCR-ROUTER-1`, `KCR-TRANSLATOR-1`) e mover pra `ready`.

## Próximo passo imediato

**KCR-DESKTOP-ZFS-TEST** (pequeno, 15-30min). Atualizar o test pra esperar `node_think = None` após round-trip idempotente. Fechar baseline 100% antes de qualquer refactor.