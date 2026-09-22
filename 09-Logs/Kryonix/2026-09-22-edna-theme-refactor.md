# Refatoração do Tema Edna (KDE Plasma 6 + Home Manager)

Data: 2026-09-22
Agente: Antigravity
Repos afetados:
- kryonix

## Objetivo
Resolver bugs visuais persistentes (mistura de cores, painéis e ícones quebrados) no tema Edna ao utilizar o NixOS / Home Manager. O Plasma gerava conflito por gerenciar estado imperativo e caches locais, colidindo com os symlinks read-only do Nix.

## Mudanças realizadas
- Adição do script `home.activation.removeMutableKdeState` no módulo `edna-theme.nix`. A rotina roda antes da criação de symlinks do Home Manager e faz o backup/exclusão de `kdeglobals`, `plasmarc` e `Trolltech.conf`, permitindo links limpos.
- Adição do script `home.activation.clearKdeCache`. Essa rotina limpa agressivamente diretórios como `~/.cache/plasma*`, `~/.cache/icon-cache.kcache`, `~/.cache/krunner*`, e caches de shaders após a ativação.
- Forçamento explícito das diretivas `programs.plasma.workspace` para `theme`, `colorScheme` e `lookAndFeel` diretamente via plasma-manager para consolidar o estado inicial.

## Commits
- `kryonix`: `fix(theme): refactor edna theme activation to aggressively clean kde cache and handle mutable state`
- `kryonix-dev`: `chore(dev): update kryonix submodule after edna theme refactoring`

## Próximo passo
- Instruir o usuário a puxar as mudanças (`pull-all`) e rodar o `systemctl --user restart plasma-plasmashell.service` para recarregar a interface limpa e aplicar as correções da cache.
