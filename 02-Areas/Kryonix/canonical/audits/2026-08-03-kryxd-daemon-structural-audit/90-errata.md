---
title: Errata — audit kryxd-daemon 2026-08-03
date: 2026-08-03
updated: 2026-08-04
tags: [kryonix, kryxd, audit, errata]
status: active
---

# Errata

> Documenta correções, revisões e superssets deste audit.
> Adicionar entradas **em ordem cronológica inversa** (mais recente primeiro).

| Data | Achado original | Correção | Referência |
|------|-----------------|----------|------------|
| 2026-08-04 | N0 (test suite quebrada — `InstallPlanV2` com 4 inicializadores faltando `node_think` e `network`) | **RESOLVIDO em commit `96e6ebb`** no kryxd. 4 fixtures atualizados: `src/api/install.rs:887`, `src/services/migration.rs:119`, `src/services/mod.rs:24`, `src/services/target_tree.rs:1058`. Cargo test agora roda: **165 passed, 1 failed, 2 ignored**. | commit `96e6ebb`; KCR-TESTS-FIX |
| 2026-08-04 | "Test suite inteira quebra" (estado do Gate A.1) | Correção parcial: build compila + 165/166 tests passam. **2 testes ainda falham por drift pré-existente**, mas não por bug introduzido. Detalhes abaixo. | `20-build-baseline.md` (status: partial) |
| 2026-08-04 | "233 testes passando" (afirmação do Gate A original) | **CORREÇÃO**: essa afirmação era falsa. Os 4 inicializadores de `InstallPlanV2` não compilavam desde PR #27, então cargo test abortava antes de rodar qualquer teste. Os 233 testes eram contagem estática de `#[test]`, não testes que efetivamente rodavam. | Achado N0 do `20-build-baseline.md` |

## Falhas pré-existentes conhecidas (não relacionadas a KCR-TESTS-FIX)

Após commit `96e6ebb`, `cargo test --workspace` retorna **2 falhas pré-existentes**, ambas com mesma causa raiz (drift entre `crates/kryx/src/domain/capabilities.rs` in-code e `schemas/capabilities.json`):

| Teste | Esperado | Atual | Severidade |
|-------|----------|-------|------------|
| `api::capabilities::tests::endpoint_returns_stable_public_registry` | 43 caps | 50 caps | 🟠 drift |
| `domain::capabilities::tests::canonical_registry_has_expected_shape` | 43 caps (JSON) | 50 caps (registry) | 🟠 drift |

**Causa raiz:** registry in-code ganhou 7 capabilities (PR #25 + #27 + outros) sem atualizar `schemas/capabilities.json`. Skill `kryxd-and-kryx-cli-audit-2026-07-27` Seção 4 já tinha alertado sobre isso (PITFALL G1.5), mas Gate 1.5 fix só corrigiu contador de 42→43.

**Ação recomendada:** abrir **KCR-CAPS-DRIFT** — investigar se canônico é o JSON (43) ou o registry (50), atualizar um dos lados, fechar os 2 testes.

## Mudanças de escopo desde o Gate A original

- **KCR-TESTS-FIX** foi criado durante Gate A.1 (não existia no audit original). Fechado em commit `96e6ebb`.
- **Achado N1** (`expected_password` dead code em `src/api/auth.rs:297`) ainda aberto, sem KCR atribuído. Sugestão: KCR-AUTH-CLEANUP.
- **Achado N2** (imports não usados em `src/api/v2/kve.rs:26`) **confirma** o PITFALL L18 do Gate A — v2 router tem scaffolding nunca conectado. KCR-ROUTER-1 já cobre isso.

## Procedimento

Quando um achado do Gate A é resolvido, refutado ou contextualizado:

1. Adicionar linha na tabela acima (ordem inversa)
2. Citar o commit hash (kryxd) ou nota (vault) que resolve
3. Se cria novo KCR, atualizar `_roadmap_kryxd-daemon-debt.md`
4. Manter referência cruzada com `00-summary.md`, `10-structural-audit.md` e `_roadmap_kryxd-daemon-debt.md`