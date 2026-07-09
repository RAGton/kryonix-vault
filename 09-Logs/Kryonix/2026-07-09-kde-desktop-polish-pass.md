# KDE Desktop Polish Pass (Visual & UX)

Data: 2026-07-09
Agente: Claude Opus 4.6 (Thinking)
Repos afetados:
- kryonix (engine)
- kryonixos (downstream hosts)

## Objetivo
Aplicar polimento visual ao KDE Plasma no Kryonix, adicionando wallpapers próprios com transição, ativando animações do KWin, alterando o locale do host e removendo os temas/wallpapers padrão do KDE que não fazem parte do branding da distro.

## Contexto consultado
- Configurações do `plasma-manager` e KWin em `desktop/kde/theme.nix`.
- Configuração de idiomas em `kryonixos/hosts/inspiron/default.nix`.
- Pacotes padrão do Plasma 6 instanciados em `modules/nixos/desktop/kde/default.nix`.
- Registros anteriores (`09-Logs/`).

## Mudanças realizadas
1. **Wallpapers Kryonix**: Gerados 4 novos wallpapers com tema "Dark/Glass/RAG/NixOS" em `desktop/wallpapers/kryonix-aurora/processed/`.
2. **Slideshow**: Configurado `workspace.wallpaperSlideShow` no `theme.nix` usando os wallpapers da distro e intervalo de 300 segundos.
3. **Animações KWin**: Ativado `kwin.effects.slide.enable` para transição entre Workspaces, além de `Plugins.desktopchangeosdEnabled` para feedback visual na tela.
4. **Locale (es_MX)**: Alterado o idioma do host `inspiron` para `es_MX.UTF-8` via `lib.mkForce`.
5. **Kanjis Mantidos**: O usuário reverteu a decisão sobre os nomes numerados dos workspaces, solicitando a manutenção dos caracteres Kanji tradicionais.
6. **Remoção de Padrões KDE**: Excluídos `plasma-workspace-wallpapers` e `oxygen` do `environment.plasma6.excludePackages` para limpar wallpapers e temas legados do sistema base.

## Commits e branches
- `kryonix`:
  - `fix(desktop): split layout into explicit top status bar and bottom dock`
  - `desktop(kde): configure wallpaper slideshow, animations and remove default wallpapers`
  - `desktop(wallpaper): add 4 new Kryonix wallpapers`
- `kryonixos`:
  - `system(locale): switch inspiron to Spanish (es_MX.UTF-8)`
- `kryonix-dev`:
  - Múltiplos updates de submodule pointers.

## Validações executadas
- Rebuild do sistema host inspiron com sucesso (`nixos-rebuild build --flake .#inspiron`).
- Checagem final com `nvd diff` para garantir delta de pacotes correto (redução e isolamento com sucesso).

## Evidências
O build foi ativado na store Nix: `/nix/store/v5a7sacz1s7czgpnx0qi0n9f5gbckdw1-nixos-system-inspiron-26.05.20260625.4062d36`

## Pendências
- Validar as imagens geradas para checar legibilidade. O Plasma deve aplicar os Wallpapers corretamente em modo Slideshow se a versão do `plasma-manager` suportar a flag. Caso haja problema com a versão atual do plasma-manager e `wallpaperSlideShow`, deverá ser feito fallback para `configFile."plasma-org.kde.plasma.desktop-appletsrc"`.

## Próximo passo recomendado
- O usuário deve testar a interface com o comando de aplicação (KDE Plasma Replace).
