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
| 2026-08-04 | N0 (test suite quebrada — `InstallPlanV2` com 4 inicializadores faltando `node_think` e `network`) | **SUPERSSED**: o trabalho foi feito em KCR-TEST-1 (`6d929bd`) em main antes desta sessão. O commit `9ba58ec` (droppado) era duplicado. **Nenhum commit aplicado** — KCR-TESTS-FIX virou KCR-NOOP. | commit `6d929bd` em main (KCR-TEST-1) |
| 2026-08-04 | "KCR-CAPS-DRIFT discovered" (afirmação do roadmap) | **CORREÇÃO**: KCR-CAPS-DRIFT **já estava resolvido** em main pelo KCR-TEST-1 (`6d929bd`). O test `endpoint_returns_stable_public_registry` foi atualizado de 43→50 caps no mesmo commit. Drift de capabilities foi fechado upstream. | commit `6d929bd` |
| 2026-08-04 | "Test suite inteira quebra" (estado do Gate A.1) | **RESOLVIDO em main** (não nesta sessão). Build compila + test majoritariamente verde. **3 falhas pré-existentes** restantes em main: 2 do KCR-TEST-1 (test desatualizado: `desktop_with_zfs_auto_creates_host_id`) + 1 do KCR-CAPS-DRIFT residual. | `20-build-baseline.md` (status: partial) |
| 2026-08-04 | "233 testes passando" (afirmação do Gate A original) | **CORREÇÃO**: essa afirmação era falsa. Os 4 inicializadores de `InstallPlanV2` não compilavam desde PR #27, então cargo test abortava antes de rodar qualquer teste. Os 233 testes eram contagem estática de `#[test]`, não testes que efetivamente rodavam. | Achado N0 do `20-build-baseline.md` |

## Falhas pré-existentes conhecidas (não relacionadas a esta sessão)

Após rebase contra `origin/main` (2026-08-04), `cargo test --workspace` retorna **3 falhas pré-existentes em main**, todas com causa estrutural no `TryFrom<InstallPlanV2Wire>` (config.rs) que mudou no KCR-TEST-1 (`6d929bd`):

| Teste | Esperado | Atual | Causa |
|-------|----------|-------|-------|
| `domain::config::tests::desktop_with_zfs_auto_creates_host_id_even_without_node_think` | `node_think = Some(...)` após deserialize | `node_think = None` | KCR-TEST-1 tornou round-trip idempotente: NÃO auto-cria mais NodeThinkPlan quando ZFS é usado sem node_think explícito. Test não foi atualizado pelo PR. |
| `domain::capabilities::tests::canonical_registry_has_expected_shape` | registry igual JSON (50 caps) | registry 50 vs JSON 43 | Drift histórico. Não foi alvo de KCR-TEST-1. |
| `api::capabilities::tests::endpoint_returns_stable_public_registry` | 43 caps (esperado hardcoded) | 50 caps (registry real) | Mesmo drift. Hardcoded no test, deveria ser derivado do registry. |

**Ação recomendada:** abrir **KCR-DESKTOP-ZFS-TEST** (atualizar test pós-KCR-TEST-1) e **KCR-CAPS-HARDCODE** (derivar número de caps no test em vez de hardcodar 43). Ambos são **main debt**, não desta sessão.

## Conclusão da sessão 2026-08-04

**KCR-TESTS-FIX virou KCR-NOOP.** O commit `9ba58ec` que eu criei foi droppado após rebase contra main revelar que o trabalho já estava entregue pelo KCR-TEST-1 (`6d929bd`). Branch `fix/kcr-ui4-wizard-allowlists` foi pushed com só os 2 commits legítimos (`b7d41e8` KCR-UI-4 + `9baf8b6` devShell).

**Lição:** sempre `git fetch origin && git log origin/main..HEAD` antes de commits em branch não-main.

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