# Configuração de Polkit, Grupos e Firewall para Pontes Virtuais Libvirt

Data: 2026-09-02
Agente: Antigravity / Gemini
Repos afetados:
- `repos/kryonix`
- `repos/kryonixos`
- `kryonix-dev` (submodule pointers)

## Objetivo
Liberar a atribuição de IP via DHCP para a ponte `virbr-gwan` mantendo as pontes desnecessárias fora da lista de confiança do firewall.

## Mudanças Realizadas
- `repos/kryonix/modules/nixos/common/default.nix`: Removidas `virbr-ragthink` e `incusbr-kryonix` da lista `networking.firewall.trustedInterfaces`. Mantidas apenas `virbr0`, `virbr-gwan` e `virbr-glan`.

## Commits e Branches
- `repos/kryonix`: `6ee99816`

## Próximos Passos
- Executar `kryx switch`.
- A VM conectada a `garos-wan` (`virbr-gwan`) receberá IP via DHCP (`10.1.0.x`) normalmente.
