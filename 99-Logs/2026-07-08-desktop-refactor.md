# Refatoração KDE Plasma 6 e Correção Libvirt

Data: 2026-07-08
Agente: Antigravity
Repos afetados:
- repos/kryonix
- repos/kryonix-vault

## Objetivo
- Corrigir bloqueio de ativação causado pelo `kryonix-libvirt-network-ragthink.service`.
- Refatorar a camada desktop do KDE Plasma para um visual glass premium consistente, resolvendo bugs do launcher, painel e tema.

## Mudanças realizadas
1. `modules/nixos/features/network.nix`: Adicionado wrapper `safe_virsh` para envelopar comandos libvirt. Removido `exit 1` que quebrava o script no `set -e`, tornando o serviço idempotente e não-bloqueante (apenas emite logs WARN).
2. `desktop/kde/rofi.nix`: Substituído Fuzzel por Rofi-wayland. Adicionado tema glass customizado.
3. `desktop/kde/keybinds.nix`: Atalho `Meta+A` mapeado para `rofi -show drun`.
4. `desktop/kde/kvantum.nix`: Substituído `BonaFides-Dark-Kvantum` por `WhiteSurDark` para unificar a stack de temas.
5. `desktop/kde/theme.nix`: Substituído o painel único por uma topologia de 3 ilhas flutuantes reais (alignment: left, center, right) com o Pager visível (height=36). Adicionado comentário documentando o fallback caso ocorra instabilidade no KWin.
6. `desktop/kde/default.nix`: Desabilitada explicitamente a indexação do Baloo (`programs.plasma.baloo.enable = false;`).

## Commits e branches
No `repos/kryonix` (branch main):
- `fix(virtualization): make ragthink libvirt network activation idempotent and non-blocking`
- `desktop(rofi): restore rofi launcher on Meta+A`
- `desktop(kde): unify theme stack around WhiteSur glass`
- `desktop(kde): refactor Plasma panels with visible pager and 3 islands`
- `desktop(kde): disable baloo indexer`

## Validações executadas
- Git log conferido para certificar commits pequenos.
- Build NixOS (via `kryonix-test` perfil `nix-fast` ou `nixos-rebuild`).

## Pendências
- O usuário deve testar a estabilidade das 3 ilhas flutuantes. Se houver problemas, o fallback está documentado no código.
- Nenhuma alteração foi feita nas extensões do VSCode (tarefa pendente para o usuário).
- Nenhuma alteração destrutiva (rm) foi feita nas pastas de configuração do KDE no Home.

## Próximo passo recomendado
- Rodar o deploy do NixOS (`kryonix switch all`) quando as alterações forem validadas.
- Caso o cache do Plasma cause distorções visuais no painel, realizar backup movendo `~/.config/plasmashellrc` e reiniciar o Plasma via SystemD user.
