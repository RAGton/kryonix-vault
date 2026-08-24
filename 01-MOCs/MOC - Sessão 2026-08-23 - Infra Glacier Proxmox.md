# MOC — Sessão 2026-08-23 — Infra Glacier/Proxmox

## Propósito

MOC (Map of Content) centralizando tudo o que foi feito em 23-24/ago/2026 sobre infraestrutura do glacier (Proxmox), MikroTik, SSH, e patches do shell web.

## Contexto

- glacier foi **reformatado** com Proxmox VE 9.2.11 fresh
- 131 pacotes atualizados (kernel 7.0.14-12, microcode AMD, ZFS 2.4.3, pve-manager 9.2.11)
- Sessão de ~14h (do zero até MFA + dtach patch funcionando)
- Hosts: inspiron (10.1.1.252), glacier (10.1.1.2), MikroTik (10.1.1.254)

## Notas principais

| Nota | Conteúdo |
|---|---|
| [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/00-INDEX\|Sessão — INDEX]] | Índice geral da sessão |
| [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/01-investigacao-rede\|Investigação da rede]] | Mapa LAN, ARP, DHCP leases, devices |
| [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/02-ssh-glacier-chave-e-porta\|SSH glacier]] | Chave ed25519, porta 2224, hardening sshd |
| [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/03-proxmox-instalacao-e-usuarios\|Proxmox users]] | `rocha@pam`, MFA TOTP, ACL Administrator |
| [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/04-mikrotik-inventario-e-dstnat\|MikroTik dst-nat]] | RB750GL, dst-nat WAN:22022/28006 |
| [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/05-shell-web-patches\|Shell web patches]] | PAM + dtach Nodes.pm |
| [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/06-tailscale-estado\|Tailscale]] | IP 100.110.225.98, status |
| [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/07-problemas-e-pendencias\|Pendências]] | Huawei, reboot, RouterOS upgrade |
| [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/08-validacoes-e-testes\|Validações]] | Testes SSH, Web, dst-nat |

## Decisões arquiteturais

| ADR | Decisão |
|---|---|
| [[02-Areas/Kryonix/canonical/ADR-006-shell-web-patch-dtach\|ADR-006]] | Patch dtach Nodes.pm pro Shell web (community Proxmox oficial) |

## Projetos ativos

- **Sessão 2026-08-23** — em andamento, várias pendências

## Prompts reutilizáveis

- Nenhum prompt novo criado nesta sessão

## Playbooks

- Ver [[04-Recursos/playbooks/SSH Hardening Playbook]] (já existente)
- Ver [[04-Recursos/playbooks/Proxmox User@realm Setup Playbook]] (já existente)

## Skills

- Nenhuma skill nova criada

## Caminho de estudo

Se você está chegando aqui agora, leia na ordem:

1. [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/01-investigacao-rede]] — entender a rede
2. [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/02-ssh-glacier-chave-e-porta]] — SSH funcionando
3. [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/03-proxmox-instalacao-e-usuarios]] — Proxmox operacional
4. [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/05-shell-web-patches]] — Shell web funcionando
5. [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/07-problemas-e-pendencias]] — o que falta

## Perguntas abertas

- Huawei EG8145V5-V2: onde está e como acessar?
- Tailscale SSH do glacier precisa ser aprovado no admin console
- MikroTik RouterOS upgrade (6.43.7 → 7.18.2) — quando?
- Cloudflare Tunnel vale a pena pra Gabriel? (depende de domínio próprio)

## Links relacionados

- [[../AGENTS|AGENTS]] — protocolo do vault
- [[../VAULT_INDEX|VAULT_INDEX]] — índice principal
- [[Mapa - Proxmox PXE NFS Homelab]] — outra nota Proxmox (já existente)

#moc #sessao-2026-08-23 #infraestrutura #glacier #proxmox
