---
title: Audit kryxd-daemon — Sumário executivo (Gate A)
date: 2026-08-03
tags: [kryonix, kryxd, audit, summary]
status: completed
severidade_maxima: 🔴 crítica
repo: ~/Proyectos/kryonix-dev/repos/kryxd
---

# Audit kryxd-daemon — Sumário executivo (Gate A)

> TL;DR do audit estrutural read-only do kryxd (KCP/Installer).
> Audit completo: [[10-structural-audit]]
> Baseline de compilação: [[20-build-baseline]]

## Veredito

O kryxd está **funcional mas arquiteturalmente frágil**. Workspace com 2 crates (`kryxd` binário + `kryx` lib), 20.919 LoC totais, 233 testes, e `src/main.rs` com 2.167 LoC funcionando como god object.

Os 3 primeiros achados (router mount + duplicação v2 + translator morto) são provavelmente responsáveis por 50%+ dos bugs latentes observados na ISO/UI.

## Achados por severidade

### 🔴 2 críticos

| # | Achado | LoC afetado |
|---|--------|-------------|
| 1 | `src/api/v2/mod.rs` é declarado mas nunca montado no router raiz | 18 LoC + 2 routers aninhados |
| 2 | Duplo mount de `/kve` e `/think` em `src/api/mod.rs:39-40` | bug latente, path ambíguo |

### 🟠 4 altos

| # | Achado | LoC afetado |
|---|--------|-------------|
| 3 | `crates/kryx/src/services/translator.rs` emite diretivas Nix mortas | 455 LoC + 6 testes órfãos |
| 4 | 2 `target_tree.rs` (1469 + 1342 = 2811 LoC) sem DRY | 2.811 LoC |
| 5 | 2 `partition.rs` (canônico 1109 + legado 458) ainda usado pelo pipeline | 1.567 LoC |
| 6 | `main.rs` é god object: bootstrap + DTOs + handlers + persistência + UI serve | 2.167 LoC |

### 🟡 6 médios/baixos

- 2 `auth.rs` no projeto (GitHub device flow vs login/sessão)
- 2 `storage.rs` no projeto (domain types vs HTTP handler)
- `Cargo.toml` sem `[[bin]]` explícito
- `docs/ai/notebooklm` é código Nix disfarçado de doc
- `ui/playwright-report/` e `ui/test-results/` committados
- Sem CI verde documentado

## Princípios violados (resumo)

- **SRP** → `main.rs` mistura 6 responsabilidades
- **DRY** → `target_tree` e `partition` duplicados
- **Dead code** → `translator.rs` (455 LoC) + 6 testes órfãos
- **Naming** → 2 `auth.rs`, 2 `storage.rs` em paths diferentes
- **Builder pattern** → falta em `InstallPlan` (113 linhas de struct)
- **State machine** → falta em `InstallStatus`
- **Factory pattern** → falta em `AppState` (4 construtores divergentes)

## Recomendação Gate B (próximos KCRs)

| KCR | Escopo | Esforço | Bloqueado por |
|-----|--------|---------|---------------|
| **KCR-ROUTER-1** | Corrigir mount v2 + remover duplo nest | 1-2h | 20-build-baseline |
| **KCR-TRANSLATOR-1** | Deletar `translator.rs` morto OU migrar asserts | 30-60min | 20-build-baseline |
| **KCR-PARTITIONER-1** | Marcar `executor/partition.rs` como deprecated | 2-3h | 20-build-baseline |
| **KCR-V1-DEPRECATE** | Marcar v1/legacy como deprecated com timeline | 2h | 20-build-baseline |
| **KCR-TARGETTREE-1** | Consolidar 2 target_tree | 1 dia | baseline + PARTITIONER-1 |
| **KCR-REFACTOR-1** | Extrair god object `main.rs` | 2-3 dias | baseline + TARGETTREE-1 |

**Status atual de todos os KCRs:** BLOCKED — baseline de compilação não passou (ver [[20-build-baseline]]).

## Honestidade intelectual

- Não rodei `cargo build` nem `cargo test` antes do audit estrutural.
- Os 455 LoC rotulados como "dead code" são **hipótese** baseada em grep + leitura de asserts, não em análise de callers via compilação.
- O 1 arquivo sujo em `src/api/virt.rs` é modificação do PR #27 não commitada — pode ter achados novos.
- Não auditei `ui/` (sub-projeto Vite/React, 11 pastas em `ui/src/`) — pode ter redundância entre views/pages/components.

## Próximo passo

Desbloquear baseline (ver [[20-build-baseline]] Opção A) antes de qualquer KCR.
