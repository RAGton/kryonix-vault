# Migração para App-as-a-Feature e Hardening Global

Data: 2026-07-15
Agente: Antigravity
Repos afetados:
- kryonix
- kryonixos
- kryonix-dev

## Objetivo
Implementar o padrão declarativo "App-as-a-Feature" para gerenciar dependências e módulos do sistema através de booleanos (Ex: Etcher e NTFS). E ativar o AppArmor globalmente em modo "complain" para preparar terreno de hardening industrial, de acordo com o plano estabelecido.

## Contexto consultado
AGENTS.md, orientações do usuário para transição "App-as-a-Feature", logs de sessões anteriores onde a fundação do CLI context-aware (`kryx feature list`) foi implementada.

## Mudanças realizadas
1. **Core (kryonix)**:
   - Criados `modules/nixos/features/etcher.nix` e `modules/nixos/features/ntfs.nix`.
   - Incluída a exportação automática da árvore `config.kryonix.features` via JSON (`environment.etc."kryonix/features.json"`) em `modules/nixos/features/default.nix`.
   - Adicionado novo namespace de segurança: `modules/nixos/security/hardening.nix` contendo opções do AppArmor (`security.apparmor.enable` e `security.apparmor.killUnconfinedConfinables`).
   - Atualizado o schema público (`schema.nix`).
   
2. **Downstream (kryonixos)**:
   - Glacier modificado para ligar `kryonix.features.ntfs.enable = true` e `kryonix.security.hardening.enable = true`.

## Commits e branches
- `repos/kryonix`: `feat(security): implement apparmor hardening and app-as-a-feature` (branch fix/installer-iso-e2e)
- `repos/kryonixos`: `feat(glacier): enable ntfs and apparmor hardening` (branch main)
- `kryonix-dev`: `chore(dev): update kryonix and kryonixos submodule pointers` (branch main)

## Validações executadas
- `nix fmt` formatou todos os arquivos recém criados para estar aderentes às diretivas da base de código.
- `nix flake check --keep-going` passou sem problemas, confirmando que não há colisões ou erros de sintaxe nas sub-árvores.

## Evidências
- N/A para UI visual, validado via ast e CLI check.

## Pendências
- Testar o boot real do Glacier com AppArmor para identificar restrições que caem no syslog antes de mudarmos `killUnconfinedConfinables` para `true`.

## Próximo passo recomendado
Criar um alerta no `kryx` (TUI) caso o AppArmor gere logs excessivos de `DENIED`, facilitando a depuração do hardening antes de forçar o restrito.
