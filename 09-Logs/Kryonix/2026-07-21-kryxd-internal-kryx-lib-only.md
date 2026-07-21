# Kryxd internal kryx lib-only cleanup

Data: 2026-07-21
Agente: Aura
Repos afetados:

- repos/kryxd
- repos/kryx-cli

## Objetivo

Remover a CLI legada duplicada dentro de `repos/kryxd/crates/kryx` e manter o crate interno apenas como biblioteca de domínio/contratos compartilhados usados pelo daemon Axum.

## Contexto consultado

- Auditoria read-only de `repos/kryxd/crates/kryx`.
- `repos/kryxd/Cargo.toml`.
- `repos/kryxd/src/*` para usos de `kryx::domain` e `kryx::services`.
- `repos/kryx-cli/src/*` para confirmar que a CLI canônica já contém a implementação mais nova.

## Mudanças realizadas

Em `repos/kryxd`:

- Removido o binário local legado `crates/kryx/src/main.rs`.
- Removido o parser duplicado `crates/kryx/src/cli/mod.rs`.
- Removidos módulos operacionais de CLI que não são consumidos pelo daemon:
  - `deployment.rs`
  - `diagnostics.rs`
  - `env.rs`
  - `fallback.rs`
  - `feature.rs`
  - `modules.rs`
  - `node.rs`
  - `telemetry.rs`
  - `theme.rs`
  - `virt_engine.rs`
- `crates/kryx/Cargo.toml` agora declara explicitamente `[lib]` com `src/lib.rs`.
- Dependências CLI removidas do crate interno: `clap`, `colored`, `ureq`, `tokio`.
- Mantidas as dependências necessárias ao domínio: `chrono`, `serde`, `serde_json`.
- `services/mod.rs` expõe apenas:
  - `identity`
  - `translator`

Nenhuma mudança foi aplicada em `repos/kryx-cli`, pois a auditoria confirmou que a CLI oficial já está mais avançada que o crate legado.

## Commits e branches

- `repos/kryxd` branch `main`:
  - `a5527f8 refactor(kryxd): strip legacy CLI binary from internal kryx crate`

## Validações executadas

Em `repos/kryxd`:

- `cargo check -p kryx`: PASS.
- `cargo fmt --check -p kryx`: PASS.
- `cargo check` direto: inicialmente bloqueado por falta de headers PAM no shell base (`security/pam_appl.h`).
- `cargo check` com ambiente Nix contendo `linux-pam`, `clang` e `pkg-config`: PASS, com 2 warnings preexistentes (`private_interfaces` e `dead_code`).
- `nix build .#default --no-link`: PASS.

Em `repos/kryx-cli`:

- `cargo fmt --check`: PASS.
- `cargo check`: PASS.
- `nix build .#default --no-link`: PASS.

## Evidências

O daemon continua resolvendo os símbolos necessários do crate interno:

- `kryx::domain::identity::HostIdentity`
- `kryx::domain::config::*`
- `kryx::services::identity::check_identity`
- `kryx::services::translator::generate_nix_config`

O crate interno não gera mais a CLI `kryx`; a CLI canônica permanece em `repos/kryx-cli`.

## Pendências

- `repos/kryxd` ainda possui alteração preexistente fora do escopo em `ui/src/views/Login.tsx`; ela foi preservada e não entrou no commit.
- Avaliar em tarefa futura se o crate interno deve ser renomeado de `kryx` para `kryxd-domain` ou `kryxd-shared`, reduzindo ainda mais o risco de namespace drift.

## Próximo passo recomendado

Planejar uma segunda refatoração pequena para renomear o crate interno e ajustar os imports do daemon, após validar que nenhum consumidor externo depende do nome `kryx` dentro de `repos/kryxd`.
