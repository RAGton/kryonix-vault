# MikroTik — inventário + dst-nat WAN:22022/28006

## Objetivo

Configurar dst-nat (port-forward) na MikroTik RB750GL para expor o glacier (LAN) pela WAN com portas altas random-like (22022 para SSH, 28006 para Proxmox web).

## Contexto

- MikroTik RB750GL (MIPSBE, 64MB, sem container, sem Tailscale nativo)
- RouterOS 6.43.7 (de 2020, upgrade disponível 7.18.2)
- WAN via PPPoE (IP `168.227.125.70`)
- LAN via bridge (`ether2..ether5`, IP `10.1.1.254/24`)

## Procedimento

### 1. Backup das regras existentes

```bash
ssh -i ~/.ssh/kryonix-mikrotik aura@10.1.1.254 \
  '/ip firewall export file=backup-pre-glacier-ssh'
# Arquivo salvo em /file list como backup-pre-glacier-ssh.rsc
```

### 2. Criar dst-nat (chain=dstnat)

```bash
# SSH glacier (WAN:22022 → LAN:2224)
/ip firewall nat add chain=dstnat \
    dst-port=22022 protocol=tcp \
    in-interface=pppoe-out1 \
    action=dst-nat \
    to-addresses=10.1.1.2 to-ports=2224 \
    comment="glacier SSH 22022->2224" \
    place-before=0

# Proxmox web (WAN:28006 → LAN:8006)
/ip firewall nat add chain=dstnat \
    dst-port=28006 protocol=tcp \
    in-interface=pppoe-out1 \
    action=dst-nat \
    to-addresses=10.1.1.2 to-ports=8006 \
    comment="proxmox web 28006->8006" \
    place-before=0
```

### 3. Liberar chain=forward

```bash
# SSH glacier
/ip firewall filter add chain=forward \
    dst-address=10.1.1.2 dst-port=2224 protocol=tcp \
    in-interface=pppoe-out1 \
    connection-state=new \
    action=accept \
    comment="permit glacier SSH forward" \
    place-before=0

# Proxmox web
/ip firewall filter add chain=forward \
    dst-address=10.1.1.2 dst-port=8006 protocol=tcp \
    in-interface=pppoe-out1 \
    connection-state=new \
    action=accept \
    comment="permit proxmox web forward" \
    place-before=0
```

### 4. Liberar chain=input (CRÍTICO)

A RB750GL tem regra default `chain=input action=drop in-interface-list=!LAN`, que dropa conexões da WAN. Mesmo com dst-nat, **a chain=input processa ANTES** se o dst original for o IP da MikroTik (que tem 168.227.125.70 via PPPoE).

```bash
# SSH
/ip firewall filter add chain=input \
    dst-port=22022 protocol=tcp \
    in-interface=pppoe-out1 \
    connection-state=new \
    action=accept \
    comment="INPUT accept glacier SSH 22022" \
    place-before=7

# Proxmox web
/ip firewall filter add chain=input \
    dst-port=28006 protocol=tcp \
    in-interface=pppoe-out1 \
    connection-state=new \
    action=accept \
    comment="INPUT accept proxmox web 28006" \
    place-before=7
```

⚠️ **Importante:** `place-before=7` (a regra #7 é o drop `!LAN`). Se colocar `place-before=0`, fica ANTES do drop invalid, mas ainda DEPOIS do drop !LAN. **Tem que ser place-before=7.**

## Regras finais aplicadas

| Chain | # | Comentário |
|---|---|---|
| dstnat | 0 | glacier SSH 22022→2224 |
| dstnat | 1 | proxmox web 28006→8006 |
| dstnat | 2 | (defconf) masquerade |
| input | 16 | INPUT accept glacier SSH 22022 |
| input | 17 | INPUT accept proxmox web 28006 |
| input | 7 | (defconf) drop all not coming from LAN |
| forward | 7 | permit glacier SSH forward |
| forward | 8 | permit proxmox web forward |
| forward | 6 | (defconf) drop all from WAN not DSTNATed |

## Validação

| Teste | Resultado |
|---|---|
| `nc -zv 168.227.125.70 22022` (Inspiron → WAN) | ✅ succeeded |
| `nc -zv 168.227.125.70 28006` (Inspiron → WAN) | ✅ succeeded |
| `ssh -i ~/.ssh/glacier-access -p 22022 rocha@168.227.125.70` | ✅ entra sem senha |
| `https://168.227.125.70:28006` (navegador) | ✅ tela de login Proxmox |
| Teste de fora (4G celular) | ⏸️ pendente |

## Pitfalls

| Sintoma | Causa real | Solução |
|---|---|---|
| `Connection refused` na WAN mesmo com dst-nat | Chain=input drop `!LAN` bloqueia antes | Adicionar regra input place-before=7 |
| `place-before=0` não funciona como esperado | Ordem importa, antes do DROP !LAN (#7), não antes do DROP invalid (#4) | Usar `place-before=7` |
| SSH multi-linha via heredoc falha com "expected end of command" | RouterOS não aceita `\` no fim de linha | Enviar comandos 1 por linha |

## Próxima ação

- Atualizar RouterOS 6.43.7 → 7.18.2 (reboot planejado)
- Testar de fora (4G)
- Fechar portas após Cloudflare Tunnel estiver no ar

## Links relacionados

- [[01-investigacao-rede]] — topologia MikroTik
- [[02-ssh-glacier-chave-e-porta]] — sshd escutando em 2224
- [[../02-Areas/Kryonix/canonical/Capability Matrix MikroTik]]

#mikrotik #dstnat #firewall #port-forward
