# Libvirt Virtual Bridge Backend PR

Data: 2026-06-26
Agente: Antigravity
Repos afetados:
- kryonix

## Objetivo
Implementar o backend (gerador de rede) no core que consome o schema `kryonix.features.network.virtualBridges` para gerar redes Libvirt e gerencia os systemd services correspondentes de forma declarativa e idempotente.

## Contexto consultado
- `docs/VIRTUAL_BRIDGE_AUDIT.md` (no core repo)
- Diretriz de não usar `virsh net-destroy` e `net-undefine` para não interromper VMs (idempotência conservadora)
- `modules/nixos/features/schema.nix` para estrutura de opções.

## Mudanças realizadas
- Adicionado módulo `/modules/nixos/features/network.nix` que filtra as virtual bridges habilitadas.
- Gera um XML para cada virtual bridge (`<network>`) com IPs, bridge id, NAT opcional (com forward mode=nat) e DHCP range opcional.
- Cria serviço systemd oneshot associado (`kryonix-libvirt-network-<nome>`) que roda antes do libvirtd, configurando autostart e status da rede via `virsh`.
- Atualizado log do VIRTUAL_BRIDGE_AUDIT.md marcando o Passo 2 da migração como feito.
- A virtualização global (libvirtd) é ativada dinamicamente caso haja pelo menos uma bridge habilitada.

## Commits e branches
- Branch: `feat/libvirt-virtual-bridge-backend`
- PR: #116 (`https://github.com/RAGton/kryonix/pull/116`)
- Repo: `kryonix`

## Validações executadas
- Preflight e regex pass fail checks.
- Formatação de arquivo (Nix fmt).
- Core check usando `nix flake check --keep-going --show-trace` no repo core (kryonix). Verificado `all checks passed!`.
- Downstream dry-run de system derivation no repo (`kryonixos`) host (`inspiron`) apontando para override local no repositório core (`kryonix`).

## Evidências
- Validação Flake passou com sucesso sem alterar o arquivo legacy `net-ragthink`. Nenhuma rede ou estado foi modificado em tempo de teste.

## Pendências
- Testar runtime em hosts (`inspiron`, `glacier`).
- Avaliar suporte a re-deploy de XML (drift real via systemd `restartIfChanged`) no futuro se preciso.

## Próximo passo recomendado
Fase 3: Migrar de fato o host `inspiron` para usar `kryonix.features.network.virtualBridges.ragthink` e desabilitar o script hardcoded em local legacy module.
