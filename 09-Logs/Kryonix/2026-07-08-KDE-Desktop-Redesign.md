# KDE Plasma 6 Desktop Redesign e Topologia 3-Ilhas

Data: 2026-07-08
Agente: Antigravity
Repos afetados:
- kryonix

## Objetivo
Refazer a camada visual do Kryonix Desktop KDE Plasma 6, removendo regressões e inconsistências de temas e criando uma experiência premium inspirada em Hyprland/macOS (WhiteSur) com painéis flutuantes e otimização de launcher.

## Contexto consultado
Auditoria completa do repositório `kryonix/modules/nixos/desktop` e `kryonix/desktop/kde`, além do estado local do Home Directory.

## Mudanças realizadas
- Unificação do ecossistema de temas para o `WhiteSurDark` (Kvantum, GTK, Plasma Style).
- Reconstrução do painel superior (`lengthMode="fill"`) para 3 ilhas flutuantes separadas (`floating=true`) garantindo coerência de design.
- Alteração da altura da ilha esquerda para `36px` para renderizar corretamente o Kanji do Pager.
- Restauração do Launcher Fuzzel atrelado ao atalho `Meta+A`, desativando o mapeamento legado do KRunner.
- Desativação global do processo de indexação `baloo_file_extractor` para otimização severa de performance.
- Limpeza rigorosa do Home directory de vestígios dos temas `Sweet`, `BonaFides` e `DankMatugen`.

## Commits e branches
Pendentes no workspace local (`kryonix-dev/repos/kryonix`).

## Validações executadas
- Avaliação de compatibilidade Flake concluída com sucesso (`nix flake check`).

## Pendências
- O usuário deve fazer commit das mudanças e aplicar via `kryonix switch all` (que requer sudo, portanto bloqueado no sandbox do agente).
- O usuário deve limpar suas extensões legadas de IA no VSCode (74 ativas) para resolver o gargalo de RAM.

## Próximo passo recomendado
Fazer o commit e aplicar as mudanças no host target e analisar o visual final do KDE.
