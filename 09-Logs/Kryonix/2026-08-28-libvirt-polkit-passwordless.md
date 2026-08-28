# Configuração de Polkit e Grupos para Libvirt Sem Senha

Data: 2026-08-28
Agente: Antigravity / Gemini
Repos afetados:
- `repos/kryonix`
- `repos/kryonixos`
- `kryonix-dev` (submodule pointers)

## Objetivo
Resolver a solicitação de autenticação via senha ao interagir com `virsh`/`libvirt` e instruir a solução para os avisos amarelados do virt-manager (OpenGL / 3D acceleration / Listen type).

## Diagnóstico
1. O daemon `libvirtd` estava ativado no `inspiron` por causa do módulo `network.nix` (`virtualBridges.ragthink`), porém o usuário `rocha` não possuía o grupo `libvirtd` no sistema ativo e a regra de Polkit dependia da flag de virtualização genérica.
2. No Virt-Manager, os avisos de OpenGL ocorrem porque o VirtIO precisa de escuta `None` e aceleração 3D habilitada.

## Mudanças Realizadas
- `repos/kryonix/modules/nixos/common/default.nix`: Polkit extraConfig e inclusão no grupo `libvirtd` vinculadas diretamente a `config.virtualisation.libvirtd.enable`.
- `repos/kryonixos/hosts/inspiron/default.nix`: Adicionado `libvirtd` e `kvm` ao `extraGroups` do usuário `rocha`.

## Commits e Branches
- `repos/kryonix`: `d8d50965`
- `repos/kryonixos`: `a7c309b`

## Próximo Passo Recomendado
- Rodar `kryx switch`.
- Executar `newgrp libvirtd` ou fazer logout/login para a sessão de usuário carregar o novo grupo `libvirtd` do Linux.
- Ajustar os parâmetros do virt-manager (Listen type = None, Video = VirtIO, 3D acceleration = marcado).
