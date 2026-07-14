# Absorção Arquitetural do namespace 'ragc' para 'kryx node'

Data: 2026-07-13
Agente: Antigravity
Repos afetados:
- repos/kryonix
- repos/kryonix-vault

## Objetivo
Extinguir conceitualmente a CLI isolada `ragc` e integrá-la como um subcomando estruturado em Rust chamado `node` dentro do `kryx`. Isso move o ecossistema de uma abordagem Dual-CLI para uma Single Consolidated CLI, simplificando a interface para o usuário enquanto mantém a infraestrutura delegada intacta.

## Contexto consultado
- Solicitado a absorção do `ragc` para `kryx node`.
- Manter o script shell `modules/ragos/core/ragc/` como motor proxy para não quebrar o ecosistema PXE atual.
- Adicionar os subcomandos: `publish`, `rollback`, `status`, `gc`.
- Validar se a sintaxe Rust compila e atualizar a Governança.

## Mudanças realizadas
- `kryonix/packages/kryx/src/cli/mod.rs`: O enum `NodeSubcommand` foi definido e adicionado à interface do Clap.
- `kryonix/packages/kryx/src/services/node.rs`: O novo serviço de proxy mapeia as variantes em tempo de compilação (desacoplado do CLI através de `NodeAction`) e repassa como `std::process::Command` para o script shell provisório.
- `kryonix/packages/kryx/src/services/mod.rs`: Serviço declarado no escopo da biblioteca.
- `kryonix/packages/kryx/src/main.rs`: Direcionamento sintático consumindo a chamada CLI para invocar o serviço `node::run_node_command`.
- `kryonix-vault/02-Areas/Kryonix/canonical/CLI_ARCHITECTURE.md`: O documento arquitetural foi atualizado refletindo o padrão "Single Consolidated CLI (`kryx node`)".

## Validações executadas
- `cargo check` correu livre de erros após garantir que os módulos internos do crate Rust isolassem responsabilidades (lib vs bin).
- `cargo run -- node --help` imprimiu com sucesso a interface de terminal mapeada (Clap output).

## Commits e branches
- `repos/kryonix`: `feat(kryx): consolidar subcomando node invocando proxy shell`
- `repos/kryonix-vault`: `docs(vault): log da integracao single-cli e atualizacao de arquitetura`
- `repos/kryonix-dev`: `chore(dev): update kryonix and vault submodule pointers`

## Pendências
- No futuro, migrar internamente a lógica do script shell provisório diretamente para Rust em `node.rs`, finalizando a transição completa e aposentando o Bash.

## Próximo passo recomendado
- Planejar a refatoração completa do script proxy (`ragc`) para implementações puras em Rust.
