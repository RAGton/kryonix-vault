---
tipo: pr-log
projeto: kryonix
componente: browser-automation
created: 2026-06-22
updated: 2026-06-22
author: aura
tags: [pr, browser-automation, zsh, formatting, mergeado]
---

# PRs #89, #88 e #87 — fila browser automation finalizada

## Resumo

A fila crítica de 3 PRs foi concluída sem aplicar mudanças no host. Nenhum switch/rebuild foi executado.

## Ordem dos PRs

| PR | Título | Commit main | Resultado |
|---:|---|---|---|
| #89 | chore(nix): format validation baseline | 2c30cb39 | Mergeado |
| #88 | fix(home-manager): wrap zsh module config | b4ddb25c | Mergeado |
| #87 | feat(nixos): add browser automation runtime support | 9791a425 | Mergeado |

## Problemas resolvidos

1. **Baseline nixfmt quebrado** — `nix fmt` aplicado em 21 arquivos (features, wallpapers) para destravar Nix Validation nos PRs seguintes.
2. **Incompatibilidade Home Manager/Zsh** — módulo `modules/home-manager/programs/zsh/default.nix` tinha `options.*` e `home.*`/`programs.*` ambos no top-level. Home Manager mais novo recusa. Correção: encapsular `home.*`, `programs.zsh` e `home.packages` dentro de `config = { ... };`.
3. **PR #87 contaminado** — branch criada a partir de `feat/remote-web-boot-mode` em vez de `origin/main`. Limpeza via worktree clean + cherry-pick + push `--force-with-lease`. Após merge da main com formatting + zsh fix, PR validou e mergeou limpo.

## Validações realizadas

- `nix build .#nixosConfigurations.inspiron.config.system.build.toplevel` com override local (zsh fix): ✅ PASS
- `nix build` com override `github:RAGton/kryonix/main` (pós #88 + #89): ✅ PASS
- `nix build` com override `github:RAGton/kryonix/feat/browser-automation`: ✅ PASS
- `nix flake check --keep-going` (pós #89): formatting ✅ PASS

## Estado atual

- GitHub `main`: `9791a425`
- `/etc/kryonix`: ainda não sincronizado
- `/etc/kryonixos`: ainda não atualizado
- host `inspiron`: ainda não recebeu mudanças

## Decisão operacional

Não fazer switch/rebuild ainda. Antes disso, auditar packages/installer para planejar sync PROD de forma segura.

## Próximos passos

1. Auditar `packages/` e installer.
2. Verificar se `kryonix-installer` entra no host `inspiron`.
3. Classificar packages por categoria.
4. Só depois planejar sync PROD.

## Links

- [[09-Logs/prs/PR-087 - browser automation runtime support]]
- [[09-Logs/evidence/downstream-home-manager-zsh-breakage-2026-06-22]]
- [[09-Logs/evidence/kryonix-general-audit-2026-06-22]]
