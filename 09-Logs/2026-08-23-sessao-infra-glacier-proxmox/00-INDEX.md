# Índice — Sessão 2026-08-23 — Infra Glacier/Proxmox

Data: 2026-08-23 a 2026-08-24
Agente: Aura (MiniMax-M3)
Escopo: SSH + Proxmox + MikroTik + Shell web patches + Tailscale
Hosts afetados: inspiron (10.1.1.252), glacier (10.1.1.2 / 168.227.125.70), MikroTik (10.1.1.254)

## Resultado consolidado

| Domínio | Status final |
|---|---|
| SSH rocha → glacier (LAN e WAN) | ✅ operacional, pubkey only |
| Proxmox VE 9.2.11 com `rocha@pam` admin | ✅ operacional, MFA ativo |
| MikroTik dst-nat WAN:22022/28006 → glacier | ✅ operacional |
| Shell web Proxmox sem pedir login | ✅ patch dtach oficial (community) |
| Tailscale no glacier | ✅ ativo, IP 100.110.225.98 |
| Hairpin NAT para SSH WAN via Inspiron | ✅ funciona (Inspiron sai pelo mesmo IP público, dst-nat responde) |

## Arquivos desta sessão

| # | Arquivo | Conteúdo |
|---|---|---|
| 01 | [[01-investigacao-rede]] | Mapa LAN, ARP, DHCP leases, devices |
| 02 | [[02-ssh-glacier-chave-e-porta]] | Chave `glacier-access`, porta 2224, hardening sshd |
| 03 | [[03-proxmox-instalacao-e-usuarios]] | Fresh install, `rocha@pve` → `rocha@pam`, ACL, MFA |
| 04 | [[04-mikrotik-inventario-e-dstnat]] | RB750GL, dst-nat WAN:22022/28006, regras firewall |
| 05 | [[05-shell-web-patches]] | PAM `pam_succeed_if` + dtach Nodes.pm |
| 06 | [[06-tailscale-estado]] | Tailscale `100.110.225.98`, status |
| 07 | [[07-problemas-e-pendencias]] | Huawei 10.1.1.253, hairpin, kernel 7.0.14 reboot |
| 08 | [[08-validacoes-e-testes]] | Testes SSH, Web, dst-nat |

## MOC relacionado

[[../01-MOCs/MOC - Sessão 2026-08-23 - Infra Glacier Proxmox]]

## Links vault-wide

- [[../AGENTS|AGENTS]] — protocolo do vault
- [[../VAULT_INDEX|VAULT_INDEX]] — índice principal
- [[../02-Areas/Kryonix/canonical/ADR-006-shell-web-patch-dtach|ADR-006 — decisão do patch dtach]]

#sessao-2026-08-23 #glacier #proxmox #mikrotik #ssh #tailscale
