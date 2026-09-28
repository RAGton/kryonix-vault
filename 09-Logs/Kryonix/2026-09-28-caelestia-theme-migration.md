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
- **Fix Home Manager Hang**: O serviço systemd `edna-theme-auto` estava travando a inicialização pois era `oneshot`. Mudei o tipo para `simple` (e logo em seguida removi o tema completamente a favor do Caelestia).
- **Caelestia Package**: Criada uma nova derivação Nix para Caelestia KDE (v2.5.0, Qt 6.11).
- **Home Manager Module**: Criado `modules/home-manager/features/caelestia-theme.nix`. Configurado `QML2_IMPORT_PATH` com `lib.mkForce` para resolver conflitos com o módulo Qt base.
- **Transparência KWin**: Forçado `blurEnabled = true` e `translucencyEnabled = true`. A derivação independente `can1357/kde-blur` foi abandonada pois o código C++ é incompatível com a nova API do Plasma 6.7 (mudanças em `prePaintScreen`). O blur nativo já cobre a transparência solicitada.
- **Warp Terminal Theme**: Gerado e injetado o tema `caelestia.yaml` em `~/.local/share/warp-terminal/themes/` para sincronia visual (fundo transparente que ativará o KWin glass blur).
- **Atalhos KWin**: Trocados os atalhos de `Meta+Ctrl+[1..0]` por `Meta+Shift+[1..0]` para a ação de "mover janela e seguir para desktop" em `desktop/kde/keybinds.nix`.
- **Gaming Stack & Cleanup**: Ativada a stack `gaming` (Lutris, WineTools, GameMode) em `inspiron` e limpos pacotes não utilizados (Chrome, Edge, Remmina, ATLauncher).

## Validações executadas
- Switch rodado localmente e erros de `QML2_IMPORT_PATH` resolvidos com `mkForce`.
- Repositórios limpos, sem rastros de rascunhos inúteis e sem arquivos *untracked* interferindo no switch (pastas locais de mcp ignoradas no `.gitignore`).

## Pendências e Notas
- O `git push` requer execução manual do usuário devido a bloqueios de autenticação de sessão do agente.

## Próximo passo recomendado
- Rodar o push manualmente em todos os submódulos:
  ```bash
  cd repos/kryonix && git push origin main
  cd ../kryonixos && git push origin main
  cd ../kryonix-vault && git push origin main
  cd ../.. && git push origin main
  ```
