# Shell web Proxmox — patches PAM + dtach

## Objetivo

Fazer o Shell web do Proxmox (clicar `>_ Shell` no nó) **abrir terminal logado automaticamente**, sem precisar digitar usuário/senha.

## Contexto

Proxmox VE 9.x **muda o comportamento padrão do Shell web**: sempre pede credenciais (mesmo com cookie "Lembrar-me"). É hardening de segurança intencional (release notes).

Tentamos múltiplos caminhos:
1. Cookie "Lembrar-me" → não cobre Shell
2. Patch PAM `pam_succeed_if.so` → não afeta o caminho do shell (PAM service=`pvedaemon` não cobre `/bin/login`)
3. Cloudflare Access / OpenID Connect → setup longo
4. **Patch dtach no `Nodes.pm`** → ✅ **solução oficial da comunidade Proxmox**

## Procedimento final (dtach patch)

### 1. Instalar `dtach`

```bash
sudo apt install -y dtach
# Já veio como dependência no Proxmox 9.x (versão 0.9-7)
```

### 2. Backup do `Nodes.pm`

```bash
sudo cp /usr/share/perl5/PVE/API2/Nodes.pm \
        /usr/share/perl5/PVE/API2/Nodes.pm.bak.$(date +%Y%m%d)
# Exemplo: Nodes.pm.bak.20260824
```

### 3. Aplicar patch (3 substituições)

Criar script `/tmp/patch_dtach.pl`:

```perl
#!/usr/bin/perl
use strict;
use warnings;

my $file = '/usr/share/perl5/PVE/API2/Nodes.pm';
my $dtach = q{['/usr/bin/dtach', '-A', '/var/run/dtach/vzctlrootshell', '-r', 'winch', '-E', '-z', '/bin/login', '-f', 'root']};

open(my $fh, '<', $file) or die "Cannot read $file: $!";
my @lines = <$fh>;
close($fh);

my $changed = 0;
foreach my $i (0..$#lines) {
    if ($lines[$i] =~ m/cmd => \['\/bin\/login', '-f', 'root'\]/) {
        $lines[$i] =~ s|cmd => \['\/bin\/login', '-f', 'root'\]|cmd => $dtach|;
        $changed++;
    }
    elsif ($lines[$i] =~ m/\$cmd = \['\/bin\/login', '-f', 'root'\]/) {
        $lines[$i] =~ s|\$cmd = \['\/bin\/login', '-f', 'root'\]|\$cmd = $dtach|;
        $changed++;
    }
    elsif ($lines[$i] =~ m/\$cmd = \['\/bin\/login'\]/) {
        $lines[$i] =~ s|\$cmd = \['\/bin\/login'\]|\$cmd = $dtach|;
        $changed++;
    }
}

open(my $out, '>', $file) or die "Cannot write $file: $!";
print $out @lines;
close($out);

print "Total: $changed linhas alteradas\n";
```

Executar:
```bash
sudo perl /tmp/patch_dtach.pl
# Saída esperada: Total: 3 linhas alteradas
```

### 4. Conferir e reiniciar

```bash
sudo grep -n "dtach\|/bin/login" /usr/share/perl5/PVE/API2/Nodes.pm
# Deve mostrar dtach em 3 linhas

sudo systemctl restart pvedaemon
# Active: active (running) since Mon 2026-08-24 10:46:11 -04
```

### 5. Testar na GUI

1. Login com `rocha@pam` + senha + TOTP
2. Clicar `>_ Shell` no nó glacier
3. **Deve abrir terminal direto como `root@glacier`** (sem pedir login)

## Validação

| Teste | Resultado |
|---|---|
| `dtach` instalado | ✅ v0.9-7 |
| Backup `Nodes.pm.bak.20260824` | ✅ |
| 3 linhas substituídas | ✅ confirmado |
| `pvedaemon` reiniciado às 10:46:11 | ✅ |
| Shell web → root sem login | ✅ **funcionando** |

## ⚠️ Patch PAM (TENTATIVA 1 — falhou)

Adicionamos antes:
- `/etc/pam.d/pve-shell-bypass` com `pam_succeed_if.so service=pvedaemon user=rocha`
- `auth include pve-shell-bypass` em `/etc/pam.d/common-auth`

**Por que não funcionou:** o Shell web chama `/bin/login` direto via `termproxy`, **não passa pelo serviço `pvedaemon` no PAM**. Patch sem efeito.

**Manter ou reverter?** Patch não causa mal, mas é ruído. Reverter:

```bash
sudo sed -i '/auth include pve-shell-bypass/d' /etc/pam.d/common-auth
sudo rm /etc/pam.d/pve-shell-bypass
```

Recomendação: **reverter** (cleanup) — patch dtach é o suficiente.

## Por que `'root'` no patch (não `rocha`)

O patch do `zodiac` (forum.proxmox.com Active Member, 1300+ posts) troca **todas** as ocorrências de `/bin/login` por `/usr/bin/dtach ... /bin/login -f root`. O `-f root` força login como root, **independente** do usuário da GUI.

**Trocar para `rocha` requer mudar a string `'root'`, o que o zodiac classifica como "absolutely braindead stupid and insecure"** — qualquer usuário autenticado na GUI vira rocha no shell direto.

## ⚠️ Trade-offs do patch dtach (do próprio zodiac)

| Risco | Detalhe |
|---|---|
| Patch some em `apt upgrade` do pve-manager | Reaplicar sempre que atualizar |
| `/var/run/dtach/vzctlrootshell` é compartilhado | 2 usuários veem mesma sessão — perigoso em multi-user |
| Sessão **persiste** entre fechamentos de aba | Continua rodando mesmo fechando navegador |
| **Funciona há 1+ ano** (post set/2024) | Comunidade confirma |

## Próxima ação

- Reverter patch PAM (cleanup)
- Criar ADR em `02-Areas/Kryonix/canonical/` documentando a decisão
- Marcar tarefa de monitorar reaplicação em upgrades do pve-manager

## Links relacionados

- [[../02-Areas/Kryonix/canonical/ADR-006-shell-web-patch-dtach|ADR-006 — Shell web patch dtach]]
- https://forum.proxmox.com/threads/shell-access-for-oidc-user.154886/ — fonte oficial do patch
- [[02-ssh-glacier-chave-e-porta]] — SSH hardening relacionado

#proxmox #shell-web #patch #dtach #pam
