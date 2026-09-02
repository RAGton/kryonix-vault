# Configuração de Polkit, Grupos e Firewall para Pontes Virtuais Libvirt

Data: 2026-09-02
Agente: Antigravity / Gemini
Repos afetados:
- `repos/kryonix`
- `repos/kryonixos`
- `kryonix-dev` (submodule pointers)

## Objetivo
Resolver o problema do `garos-wan`/`garos-lan` não entregar IP DHCP para as máquinas virtuais.

## Causa Raiz
O firewall nativo do NixOS (`networking.firewall.trustedInterfaces`) só permitia tráfego na interface `lo` (loopback). Com isso, as solicitações DHCP (porta UDP 67/68) vindas das interfaces de ponte das VMs (`virbr-gwan`, `virbr-glan`, `virbr-ragthink`, `virbr0`, `incusbr-kryonix`) eram bloqueadas antes de chegarem ao serviço `dnsmasq` do Libvirt no host.

## Mudanças Realizadas
- `repos/kryonix/modules/nixos/common/default.nix`: Adicionadas as pontes virtuais (`virbr0`, `virbr-gwan`, `virbr-glan`, `virbr-ragthink`, `incusbr-kryonix`) à lista `networking.firewall.trustedInterfaces` declarativamente.

## Commits e Branches
- `repos/kryonix`: `fcb48a4e`

## Próximos Passos
- Executar `kryx switch`.
- As VMs conectadas a `garos-wan` ou `garos-lan` passarão a receber endereço IP DHCP imediatamente.
