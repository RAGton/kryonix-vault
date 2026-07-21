# Correção de Erro Disko no Installer e Refatoração Estruturada

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- kryxd
- kryonix-vault

## Objetivo
Resolver o bloqueio crítico durante a etapa de verificação de partição do `disko` no web kiosk, em que modos inválidos como "dry-run" vazavam para o CLI do Disko, impedindo a continuação de instalações simuladas ou em hardware real, além de documentar formalmente a arquitetura, roadmap, contratos de erro estruturado e fluxo de libvirt tester.

## Contexto consultado
O usuário forneceu detalhes do erro `mode must be one of "destroy", "format", "mount"...` vindo da saída padrão da ferramenta Disko. Verificamos `src/executor/partition.rs` e `src/main.rs`. A API estava passando diretamente `--mode dry-run` em vez de usar `--dry-run` separadamente combinado aos modos suportados do script Disko.

## Mudanças realizadas
1. `src/executor/partition.rs`:
   - Refatorada a chamada do disko para `dry_run` e real usando a string valiada proveniente do payload do frontend (`&plan.disk.mode`).
   - Para `dry_run`, o comando usa `--mode <modo_valido> --dry-run`.
2. `src/main.rs`:
   - Corrigidos warnings de nesting do clippy identificados ao rodar os testes, como `collapsible_if`.
   - Adicionada pré-validação estruturada na rota `/dry-run` para assegurar que `plan.disk.mode` chegue compatível, substituindo o alias "disko" ou "dry-run" internamente, ou rejeitando antecipadamente em caso de modos não conhecidos.
   - Modificado o retorno de erro utilizando um payload semântico: `{"code": "INVALID_DISK_MODE", "action": "...", "destructiveActionStarted": false}`.
3. Repositório Vault:
   - Gerados documentos canônicos para Roadmap, Architecture, API Contract, Test Plan e diretrizes de Redesign de UI/UX.
   - Criada a instrução de skill técnica `libvirt-ui-runtime-tester` para simulações L4 sem hardware real.

## Commits e branches
Os commits foram feitos na branch `main` dos seguintes repos:
- `repos/kryxd`:
  - `fix(installer): validate disk mode before disko dry-run`
- `repos/kryonix-vault`:
  - `docs(installer): add architecture contract roadmap and VM test skill`
- `kryonix-dev` (Raiz):
  - `chore(dev): update installer and vault submodule pointers`

## Validações executadas
- [x] Testes de Unidade Rust (`cargo test`) rodaram e passaram (`64 passed`).
- [x] Lints rígidos do Clippy (`cargo clippy -- -D warnings`) agora em conformidade.
- [x] Comandos de diagnóstico executados no ambiente nix core.

## Evidências
- Erros de pipeline do Rust na master resolvidos.
- Payload estruturado do `UNPROCESSABLE_ENTITY` assegura feedback contínuo sem comprometer UX.

## Pendências
- Testar visualmente os feedbacks do `INVALID_DISK_MODE` integrados no novo Frontend React (agendado para Fase 2).
- Proceder com a Refatoração Baseada no Redesign Visual usando o tailwindcss moderno.
- Integrar Skill do Libvirt como step contínuo via Nix Flake Checks.

## Próximo passo recomendado
Atualizar a UI e os componentes Vue/React para renderizarem os `InstallError` de maneira legível, consumindo o novo contrato API, em seguida refatorar globalmente o look-and-feel para o padrão Blue Glassmorphism.
