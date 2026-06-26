# Migração e Validação do Glacier para remote.ssh

Data: 2026-06-25
Agente: Antigravity
Repos afetados:

- repos/kryonix
- repos/kryonixos

## Objetivo

Migrar e validar a nova feature `kryonix.features.remote.ssh` no host `Glacier` (downstream `kryonixos`), removendo as antigas opções legadas da arquitetura passada.

## Contexto consultado

- `09-Logs/Kryonix/2026-06-24-remote-ssh-glacier.md` (validação passada)
- `09-Logs/Kryonix/2026-06-24-gpu-cpu-feature-resolutions.md` (remoção antiga do gpu/cpu)
- Repositório `kryonixos` (host glacier).
- Repositório `kryonix` (schema.nix e profiles legacy).

## Mudanças realizadas

1. **Downstream (`kryonixos`)**:
   - `hosts/glacier/default.nix`: Migrado completamente de `hardware.remote.ssh` (ou similar) para `kryonix.features.remote.ssh`.
   - Removidos atributos legados como `kryonix.features.cpu.amd.enable` e substituidos pelos canônicos (`gpu.amd`, `gpu.nvidia`, `gaming.enable`).
   - Adicionada opção `hardware.nvidia.open = false` para satisfazer as assertions do nixpkgs para as GPUs NVIDIA não-Turing configuradas no host.
   - Atualizado o pointer do submodule (`flake.lock`).

2. **Core (`kryonix`) - Ajustes não commitados (Pending User Review)**:
   - Durante a avaliação downstream, descobriu-se que o core ainda impedia a compilação por conta de falhas lógicas e estruturais residuais:
     - `schema.nix` continha a declaração redundante e conflitante da opção `vscode`, que conflitava com `mkRemovedOptionModule` de `development.nix`.
     - `profiles/glacier-gamer.nix` e `profiles/workstation-gamer.nix` ainda chamavam opções obsoletas (`kryonix.features.workstation.enable` e `kryonix.features.openrgb.enable`).
   - Esses itens foram corrigidos localmente no workspace para destravar a build downstream.

## Commits e branches

- `kryonixos`: `chore(glacier): migrate to canonical remote.ssh and gaming features` (branch: `pr-16-glacier-remote-ssh-feature`)
- `kryonix`: Ajustes não commitados na branch `main`.

## Validações executadas

- `nix build .#nixosConfigurations.glacier.config.system.build.toplevel --show-trace --dry-run` finalizou com SUCESSO no downstream após os ajustes do core e downstream.

## Pendências

- O usuário precisa revisar as alterações pendentes (modificações read-only no core `schema.nix` e `profiles/*-gamer.nix`) e decidir se fará um novo PR corretivo na branch `main` do core.
- Fazer o PUSH da branch `pr-16-glacier-remote-ssh-feature` no downstream.

## Próximo passo recomendado

1. Analisar as alterações não-commitadas no core `kryonix`.
2. Criar um PR corretivo no core (`fix: legacy schema and profiles overlap`).
3. Prosseguir com o merge do PR 16 no downstream, já que a build foi validada.
