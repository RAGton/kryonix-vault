# Kryonix CLI — V2 Paridade (Phase 2)

Data: 2026-07-25
Agente: Aura
Branches: `pr-13-kcp-cli-proxy` em `kryx-cli`
Repos afetados:

- kryx-cli (src/cli/kve.rs, src/cli/think.rs, src/client.rs, deps)
- kryonix-vault (este log)

## Objetivo

Estabelecer a paridade da CLI (`kryx-cli`) com o contrato V2 do
daemon kryxd. A CLI consome os 4 stubs V2 via HTTP (ureq) e formata
o output como tabela humana. Erros de transporte não quebram o
terminal — viram mensagens amigáveis e exit code 2.

## Contexto consultado

- [[09-Logs/Kryonix/2026-07-25-kcp-foundation-phase-1]]
- kryxd/src/api/v2/{kve,think}.rs (stubs V2 comitados na Fase 1)
- kryx-cli/AGENTS.md (subcomandos existentes, papel da CLI)

## Decisões arquiteturais

1. **ureq em vez de reqwest**: o `kryx-cli` já tem `ureq 2.9`. Os
   4 endpoints V2 são GET-only; ureq síncrono é suficiente e
   mantém o diff mínimo. `reqwest 0.12` (async) entra na
   Fase 2.5 (`kryx ct shell` via WebSocket).

2. **cli-table 0.4 desde o commit 1**: tabela é o que diferencia
   `kryx kve instances` de `curl | jq`. Custo: ~0.5MB no binário.
   Sem tabela o usuário não enxerga que está funcionando.

3. **`use kryx::client;` em vez de `use crate::client;`**: o
   módulo `cli` é declarado `mod cli` (privado) em `main.rs`, e
   os submódulos de `cli/` (kve, think) não enxergam o root
   do crate via `crate::`. O `kryx` é a lib exposta pelo
   `kryx-cli/Cargo.toml` e o caminho é `kryx::client`.

4. **Não usar `Justify::Left` no derive de Table**: a macro
   `cli_table::Table` precisa do tipo `Justify` no escopo
   quando recebe `justify = "Justify::Left"` no atributo
   (a string é convertida em tipo). Como default já é left,
   removi o atributo e o import órfão.

5. **`exit(2)` para erros de comunicação**: 0 = OK, 1 = erro
   geral, 2 = erro de I/O (convenção Unix). 0 é o que `cargo
   run && echo "OK"` espera ver.

## Subcomandos adicionados

| Comando | Endpoint consumido | Função |
|---|---|---|
| `kryx kve instances` | `GET /api/v2/kve/instances` | Tabela com source/status/count |
| `kryx kve storage` | `GET /api/v2/kve/storage` | Tabela com source/status/count |
| `kryx think topology` | `GET /api/v2/think/topology` | Tabela com network (pxe/dhcp) |
| `kryx think storage` | `GET /api/v2/think/storage/zfs` | Tabela com source/status/count |

## Commits

- `kryx-cli` (branch `pr-13-kcp-cli-proxy`):
  - `ca3192c chore(kryx-cli): add cli-table 0.4 for tabular output`
  - `1497f07 feat(kryx-cli): add kryxd http client module`
  - `aea7a08 feat(kryx-cli): add kve and think subcommands (clap + cli-table)`
- `kryonix-vault`: este log
- `kryonix-dev`: pendente — `chore(dev): update kryx-cli submodule pointer` após merge do PR

## Validações executadas

- `cargo check` em kryx-cli: **OK** (zero warnings, zero errors)
- `cargo build --bin kryx` em kryx-cli: **OK** em 25.94s
- `kryx kve --help` e `kryx think --help`: listam os subcommands
  corretamente via clap derive.
- Round-trip runtime (KRYXD_URL=http://127.0.0.1:18080 apontando
  para o kryxd da Fase 1, branch pr-kcp-foundation HEAD c2c854b):

  ```text
  --- kryx kve instances ---
  +-------------------+------+---+--------------------------------------------+
  | incus:lista-vazia | stub | 0 | see /api/v2/kve/instances for full payload |
  +-------------------+------+---+--------------------------------------------+
  RC=0

  --- kryx kve storage ---
  +----------+------+---+------------------------------------------+
  | zfs:stub | stub | 0 | see /api/v2/kve/storage for full payload |
  +----------+------+---+------------------------------------------+
  RC=0

  --- kryx think topology ---
  +----------------+------+---+--------------------------+
  | think:topology | stub | 0 | pxe=unknown dhcp=unknown |
  +----------------+------+---+--------------------------+
  RC=0

  --- kryx think storage ---
  +------------+------+---+------------------------------------------------+
  | zpool:stub | stub | 0 | see /api/v2/think/storage/zfs for full payload |
  +------------+------+---+------------------------------------------------+
  RC=0
  ```

- Tratamento de erro contra kryxd antigo (porta 8080, do Nix store
  v0.2.1 sem stubs V2): `KVE Backend Error: HTTP 404 — <html...>`,
  RC=2. Não crasha, não panic, mensagem útil.

- Secret scan no diff: CLEAN.

## Pendências (próximas fases)

- **Fase 2.5**: `kryx ct shell` via WebSocket (reqwest 0.12 async
  + tokio::process para PTY) — pré-requisito: rota `/api/v1/console`
  no kryxd (já existe como `src/api/console.rs`, validar).
- **Fase 2.6**: auth via header `X-Kryonix-Installer-Token` (lê
  `KRYXD_TOKEN` env ou `~/.config/kryonix/token`).
- **Fase 3**: mutation endpoints — `kryx kve start <name>`,
  `kryx kve stop <name>`, `kryx think reboot` etc.
- **Fase 3.5**: deixar de depender dos stubs V2 quando o backend
  real (Incus + ZFS) entrar.

## Próximo passo recomendado

Push + abrir PR:

```bash
cd /home/rocha/Proyectos/kryonix-dev/repos/kryx-cli
git push -u origin pr-13-kcp-cli-proxy
# (abrir PR no GitHub: base=main, head=pr-13-kcp-cli-proxy,
#  titulo: feat(kryx-cli): add kve/think subcommands (V2 paridade))
```

Após merge em `main` upstream:

```bash
cd /home/rocha/Proyectos/kryonix-dev
git -C repos/kryx-cli pull --ff-only
# atualizar o pointer do submodule no kryonix-dev
```

Gate humana antes de qualquer switch. Sem comandos destrutivos
nesta fase.
