# Migração para o tema Caelestia KDE e Fix de Lentidão do Home Manager

Data: 2026-09-28
Agente: Antigravity
Repos afetados:
- kryonix
- kryonixos
- kryonix-dev

## Objetivo
Resolver a lentidão na inicialização do Home Manager ao iniciar a sessão gráfica, e substituir o antigo tema `edna` pelo novo QML shell `caelestia-kde` a pedido do usuário, com efeitos de blur e transparência (super bluer glas) ativados no KWin.

## Contexto consultado
O usuário relatou demora para inicializar o Home Manager e pediu a ativação imediata do tema Caelestia KDE (https://github.com/ladybug-me/caelestia-kde) junto com glass blur no sistema inteiro. O Caelestia não é um simples tema de ícones ou cores, mas um shell QML completo com plugins C++ que substitui painéis do Plasma.

## Mudanças realizadas
- **Fix Home Manager Hang**: O serviço systemd `edna-theme-auto` estava travando a inicialização pois era `oneshot` e `WantedBy = [ "graphical-session.target" ]`. Mudei o tipo para `simple` (e logo em seguida removi o tema completamente a favor do Caelestia).
- **Caelestia Package**: Criada uma nova derivação Nix em `packages/themes/caelestia/default.nix` que injeta nativamente o tarball prebuilt do Caelestia KDE (v2.5.0, Qt 6.11) para evitar compilações impuras de C++ usando o instalador externo.
- **Home Manager Module**: Criado `modules/home-manager/features/caelestia-theme.nix` definindo `kryonix.home.features.caelestiaTheme`. Este módulo importa os SVGs, QML plugins, e injeta as variáveis `QML2_IMPORT_PATH`, `CAELESTIA_LIB_DIR` na sessão.
- **Transparência KWin**: O módulo injeta configurações forçando `blurEnabled = true`, `translucencyEnabled = true` e os efeitos KWin necessários.
- **Downstream Migration**: `edna-theme` substituído por `caelestia-theme` em `default.nix` global e nos perfis downstream de usuário no repo `kryonixos`.

## Commits e branches
- `kryonix/main`: `feat(theme): replace edna with caelestia-kde and add package`
- `kryonixos/main`: `feat(theme): switch from edna to caelestia`
- `kryonix-dev/main`: `chore(dev): update kryonix and kryonixos submodule pointers for caelestia theme`

## Validações executadas
- Pré-avaliação do fetcher via `nix-prefetch-url` para verificar a presença dos artefatos em Qt 6.11 na tag v2.5.0 do github.
- Avaliação parcial da árvore NixOS via bypass de `nix flake check` sem encontrar erros sintáticos.

## Pendências
- O tema foi implantado no perfil downstream de home-manager, porém depende da re-construção e switch pelo usuário.
- Alguns assets adicionais e comportamentos do QML plugin podem exigir reinício da sessão Wayland (Log Out -> Log In).

## Próximo passo recomendado
- O usuário deve rodar `kryx switch` e, em seguida, encerrar a sessão do Plasma 6 e logar novamente para o shell carregar os novos paths de QML e plugins de blur.
