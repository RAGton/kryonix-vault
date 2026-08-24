# Proxmox — instalação, usuários, MFA

## Objetivo

Instalar Proxmox VE 9.2.11 fresh no glacier, criar usuário admin `rocha@pam`, configurar MFA (TOTP), ACL Administrator em `/`.

## Contexto

- glacier formatado, Proxmox 9.2.11 instalado do zero
- Sistema base Debian 13 (trixie) + 131 pacotes atualizados via `apt upgrade` (incluindo `pve-manager`, kernel 7.0.14-12, microcode AMD, ZFS 2.4.3)
- `sudo` não vem instalado por padrão → instalar manualmente
- `polkit` (pkttyagent) ausente → causa `Failed to execute /usr/bin/pkttyagent` em alguns comandos

## Procedimento

### 1. Após instalação, instalar sudo

```bash
su -
apt install -y sudo
usermod -aG sudo rocha
```

### 2. Atualizar sistema (131 pacotes)

```bash
apt update
apt upgrade -y
# reinicialização pendente: kernel 7.0.14-12-pve, microcode AMD
```

⚠️ **NÃO reiniciar ainda** — kernel/microcode ficam em standby até o próximo reboot.

### 3. Criar `rocha@pam` no Proxmox (decisão importante)

`rocha@pve` é conta do banco interno Proxmox.
`rocha@pam` autentica via `/etc/shadow` do Linux, **mais flexível** pra automação.

```bash
sudo pveum userdel rocha@pve    # remove versão antiga
sudo pveum useradd rocha@pam -comment "Gabriel Rocha - admin"
sudo pveum passwd rocha@pam     # interativo, digitar 2x
sudo pveum groupadd admins -comment "Proxmox administrators" 2>/dev/null
sudo pveum usermod rocha@pam -group admins
sudo pveum aclmod / -user rocha@pam -role Administrator
```

### 4. Ativar MFA (TOTP)

Na GUI: **Datacenter → Permissions → Users → rocha@pam → TFA → Add → TOTP**

Escanear QR code com app authenticator (Bitwarden Authenticator, Google Authenticator, Authy).

Configurar política MFA obrigatória:
- **Datacenter → Permissions → Users → rocha@pam → TFA → Set TFA Policy → Required (realm=pam)**

### 5. Política de cookies "Lembrar-me"

A sessão web dura 14 dias. Marcar checkbox "Lembrar-me" no login.

⚠️ **Limitação Proxmox 9.x:** Shell web pede login separada mesmo com cookie válido.

## Validação

| Teste | Resultado |
|---|---|
| `pveum user list` mostra `rocha@pam` no realm `pam` | ✅ |
| `pveum acl list` mostra `path=/ roleid=Administrator user=rocha@pam` | ✅ |
| `pveum group list admins` mostra `users=rocha@pam` | ✅ |
| Login GUI com `rocha@pam` + senha + TOTP | ✅ |
| Cookie "Lembrar-me" dura 14 dias | ✅ |
| Shell web via xterm.js pede login mesmo com cookie | ❌ (limitação Proxmox 9.x) |

## ⚠️ Decisões e trade-offs

| Decisão | Por quê |
|---|---|
| `rocha@pam` em vez de `rocha@pve` | PAM bridge = mais controle, mesmo usuário Linux |
| `PasswordAuthentication no` no sshd | Bloqueia brute-force SSH |
| MFA TOTP obrigatório | Proteção contra senha vazada |
| Portas 8006/2224 expostas via MikroTik dst-nat | Resolvido por portas altas random-like |

## Pitfalls

| Sintoma | Causa real | Solução |
|---|---|---|
| `passwd: user 'rocha' does not exist` | `rocha@pve` é conta Proxmox, não Linux | Criar `rocha` em `/etc/passwd` via `useradd` |
| `pveum passwd rocha@pve` pede senha mas login falha | Senha Proxmox não é a senha do `/etc/shadow` | Usar `pam` realm |
| `Failed to execute /usr/bin/pkttyagent` | `polkit` não vem instalado | Ignorar (cosmético) ou instalar `polkitd` |
| `sudo: command not found` | Proxmox fresh não tem sudo | `apt install sudo` |
| `Permission denied` em `/etc/ssh/` como `rocha` | Arquivos sshd são `root:root 600` | `sudo` ou virar root |

## Próxima ação

- Ativar Cloudflare Tunnel (esconder IP público)
- Atualizar MikroTik RouterOS 6.43.7 → 7.18.2

## Links relacionados

- [[02-ssh-glacier-chave-e-porta]] — SSH hardening
- [[05-shell-web-patches]] — Shell web sem pedir login
- [[../02-Areas/Kryonix/canonical/Proxmox User@realm vs Linux PAM]]

#proxmox #autenticacao #mfa #totp #pam
