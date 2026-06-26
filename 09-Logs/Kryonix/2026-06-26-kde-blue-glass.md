# Kryonix Blue Glass

Data: 2026-06-26
Agente: Codex
Repos afetados:

- repos/kryonix
- repos/kryonix-vault

## Objetivo

Implementar o preset opt-in `Kryonix Blue Glass` para KDE/Plasma no motor
Kryonix e corrigir a duplicidade visual de Wi-Fi no KDE sem desligar
`NetworkManager`.

## Contexto consultado

- `AGENTS.md` do workspace
- `repos/kryonix/AGENTS.md`
- `repos/kryonix-vault/AGENTS.md`
- `repos/kryonix/docs/desktop/KDE_PLASMA.md`
- `repos/kryonix/modules/nixos/desktop/kde/default.nix`
- `repos/kryonix/modules/nixos/network/default.nix`
- `repos/kryonix/desktop/kde/theme.nix`

## Mudanças realizadas

- Criado package `kryonix-plasma-theme` com desktoptheme, color schemes,
  wallpapers e prompts de mascote.
- Adicionado preset `kryonix.desktop.kde.theme.preset` com variantes
  `bonafides`, `kryonix-blue-glass-dark` e `kryonix-blue-glass-light`.
- Corrigida a duplicidade visual de rede no KDE:
  `nm-applet` desabilitado apenas em KDE e removidos widgets standalone de rede
  e volume do painel superior, preservando um único `systemtray`.
- Documentação adicionada para Blue Glass.

## Commits e branches

- Branch de trabalho no core: `main`
- Vault alterado localmente; commits dependem da validação final

## Validações executadas

- `repos/kryonixos`: `nix flake check --keep-going`
- Demais validações: ver relatório final da execução

## Evidências

- O downstream passou `nix flake check --keep-going` sem `--impure` antes da
  implementação.
- A opção `programs.nm-applet.enable` existe no nixpkgs pinado do flake em
  `nixos/modules/programs/nm-applet.nix`.

## Pendências

- Confirmar build do package `kryonix-plasma-theme`.
- Confirmar `nix flake check --keep-going` do core após a mudança.
- Confirmar status final PASS/WARN/FAIL de cada validação.

## Próximo passo recomendado

Fechar validações, classificar falhas e criar commits pequenos por tema.
