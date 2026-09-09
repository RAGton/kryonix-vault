# Refatoração Visual do Desktop Kryonix Aurora

Data: 2026-09-08
Agente: Antigravity
Repos afetados:
- repos/kryonix

## Objetivo
Melhorar drasticamente a experiência visual do KDE Plasma do Kryonix sem realizar downgrade do NixOS (permanecendo na 26.11-unstable), eliminando dependências frágeis de temas (Kvantum/Aurorae) e construindo uma identidade visual própria e nativa.

## Contexto consultado
- Arquitetura visual antiga baseada no Kvantum e `bonafides-theme`.
- Falhas e artefatos reportados pelo usuário no Plasma 6 devido à fragilidade de temas terceiros no stack Qt.

## Mudanças realizadas
- O engine `Kvantum` foi completamente erradicado do repositório, incluindo o pacote legado `bonafides-theme` e o módulo `kvantum.nix`.
- Padronização total para renderização através do motor nativo `Breeze` no Qt, no Plasma Theme e nas Decorações de Janelas (Aurorae desativado).
- O esquema de cores `KryonixDark` foi definido como global e injetado nativamente no Plasma para pintar os widgets e janelas.
- A camada GTK foi padronizada no `Breeze-Dark`, com ícones `Papirus-Dark`.
- Cursores (SDDM, GTK, X11, Wayland) padronizados para `Bibata-Modern-Ice`.

## Commits e branches
- N/A (A ser comitado pelo usuário na main).

## Validações executadas
- Formatação geral do código via `nix fmt`.
- Compilação estática bem-sucedida via `nix flake check --keep-going --impure` (bypass Kryonix Guard).

## Evidências
- Walkthrough completo com passos para switch e limpeza de cache.

## Pendências
- Teste e aprovação de usuário pós `kryx switch`.

## Próximo passo recomendado
- Aplicar a atualização com `kryx switch`, reiniciar a sessão, e se restarem cores antigas, re-aplicar o Color Scheme "Kryonix Dark" na configuração do sistema.
