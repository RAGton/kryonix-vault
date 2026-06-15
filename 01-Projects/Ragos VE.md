# Ragos VE

## Objetivo

Projeto/base de conhecimento para infraestrutura pessoal e profissional com:

- Proxmox VE;
- Linux;
- NixOS;
- PXE/iPXE;
- NFS;
- storage;
- automação;
- rede;
- homelab;
- serviços internos.

## MOCs relacionados

- [[10-MOCs/Mapa - Proxmox PXE NFS Homelab]]
- [[10-MOCs/Mapa - Linux e Sistemas]]
- [[10-MOCs/Mapa - NixOS e Infra Declarativa]]
- [[10-MOCs/Mapa - DevOps e SRE]]
- [[10-MOCs/Mapa - Debug Testes e Qualidade]]

## Prioridades técnicas

1. Reprodutibilidade.
2. Backup antes de mudança crítica.
3. Rollback documentado.
4. Segurança de rede e secrets.
5. Logs e observabilidade.
6. Scripts de diagnóstico.
7. Documentação mínima de operação.

## Áreas críticas

- firewall;
- storage;
- boot;
- rede bridge/VLAN;
- NFS exports;
- permissões;
- backups;
- clusters;
- systemd services;
- secrets.

## Playbooks relacionados

- [[03-Resources/playbooks/Debug Scripts e Test Harness]]
- [[03-Resources/playbooks/Como Fazer Outra IA Consumir Este Vault]]
- [[03-Resources/prompts/PROMPT_AGENT_INFRA_LINUX]]

## Checklist antes de produção

- [ ] backup testado
- [ ] rollback definido
- [ ] firewall revisado
- [ ] secrets fora do repo
- [ ] logs habilitados
- [ ] NFS com permissões corretas
- [ ] Proxmox com backup/snapshot
- [ ] documentação atualizada
