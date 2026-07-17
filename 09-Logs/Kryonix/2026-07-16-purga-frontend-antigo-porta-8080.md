# Purga do frontend antigo na porta 8080

Data: 2026-07-16
Agente: Aura
Repos afetados:

- kryxd
- kryonix-vault

## Objetivo

Remover a UI legada servida diretamente pelo backend Axum na porta 8080, deixando o backend sem fallback de arquivos estáticos e removendo artefatos de build antigos em `ui/`.

## Contexto consultado

- `repos/kryonix-vault/AGENTS.md`
- `repos/kryonix-vault/VAULT_INDEX.md`
- Busca no Vault por `8080`, `ServeDir`, `kryxd`, `UI legada`, `Axum`
- `repos/kryxd/src/main.rs`
- `repos/kryxd/nix/package.nix`
- `repos/kryxd/Cargo.toml`

## Mudanças realizadas

- Removido `tower_http::services::ServeDir` de `src/main.rs`.
- Removido `KRYONIX_INSTALLER_UI_DIR` e `.fallback_service(ServeDir::new(...))` do router Axum.
- Adicionado alias direto `/api/virt` para `api::virt::router()` além do caminho existente `/api/v2/virt`.
- Movidas as rotas legadas do installer para baixo de `/api/v1/legacy/*`, deixando o router principal exposto apenas em `/api/v1`, `/api/v2` e `/api/virt`; sem fallback, `/` e rotas fora desses prefixos passam a cair em 404.
- Removido o empacotamento do `ui/dist` no pacote Nix do backend.
- Removido o feature flag `fs` do `tower-http`, mantendo apenas `cors`.
- Executado `rm -rf ui/dist ui/build ui/out`; os diretórios não permaneceram no workspace.
- Inspecionadas as raízes de `repos/kryxd` e `repos/kryonix`; não havia `implementation_plan.md`, `task.md` ou `*.log` soltos para mover.

## Commits e branches

- Nenhum commit realizado nesta etapa.
- Branch observada do installer: `refactor/installer-phase1`.

## Validações executadas

- `git diff --check -- Cargo.toml nix/package.nix src/main.rs` — passou.
- Busca por `ServeDir`, `fallback_service`, `nest_service`, `KRYONIX_INSTALLER_UI_DIR`, `share/kryxd/ui` — sem ocorrências no código/empacotamento alterado; restam apenas referências documentais/source UI (`README.md`, `nix/ui.nix`).
- Checagem de existência de `ui/dist`, `ui/build`, `ui/out` — todos ausentes.
- `cargo check` — passou com warning preexistente em `src/api/virt.rs` (`unused import: InstallPlan`).
- `git diff --check -- Cargo.toml nix/package.nix src/main.rs` — passou após mover as rotas legadas para `/api/v1/legacy/*`.
- Verificação ad-hoc em `/tmp/nix-shell-266339-3526915383/hermes-verify-*.py` — passou e o script temporário foi removido. Escopo: ausência de `ServeDir`/fallback/UI dir, pacote Nix sem `ui/dist`, `tower-http` sem `fs`, root router só com `/api/v1`, `/api/v2`, `/api/virt`, diretórios `ui/dist|build|out` ausentes, `cargo check` bem-sucedido.
- `cargo test` — compilou e executou; resultado: 100 passaram, 1 falhou, 2 ignorados. Falha observada em `api::install::tests::test_install_endpoint_rejects_unsupported_topology`, com `left: 202`, `right: 422`, não relacionada diretamente à remoção do fallback estático.
- `cargo fmt --check` / `rustfmt --edition 2024 --check src/main.rs` — bloqueado por formatação preexistente em múltiplos módulos (`src/api/console.rs`, `src/api/storage.rs`, `src/api/v1/*`, `src/api/virt.rs`, etc.).

## Evidências

- O router principal monta somente `/api/v1`, `/api/v2` e `/api/virt`; as rotas legadas ficam preservadas sob `/api/v1/legacy/*`.
- O diff remove a montagem `.fallback_service(ServeDir::new(ui_dir).fallback(...))`.
- O pacote Nix não copia mais `${ui}/dist` para `$out/share/kryxd/ui/dist` e não injeta mais `KRYONIX_INSTALLER_UI_DIR`.
- `ui/dist`, `ui/build` e `ui/out` ficaram ausentes após a limpeza.

## Pendências

- Decidir se o arquivo `nix/ui.nix` e referências documentais à Web UI devem ser removidos em uma purga posterior.
- Resolver a falha existente do teste `test_install_endpoint_rejects_unsupported_topology`.
- Resolver formatação global preexistente se `cargo fmt --check` for gate obrigatório.

## Próximo passo recomendado

Commitar separadamente `kryxd` e o log do Vault, depois decidir se `nix/ui.nix`/documentação da antiga Web UI devem sair em uma purga documental própria.
