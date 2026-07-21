# ISO Polish and Theme State UI Fixes

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- repos/kryxd
- repos/kryonix

## Objetivo
Implementar os tokens de design light/dark do UI de modo determinístico (eliminando hardcodes) e configurar a ISO live de instalação para utilizar cursores Nord e fontes Nerd Fonts.

## Mudanças realizadas
1. **Frontend (kryxd):**
   - Atualizados os Design Tokens em `index.css` e `tailwind.config.js` via variáveis `--kx-*`.
   - A gestão do estado da classe `dark` já estava vinculada no `App.jsx`, as alterações agora refletem as cores especificadas de light e dark.
2. **Sistema (kryonix):**
   - Configurado o NixOS module `web-kiosk.nix` para puxar `nordzy-cursor-theme` (no environment.systemPackages) e definir propriedades globais do XCURSOR para o Wayland (`cage`).
   - Adicionada a dependência da fonte `nerd-fonts.symbols-only` garantindo renderização de ícones de interface.

## Commits e branches
- `feat(installer-ui): fix theme state and light mode tokens` (Branch: main, kryxd)
- `feat(iso): add premium cursor and nerd fonts to live environment` (Branch: main, kryonix)

## Validações executadas
- Avaliação dos pacotes `nordzy-cursor-theme`, `nerd-fonts.jetbrains-mono`, `nerd-fonts.symbols-only` contra a entrada do Flake `nixpkgs` (comprovando existência sem quebrar builds).
- Git diff clean.
- Nenhuma ação destrutiva realizada.
