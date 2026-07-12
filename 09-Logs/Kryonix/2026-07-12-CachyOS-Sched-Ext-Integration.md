# Integração do CachyOS e Sched-Ext no Glacier

Data: 2026-07-12
Agente: Antigravity (Claude)
Repos afetados:
- kryonix-core
- kryonixos

## Objetivo
Implementar a integração limpa do kernel CachyOS e suporte declarativo a sched-ext para o host Glacier.

## Contexto consultado
- Decisões anteriores sobre não compilar o CachyOS localmente.
- O uso de `services.scx` nativo do NixOS para o sched-ext.
- Uso de `pkgs.cachyosKernels` via overlay do flake `nix-cachyos-kernel`.

## Mudanças realizadas
- `kryonix-core`:
  - `modules/kernel/cachyos.nix`: Removida injeção manual e uso de `pkgs.extend`, voltando a usar o overlay `overlays.default` que fornece `pkgs.cachyosKernels` corretamente empacotado, além dos pacotes de ZFS nativos.
  - `modules/nixos/performance/sched-ext.nix`: Interface declarativa adicionada sobre o serviço nativo `services.scx`.
- `kryonixos`:
  - `hosts/glacier/default.nix`: Removida a configuração complexa e inseridas opções limpas. O kernel e o ZFS usam `cachyosKernels.linuxPackages-cachyos-lts-lto` e a specialisation `cachyos-release-gaming` usa a variante `latest-lto`.
  - Corrigido o conflito em `fs.inotify.max_user_watches` entre features de gaming e as configurações estritas do Glacier.

## Commits e branches
- Upstream (`kryonix-core-zfs-cachyos`) na branch `main`.
- Downstream (`kryonixos-glacier-zfs-canonical`) mergeado na branch `main`.

## Validações executadas
- Avaliação completa com `nix eval --raw .#nixosConfigurations.glacier.config.system.build.toplevel` concluída com sucesso após a correção de colisões de dependências.

## Evidências
- Resultado de avaliação aponta para: `/nix/store/jldqrppwxg0y8lahgprkdl4cbkc9pzws-nixos-system-RVE-GLACIER-26.05.20260625.4062d36`

## Pendências
- Deploy na máquina real.
- Execução do teste A/B para benchmarks.
- O pull em `/etc/kryonix` precisa ser feito pelo usuário com sudo.

## Próximo passo recomendado
Fazer o pull em `/etc` e aplicar a configuração sem dar boot imediato.
