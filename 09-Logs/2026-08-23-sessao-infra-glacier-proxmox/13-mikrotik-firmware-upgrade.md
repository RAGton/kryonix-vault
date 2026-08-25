# Upgrade firmware RouterBoard RB750GL: 6.43.7 → 7.18.2

Data: 2026-08-25
Agente: Aura (MiniMax-M3)
Host: RB750GL MikroTik (10.1.1.254 / 168.227.125.70 via PPPoE)

## Objetivo

Atualizar firmware do RouterBoard (NOR flash) de 6.43.7 para 7.18.2, pareando com a versão do RouterOS que já estava em 7.18.2 (versão já tinha atualizado em algum momento anterior, mas o firmware do routerboard ficou desatualizado).

## Contexto consultado

- [[00-INDEX]] — índice da sessão 2026-08-23
- [[04-mikrotik-inventario-e-dstnat]] — dst-nat WAN:22022/28006 → glacier

## Estado pré-upgrade

| Item | Valor |
|---|---|
| Modelo | RB750GL (ar7240, MIPSBE) |
| RouterOS version | **7.18.2** (já atualizado em momento anterior) |
| RouterBoard firmware | **6.43.7** (de 2020, desatualizado) |
| Factory firmware | 3.19 |
| Memória | 24 MiB livre de 64 |
| Uptime | 1w15h18m (estável) |
| License | level 4 |
| Regra dst-nat | WAN:22022 → 10.1.1.2:2224 (SSH glacier) ✅ |
| Regra dst-nat | WAN:28006 → 10.1.1.2:8006 (Proxmox web) ✅ |

## Procedimento

### 1. Backup final pré-upgrade

```bash
/ip firewall export file=backup-pre-firmware-upgrade
```

Arquivo salvo em `/file list` na MikroTik.

### 2. Health check pré-reboot

```bash
/ping 8.8.8.8 count=3
# sent=3 received=3 packet-loss=0% min-rtt=23ms941us
```

Internet funcionando normalmente.

### 3. Listar DHCP leases ativos (devices na LAN)

```
10.1.1.250  echoshow-9d76500a252a0490   bound
10.1.1.249  Electrolux_Appliance       bound
10.1.1.253  lwip0                      bound
10.1.1.248  (desconhecido)             bound
10.1.1.242  moto-g56-5G                bound
10.1.1.247  Galaxy-A21s-de-ivonete     bound
```

6 devices reconectam após reboot (sem perda significativa).

### 4. Download do firmware

```bash
/system routerboard upgrade
```

**Output:**
```
;;; Firmware upgraded successfully, please reboot for changes to take effect!
       routerboard: yes
             model: RB750GL
     serial-number: 467B04F11B7E
      firmware-type: ar7240
   factory-firmware: 3.19
     current-firmware: 6.43.7
     upgrade-firmware: 7.18.2
```

Firmware 7.18.2 foi baixado e gravado em NOR flash, mas só aplica após reboot.

### 5. Reboot

```bash
/system reboot
```

Conexão SSH caiu imediatamente (esperado).

**Downtime:** ~60 segundos (downtime real medido pelo ping pós-reboot).

### 6. Validação pós-reboot

| Check | Resultado |
|---|---|
| Uptime | 1m10s ✅ |
| RouterOS version | 7.18.2 ✅ |
| RouterBoard firmware | **7.18.2** ✅ (mudou de 6.43.7) |
| Memória livre | 27.8 MiB (melhor que antes) |
| Ping 8.8.8.8 | 3/3, 23ms ✅ |
| DHCP leases | 6 devices reconectaram ✅ |
| dst-nat SSH (22022) | ✅ Mantida |
| dst-nat Proxmox (28006) | ✅ Mantida |
| Input accept NEW SSH | ✅ Mantida |
| Input accept NEW Proxmox | ✅ Mantida |
| SSH WAN → glacier | ✅ Funcionando |

## Impacto

### Durante o reboot (60 segundos)

| Afetado | Duração |
|---|---|
| Internet em casa | ~60s |
| SSH pro glacier via WAN:22022 | ~60s (dst-nat MikroTik down) |
| VM 100 do glacier | Sem rede (LAN down), mas continua rodando |
| Inspiron do trabalho | Sem acesso à casa |
| Proxmox web LAN | ✅ Funciona (não depende da MikroTik) |

### Após o reboot

Tudo voltou ao normal automaticamente — config persiste em flash, firmware atualiza bootloader.

## Validação final

```bash
# Estado final MikroTik
/system routerboard print
       current-firmware: 7.18.2    ✅
       upgrade-firmware: 7.18.2    ✅

# Regras dst-nat persistem (config não é afetada por firmware)
/ip firewall nat print
0    chain=dstnat to-addresses=10.1.1.2 to-ports=2224 in-interface=pppoe-out1 dst-port=22022
1    chain=dstnat to-addresses=10.1.1.2 to-ports=8006 in-interface=pppoe-out1 dst-port=28006
2    chain=srcnat action=masquerade out-interface-list=WAN
```

## Próxima ação

- [ ] Verificar se algum device IoT perdeu config (lwip0, Electrolux, etc)
- [ ] Atualizar documentação: MikroTik agora roda RouterOS + firmware 7.18.2
- [ ] Considerar upgrade similar em outros devices MikroTik (se houver)

## Links relacionados

- [[00-INDEX]] — índice da sessão
- [[04-mikrotik-inventario-e-dstnat]] — dst-nat e regras que persistiram
- https://help.mikrotik.com/docs/spaces/ROS/pages/116130110/RouterOS+release+notes — release notes oficiais

#mikrotik #routerboard #upgrade #firmware #RB750GL #routeros-7
