# Sincronização de Produção Glacier (ZFS e EFI)

Data: 2026-07-19
Agente: Antigravity
Repos afetados:

- kryonixos
- kryonix-vault

## Objetivo
Alinhar as modificações aplicadas diretamente em produção no `/etc/kryonixos` (commit `89a0591`) com o fluxo canônico em `origin/main`, desfazendo o descompasso (divergência de 4 commits).

## Contexto consultado
- Configuração canônica anterior em `hosts/glacier/default.nix` e `hosts/glacier/hardware-configuration.nix`.
- Commits remotos: `c036c26`, `cc7aa65`, `c704d1d` e `de63b7b`.

## Mudanças realizadas
- Cherry-pick (sem commit) do patch `89a0591` para a branch `sync/glacier-functional-cherry-pick`.
- Resolução de conflitos em `default.nix` para preservar as modificações dos kernels CachyOS (movidas para a specialization por `c036c26`).
- Refatoração do patch em 3 commits menores e granulares:
  - `fix(glacier): resolve LightRAG package from flake output`
  - `fix(glacier): align ZFS root and EFI mounts`
  - `feat(glacier): declare secondary ZFS datasets and swap`

## Commits e branches
Branch: `sync/glacier-functional-cherry-pick` (criada a partir de `origin/main`)
PR: https://github.com/RAGton/Kryonixos/pull/14

## Validações executadas
- Git fsck e verificações de integridade nos repositórios clones.
- `nix eval --raw '.#nixosConfigurations.glacier.config.system.build.toplevel.drvPath'`
- `nix build --dry-run` para validar o toplevel no novo estado da árvore.

## Evidências
- Avaliação Nix sem erros.
- PR aberto com sucesso.

## Pendências
- O PR precisa ser mergeado no GitHub.
- Criar as worktrees do Aura (kryonix-aura e kryonixos-aura-glacier).

## Próximo passo recomendado
- Realizar a fusão (merge) do PR.
- Criar as worktrees solicitadas para o Agente Aura.
