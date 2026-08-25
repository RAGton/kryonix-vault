# Índice — Sessão 2026-08-23 — Infra Glacier/Proxmox

Data: 2026-08-23 a 2026-08-24
Agente: Aura (MiniMax-M3)
Escopo: SSH + Proxmox + MikroTik + Shell web patches + GPU passthrough completo
Hosts afetados: inspiron (10.1.1.252), glacier (10.1.1.2 / 168.227.125.70), MikroTik (10.1.1.254)

## Resultado consolidado

| Domínio | Status final |
|---|---|
| SSH rocha → glacier (LAN e WAN) | ✅ operacional, pubkey only |
| Proxmox VE 9.2.11 com `rocha@pam` admin | ✅ operacional, MFA ativo |
| MikroTik dst-nat WAN:22022/28006 → glacier | ✅ operacional |
| Shell web Proxmox sem pedir login | ✅ patch dtach oficial (community) |
| Tailscale no glacier | ✅ ativo, IP 100.110.225.98 |
| GPU passthrough RTX 4060 | ✅ funcional, validação 4% CPU idle |
| NVMe Lexar 1TB passthrough | ✅ Windows 11 instalado bare-metal |
| CPU pinning via hook script | ✅ vCPUs em cores 2-7+SMT 10-15 |

## Arquivos desta sessão

| # | Arquivo | Conteúdo |
|---|---|---|
| 00 | [[00-INDEX]] | Índice geral da sessão (este arquivo) |
| 01 | [[01-investigacao-rede]] | Mapa LAN, ARP, DHCP leases, devices |
| 02 | [[02-ssh-glacier-chave-e-porta]] | Chave `glacier-access`, porta 2224, hardening sshd |
| 03 | [[03-proxmox-instalacao-e-usuarios]] | Fresh install, `rocha@pve` → `rocha@pam`, ACL, MFA |
| 04 | [[04-mikrotik-inventario-e-dstnat]] | RB750GL, dst-nat WAN:22022/28006, regras firewall |
| 05 | [[05-shell-web-patches]] | PAM + dtach Nodes.pm |
| 06 | [[06-tailscale-estado]] | Tailscale `100.110.225.98`, status |
| 07 | [[07-problemas-e-pendencias]] | Huawei, reboot, RouterOS upgrade |
| 08 | [[08-validacoes-e-testes]] | Testes SSH, Web, dst-nat |
| **11** | [[11-gpu-passthrough-completo]] | **Log detalhado Fases 1-7 GPU/NVMe passthrough** |

## MOC relacionado

[[../../01-MOCs/MOC - Sessão 2026-08-23 - Infra Glacier Proxmox]]

## Decisões arquiteturais (ADRs)

| ADR | Decisão |
|---|---|
| [[../../02-Areas/Kryonix/canonical/ADR-006-shell-web-patch-dtach\|ADR-006]] | Patch dtach Nodes.pm pro Shell web (community Proxmox oficial) |
| [[../../02-Areas/Kryonix/canonical/ADR-007-passthrough-nvme-via-pcie\|ADR-007]] | GPU + NVMe passthrough via PCIe direto |

## Links vault-wide

- [[../AGENTS|AGENTS]] — protocolo do vault
- [[../VAULT_INDEX|VAULT_INDEX]] — índice principal

#sessao-2026-08-23 #glacier #proxmox #mikrotik #ssh #tailscale #gpu-passthrough
