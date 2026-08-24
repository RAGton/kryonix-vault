# Problemas e pendências — sessão 2026-08-23

## Objetivo

Listar problemas conhecidos, blockers e pendências após a sessão de infraestrutura.

## 🔴 Bloqueios críticos

### 1. Huawei EG8145V5-V2 sem acesso

| Item | Valor |
|---|---|
| IP suposto | 10.1.1.253 |
| MAC no DHCP lease | `FC:3C:D7:03:1F:F9` |
| Hostname DHCP | `lwip0` (suspeito — não é padrão Huawei) |

**Sintoma:** Gabriel reportou que **transformou Huawei em AP** mas **não consegue acessar**.

**Hipótese 1:** O dispositivo em `.253` NÃO é o Huawei (hostname `lwip0` é típico de ESP32/IoT, MAC não bate com prefixo Huawei).

**Hipótese 2:** O Huawei está em outro IP ou perdeu config após virar AP.

**Ação:** Conferir MAC na etiqueta do Huawei (parte de trás/embaixo). Se diferente de `FC:3C:D7:03:1F:F9`, o `.253` é outro device.

### 2. SSH WAN não testado de fora (4G)

**Sintoma:** Hairpin NAT (Inspiron LAN acessando WAN pública) **funciona por sorte** porque Inspiron e MikroTik compartilham IP público (CGNAT).

**Não validado:** Conexão de uma rede realmente externa (4G celular, café) até `168.227.125.70:22022`.

**Risco:** dst-nat pode ter regra de firewall ainda bloqueando conexões de WAN real.

**Ação:** Testar com 4G do celular `edge-50-pro`.

## 🟡 Pendências médias

### 3. Atualização RouterOS 6.43.7 → 7.18.2

| Item | Valor |
|---|---|
| Versão atual | 6.43.7 (de 2020, sem patches de segurança) |
| Versão target | 7.18.2 (build 2025-03-11) |
| Tipo upgrade | Routerboard firmware + RouterOS |
| Risco | ~1 min de downtime, internet cai |
| Pré-requisito | Backup atual já feito (`backup-pre-glacier-ssh.rsc`) |

**Ação:** Planejar janela de manutenção.

### 4. Reboot do glacier (kernel 7.0.14-12 + microcode AMD)

| Item | Valor |
|---|---|
| Kernel atual | 7.0.14-12-pve (instalado, mas não ativo) |
| Kernel em uso | 7.0.2-6-pve (anterior) |
| Pendência | microcode AMD `3.20251202.1~bpo13+1` (também aguardando reboot) |

**Ação:** Reiniciar **depois** do dst-nat MikroTik estar validado de fora. Não reiniciar com SSH como único caminho de acesso.

### 5. Patch PAM (`pam_succeed_if.so` no pvedaemon) não aplicado ao shell web

**Estado:** Patch criado em `/etc/pam.d/pve-shell-bypass` e referenciado em `common-auth`.

**Efeito real:** Nenhum no Shell web (o `/bin/login` chamado via `termproxy` não passa pelo serviço `pvedaemon` no PAM).

**Recomendação:** Reverter (cleanup) já que o patch dtach no `Nodes.pm` é o que resolve.

```bash
sudo sed -i '/auth include pve-shell-bypass/d' /etc/pam.d/common-auth
sudo rm /etc/pam.d/pve-shell-bypass
```

## 🟢 Pendências baixas / nice-to-have

### 6. Desabilitar serviços MikroTik não usados

| Serviço | Porta | Recomendação |
|---|---|---|
| telnet | 23 | ❌ desabilitar |
| ftp | 21 | ❌ desabilitar |
| www | 80 | ⚠️ mover pra porta alta |
| api | 8728 | ❌ desabilitar (usar api-ssl 8729) |
| api-ssl | 8729 | ✅ manter |
| winbox | 8291 | ✅ manter |
| ssh | 22 | ✅ manter |

### 7. Fail2ban no glacier (Proxmox + sshd)

Proteger contra brute-force em 8006 e 2224.

```bash
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
```

### 8. Cloudflare Tunnel (esconder IP público)

| Benefício | Como |
|---|---|
| Esconde IP origem | Cloudflare proxy na frente |
| MFA grátis | Cloudflare Access |
| Sem dst-nat necessário | cloudflared faz outbound |

**Requisito:** Domínio próprio no Cloudflare.

### 9. OpenID Connect / Keycloak (SSO self-hosted)

Solução mais completa pra SSO multi-app. Setup ~2-3h.

### 10. VLANs (rede separada)

Gabriel pediu VLANs (Wi-Fi 2.4/5G, IoT, servers, GAROS dedicada). **Não começou.** Projeto separado, requer Huawei funcional + APs com VLAN trunk.

## Próxima ação (ordenada por prioridade)

1. ✅ Reverter patch PAM (`/etc/pam.d/pve-shell-bypass`)
2. ✅ Criar ADR-006 documentando decisão do dtach
3. 🔴 Resolver Huawei (etiqueta MAC)
4. 🔴 Testar dst-nat de fora (4G)
5. 🟡 Planejar reboot MikroTik + glacier
6. 🟡 Fail2ban
7. 🟢 Cloudflare Tunnel (se Gabriel tiver domínio)
8. 🟢 VLANs (projeto grande, agendar)

## Links relacionados

- [[01-investigacao-rede]] — descoberta do `.253`
- [[04-mikrotik-inventario-e-dstnat]] — dst-nat pendente validação externa
- [[05-shell-web-patches]] — cleanup do PAM

#pendencias #huawei #routeros #tailscale
