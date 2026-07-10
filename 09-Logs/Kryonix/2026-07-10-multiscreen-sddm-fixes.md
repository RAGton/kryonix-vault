# Fix: Layout do SDDM e Suporte Multi-Monitor no KDE Plasma

Data: 2026-07-10
Agente: Antigravity
Repos afetados:
- kryonix
- kryonixos

## Objetivo
1. Corrigir vazamento visual no campo de senha do SDDM (`kryonix-clean`) e ajustar seu layout responsivo, evitando sobreposição com o relógio.
2. Implementar suporte a multi-monitor (wallpaper de fallback idempotente) no KDE Plasma, mantendo o dock principal restrito ao `screen = 0` e aplicando o wallpaper de forma dinâmica sem quebrar a topologia de painéis.

## Contexto consultado
- Configurações do SDDM (QML) em `repos/kryonix/desktop/sddm/kryonix-clean/Main.qml`.
- Configurações do plasma-manager em `repos/kryonix/desktop/kde/theme.nix` e documentação de NixOS HM (`desktops()` via `qdbus`).

## Mudanças realizadas
- **SDDM**:
  - Ajustado `anchors` no login card para se alinhar à direita (responsivo, recua para o centro em `width < 1000`).
  - Adicionado `clip: true` e alturas fixas maiores (54) no `TextInput` de senha para evitar vazamento do texto.
- **Multimonitor**:
  - Criado módulo HM em `desktop/kde/multimonitor.nix` e exportado em `desktop/kde/user.nix`.
  - Definido um serviço do usuário do systemd (`kryonix-plasma-multiscreen.service`) do tipo oneshot que usa `qdbus` para setar `org.kde.slideshow` em todos os desktops via script JS.
  - Fixado dock inferior no monitor principal adicionando `screen = 0;` no `theme.nix`.
  - Habilitado no `inspiron/default.nix`.

## Commits e branches
- `repos/kryonix` (main):
  - `feat(desktop): add declarative multi-monitor fallback support`
- `repos/kryonixos` (main):
  - `feat(inspiron): enable multi-monitor KDE support`

## Validações executadas
- Build do NixOS (`nixos-rebuild build --flake .#inspiron`) completado com sucesso (+2 deltas no closure, scripts injetados).

## Evidências
- Novas derivações `kryonix-plasma-multiscreen.service` e `apply-multiscreen-wallpapers.js` foram listadas no delta final do build.

## Pendências
- O usuário deve testar fisicamente plugando um segundo monitor para confirmar que o serviço oneshot não é muito agressivo ou muito lento e que não ocorre "piscar de tela" indesejado ao iniciar a sessão.

## Próximo passo recomendado
- O usuário deve rodar `sudo nixos-rebuild switch --flake .#inspiron` (e opcionalmente `sudo systemctl restart display-manager`) para testar.
