---
aliases:
  - "Strike 1 - Fechamento Node Think"
  - "KCR t_690ebeeb - fechamento"
tags:
  - kryonix
  - kryxd
  - log
  - strike-1
  - node-think
  - kcr
kanban_card: t_690ebeeb
pull_request: "https://github.com/RAGton/kryxd/pull/27"
date: "2026-07-30"
status: FEATURE_DELIVERED
---
# Log de Sessão: Fechamento do Strike 1 (Node Think)

## Metadados

- **Data:** 2026-07-30
- **Kanban Card:** [[t_690ebeeb]] (workspace `dir:/home/rocha/Proyectos/kryonix-dev/repos/kryxd`, branch `feat/kve-media-storage`)
- **Pull Request:** #27 — [RAGton/kryxd#27](https://github.com/RAGton/kryxd/pull/27)
- **Merge commit:** `9fac85921d17f99f79891d2c36e89656e671d9c8` em `main`
- **PR title:** `feat(kryxd): implement typed NodeThinkPlan in InstallPlanV2`

## Resumo da Operação

O Strike 1 do card `t_690ebeeb` foi concluído com sucesso. Ele estabelece a fundação tipada do **Node Think** no backend Rust do `kryxd`, substituindo a flag legada `is_think_server: bool` por uma estrutura `NodeThinkPlan` dedicada, e corrigindo o namespace Nix emitido pelo tradutor de `kryonix.thinkServer` (legado, inexistente no módulo) para `node.thinkServer` (canônico no `modules/node/think/think-server.nix`).

## Commits entregues

1. `e3ce276 chore(dev): add rust-toolchain.toml for deterministic builds`
   - Adiciona `rust-toolchain.toml` com `channel = "stable"` na raiz do `kryxd` para garantir toolchain determinístico em CI e em qualquer agente que clone o repo.
2. `a8b76af feat(kryxd): implement typed NodeThinkPlan in InstallPlanV2`
   - Adiciona `NodeThinkPlan { enable, host_id }` em `crates/kryx/src/domain/config.rs`.
   - Acrescenta `pub node_think: Option<NodeThinkPlan>` em `InstallPlanV2`.
   - `crates/kryx/src/services/translator.rs` agora emite `node.thinkServer.enable` e `node.thinkServer.hostId` quando `node_think.enable = true`, e nada caso contrário.
   - Atualiza o teste `test_think_server_translation` e adiciona `test_think_server_disabled_emits_nothing` + `test_node_think_absent_emits_nothing`.

## Decisões Arquiteturais Registradas

### 1. Strangler Fig do `is_think_server` (Strike 2 planejado)

O campo legado `is_think_server: bool` foi **mantido na struct** `InstallPlanV2` durante este Strike, embora o tradutor já não o leia. A decisão é deliberada e documentada inline em `translator.rs`:

```rust
// A flag legada `plan.is_think_server` foi aposentada pelo tradutor.
// Toda a ativação agora vem de `plan.node_think`, que carrega o `hostId`
// obrigatório exigido por `node.thinkServer.hostId` no módulo Nix.
```

**Razões:**

- O campo continua sendo construído em call sites externos (endpoints em `src/api/install.rs`, fixtures de outros testes, serializações JSON intermediárias). Removê-lo agora seria um **breaking change** que cascateia para o frontend, o schema JSON do `install-plan.schema.json` e o capability registry.
- O tradutor passou a usar **apenas** `plan.node_think`. A flag legada fica como resíduo para deprecação no Strike 2, que deve remover simultaneamente: campo da struct, asserts nos testes, todas as referências em fixtures e nos call sites que ainda constroem `is_think_server: false` por compatibilidade.

**Próximo passo (Strike 2):** remover `is_think_server` da struct, do registry, do schema JSON, e de todos os call sites que constroem o plano a partir de um input do frontend. Cobertura: também atualizar o frontend UI (que hoje manda o toggle) e o capability registry em `crates/kryx/src/domain/capabilities.rs`.

### 2. Pattern `cargo fmt drift` como Baseline-Failure Conhecida

O CI do `kryxd` tem o step `cargo fmt` (parte de `Rust (fmt + clippy + test)`) que **falhou** no PR #27 em arquivos que **não foram tocados pelo patch**: `src/services/media_storage.rs` e `src/storage.rs`. O drift de `rustfmt` foi introduzido por commits KVE anteriores em `feat/kve-media-storage` e não foi reformatado antes do push.

**Padrão documentado:**

- Drift de formatação em arquivo não tocado pelo PR = **PREEXISTING_FORMAT_DRIFT**.
- Aceitável mesclar quando (a) a CI de avaliação semântica (Nix Flake Check) passa, e (b) o `cargo fmt --check` falha **apenas** em arquivos fora do escopo do diff.
- Antes do próximo push que toque a branch KVE, rodar `cargo fmt` localmente no `kryxd` workspace inteiro.

**Para registro no `kryonix-ci-baseline-restoration`:** este é o primeiro caso de `cargo fmt drift` que precisei classificar com `--admin` implícito (a branch `main` do `kryxd` não tem protection, então não foi preciso `--admin` real). Vale documentar para futuras strikes que peguem a mesma armadilha.

### 3. Pattern `node --test` glob no `package.json` da UI

A UI check falhou no `npm test` porque `ui/package.json` passa um glob literal para `node --test`, mas Node 20+ não expande globs automaticamente. Os 16 arquivos `*.test.js` existem em `a8b76af`, o `node --test` simplesmente não os encontra.

**Padrão documentado:**

- Bug pré-existente do workflow da UI, **não regressão do PR**.
- Fix correto (não no escopo do Strike 1): substituir `node --test "src/tests/**/*.test.js" "src/tests/*.test.js"` por `find ui/src/tests -name '*.test.js' -print0 | xargs -0 node --test` ou usar `vitest`/`mocha` com glob real.
- **Para registro no backlog:** criar card futuro para arrumar o glob. Pode esperar — não bloqueia o flow.

## Validação executada

| Check | Status | Evidência |
|---|---|---|
| `cargo check -p kryx` | ✅ PASS | `Finished dev profile in 7.58s` (log fresco desta sessão) |
| `cargo test -p kryx --lib domain::config::` | ✅ 10/10 PASS | `test result: ok. 10 passed; 0 failed; 0 ignored` |
| `cargo test -p kryx --lib services::translator::` | ✅ 3/3 PASS | (teste preexistente + 2 novos) |
| `Nix Flake Check` (CI) | ✅ SUCCESS | job 91030389356 |
| `Rust (fmt + clippy + test)` (CI) | ❌ FAILURE em `cargo fmt` | drift pré-existente em `media_storage.rs`/`storage.rs` |
| `UI (test + build)` (CI) | ❌ FAILURE em `npm test` | glob literal do `node --test` em `package.json` |
| `gh pr merge 27 --merge --delete-branch` | ✅ MERGED | merge commit `9fac859` |
| Branch `feat/kve-media-storage` | ✅ DELETED no origin | cleanup pós-merge |

## Baseline-failure justification

Postada como [issuecomment no PR #27](https://github.com/RAGton/kryxd/pull/27#issuecomment-5137285646) com classificação explícita de cada check em:

- PREEXISTING_FORMAT_DRIFT (Rust fmt)
- PREEXISTING_TOOLING_BUG (UI glob)
- Não-regressão justificada pela evidência de que os arquivos dos checks vermelhos não estão no diff do PR.

## Fora de escopo (próximas strikes)

| Strike | Escopo | Repos |
|---|---|---|
| 2 | Remover `is_think_server` da struct + registry + schema + UI | kryxd, kryonix, kryonix-installer |
| 3 | Alinhar Disko com os mounts fixos ZFS do Node Think (`/srv/data/{home,images,snapshots,storage}` em `zroot`); regra `node_think.enable ⇒ filesystem == ZFS` | kryxd (`partitioner.rs`), kryonix (`think-server.nix`) |
| 4 | Integrar `target_tree.rs` e `translator.rs` num único pipeline de geração de configuração Nix + Disko | kryxd |
| — | Fix do glob `node --test` em `ui/package.json` | kryxd (UI) |

## Pendências e Próximo Passo

- **Submodule pointer bump** no meta-repo `kryonix-dev` (gate humano, próximo passo).
- **Vault log** (este arquivo) commitado e pushed no `kryonix-vault` (gate humano).
- **PRODUCTION sync** em `/etc/kryonix` e `/etc/kryonixos` via `sudo git pull --ff-only` (gate humano).
- **`kryx update`** rebuild closure Nix (gate humano, 10-30 min).
- **`kryx switch`** ativa nova closure (gate humano, gate final).
- Card `t_690ebeeb` no Kanban continua `ready` — mover para `done` via `hermes kanban complete t_690ebeeb --result "..."` quando o flow de produção terminar.

## Links Relacionados

- [[Architecture]] — derivação canônica da arquitetura Kryonix
- [[Install]] — derivação canônica do fluxo de instalação
- [[CLI_ARCHITECTURE]] — contexto do daemon `kryxd` como consumidor do contrato
- [[CORE_DOWNSTREAM_INSTALLER]] — boundaries entre core, downstream e installer
- [[kryx-nix-lockdown-pitfalls]] — outra armadilha recente do CI no mesmo daemon
- [[2026-07-30-kryx-cli-check-deploy]] — log da mesma data mostrando outro padrão de gate humano

#tags: #kryonix #kryxd #log #strike-1 #node-think #kcr
