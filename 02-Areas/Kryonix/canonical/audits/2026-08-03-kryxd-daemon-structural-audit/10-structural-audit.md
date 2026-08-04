---
title: Audit estrutural kryxd-daemon (Gate A) — achados detalhados
date: 2026-08-03
tags: [kryonix, kryxd, audit, structural]
status: completed
metodologia: Evidence Pack (read-only)
repo: ~/Proyectos/kryonix-dev/repos/kryxd @ 771c086
---

# Audit estrutural kryxd-daemon (Gate A) — achados detalhados

> Análise detalhada dos achados do audit estrutural.
> Sumário executivo: [[00-summary]]
> Baseline de compilação: [[20-build-baseline]]
> Evidências brutas: [[11-evidence-pack]]

## 1. Inventário

### 1.1 Números brutos

| Métrica | Valor |
|---------|-------|
| Total LoC (Rust + Nix) | 20.919 |
| Total LoC Rust (sem Nix) | 20.864 |
| Total de testes | 233 |
| Crates no workspace | 2 (`kryxd` binário + `kryx` lib) |
| Schemas JSON | 3 (`capabilities.json`, `capabilities.schema.json`, `install-plan.schema.json`) |
| Sub-projetos | 2 (Rust + UI Vite/React) |
| Pastas com Rust | 8 (`api`, `services`, `executor`, `providers`, `middleware`, `domain`, `crates/kryx/src`, `src/`) |
| Pastas com Nix | 1 (`nixos/modules/kryonix` com **1 só arquivo**) |

### 1.2 Top 10 arquivos por LoC

| # | Arquivo | LoC | Sinal |
|---|---------|-----|-------|
| 1 | `src/main.rs` | 2.167 | 🔴 God object |
| 2 | `src/services/target_tree.rs` | 1.469 | 🟠 Sem DRY com #3 |
| 3 | `src/executor/target_tree.rs` | 1.342 | 🟠 DRY violation |
| 4 | `crates/kryx/src/domain/config.rs` | 1.214 | 🟡 Aceitável para domínio |
| 5 | `src/api/install.rs` | 1.185 | 🟡 Múltiplas responsabilidades |
| 6 | `src/services/partitioner.rs` | 1.109 | ✅ Canônico, precisa deprecation dos legados |
| 7 | `src/network.rs` | 1.091 | 🟡 Não auditado (P14 do audit anterior) |
| 8 | `src/providers/incus.rs` | 853 | ✅ Coerente |
| 9 | `src/services/media_storage.rs` | 831 | ✅ Coerente (PR #27) |
| 10 | `src/api/storage.rs` | 717 | 🟡 Ceph + replication + media misturados |

## 2. Achados detalhados

### Achado #1 + #2 — Router mount quebrado / duplicação v2

**Severidade:** 🔴 CRÍTICO

**Sintoma:** `src/api/v2/mod.rs` é declarado mas nunca montado no router raiz. Os endpoints `/api/v2/kve/*` e `/api/v2/think/*` funcionam **por acidente** porque `src/api/mod.rs` tem 2 `nest("/kve", v2::kve::router())` redundantes.

**Risco:** se alguém mover os sub-routers pra `v2/mod.rs`, vai criar `/api/v2/kve/kve/health` (404) sem aviso.

**Padrão violado:** "Mount the Router" (GoF Mediator), DRY, Single Source of Truth.

**Recomendação:** adicionar `.nest("/v2", v2::router())` em `api/mod.rs` e remover os `nest` diretos de `/kve` e `/think`.

### Achado #3 — Translator emite diretivas Nix mortas

**Severidade:** 🟠 ALTO

**Sintoma:** `crates/kryx/src/services/translator.rs` (455 LoC) emite opções `kryonix.storage.*` que o motor **NÃO tem como opção**. Resultado: 6 testes órfãos verificam output que nunca é consumido.

**Padrão violado:** Clean Code cap. 4 — *Comments / Dead Code*, GoF Strategy não aplicado.

**Recomendação (2 opções):**
- **Opção A:** deletar `translator.rs` + 6 testes órfãos. Esforço: 30-60min.
- **Opção B:** implementar as opções `kryonix.storage.*` no motor. Esforço: 1-2 dias.

**Recomendação A** até baseline passar e provar que não há caller oculto.

### Achado #4 — target_tree duplicado

**Severidade:** 🟠 ALTO

**Sintoma:** 2 módulos com mesmo nome em paths diferentes:
- `src/services/target_tree.rs` (1.469 LoC)
- `src/executor/target_tree.rs` (1.342 LoC)

Total: 2.811 LoC com sobreposição semântica não auditada.

**Padrão violado:** DRY, SRP.

**Recomendação:** consolidar em 1 módulo. Requer auditoria de callers (não foi feita).

### Achado #5 — partition.rs legado ainda em uso

**Severidade:** 🟠 ALTO

**Sintoma:** `src/services/partitioner.rs` (1.109 LoC) é o renderer Disko canônico, mas `src/executor/partition.rs` (458 LoC) ainda existe e é usado pelo pipeline de instalação.

**Padrão violado:** DRY, YAGNI.

**Recomendação:** marcar `executor/partition.rs` como `#[deprecated]`, remover em 1 release. Migrar pipeline para canônico.

### Achado #6 — main.rs é god object

**Severidade:** 🟠 ALTO

**Sintoma:** `src/main.rs` (2.167 LoC, 33 funções) acumula:
- bootstrap do daemon
- definição de DTOs de domínio
- montagem do router
- handlers HTTP
- persistência
- servir UI estática

**Padrão violado:** SRP, Clean Code cap. 1 — *Small Functions*.

**Recomendação:** extrair em:
- `bootstrap.rs` (boot + config load)
- `routes/mod.rs` (mount centralizado)
- `domain/plan.rs` (DTOs canônicos)
- `services/install_state.rs` (persistência)

Esforço: 2-3 dias com testes.

### Achados #8-#13 — Médios/baixos

Ver [[00-summary]] para lista resumida. Padrões violados principais:
- **Naming consistency:** 2 `auth.rs` (`src/auth.rs` vs `src/api/auth.rs`), 2 `storage.rs` (`src/storage.rs` vs `src/api/storage.rs`)
- **Build clarity:** `Cargo.toml` sem `[[bin]]` explícito
- **Repo hygiene:** `docs/ai/notebooklm` em repo de código, `ui/playwright-report/` e `ui/test-results/` committados

## 3. Princípios Clean Code / GoF violados (resumo)

| Princípio | Onde | Severidade |
|-----------|------|-----------|
| SRP | `main.rs` mistura 6 responsabilidades | 🟠 |
| DRY | `target_tree` e `partition` duplicados | 🟠 |
| Dead code | `translator.rs` (455 LoC) + 6 testes órfãos | 🟠 |
| Naming consistency | 2 `auth.rs`, 2 `storage.rs` em paths diferentes | 🟡 |
| Builder pattern | Falta em `InstallPlan` (113 linhas de struct) | 🟡 |
| State machine | Falta em `InstallStatus` | 🟡 |
| Factory pattern | Falta em `AppState` (4 construtores divergentes) | 🟡 |
| Inappropriate Intimacy | 3 camadas de API (v1/legacy/v2) sem plano de deprecation | 🟠 |

## 4. Próximos passos

Ver [[00-summary#recomendação-gate-b-próximos-kcrs]].
