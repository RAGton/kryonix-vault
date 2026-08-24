# Investigação da rede — sessão 2026-08-23

## Objetivo

Mapear a topologia física e lógica da rede caseira antes de configurar SSH/Proxmox/MikroTik, identificando dispositivos, IPs, MACs, e o que era Proxmox vs IoT vs celular.

## Comando usado (via SSH na MikroTik)

```bash
ssh -i ~/.ssh/kryonix-mikrotik aura@10.1.1.254 <<'CMDS'
/interface bridge host print detail where !local
/ip arp print
/ip dhcp-server lease print detail
/ip firewall filter print where chain=forward
/ip firewall filter print where chain=input
/ip dns print
/system routerboard print
CMDS
```

## Mapa descoberto

### Topologia física

```
INTERNET
   │  (PPPoE)
   ▼
[MikroTik RB750GL 10.1.1.254]
   │  ether2..ether5 + bridge (LAN)
   ├── ether2 ──── switch/hub
   │   ├── Echo Show              10.1.1.250  AC:41:6A:FD:96:68
   │   ├── Electrolux_Appliance   10.1.1.249  44:3E:07:58:F2:1E
   │   ├── Galaxy A21s (Ivonete)  10.1.1.247  E2:2B:57:EB:AB:47
   │   ├── edge-50-pro (Gabriel)  10.1.1.244  4A:8B:94:34:1A:11
   │   ├── Inspiron               10.1.1.252  5C:CD:5B:BE:F7:FD
   │   └── DESCONHECIDO           10.1.1.253  FC:3C:D7:03:1F:F9  (hostname "lwip0" — ver pendência)
   ├── ether5 ──── glacier/Proxmox    10.1.1.2  D8:43:AE:6E:1B:50
   ├── ether3 ──── (vazio)
   └── ether4 ──── (vazio)
```

### MikroTik RB750GL

| Atributo | Valor |
|---|---|
| Modelo | RB750GL (MIPSBE, 64MB RAM) |
| RouterOS atual | 6.43.7 (de 2020!) |
| Upgrade disponível | 7.18.2 |
| WAN IP (PPPoE) | 168.227.125.70/32 |
| LAN IP | 10.1.1.254/24 |
| Interface list WAN | pppoe-out1 |
| License level | 4 |
| SSH port | 22 (chave `kryonix-mikrotik` para `aura`) |
| **Tailscale** | ❌ **não suporta** (MIPSBE sem container) |

### IPs ARP `failed` (devices off)

10.1.1.240, .241, .242, .243, .248 — entradas stale que vão sumir.

## ⚠️ Pendência crítica — dispositivo `10.1.1.253`

| Item | Valor |
|---|---|
| IP | 10.1.1.253 |
| MAC | FC:3C:D7:03:1F:F9 |
| DHCP hostname | `lwip0` |

**Análise:**
- Hostname `lwip0` é típico de **LwIP stack** (ESP32/Arduino/STM32)
- MAC `FC:3C:D7:03:1F:F9` **não bate** com prefixos típicos da Huawei (Huawei usa `00:E0:FC`, `04:C0:6F`, `48:46FB`)
- Gabriel disse que **transformou o Huawei EG8145V5-V2 em AP** e que ele estaria em `10.1.1.253`
- **Conclusão provável:** o dispositivo em `.253` **NÃO é o Huawei**, é outro device (provavelmente ESP32 IoT). O Huawei está em outro IP ou está sem acesso.

**Ação recomendada:** conferir MAC do Huawei na etiqueta (embaixo ou atrás) e comparar com `FC:3C:D7:03:1F:F9`. Se diferentes, o `.253` é outro device.

## Procedimento

1. Backup das regras MikroTik:
   ```bash
   /ip firewall export file=backup-pre-glacier-ssh
   ```

2. Verificar DHCP leases, ARP, interfaces — comandos acima.

3. Listar serviços ativos MikroTik:
   ```
   telnet 23, ftp 21, www 80, ssh 22, api 8728, winbox 8291, api-ssl 8729
   ```
   **Recomendação futura:** desabilitar telnet, ftp, api não-SSL.

## Riscos

- MikroTik RouterOS 6.43.7 está desatualizado (sem updates de segurança desde 2020). Atualizar para 7.18.2 requer reboot (~1 min downtime).
- IP público compartilhado Inspiron + MikroTik (CGNAT) — hairpin NAT funciona por sorte.

## Validação

| Teste | Resultado |
|---|---|
| `ping 10.1.1.2` do Inspiron | ✅ 1.4ms |
| `nc -zv 10.1.1.254 22` | ✅ aberta |
| `nc -zv 10.1.1.254 8291` | ✅ aberta (WinBox) |
| `ssh aura@10.1.1.254` com `kryonix-mikrotik` | ✅ funciona |

## Próxima ação

- Verificar identidade real do dispositivo em `.253`
- Resolver acesso ao Huawei EG8145V5-V2 (Fase 1)

## Links relacionados

- [[04-mikrotik-inventario-e-dstnat]]
- [[06-tailscale-estado]]
- [[../02-Areas/Kryonix/canonical/Capability Matrix MikroTik]]

#rede #mikrotik #recon
