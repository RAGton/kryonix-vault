# Configuração de Navegadores, Gaming e Atalhos no Inspiron

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- repos/kryonix
- repos/kryonixos

## Objetivo
Atender à solicitação de habilitação de múltiplos recursos e navegadores (Chrome, Edge, Steam), definição do Zen Browser como padrão e remapeamento de atalhos globais de sessão no KDE Plasma (log out, lock, suspend).

## Contexto consultado
- Configurações do host inspiron (`hosts/inspiron/default.nix`)
- Configuração de perfil de usuário e ambiente dev (`users/rocha/inspiron/default.nix`, `users/shared/dev-workstation.nix`)
- Definição de atalhos globais e comandos da sessão do KDE Plasma (`desktop/kde/keybinds.nix`)
- Documentação de recursos de jogos (`features/gaming.nix`)
- Configuração do Zen Browser (`programs/zen-browser/default.nix`)

## Mudanças realizadas
1. **Browsers e Steam**:
   - Ativada a `feature.gaming` (Steam, MangoHud, Gamemode) em `hosts/inspiron/default.nix`.
   - Adicionados `google-chrome` e `microsoft-edge` nos pacotes do usuário no inspiron e no perfil dev (`dev-workstation.nix`).
   - Importado o módulo `zen-browser/default.nix` para garantir sua definição como browser padrão.
2. **Atalhos do Sistema (KDE Plasma)**:
   - Remapeado `"Log Out"` para `Ctrl+Alt+Del` (exibe menu completo de opções de sessão).
   - Remapeado `"Lock Session"` para `Ctrl+Esc`.
   - Adicionado novo atalho de comando personalizado para `Meta+L`, chamando `systemctl suspend` (e removido conflito com KrohnkiteFocusRight).

## Commits e branches
- Submodules (`kryonix`, `kryonixos`) atualizados na branch `main`.
- Alterações empurradas (`push`) e recebidas em ambiente de produção (`pull` em `/etc/kryonixos` e `/etc/kryonix`).

## Validações executadas
- Avaliação de sintaxe (`nix flake check --keep-going`) realizada nos dois repositórios.
- Operações de `git` executadas para persistir o código no repositório remoto.

## Pendências
- O usuário deve aplicar a configuração no sistema ativo (`kryonix switch` ou `nixos-rebuild switch`) para que as modificações de atalho e pacotes entrem em vigor na próxima sessão.

## Próximo passo recomendado
- Realizar a atualização do sistema via `kryonix switch` e testar os atalhos remapeados (Crtl+Alt+Del, Ctrl+Esc, Meta+L).
