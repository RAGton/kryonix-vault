# Correção de Integração Incus no CachyOS
Data: 2026-07-12
Agente: Antigravity
Repos afetados:
- kryonix
- kryonixos

## Contexto
O commit `e28c00c` introduziu o kernel CachyOS e suporte ao Incus.
Porém, `incus.enable` falhou ao avaliar downstream porque a opção `virtualization.enable` (top-level) estava faltando no profile do host `glacier`. O módulo declarativo do `incus` upstream já estava completo.
Adicionalmente, havia um erro de tipagem no backend de wallpaper animado (`engine` em vez de `backend`).

## Mudanças realizadas
1. No `kryonixos`:
   - Adicionado `kryonix.features.virtualization.enable = true` no `hosts/glacier/default.nix`.
   - Corrigido `animated.engine` para `animated.backend` em `desktop-visual-defaults.nix`.
   - Removida tentativa de duplicação do módulo do incus no core.

## Validações
- `nix eval --json .#nixosConfigurations.glacier.config.virtualisation.incus.enable` retornou `true`.
- `nix flake check` passou sem erros em todos os profiles.
- `nix build .#nixosConfigurations.glacier.config.system.build.toplevel --dry-run` passou perfeitamente, resolvendo 100% das derivações para deploy.

## Commits
- `kryonix`: revertida a adição local redundante do incus. Commit mantido: `e28c00c`
- `kryonixos`: `2fcc7be` fix(glacier): enable virtualization stack and correct wallpaper backend option

## Próximo passo
O usuário pode rodar `git pull --ff-only origin main` nos subdiretórios em `/etc/` e rodar `kryonix switch all` para aplicar e testar o deploy no Glacier físico.

