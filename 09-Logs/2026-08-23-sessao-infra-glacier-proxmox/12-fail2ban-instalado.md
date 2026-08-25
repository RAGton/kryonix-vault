# Fail2ban instalado no glacier — proteção brute-force

Data: 2026-08-25
Agente: Aura (MiniMax-M3)
Host: glacier (Proxmox 9.2.11)

## Objetivo

Instalar e configurar fail2ban no glacier pra banir IPs com tentativas falhas em SSH (porta 2224) e Proxmox web (porta 8006), usando systemd journal (já que configuramos journald em RAM na Fase 2 da sessão anterior).

## Contexto consultado

- [[00-INDEX]] — índice da sessão 2026-08-23
- [[11-gpu-passthrough-completo]] — Fase 2 configurou `journald volatile`

## Procedimento

### 1. Instalação

```bash
sudo apt install -y fail2ban
# Output: fail2ban v1.1.0 instalado
```

### 2. Configuração `/etc/fail2ban/jail.local`

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
banaction = iptables-multiport
ignoreip = 127.0.0.1/8 10.1.1.0/24 100.64.0.0/10

[sshd]
enabled = true
port = 2224
backend = systemd
journalmatch = _SYSTEMD_UNIT=ssh.service + _COMM=sshd
maxretry = 3
bantime = 86400

[pvedaemon]
enabled = true
port = 8006
backend = systemd
journalmatch = _SYSTEMD_UNIT=pvedaemon.service
maxretry = 5
bantime = 3600

[pveproxy]
enabled = true
port = 8006
backend = systemd
journalmatch = _SYSTEMD_UNIT=pveproxy.service
maxretry = 5
bantime = 3600
```

### 3. Filtros customizados

**`/etc/fail2ban/filter.d/pvedaemon.conf`:**
```ini
[Definition]
failregex = pvedaemon\[.*\]: authentication failure; rhost=<HOST> user=\S+ msg=\S+
ignoreregex =
```

**`/etc/fail2ban/filter.d/pveproxy.conf`:**
```ini
[Definition]
failregex = pveproxy\[.*\]: Failed to authenticate user.+\s+r=<HOST>
ignoreregex =
```

### 4. Restart + validação

```bash
sudo systemctl restart fail2ban
sudo fail2ban-client status
```

## Validação

| Check | Resultado |
|---|---|
| 3 jails ativos | ✅ sshd, pvedaemon, pveproxy |
| Backend systemd | ✅ journal matches funcionando |
| `fail2ban-server --version` | ✅ v1.1.0 |
| `systemctl is-enabled` | ✅ enabled (sobrevive reboot) |
| Teste de ban (IP fake) | ✅ `fail2ban-client set sshd banip 203.0.113.50` → iptables REJECT ativo |
| Desban | ✅ `fail2ban-client set sshd unbanip` → regra removida |

## Pitfalls encontrados

| Problema | Causa | Solução |
|---|---|---|
| Erro "no log file for pvedaemon" | Tentou usar `logpath = /var/log/pveproxy/pveproxy.log` que não existe | Mudar pra `backend = systemd` + `journalmatch` |
| Erro "filter.d/pveproxy not found" | Não criei o filter `pveproxy.conf` | Criar `/etc/fail2ban/filter.d/pveproxy.conf` |
| `journalctl` exige grupo `adm` ou systemd-journal | Proxmox escreve logs via pvedaemon/pveproxy mas eles não criam arquivos | Usar `journalmatch` direto |

## Próxima ação

- [ ] Testar ban real (3 tentativas erradas de SSH pra confirmar regex funcionando)
- [ ] Configurar Cloudflare Tunnel pra esconder IP origem (diminui superfície ataque)
- [ ] Adicionar jail pra Tailscale SSH também

## Links relacionados

- [[11-gpu-passthrough-completo]] — Fase 2: journald em RAM
- [[../../01-MOCs/MOC - Sessão 2026-08-23 - Infra Glacier Proxmox]]
- https://wiki.debian.org/fail2ban

#fail2ban #segurança #brute-force #ssh #proxmox #iptables
