# KCP Web Base - API Axum v1 e Serialização JSON

Data: 2026-07-15
Agente: Antigravity
Repos afetados:
- kryonix (engine kryx)
- kryonix-installer (API v1)
- kryonix-dev (pointers)

## Objetivo
Preparar o backend (Kryonix Installer + Kryx CLI) para atuar como o centro de dados estruturados e autorização da nova Kryonix Control Plane Web UI (React/Vite).

## Contexto consultado
Missão sobre KCP Web UI, definições estruturais do projeto, e arquivos base da API Axum legada (`system.rs`, `main.rs`).

## Mudanças realizadas
1. **Kryx Engine**:
   - `packages/kryx/src/cli/mod.rs`: `Identity` e `FeatureSubcommand::List` transformados em struct variants com a flag `#[arg(long)] json: bool`.
   - `packages/kryx/src/main.rs`: Lógica de inibição de logs decorativos, priorizando exclusivamente o output bruto de `serde_json::to_string` e direcionando os erros para um JSON simples ou texto em `stderr`.
   - `packages/kryx/src/services/feature.rs`: Função `list_features(json: bool)` implementada para exportar o dump completo (tree JSON) se `--json` estiver presente.

2. **API Axum v1 (kryonix-installer)**:
   - Adicionada camada de autenticação/RBAC baseada nas próprias permissões do sistema (`kryx::services::identity::check_identity`) via Extractor `RequireCoreRole`.
   - Criado o namespace `/api/v1/` com as rotas `system/identity`, `fleet/status`, `storage/quotas` e `ldap/users`.
   - O CORS no `main.rs` já autorizava os clientes em portas locais (`http://localhost`), atendendo perfeitamente o ambiente Vite.

## Commits e branches
- `repos/kryonix`: `feat(cli): add json serialization support to kryx engine`
- `repos/kryonix-installer`: `feat(api): create v1 endpoints for kcp web ui and rbac`
- `repos/kryonix-vault`: `docs(vault): log kcp web api and json execution`
- `kryonix-dev`: `chore(dev): update submodule pointers for kcp api`

## Validações executadas
- Teste nativo na engine invocando `cargo run --bin kryx -- identity --json` que validou perfeitamente o dump em formato estruturado.
- Subida da API legada + v1 e testes simultâneos via loop de `curl`, certificando a operação da porta `8080`.
- Compilação limpa pelo `cargo check --workspace`.

## Próximo passo recomendado
Integrar a nova KCP Web UI, configurar as chamadas `fetch` apontando para `http://localhost:8080/api/v1` e mapear as respostas do ZFS Quotas e Identidade no front.
