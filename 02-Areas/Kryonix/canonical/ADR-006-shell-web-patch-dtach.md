# ADR-006 — Shell web Proxmox sem pedir login via dtach patch

**Status:** Aceito
**Data:** 2026-08-24
**Decisor:** Gabriel (após análise da comunidade Proxmox)

## Contexto

Proxmox VE 9.x mudou o comportamento padrão do Shell web (`>_ Shell` no nó): sempre pede credenciais separadas, mesmo com cookie "Lembrar-me" ativo. É hardening de segurança intencional (release notes oficiais Proxmox 9.0).

Tentamos em ordem:
1. ❌ Cookie "Lembrar-me" — não cobre Shell
2. ❌ Patch PAM `pam_succeed_if.so` — `/bin/login` chamado via termproxy não passa pelo serviço `pvedaemon` no PAM
3. ❌ Cloudflare Access / OpenID Connect — setup longo, Gabriel queria solução mais rápida
4. ✅ **Patch dtach no `Nodes.pm` da comunidade Proxmox** — validado por `zodiac` (Active Member, 1300+ posts no forum oficial)

## Decisão

Aplicar patch do `zodiac` no arquivo `/usr/share/perl5/PVE/API2/Nodes.pm`, substituindo as **3 ocorrências** de `/bin/login` por wrapper `dtach` que abre sessão persistente sem pedir credenciais:

```diff
--- Nodes.pm.orig
+++ Nodes.pm
@@ -977,7 +977,7 @@
 my $shell_cmd_map = {
     'login' => {
-       cmd => [ '/bin/login', '-f', 'root' ],
+       cmd => [ '/usr/bin/dtach', '-A', '/var/run/dtach/vzctlrootshell', '-r', 'winch', '-E', '-z', '/bin/login', '-f', 'root' ],
     },
```

## Consequências

### Positivas

- Shell web abre direto, sem prompt de login (UX melhor)
- Sessão persiste entre fechamentos de aba (debugging remoto mais fácil)
- Patch validado pela comunidade Proxmox há 1+ ano
- Solução **oficial** (moderadores do fórum aprovaram)

### Negativas / Trade-offs

- ⚠️ **Patch some a cada `apt upgrade` do pve-manager** — reaplicar manualmente
- ⚠️ Sessão `dtach` é **compartilhada** entre usuários — perigoso em multi-user; OK para single-user caseiro
- ⚠️ Shell loga como **root**, não como `rocha@pam` — limitação intencional do patch (mais seguro)
- ⚠️ Modifica arquivo do sistema (`/usr/share/perl5/PVE/API2/Nodes.pm`) — fora do gerenciador de pacotes
- ⚠️ Não é "oficial Proxmox GmbH" — é da comunidade

## Alternativas consideradas

| Alternativa | Por que rejeitada |
|---|---|
| Aceitar prompt extra no Shell | Gabriel rejeitou explicitamente |
| Cloudflare Access | Setup 1h, requer domínio próprio |
| OpenID Connect self-hosted | Setup 2-3h, requer Keycloak/Authentik |
| Patch PAM `pam_succeed_if` | Testado, não funciona (não cobre termproxy) |
| Mudar `-f root` pra `-f rocha` | Zodiac classifica como "braindead stupid and insecure" |
| Tailscale SSH | Requer aprovação admin, ainda pendente |

## Implementação

- Script: `/tmp/patch_dtach.pl` (ver [[../../09-Logs/2026-08-23-sessao-infra-glacier-proxmox/05-shell-web-patches|05-shell-web-patches]])
- Backup: `/usr/share/perl5/PVE/API2/Nodes.pm.bak.YYYYMMDD`
- Após patch: `systemctl restart pvedaemon`

## Reversão

```bash
sudo cp /usr/share/perl5/PVE/API2/Nodes.pm.bak.YYYYMMDD \
        /usr/share/perl5/PVE/API2/Nodes.pm
sudo systemctl restart pvedaemon
```

## Monitoramento

Criar lembrete/tarefa para reaplicar patch após cada `apt upgrade` do `pve-manager`:

```bash
# Após apt upgrade do Proxmox, conferir se patch ainda está:
grep -c "dtach" /usr/share/perl5/PVE/API2/Nodes.pm
# Deve retornar >= 3. Se retornar 0, reaplicar.
```

## Referências

- Forum thread: https://forum.proxmox.com/threads/shell-access-for-oidc-user.154886/
- Autor do patch: `zodiac` (Active Member, 1300+ posts)
- Sessão documentada: [[../../09-Logs/2026-08-23-sessao-infra-glacier-proxmox/05-shell-web-patches]]

## Tags

#adr #proxmox #shell-web #dtach #patch
