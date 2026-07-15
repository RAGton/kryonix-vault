# KCP (Kryonix Control Plane) - Virt Engine e AppArmor Estrito

Data: 2026-07-15
Agente: Antigravity
Repos afetados:
- kryonix
- kryonix-installer
- kryonix-dev

## Objetivo
Transformar o backend num orquestrador real de virtualização utilizando o `incus` e implementar o hardening industrial via AppArmor, de acordo com o planejamento aprovado pela arquitetura técnica.

## Contexto consultado
AGENTS.md, discussões anteriores sobre "App-as-a-Feature", documentação de arquitetura sobre os planos para a API de virtualização local.

## Mudanças realizadas
1. **Core (kryonix)**:
   - Removido `hardening.nix` antigo e criado `apparmor_industrial.nix`.
   - Adicionados os perfis `kryonix-incus-container` e `kryonix-core-backend`.
   - Definido `killUnconfinedConfinables = false` (modo complain) inicialmente.
   - Criado `virt_engine.rs` no CLI `kryx` com integração direta com `tokio::process::Command` mapeando a CLI do `incus`.
   - Modificado `Cargo.toml` do `kryx` para incluir a crate `tokio`.

2. **Installer (kryonix-installer)**:
   - Adicionado `src/api/virt.rs` na API Axum contendo as rotas `GET /nodes`, `POST /container` e `POST /vm`.
   - Atualizado `src/api/mod.rs` para anexar as rotas no namespace `/api/virt`.
   - O provisionamento já garante que o container injeta o profile `kryonix-incus-container`.

## Commits e branches
- `repos/kryonix`: `feat(security): implement apparmor industrial and virt_engine` (branch fix/installer-iso-e2e)
- `repos/kryonix-installer`: `feat(api): add virt endpoints for incus container orchestration` (branch refactor/installer-phase1)
- `kryonix-dev`: `chore(dev): update kryonix and kryonix-installer submodule pointers` (branch main)

## Validações executadas
- `nix fmt` para garantia de estilo.
- `cargo check --workspace` no `kryonix` e `kryonix-installer`.
- `nix flake check --keep-going` finalizado com sucesso no repositório inteiro.

## Evidências
- Todo o build do workspace passou nos testes.
- Validação declarativa garantindo que as definições de NixOS estão unificadas.

## Pendências
- Testar a comunicação real com o socket do `incus` local.
- Alterar `killUnconfinedConfinables` para `true` após validar que os syslogs não geraram `DENIED` fatais no modo atual.

## Próximo passo recomendado
Testar o fluxo inteiro do instalador batendo nos endpoints `/api/virt/container` enviando um InstallPlan falso (dry-run).
