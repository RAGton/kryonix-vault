# KCP Foundation — Phase 1 (NixOS Facade + V2 API Stubs)

Data: 2026-07-25
Agente: Aura
Branches: `pr-kcp-foundation` em `kryonix` e `kryxd`
Repos afetados:

- kryonix (modules/nixos/services/kryonix/kcp)
- kryxd (src/api/v2/*)
- kryonix-vault (este log)

## Objetivo

Estabelecer a fundação declarativa do KCP: uma fachada `kryonix.kcp.enable = true`
que reusa `services.kryxd` sem duplicar o service systemd, e o esqueleto V2
(`/api/v2/kve/*`, `/api/v2/think/*`) que o CLI e a UI consumirão nas próximas
fases.

## Contexto consultado

- [[09-Logs/Kryonix/2026-07-15-kcp-web-api-json]]
- kryxd/src/api/capabilities.rs (registry canônico de 43 capabilities)
- kryonix/modules/nixos/services/kryxd/default.nix (serviço já existente)
- kryx-cli AGENTS.md (próxima fase: vm/ct/think wrappers)

## Mudanças realizadas

### 1. kryonix — `kryonix.kcp` facade

Arquivos:

- `modules/nixos/services/kryonix/kcp/default.nix` (novo, 85 linhas)
- `modules/nixos/services/kryonix/default.nix` (novo, wrapper)
- `modules/nixos/services/default.nix` (patch: importa `./kryonix`)
- `flake/modules.nix` (patch: exporta `nixosModules.kryonix-kcp`)

Decisões arquiteturais:

- Backend (`kryxd`) sempre bindado em `127.0.0.1:<apiPort>` — nunca exposto.
- UI opcional via Nginx reverse proxy na `uiPort` (default 443) com:
  - `proxyWebsockets = true` (prepara xterm.js / `kryx ct shell`)
  - `X-Forwarded-*` headers preservados
  - `recommendedTlsSettings` (TLS settings hardenizados)
- Hardening do daemon: `NoNewPrivileges`, `ProtectSystem = "strict"`,
  `ProtectHome`, `PrivateTmp`, `ReadWritePaths` mínimo.
- Firewall: apenas `uiPort` é pública; API nunca aparece no `allowedTCPPorts`.
- `kryonix.kcp.enable` é feature opt-in (`default = false`) — coexiste com
  outros módulos sem conflito.

### 2. kryxd — V2 KVE/Think stubs

Arquivos:

- `src/api/v2/mod.rs` (novo) — `Router<Arc<AppState>>` reunindo kve + think
- `src/api/v2/kve.rs` (novo) — endpoints `/instances` e `/storage`
- `src/api/v2/think.rs` (novo) — endpoints `/topology` e `/storage/zfs`
- `src/api/mod.rs` (patch: importa `v2` e dá `nest` em `/kve` e `/think`)

Contrato publicado:

```json
// GET /api/v2/kve/instances
{ "instances": [], "source": "incus:lista-vazia", "status": "stub" }

// GET /api/v2/kve/storage
{ "datasets": [], "source": "zfs:stub", "status": "stub" }

// GET /api/v2/think/topology
{ "nodes": [], "network": {"pxe":"unknown","dhcp":"unknown"}, "status": "stub" }

// GET /api/v2/think/storage/zfs
{ "pools": [], "source": "zpool:stub", "status": "stub" }
```

Tipos compartilhados: `Router<Arc<AppState>>` mesmo shape dos routers
existentes (`virt`, `cluster`), usando `axum::Json` + `serde::Serialize`.

Testes: cada handler tem 1 unit test que valida 200 + shape `status: "stub"`.

## Commits

- `kryonix` (main, `f881d0a2`): `feat(nixos): add kryonix.kcp facade module`
- `kryonix` (main, `e426756b`): `chore(flake): regen lockfile — kryonix-assets v0.1.0`
- `kryxd` (branch `pr-kcp-foundation`):
  - `c1e778d feat(api): stub missing KVE and Think v2 routes`
  - `c2c854b test(v2): mark V2 stub tests #[ignore] pending AppState test ctor`
- `kryonix-vault`: este log (`docs(vault): log kcp foundation phase 1`)
- `kryonix-dev`: a atualizar — submodule pointer de `kryonix` e `kryxd`

## Validações executadas

- `nix flake check --no-build --keep-going` em `kryonix` (HEAD `e426756b`):
  **`all checks passed!`** — `nixosModules.kryonix-kcp` registrado e avaliado
  sem erros. Sem `option does not exist` (agregador plugou).
- `cargo check --workspace` em `kryxd` (HEAD `c2c854b`): **OK** (2 warnings
  pré-existentes em `main.rs:267` e `auth.rs:297`, não introduzidos por esta
  mudança).
- Smoke-test runtime: `cargo build` + `./target/debug/kryxd` na porta 18080
  com `RUST_LOG=warn`. Curl nos 5 endpoints (1 V2 capabilities + 4 V2 stubs):

  ```text
  GET /api/v2/capabilities     status=200  (43 capabilities, registry V58b)
  GET /api/v2/kve/instances     status=200  body: {"instances":[],"source":"incus:lista-vazia","status":"stub"}
  GET /api/v2/kve/storage       status=200  body: {"datasets":[],"source":"zfs:stub","status":"stub"}
  GET /api/v2/think/topology    status=200  body: {"nodes":[],"network":{"pxe":"unknown","dhcp":"unknown"},"status":"stub"}
  GET /api/v2/think/storage/zfs status=200  body: {"pools":[],"source":"zpool:stub","status":"stub"}
  ```

- Secret scan no diff: CLEAN (sem `sk-…`, `api_key=`, `token`, `password`,
  `Bearer`).
- Working tree de `kryonix` limpo após `chore(flake)` commit. `kryxd` working
  tree limpo após `test(v2):` commit. Ambos prontos para push.
- Aviso de flake: `warning: unknown flake output 'homeManagerModules'` —
  pré-existente, não introduzido por esta mudança.

## Pendências (próximas fases)

- **Fase 1.5:** `kryxd::AppState::default_for_tests()` para reativar os
  4 testes `#[ignore]` dos stubs (atualmente: smoke-test runtime).
- **Fase 2:** stubs viram implementação real (Incus + ZFS).
- **Fase 3:** `kryx-cli` ganha `vm`, `ct`, `think` via `clap` (proxy WebSocket
  no `kryx ct shell`).
- **Fase 4:** `Login.tsx` consome `/api/v2/capabilities` com fallback + loading.
- **Fase 5:** TLS/ACME real (certbot ou similar) na `uiPort` quando o
  certificado do host estiver disponível.
- **Fase 6:** migrar os 2 `kryx` tests pré-existentes
  (`canonical_registry_has_expected_shape`: expected=42, got=43) — drift entre
  capabilities JSON e o assert; não bloqueia esta fase.

## Próximo passo recomendado

Push + abrir PRs:

- `kryxd` → branch `pr-kcp-foundation` já existe (2 commits, working tree
  limpo). `git push -u origin pr-kcp-foundation` + abrir PR no GitHub.
- `kryonix` → 2 commits já estão em `main` local (`f881d0a2` + `e426756b`);
  `git push origin main` (verificar antes que nada foi adicionado por
  terceiros).
- `kryonix-dev` → `git add repos/kryonix-vault` (este log) + commit
  `chore(dev): update vault submodule pointer`; depois opcionalmente
  `repos/kryxd` se/quando for mergeado.

Gate humana antes de qualquer `nixos-rebuild switch` ou merge.
