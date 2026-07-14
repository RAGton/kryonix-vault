# Refinamento Industrial do Host Glacier (ZFS + Kernel LTS)

Data: 2026-07-14
Agente: Antigravity
Repos afetados:
- repos/kryonixos

## Objetivo
Garantir a estabilidade absoluta no armazenamento ZFS e atualizar o Kernel para a release LTS mais recente no host Glacier, evitando problemas de dessincronização de boot.

## Mudanças realizadas
- Adicionado `services.zfs.autoScrub.enable = true;` no arquivo `hosts/glacier/default.nix` para prevenção de bit-rot.
- A configuração `boot.supportedFilesystems = [ "zfs" ];` e as dependências systemd de montagem do ZFS antes do `local-fs.target` já estavam configuradas corretamente no repositório.
- A versão base do Kernel (`boot.kernelPackages = lib.mkOverride 60 pkgs.linuxPackages;`) já estava correta (Track LTS), e o CachyOS restrito à especialização de Gaming.

## Commits e branches
- `repos/kryonixos`: `refactor(glacier): enforce zfs mount order and autoscrub for LTS boot` (na branch `main`)

## Validações executadas
- A compilação da imagem local (`toplevel`) no workspace atual foi explicitamente abortada pelo usuário por restrições de hardware, delegando o build real para um momento futuro (provavelmente num runner CI ou diretamente no nó).

## Pendências
- Testar o boot na máquina física Glacier e verificar o status dos serviços do ZFS (`zfs-import-cache.service` e `zfs-mount.service`).
