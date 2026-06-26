# Integracao Waywallen / Wallpaper Engine no Kryonix

Data: 2026-06-26
Agente: Codex
Repos afetados:

- repos/kryonix
- repos/kryonix-vault

## Objetivo

Adicionar suporte declarativo e opt-in para wallpapers dinamicos no Kryonix com
Waywallen, preservando o wallpaper estatico atual por default, sem mexer em
SDDM, Blue Glass, BonaFides, host runtime ou `switch`.

## Contexto consultado

- `repos/kryonix-vault/09-Logs/Kryonix/2026-06-26-branding-kde-sddm-wallpapers.md`
- `repos/kryonix-vault/09-Logs/Kryonix/2026-06-26-sddm-clean-theme.md`
- `repos/kryonix/packages/kryonix-branding.nix`
- `repos/kryonix/packages/kryonix-wallpapers.nix`
- `repos/kryonix/desktop/kde/theme.nix`
- `repos/kryonix/modules/nixos/features/gaming.nix`
- `repos/kryonixos/hosts/inspiron/default.nix`
- upstream oficial:
  - `waywallen/waywallen` release `v0.2.2`
  - `waywallen/waywallen-display` release `v0.2.7`
  - `waywallen/open-wallpaper-engine` release `v0.1.8`

## Diagnostico

1. O Kryonix nao tinha modulo declarativo de wallpaper dinamico.
2. Wallpapers estaticos ja existiam em:
   - `desktop/kde/theme.nix`
   - `desktop/kde/wallpaper.nix`
   - `modules/home-manager/misc/wallpaper/default.nix`
   - fluxo Hyprland/Caelestia/hyprpaper
3. `kryonix-branding` instala wallpapers em
   `${pkgs.kryonix-branding}/share/backgrounds/kryonix/`.
4. `kryonix-wallpapers` legado continua empacotando
   `share/wallpapers/kryonix-aurora/`.
5. `inspiron` continua com `kryonix.desktop.environment = "kde"`.
6. Steam ja existia no projeto via `modules/nixos/features/gaming.nix`.
7. `allowUnfree` ja existia no projeto.
8. No pin atual do nixpkgs do flake, `waywallen = false`.
9. No pin atual do nixpkgs do flake, `open-wallpaper-engine = false`.
10. O bloco herdado de formatação em `modules/nixos/features/removed-options.nix`
    foi corrigido antes da feature para destravar `nix flake check`.

## Mudancas realizadas

- commit isolado de baseline:
  - `style(nix): format removed options module`
- Waywallen empacotado via AppImage oficial reempacotado:
  - `packages/kryonix-waywallen.nix`
- plugin oficial `open-wallpaper-engine` separado e opt-in:
  - `packages/kryonix-open-wallpaper-engine.nix`
- plasmoid KDE oficial separado:
  - `packages/kryonix-waywallen-display-kde.nix`
- exposicao no flake e overlay:
  - `flake/packages.nix`
  - `overlays/default.nix`
- modulo NixOS opt-in:
  - `modules/nixos/desktop/wallpaper/default.nix`
- servico Home Manager user:
  - `modules/home-manager/services/kryonix-waywallen/default.nix`
- import do servico na base HM:
  - `modules/home-manager/common/default.nix`
- import do modulo desktop:
  - `modules/nixos/desktop/default.nix`
- docs:
  - `docs/desktop/WALLPAPER_DYNAMIC.md`
  - `docs/desktop/WAYWALLEN.md`

## Semantica final

```nix
kryonix.desktop.wallpaper.dynamic = {
  enable = false;
  engine = "waywallen";
  steam.enable = false;
  wallpaperEngine.enable = false;
  defaultWallpaper = null;
};
```

Quando habilitado:

- instala `kryonix-waywallen`;
- em KDE, instala `kryonix-waywallen-display-kde`;
- em Hyprland, prepara `waywallen-layer-shell`;
- sobe `kryonix-waywallen.service` no user session;
- expõe wallpapers oficiais do branding em
  `~/.local/share/kryonix/waywallen/wallpapers/`;
- nao troca o wallpaper atual por default;
- `open-wallpaper-engine` so entra com `wallpaperEngine.enable = true`;
- Steam so entra com `steam.enable = true`.

## Validações executadas

- `PASS` `repos/kryonix: nix fmt modules/nixos/features/removed-options.nix`
- `PASS` `repos/kryonix: nix flake check --keep-going`
  - baseline apos formatacao
- `PASS` `repos/kryonix: nix flake show path:. --all-systems`
- `PASS` `repos/kryonix: nix build 'path:.#kryonix-waywallen' --no-link -L --show-trace`
- `PASS` `repos/kryonix: nix build 'path:.#kryonix-open-wallpaper-engine' --no-link -L --show-trace`
- `PASS` `repos/kryonix: nix build 'path:.#kryonix-waywallen-display-kde' --no-link -L --show-trace`
- `PASS` `repos/kryonix: nix flake check 'path:.' --keep-going`
- `PASS` `repos/kryonixos: nix flake check 'path:.' --keep-going`
- `PASS` `repos/kryonixos: nix build 'path:.#nixosConfigurations.inspiron.config.system.build.toplevel' --no-link -L --show-trace`
- `PASS` `repos/kryonix: git diff --check`
- `PASS` secret scan no diff staged do core

## Evidencias

- os tres pacotes novos apareceram em `nix flake show path:. --all-systems`
- o core voltou a fechar com `all checks passed!`
- o downstream `kryonixos` tambem fechou com `all checks passed!`
- `inspiron` continuou buildando sem opt-in automatico do recurso

## Status final

- package-only: `PASS`
- module wired: `PASS`
- preset ativavel / opt-in declarativo: `PASS`
- runtime testado: `WARN`
- build-validado: `PASS`

Classificacao honesta: `module wired + build-validado`, sem `switch` e sem
preview visual runtime.

## Pendencias

- testar runtime real do daemon user em KDE e Hyprland
- validar manualmente o plasmoid `org.waywallen.kde` no Plasma
- validar workflow com assets reais do Wallpaper Engine + Steam
- avaliar no futuro um pacote from-source quando o upstream estabilizar lock/deps

## Rollback

1. Reverter `358689d` para remover a documentacao da feature.
2. Reverter `17101cd` para remover pacote/modulo/servicos do Waywallen.
3. Reverter `f74cedf` se for necessario voltar ao baseline anterior de
   formatacao herdada.

## Commits

- `f74cedf` `style(nix): format removed options module`
- `17101cd` `feat(desktop): add opt-in waywallen wallpaper integration`
- `358689d` `docs(desktop): document dynamic wallpaper support`
