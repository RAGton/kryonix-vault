# Estabilização do Tema Edna e Fix do AnyDesk

Data: 2026-09-22
Agente: Antigravity
Repos afetados:
- kryonix

## Objetivo
Resolver a instabilidade sistêmica do KDE Plasma e a quebra de programas (incluindo o AnyDesk) após a refatoração do tema Edna.

## Mudanças realizadas
- **Edna Theme (`modules/home-manager/features/edna-theme.nix`)**:
  - Removido o script de ativação `home.activation.removeMutableKdeState` que fazia mv indiscriminado de `kdeglobals`, `plasmarc` e `Trolltech.conf` durante o switch.
  - Removido o script de ativação `home.activation.clearKdeCache` que executava `rm -rf ~/.cache/plasma*` e deletava os caches de shaders da NVIDIA. Essas operações agressivas estavam corrompendo a sessão ativa do Wayland/KDE. O Plasma e o plasma-manager nativo agora gerenciam o state.
- **Flatpak / AnyDesk (`modules/home-manager/services/flatpak/default.nix`)**:
  - Injetado `overrides` para `com.anydesk.Anydesk` forçando o socket para `x11` / `fallback-x11` e as variáveis de ambiente `GDK_BACKEND=x11` e `QT_QPA_PLATFORM=xcb`. O AnyDesk nativamente tem problemas com o Wayland no Plasma 6, e rodar via XWayland estabiliza a ferramenta.

## Validações executadas
- Avaliação com sucesso via `nix flake check` para os módulos e perfis downstream. (Nenhum assertion failed).

## Commits e branches
- `kryonix/main`: `fix(theme,anydesk): remove cache wipe and add x11 override`
- `kryonix-dev/main`: `chore(dev): update kryonix submodule for theme and anydesk fixes`

## Próximo passo recomendado
- Rodar `sudo kryx switch` no ambiente de desenvolvimento local (ou empurrar para o GitHub e dar update em `/etc`).
