# Unificacao de branding KDE + SDDM + wallpapers

Data: 2026-06-26
Agente: Codex
Repos afetados:

- repos/kryonix
- repos/kryonix-vault

## Objetivo

Criar uma camada canônica de branding reutilizável para KDE/Plasma, SDDM e
wallpapers, preservando:

- `BonaFides` como default do KDE;
- `kryonix-clean` como opt-in do SDDM;
- `kryonix-blue-glass-*` como opt-in do KDE.

## Diagnostico

1. Wallpapers do KDE estavam divididos entre:
   - `desktop/kde/kryonix-blue-glass/wallpapers/`
   - `desktop/wallpapers/kryonix-aurora/`
   - defaults espalhados em `desktop/kde/theme.nix`, `desktop/kde/wallpaper.nix`
     e `modules/home-manager/misc/wallpaper/default.nix`
2. Assets do SDDM estavam em:
   - `desktop/sddm/kryonix-clean/assets/`
   - `desktop/sddm/kryonix-aurora/assets/`
3. A paleta Blue Glass estava espalhada entre:
   - `desktop/kde/scheme.nix`
   - `desktop/kde/kryonix-blue-glass/color-schemes/*.colors`
   - SVGs/wallpapers locais
4. Havia duplicidade real de wallpapers e logo entre KDE e SDDM Clean.

## Decisoes

- criar `desktop/branding/kryonix/` como fonte de verdade;
- expor `.#kryonix-branding` e `pkgs.kryonix-branding`;
- fazer `kryonix-plasma-theme` consumir wallpapers oficiais do branding;
- fazer `kryonix-sddm-theme` injetar `logo.svg` e wallpapers oficiais do branding
  no build do `kryonix-clean`;
- remover os SVGs duplicados do Blue Glass e do SDDM Clean;
- manter o pack legado `kryonix-wallpapers` separado por enquanto.

## Arquivos alterados

### Core

- `desktop/branding/kryonix/**`
- `packages/kryonix-branding.nix`
- `flake/packages.nix`
- `overlays/default.nix`
- `packages/kryonix-plasma-theme.nix`
- `packages/kryonix-sddm-theme.nix`
- `desktop/kde/theme.nix`
- `desktop/kde/scheme.nix`
- `desktop/kde/kryonix-blue-glass/color-schemes/*.colors`
- `desktop/sddm/kryonix-clean/README.md`
- `docs/desktop/KRYONIX_BRANDING.md`
- `docs/desktop/KRYONIX_BLUE_GLASS.md`
- `docs/desktop/KRYONIX_SDDM_CLEAN.md`

### Removidos por duplicidade

- `desktop/kde/kryonix-blue-glass/wallpapers/*.svg`
- `desktop/sddm/kryonix-clean/assets/background-dark.svg`
- `desktop/sddm/kryonix-clean/assets/background-light.svg`
- `desktop/sddm/kryonix-clean/assets/logo.svg`

## Commits

### repos/kryonix

- `3e89ab0` `feat(branding): add shared Kryonix branding package`
- `1e76627` `refactor(branding): reuse shared assets in KDE and SDDM`
- `2c1bf10` `docs(branding): document shared KDE and SDDM branding`

### repos/kryonix-vault

- pendente no momento do registro

## Validacoes executadas

### Auditoria inicial

- `git status --short`
- `git diff --stat`
- `rg -n "kryonix-plasma-theme|kryonix-sddm-theme|Blue Glass|blue-glass|kryonix-clean|kryonix-aurora|wallpaper|background|colorScheme|palette|branding|logo" flake.nix packages desktop modules profiles features home docs 2>/dev/null || true`
- `find desktop packages modules docs -maxdepth 5 \( -iname '*wallpaper*' -o -iname '*branding*' -o -iname '*sddm*' -o -iname '*plasma*' -o -iname '*kde*' -o -iname '*logo*' \) -print | sort`
- `nix flake show --all-systems`

### Core

- `git diff --check`
- `nix build .#kryonix-branding --no-link -L --show-trace`
- `nix build .#kryonix-plasma-theme --no-link -L --show-trace`
- `nix build .#kryonix-sddm-theme --no-link -L --show-trace`
- `nix flake check --keep-going`
- `git diff --cached | rg -n "api[_-]?key|token|secret|password|passwd|bearer|authorization|private|id_ed25519|KRYONIX_BRAIN_API_KEY|NEO4J_AUTH|BEGIN .*PRIVATE" -i || true`

### Downstream

- `nix flake check --keep-going`
- `nix build .#nixosConfigurations.inspiron.config.system.build.toplevel --no-link -L --show-trace`

## Resultado das validacoes

- `PASS` `git diff --check`
- `PASS` `nix flake show --all-systems`
- `PASS` `nix build .#kryonix-branding --no-link -L --show-trace`
- `PASS` `nix build .#kryonix-plasma-theme --no-link -L --show-trace`
- `PASS` `nix build .#kryonix-sddm-theme --no-link -L --show-trace`
- `WARN` `nix flake check --keep-going` em `repos/kryonix`
  - motivo: falha herdada fora do diff em `modules/nixos/features/removed-options.nix: not formatted`
- `PASS` `nix flake check --keep-going` em `repos/kryonixos`
- `PASS` `nix build .#nixosConfigurations.inspiron.config.system.build.toplevel --no-link -L --show-trace`
- `PASS` scan defensivo de secrets no diff
- `PASS` nenhum `--impure` foi necessario

## Riscos restantes

- `kryonix-wallpapers` legado ainda existe fora da camada nova;
- `kryonix-aurora` continua legado no SDDM e nao foi migrado;
- nao houve preview runtime com `sddm-greeter --test-mode`;
- nao houve `switch`.

## Rollback

1. Reverter no core:
   - `git -C repos/kryonix revert 2c1bf10 1e76627 3e89ab0`
2. Funcionalmente:
   - manter `kryonix.desktop.kde.theme.preset = "bonafides";`
   - manter `kryonix.desktop.sddm.theme.preset = "default";`
3. Validar com:
   - `kryonix test`
4. Aplicar depois com:
   - `kryonix switch`
