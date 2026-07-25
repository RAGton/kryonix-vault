# LOOP_STATE.md — Kryonix Autonomous Loop State

> Arquivo de memória persistente do protocolo de Loop Engineering.
> Atualizado ao final de cada iteração. Lido ao início de cada nova sessão/loop.

---

## Estado Atual

**Status Global:** `IDLE — Aguardando definição de Objetivo pelo Arquiteto`  
**Última Atualização:** 2026-07-24  
**Agente Responsável:** Aura (MiniMax-M3) em sessão com Gabriel Aguiar Rocha  
**Próximo Turno:** Humano (Gabriel Aguiar Rocha) — gate humano para P1 (capability `virtualization.incus`)

---

## Contexto da Última Sessão (2026-07-24 noturna)

### O que foi concluído ✅

| Item | Resultado | Evidência |
|------|-----------|-----------|
| V25a: SSOT canônico `release-process.md` | `VALIDATED` | `kryonix-vault/02-Areas/Kryonix/canonical/release-process.md` commit `8becc9f` |
| V25a: Skill procedural `kryonix-versioning.md` | `VALIDATED` | `~/.hermes/skills/kryonix-versioning.md` |
| V25a: 4 AGENTS.md com skill ref (kryxd, kryx-cli, kryonix, kryonix-vault) | `VALIDATED` | commits `f56ec7a`, `b38f399`, `f827bede`, `9ab3df6` |
| V30a/b: merge `pointerCursor` fix na main do Kryonixos | `VALIDATED` | `Kryonixos` commit `10927c0` |
| V34a: tags semver `v0.1.0` no `kryx-cli` + pin no flake | `VALIDATED` | `kryx-cli` tag `v0.1.0` → `9197436`, `kryonix` commit `3675d5fd` |
| V36b: tags `v0.1.0` em `kryxd`, `kryonixos`, `kryonix-assets` | `VALIDATED` | tags + pins em 3 flake.nix |
| V37a: fix sintaxe `refs/tags/v0.1.0` (Nix assume `refs/heads/`) | `VALIDATED` | `kryonix` commit `90a36fa5`, `kryonixos` commit `188350a` |
| Geração 54 bootável com `kryx@cs61z72r...` (com fix bypass) | `VALIDATED` | `system-54-link` → `y4ixsp38...` |
| Geração 55 bootável (auto-update) | `VALIDATED` | `system-55-link` → `0dazr5yx...` |
| Meta-repo `kryonix-dev` com 6 submodules ALIGNED | `VALIDATED` | commits `3a1c5ff`, `d90b94c`, `572e693`, `e42ed49` |
| `incus` daemon com container `debian-test` RUNNING | `VALIDATED` | `incus list` |
| Lock produção: `kryx-cli@9197436` (via tag), `kryxd@f56ec7a` (via tag) | `VALIDATED` | `flake.lock` em `/etc/kryonixos` |

### O que está pendente ⏳

| Item | Estado | Bloqueador |
|------|--------|------------|
| P1: Capability `virtualization.incus` no registry do `kryxd` | `READY` | Gate humano (V41d) — toque em daemon de produção |
| P2: `kryx --version` com SHA via Vergen | `BACKLOG` | - |
| P3: Validação visual da Sidebar no navegador | `BACKLOG` | depende de P1 |
| P4: Remoção de libvirt/kvm + rename `incus`→`KVE` | `BLOCKED (V41d)` | sessão dedicada com CR formal |
| P5: Merge PR #1 do `kryonix-vault` | `READY` | merge via UI + bump pointer |
| P6: Pendências preexistentes (clippy 27 errors, stubs Node, /tmp nh-os) | `BACKLOG` | - |
| P7: Vault log desta sessão + atualizar LOOP_STATE | `VALIDATED` | este commit |

### O que falhou e foi resolvido ♻️

| Falha | Causa Raiz | Resolução |
|-------|-----------|-----------|
| `kryx update --force-sync` revertia `kryx-cli@9197436` → `5ab75997` | Nix semver resolution preferia HEAD do main sem rev/tag explícito | Tags semver `v0.1.0` + pin explícito `?ref=refs/tags/v0.1.0` no flake.nix (V34a + V37a) |
| `kryx` em produção (`4wkzlzd94`) sem fix do lockdown bypass | rev `5ab75997` no lock, sem `discover_real_nix_dir` | Force `kryx-cli@9197436` no lock + `target/release/kryx switch` (V21a + V33a) |
| Chicken-and-egg: `kryx update` falhava com `[Kryonix Guard] O comando 'nix' foi bloqueado` | `kryx` em prod chamava `Command::new("nix")` sem bypass; wrapper lockdown bloqueava | Patch `discover_real_nix_dir()` em `modules.rs` (V21a, commit `6fb58a4`) |
| Erro: `fatal: no se pudo encontrar ref remota refs/heads/v0.1.0` | `?ref=v0.1.0` (sem prefixo) → Nix assume `refs/heads/` (branch) | Sintaxe corrigida para `?ref=refs/tags/v0.1.0` (V37a) |
| `home-manager-rocha.service` falhava restart | `mimeapps.list.hm-bak-kryonix` clobber preexistente (jul 23) | Backup movido + `home.pointerCursor.enable = true` adicionado (V27) |
| `kryxd` (kryxd-ui Sidebar) não mostra KVE | `virtualization.incus` ausente do capability registry | P1 (pendente, gate humano) |

---

## Próximo Loop — Template (preencher antes de iniciar)

```
OBJETIVO (Goal):
  [ ] Adicionar virtualization.incus ao capability registry do kryxd (P1)
  [ ] Validar visualmente a Sidebar capability-driven no navegador (P3)

MÉTRICA (Metric):
  [ ] curl /api/v2/capabilities retorna virtualization.incus com status=ready
  [ ] cargo test -p kryxd --lib: PASS (sem regressão)
  [ ] cargo build --release: exit code 0
  [ ] sudo target/release/kryx switch: [PASS] Switch do sistema concluído

FRONTEIRA (Boundary):
  Repos permitidos: [kryxd]
  Arquivos permitidos: [kryxd/src/api/capabilities.rs, kryxd/crates/kryx/src/domain/capabilities.rs, kryxd/schemas/capabilities.json, kryxd/ui/src/lib/api.js]
  Max Iterations: 3
  Comandos PROIBIDOS: git reset --hard, nix-collect-garbage, mkfs, disko

SUBAGENTES:
  Executor: Aura
  Revisor: Gabriel (humano)
  Orquestrador: Hermes

ESTADO INICIAL (snapshot git):
  kryxd: branch=feat/ui-capability-driven-kcp (mergeado em main=5da3734) tag=v0.1.0=f56ec7a
  kryonix: branch=main commit=90a36fa5
```

---

## Histórico de Loops

| Data | Objetivo | Iterações | Resultado | Commit |
|------|----------|-----------|-----------|--------|
| 2026-07-20 | Build `inspiron` verde sem erros | ~4 | `VALIDATED` | `473f0c0` |
| 2026-07-24 (V21a + V33a) | Resolver chicken-and-egg do lockdown wrapper | ~6 | `VALIDATED` (gen 54) | kryx-cli `6fb58a4`, kryonix `3675d5fd` |
| 2026-07-24 (V34a + V36b + V37a) | Estabilizar versionamento semver em 4 mono repos | ~12 | `VALIDATED` (gen 55) | kryonix `90a36fa5`, kryonixos `188350a` |

---

## Freios Ativos (Guardrails)

- ❌ Nenhum loop pode iniciar sem a **Tríade (Objetivo + Métrica + Fronteira)** aprovada pelo Arquiteto
- ❌ Após 3 falhas consecutivas na mesma Métrica → ABORT, registrar aqui, devolver controle
- ❌ Comandos destrutivos (`mkfs`, `zpool destroy`, `wipefs`) → NUNCA em modo autônomo
- ❌ `git push --force` sem autorização → NUNCA
- ✅ `git stash`, `git diff --stat`, `git add <arquivo>` → sempre permitidos
- ❌ Mudanças em `virtualization.incus` ou rename para `KVE` sem CR formal → V41d (gate humano)

---

## Próxima Ação Recomendada (P1)

**Tarefa:** Adicionar `virtualization.incus` ao registry de capabilities do `kryxd`.

**Arquivos a modificar:**
- `kryxd/crates/kryx/src/domain/capabilities.rs` (Rust crate, hardcoded registry)
- `kryxd/schemas/capabilities.json` (mirror)
- `kryxd/src/api/capabilities.rs` (verificar se tem injeção dinâmica)

**Validação:**
- `cargo test -p kryxd --lib` (sem regressão)
- `cargo build --release` (build OK)
- `sudo target/release/kryx switch` (gen 56+ persistida)
- `curl /api/v2/capabilities | jq '.capabilities[] | select(.id | contains("virt"))'` retorna `virtualization.incus: ready`

**Gate humano:** obrigatório.

**Refs:** kanban P1 (priority 1), V41d (pausa por falta de CR formal).

