# Reversão de Kernel: Glacier (Zen -> CachyOS)

Data: 2026-09-20
Agente: Antigravity
Repos afetados:
- kryonixos

## Objetivo
Reverter o kernel do host `glacier` para `CachyOS LTS` devido à incompatibilidade do módulo ZFS.

## Contexto consultado
Durante a ativação do perfil `glacier-gamer`, foi solicitado a alteração do kernel de `CachyOS LTS` para `Linux Zen`. No entanto, isso gerou uma quebra de avaliação/build (`Refusing to evaluate package 'zfs-kernel-...' because it has problems: broken`).

## Motivo da Falha
O host `glacier` depende fortemente de `zfs` (`boot.supportedFilesystems = [ "zfs" ]`). O `linuxPackages_zen` atual está na versão 7.1.3+, versão esta que ainda não possui compatibilidade oficial no Nixpkgs com o OpenZFS mais recente (ou é explicitamente marcada como "broken").

O módulo `kryonix.kernel.cachyos` que estava ativado anteriormente não só ativa o Kernel CachyOS (que já é otimizado para baixa latência e gaming), como também **injeta forçadamente um pacote ZFS patcheado (`zfs_cachyos`)** perfeitamente sincronizado com ele, sendo exatamente por isso que ele era a escolha arquitetural de Caminho A (`glacier-gaming-jul2026`).

## Mudanças realizadas
- `hosts/glacier/default.nix`: Revertido desabilitação de `cachyos` e habilitação de `kernelZen`.

## Commits
- `kryonixos`: `fix(glacier): revert kernel switch to cachyos due to zfs incompatibility with zen`
- `kryonix-dev`: `chore(dev): revert kryonixos submodule kernel switch`

## Próximo passo recomendado
- Manter o `glacier` na ramificação do CachyOS, que já oferece todos os schedulers e patches necessários para gaming sem comprometer a integridade do storage.
