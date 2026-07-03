# Automação de Reconciliação Libvirt Destrutiva

Data: 2026-07-03
Agente: Antigravity
Repos afetados:
- kryonix (core)
- kryonixos (downstream)

## Objetivo
Resolver o problema de "drift" na rede declarativa Libvirt (ex: `net-ragthink`) de forma segura. O serviço `kryonix-libvirt-network-*.service` falhava quando a rede existia, exigindo migração manual. Precisávamos de uma automação para reconciliar (destruir e recriar) a rede quando necessário.

## Contexto consultado
- Política anti-vibe coding no AGENTS.md.
- Avaliação da segurança da destruição automática de redes no Libvirt.

## Mudanças realizadas
1. Adicionadas flags `allowDestructiveReconcile` (padrão `false`) e `requireNoRunningDomains` (padrão `true`) no módulo `virtualBridges` (Kryonix core).
2. O script do serviço agora compara de forma segura os booleanos do Nix no bash para destruir (`virsh net-destroy` / `net-undefine`) a rede anterior antes de criá-la com o novo XML, se a flag destrutiva estiver ativada.
3. Backup do XML da rede é feito em `/var/lib/kryonix/libvirt-network-backups` antes da destruição.
4. Flag destrutiva foi ativada temporariamente no `inspiron` (Kryonixos downstream) para migração.
5. Após o sucesso da migração da rede no `inspiron` (`kryonix switch all`), a flag foi **desativada** (voltando para `false`) para manter o host seguro em reloads futuros.

## Commits e branches
- Core (`kryonix`): commits implementando e corrigindo a conversão de booleano no Bash.
- Downstream (`kryonixos`): habilitado e posteriormente desabilitado `allowDestructiveReconcile = true` no `hosts/inspiron/default.nix`.
- Todos os submodules atualizados no workspace `kryonix-dev`.

## Validações executadas
- Re-build da configuração (`kryonix switch all` / `nixos-rebuild`).
- Validação no `systemctl status kryonix-libvirt-network-ragthink.service` mostrando que a rede foi recriada e inicializou com sucesso.
- Revisão completa do código do bash de migração.

## Evidências
- Serviço `kryonix-libvirt-network-ragthink` rodou e fechou como esperado no `inspiron`.

## Pendências
- Nenhuma. A migração concluiu com sucesso e a segurança padrão do módulo foi restaurada.

## Próximo passo recomendado
- Realizar pull local em `/etc/kryonixos` com `sudo git pull --ff-only origin main` para refletir o desligamento da flag destrutiva no diretório oficial de produção do host.
