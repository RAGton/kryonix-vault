# Mudança de Kernel: Glacier (CachyOS -> Zen)

Data: 2026-09-20
Agente: Antigravity
Repos afetados:
- kryonixos

## Objetivo
Trocar o kernel padrão do host `glacier` para otimizar a experiência de gaming.

## Contexto consultado
Na sessão anterior que configurou o perfil `glacier-gamer` ativando as bibliotecas 32-bits, Steam e Gamemode, ficou pendente a substituição do Kernel de CachyOS LTS para Linux Zen (otimizado para Desktop/Gaming).

## Mudanças realizadas
- `hosts/glacier/default.nix`:
  - Desabilitado `kryonix.kernel.cachyos.enable = false;`
  - Habilitado módulo Zen: `kernelZen.enable = true;` e `kernelZen.kernel = "zen";`

## Commits e branches
- `kryonixos`: `fix(glacier): switch kernel from cachyos to zen for better gaming compatibility`
- `kryonix-dev`: `chore(dev): update kryonixos submodule after kernel switch`

## Validações executadas
- Avaliação com `nix flake check` finalizada sem erros de assertions.

## Evidências
- Flake avaliado com o módulo `kernelZen`.

## Pendências
- Nenhuma pendência associada.

## Próximo passo recomendado
- Dar switch para o novo Kernel e reinicializar a máquina.
