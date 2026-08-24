# SSH glacier — chave + porta 2224 + hardening

## Objetivo

Configurar acesso SSH do Inspiron para o glacier (que foi reformatado como Proxmox) usando chave pública ed25519, porta não-padrão 2224, sem login por senha.

## Contexto

- glacier foi reformatado com Proxmox VE 9.2.11 fresco
- IP LAN `10.1.1.2`, IP público `168.227.125.70` (via PPPoE MikroTik)
- IP público antigo (`168.227.127.73`) ficou obsoleto após reformatação
- Tailscale estava rodando no glacier da instalação NixOS anterior — morreu na formatação

## Procedimento

### 1. Gerar par de chaves no Inspiron

```bash
ssh-keygen -t ed25519 -C "rocha@inspiron-glacier-access-$(date +%Y%m%d)" \
  -f ~/.ssh/glacier-access -N ""
```

**Saída:**
```
SHA256:ox6glWjFZ3EdtZt08rWWi7FVIhFX2DetJhe2a/11Qu8
```

### 2. Endurecer sshd_config no glacier (acesso root via console)

Acervo: `/etc/ssh/sshd_config` (root via Proxmox GUI Console):

```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d)

cat >> /etc/ssh/sshd_config <<'EOF'

# Glacier/Proxmox hardening 2026-08-23
Port 2224
PasswordAuthentication no
ChallengeResponseAuthentication no
PermitRootLogin prohibit-password
PubkeyAuthentication yes
EOF

/usr/sbin/sshd -t && echo "✓ sshd_config OK"
```

### 3. Instalar pubkey no rocha Linux

```bash
mkdir -p /home/rocha/.ssh
cat > /home/rocha/.ssh/authorized_keys <<'KEY'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWcb9UJn0f9hk2B5ak1WLttEY+HXXTPdc1BAfcU40CD rocha@inspiron-glacier-access-20260823
KEY
chown -R rocha:rocha /home/rocha/.ssh
chmod 700 /home/rocha/.ssh
chmod 600 /home/rocha/.ssh/authorized_keys
```

### 4. Liberar 2224 no firewall local

```bash
iptables -C INPUT -p tcp --dport 2224 -j ACCEPT 2>/dev/null || \
  iptables -I INPUT -p tcp --dport 2224 -j ACCEPT -m comment --comment "SSH hardened"
```

### 5. Reiniciar sshd (preserva sessão atual)

```bash
systemctl reload ssh
```

### 6. Atualizar `~/.ssh/config` do Inspiron

```text
Host glacier
  HostName 168.227.125.70
  User rocha
  Port 22022                  ← porta EXTERNA (dst-nat MikroTik)
  IdentityFile ~/.ssh/glacier-access
  IdentitiesOnly yes

Host glacier-lan
  HostName 10.1.1.2
  User rocha
  Port 2224                   ← porta INTERNA
  IdentityFile ~/.ssh/glacier-access
  IdentitiesOnly yes
```

⚠️ **Arquivo `~/.ssh/config` é protegido contra auto-write pelo Hermes.** Editar manualmente (não via tool).

## Validação

| Teste | Resultado |
|---|---|
| `ssh -i ~/.ssh/glacier-access -p 2224 rocha@10.1.1.2` (LAN) | ✅ entra sem senha |
| `ssh glacier` (WAN via dst-nat) | ✅ entra sem senha |
| `ssh glacier-lan` (LAN) | ✅ entra sem senha |
| `whoami` após login | `rocha` |
| `hostname -I` após login | `10.1.1.2 100.110.225.98 fd7a:115c:a1e0::583a:e163` |

## Pitfalls encontrados

| Problema | Causa | Solução |
|---|---|---|
| SSH pediu senha após reload | Authorized_keys não estava no `/home/rocha/.ssh/` | Reinstalar manualmente via console root |
| sshd -t reclamou "no hostkeys available" | Era rodando como `rocha` (sem permissão) | Rodar como root, host keys existem |
| Connection refused WAN:22022 | dst-nat não tinha regras chain=input | Adicionar regras `chain=input` antes do drop !LAN |
| `/etc/ssh/sshd_config` auto-write bloqueado | Hermes protege arquivos sensíveis | Editar manualmente no Inspiron |

## Próxima ação

- Backup do `sshd_config.bak.YYYYMMDD` (rollback)
- Monitorar logs de auth

## Links relacionados

- [[04-mikrotik-inventario-e-dstnat]] — dst-nat que expõe WAN:22022 → LAN:2224
- [[05-shell-web-patches]] — patches complementares
- [[../02-Areas/Kryonix/canonical/SSH Hardening Playbook]]

#ssh #glacier #chave-publica #hardening
