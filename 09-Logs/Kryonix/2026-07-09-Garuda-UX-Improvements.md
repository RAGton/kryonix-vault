# Garuda UX Improvements no KDE Plasma

Data: 2026-07-09
Agente: Antigravity
Repos afetados:
- kryonix
- kryonixos

## Objetivo
Melhorar a estética do KDE Plasma no Kryonix, inspirando-se no tema e disposição do Garuda Dr460nized (Neon/Glass look), mantendo a topologia segura já existente no ecossistema (Rofi, SDDM Breeze, WhiteSurDark).

## Contexto consultado
O repositório `garuda-dr460nized` (configurações do Garuda KDE) foi clonado temporariamente e seus parâmetros de blur, KWin, dock e transparência foram avaliados e traduzidos para a estrutura declarativa Nix do Kryonix via Home Manager.

## Mudanças realizadas
- `desktop/kde/theme.nix`: 
  - Ajuste na altura do painel superior (`height = 36`) e do dock inferior (`height = 56`).
  - Painel inferior (Dock) ajustado para `hiding = "windowscover"` (dodge window behavior).
  - Configuração do KWin ajustada para garantir a ativação global de Blur e Translucency, além dos efeitos de Slide na transição entre workspaces, mimetizando o Glass profundo do Garuda de modo otimizado.

## Commits e branches
- `desktop(kde): tune top bar glass spacing` (kryonix, main)
- `desktop(kde): polish dock hiding and sizing` (kryonix, main)
- `desktop(kde): enable blur and smooth slide effects` (kryonix, main)
- `chore(dev): update kryonix submodule pointer for Garuda UX improvements` (kryonix-dev, main)

## Validações executadas
- `nix fmt` para checagem sintática no core.
- `nix flake lock --update-input kryonix` no downstream (`kryonixos`).
- Build do `inspiron` compilou com sucesso localmente.
- Revisão local via `nvd diff`.

## Evidências
- As instâncias KWin agora forçam Blur e Slide sem conflitar com o compositor padrão.
- O fallback de `windowscover` foi aplicado com sucesso na Dock flutuante, que comporta atalhos do VSCode e afins.

## Pendências
- Nenhuma. O `kryonix switch` ou `nixos-rebuild switch` manual pode ser aplicado pelo usuário para consolidar as alterações na interface atual.

## Próximo passo recomendado
Atualizar a documentação ou graphify, e o utilizador pode aplicar o switch e validar visualmente o comportamento da barra com "windowscover".
