# Validações e testes — sessão 2026-08-23

## Objetivo

Documentar todas as validações executadas durante a sessão, com comandos e resultados.

## 🔬 Validações SSH

### V1. LAN:2224 com pubkey (glacier fresh)

```bash
ssh -i ~/.ssh/glacier-access -p 2224 -o BatchMode=yes rocha@10.1.1.2 'whoami && hostname -I'
```

**Esperado:** `rocha` + `10.1.1.2 ...`
**Resultado:** ✅ `rocha` + `10.1.1.2 100.110.225.98 fd7a:115c:a1e0::583a:e163`

### V2. WAN:22022 com pubkey (via dst-nat MikroTik)

```bash
ssh -i ~/.ssh/glacier-access -p 22022 -o BatchMode=yes rocha@168.227.125.70 'whoami && hostname -I'
```

**Esperado:** `rocha` + IPs do glacier
**Resultado:** ✅ `rocha` + `10.1.1.2 100.110.225.98 fd7a:115c:a1e0::583a:e163`

### V3. WAN:22022 com `ssh glacier` (atalho via config)

```bash
ssh glacier 'whoami && hostname -I'
```

**Resultado:** ✅ entra direto sem pedir nada.

### V4. Tailscale SSH (100.110.225.98)

```bash
ssh rocha@100.110.225.98
```

**Resultado:** ❌ `Tailscale SSH requires an additional check. Visit: https://login.tailscale.com/a/l19e...`
**Status:** Aguardando aprovação do nó no admin console.

## 🔬 Validações MikroTik

### V5. Backup `.rsc`

```bash
ssh -i ~/.ssh/kryonix-mikrotik aura@10.1.1.254 \
  '/ip firewall export file=backup-pre-glacier-ssh'
```

**Resultado:** ✅ `backup-pre-glacier-ssh.rsc` salvo em `/file list` (1580 bytes).

### V6. dst-nat regras aplicadas

```bash
ssh -i ~/.ssh/kryonix-mikrotik aura@10.1.1.254 '/ip firewall nat print'
```

**Resultado:** ✅ 2 regras dst-nat (SSH 22022→2224, Proxmox 28006→8006) + 1 masquerade.

### V7. chain=input regras

```bash
ssh -i ~/.ssh/kryonix-mikrotik aura@10.1.1.254 '/ip firewall filter print where chain=input'
```

**Resultado:** ✅ 2 regras input (accept NEW) ANTES do drop !LAN.

### V8. chain=forward regras

```bash
ssh -i ~/.ssh/kryonix-mikrotik aura@10.1.1.254 '/ip firewall filter print where chain=forward'
```

**Resultado:** ✅ 2 regras forward (accept NEW) ANTES do drop not DSTNATed.

### V9. nc brute WAN:22022

```bash
nc -zv -w 3 168.227.125.70 22022
```

**Resultado:** ✅ `Connection to 168.227.125.70 22022 port [tcp/*] succeeded!`

### V10. nc brute WAN:28006

```bash
nc -zv -w 3 168.227.125.70 28006
```

**Resultado:** ✅ `Connection to 168.227.125.70 28006 port [tcp/*] succeeded!`

### V11. Hairpin NAT (Inspiron → WAN pública)

```bash
ssh -i ~/.ssh/glacier-access -p 22022 -o BatchMode=yes rocha@168.227.125.70 'whoami'
```

**Resultado:** ✅ funciona (hairpin NAT acontece por sorte — Inspiron sai pela MikroTik).

### V12. Tailscale SSH (ainda pendente)

⏸️ Aguardando aprovação do nó glacier no admin console.

## 🔬 Validações Proxmox

### V13. Web GUI com rocha@pam

```
https://10.1.1.2:8006 → login rocha@pam + senha + TOTP → OK
https://168.227.125.70:28006 → mesma tela → OK
```

**Resultado:** ✅ Login funciona com MFA em ambas portas.

### V14. Permissões Administrator

```bash
pveum acl list
```

**Saída:**
```
path  roleid        type  ugid       propagate
/     Administrator user  rocha@pam  1
```

**Resultado:** ✅ Administrator em `/` com propagação.

### V15. Grupo admins

```bash
pveum group list
```

**Saída:**
```
groupid  comment                users
admins   Proxmox administrators rocha@pam
```

**Resultado:** ✅ rocha@pam no grupo admins.

### V16. Shell web com patch dtach

**Procedimento:**
1. Login na GUI como `rocha@pam`
2. Click em `>_ Shell` no nó glacier
3. **Esperado:** Terminal direto como `root@glacier`

**Resultado:** ✅ **Terminal abriu direto como `root@glacier`** (sem pedir login).

## 🔬 Validações Pendentes

| # | Validação | Status |
|---|---|---|
| V17 | dst-nat WAN testado de **fora** (4G) | ⏸️ |
| V18 | Reboot glacier com kernel 7.0.14-12 + microcode AMD | ⏸️ |
| V19 | RouterOS 6.43.7 → 7.18.2 | ⏸️ |
| V20 | Hairpin NAT origem real (4G do celular) | ⏸️ |

## Próxima ação

- Marcar V17 como primeira validação pendente
- Não marcar sessão como encerrada até V17-V20 serem executadas

## Links relacionados

- [[02-ssh-glacier-chave-e-porta]] — origem das validações SSH
- [[04-mikrotik-inventario-e-dstnat]] — origem das validações MikroTik
- [[05-shell-web-patches]] — validação do dtach

#validacoes #testes #evidencias
