# Tailscale — estado na sessão 2026-08-23

## Objetivo

Identificar e documentar o estado do Tailscale no glacier após a reformatação Proxmox.

## Contexto

- glacier foi reformatado (NixOS antigo → Proxmox fresh)
- Tailscale estava rodando na instalação NixOS anterior (visto em `tailscale status` inicial como `glacier active; offline 9d`)
- Esperava-se que Tailscale tivesse morrido com a formatação
- **Surpresa: Tailscale está rodando no Proxmox fresh com IP `100.110.225.98`**

## Procedimento

### 1. Verificar Tailscale no Inspiron (já instalado)

```bash
tailscale status
```

**Saída:**
```
100.64.103.97   inspiron     RAGton@  linux    -
100.79.76.36    edge-50-pro  RAGton@  android  offline, last seen 11d ago
100.112.137.46  glacier      RAGton@  linux    active; relay "sao"; offline, last seen 9d ago
```

### 2. Verificar Tailscale no glacier (via SSH pós-reinstalação)

```bash
ssh -i ~/.ssh/glacier-access rocha@10.1.1.2 'hostname -I'
```

**Saída:**
```
10.1.1.2 100.110.225.98 fd7a:115c:a1e0::583a:e163
```

**Tailscale IP:** `100.110.225.98`
**Tailscale IPv6:** `fd7a:115c:a1e0::583a:e163`
**Tailnet:** `tail682be6.ts.net` (vista no `/etc/resolv.conf` do Inspiron)

## ⚠️ Observação

- O IP `100.110.225.98` é diferente do `100.112.137.46` que aparecia no status inicial — significa que **Tailscale foi reinstalado/reautenticado** após a formatação Proxmox
- Como Proxmox fresh não tem Tailscale pré-instalado, **alguém (ou algum script) reinstalou após a formatação**
- Provavelmente durante o `apt upgrade` ou como parte do setup que ainda não identificamos

## Tailscale SSH

Tentativa de `ssh rocha@100.110.225.98`:

```
# Tailscale SSH requires an additional check.
# To authenticate, visit: https://login.tailscale.com/a/l19e815523a968d
```

**Significa:** Tailscale SSH está habilitado no glacier, mas o nó precisa ser **aprovado no admin console** antes de aceitar conexões SSH via tailnet.

## Pendência

| Item | Status |
|---|---|
| Tailscale IP `100.110.225.98` confirmado | ✅ |
| Tailscale SSH bloqueado esperando aprovação admin | ⏸️ |
| Subnet route `10.1.1.0/24` anunciada? | ❌ não — Tailscale não tem rota pra LAN ainda |
| Proxmox como nó anunciante de subnet route | ⏸️ requer config manual |

## Próxima ação

- Aprovar nó glacier no admin console
- Decidir se glacier anuncia subnet route 10.1.1.0/24 para outros devices na tailnet acessarem a LAN

## Links relacionados

- [[01-investigacao-rede]] — MikroTik não roda Tailscale (MIPSBE)
- [[../02-Areas/Kryonix/canonical/Capability Matrix MikroTik]]

#tailscale #vpn #subnet-route
