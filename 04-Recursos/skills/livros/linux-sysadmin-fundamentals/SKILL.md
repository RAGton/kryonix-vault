---
title: linux-sysadmin-fundamentals
type: skill
status: ativo_revisao_pendente
purpose: Aplicar fundamentos de administração Linux e sysadmin em servidores e máquinas do dia-a-dia
validade: revisao_humana_pendente
tipo: skill
projeto: kryonix
componente: linux-ops
fonte_verdade: livro (Guia prático do servidor Linux, Começando com o Linux, Casa do Código)
confianca: media
rag: baixo_peso
graph: true
validado_em: 2026-06-20
operation_mode: inspiron-local-hermes-openrouter
author: aura
source_book: "Guia prático do servidor Linux (Casa do Código), Começando com o Linux (Casa do Código)"
source_path: 04-Recursos/livros/
tags: [kryonix, skill, linux, sysadmin, server, books]
---

# linux-sysadmin-fundamentals

## Objetivo

Aplicar fundamentos de administração Linux em máquinas Inspiron/Glacier e em servidores em geral, baseado em 2 livros: **Guia prático do servidor Linux** (CdC) e **Começando com o Linux** (CdC).

## Resumo

Os 2 livros cobrem: inicialização, FHS, editor vim, shell script, redes básicas, particionamento, LVM, quotas, hardening, SSH, NFS, RAID, Samba, Apache, proxy. A skill condensa em operações do dia-a-dia relevantes para o Kryonix (NixOS com foco server e desktop).

> **⚠️ Amostragem parcial** — Esta skill é derivada de amostragem limitada (apenas 15 páginas por livro + metadados via `pdfinfo`) e consolidação de múltiplas fontes. **NÃO é verdade operacional do Kryonix.** Requer validação prática em uso real antes de ser promovida para confiança alta. Use como checklist orientativo; para decisão crítica, consulte o livro original.

## Quando usar

- Ao configurar SSH no Inspiron/Glacier.
- Ao particionar disco (antes de disko).
- Ao configurar LVM para storage persistente.
- Ao compartilhar arquivos entre máquinas (NFS, Samba).
- Ao fazer hardening de servidor.
- Ao debugar serviço (systemd, journalctl).

## Quando não usar

- Não serve para configuração declarativa NixOS (usar skills NixOS-específicas).
- Não serve para kernel custom (avançado).

## Princípios-chave consolidados

### FHS — hierarquia de arquivos

```txt
/bin         → binários essenciais do sistema
/sbin        → binários administrativos
/etc         → configuração (arquivos de texto)
/home        → dados de usuários
/var         → dados variáveis (logs, spool)
/tmp         → temporários
/usr         → arquivos de usuário (aplicações)
/opt         → pacotes adicionais auto-contidos
/proc        → virtual fs do kernel
/sys         → virtual fs de dispositivos
/boot        → kernel, initramfs, bootloader
/dev         → devices (discos, terminais)
/run         → runtime data (desde systemd)
/srv         → dados servidos (web, ftp)
/mnt /media  → mount points temporários
```

### Comandos essenciais

```txt
Sistema:
  uname -a                  → info kernel
  uptime                    → uptime e load
  whoami                    → usuário atual
  sudo <cmd>                → exec como root
  systemctl status <serv>   → status de serviço
  journalctl -xe            → logs do sistema

Arquivos:
  ls -la                    → listar com detalhes
  cd, pwd                   → navegar
  cp, mv, rm                → copiar, mover, remover
  mkdir, rmdir              → criar/remover diretórios
  cat, less, head, tail     → ver conteúdo
  find, locate              → procurar arquivos
  grep, awk, sed            → filtrar/processar texto

Permissões:
  chmod 755 arquivo          → permissões numéricas
  chown user:group arquivo   → trocar dono
  umask                      → permissões padrão

Processos:
  ps aux                     → listar processos
  top, htop                  → monitorar em tempo real
  kill <pid>                 → matar processo
  killall <name>             → matar por nome

Rede:
  ip addr, ip route          → configuração de rede
  ping, curl, wget           → testar conectividade
  ss -tlnp                   → portas abertas
  nmap                       → scan de rede avançado
```

### Vim (básico produtivo)

```txt
Modos:   normal (ESC), insert (i), visual (v), command (:)
Navegar: h, j, k, l (esq, baixo, cima, dir)
Editar:  yy = copiar linha; dd = deletar linha; p = colar
Salvar:  :w
Sair:    :q  (ou :q! para forçar)
Salvar+sair: :wq  ou  :x
Busca:   /termo (n para próxima, N para anterior)
```

### Shell script (básico)

```bash
#!/usr/bin/env bash
set -euo pipefail     # segurança: falha em erro, variáveis não-definidas, pipe

# variáveis
NOME="mundo"
echo "Olá, $NOME"    # interpolação

# condicionais
if [[ -f /etc/os-release ]]; then
  echo "Linux"
fi

# loops
for arq in *.md; do
  echo "Processando: $arq"
done

# funções
saudacao() {
  echo "Olá, $1!"
}
saudacao "mundo"

# command substitution
DATA=$(date +%F)
echo "hoje é $DATA"
```

### Particionamento e LVM

```txt
MBR vs GPT:
  MBR: até 2TB, 4 partições primárias (antigo)
  GPT: até 9ZB, 128 partições (moderno) — preferir

Tipos:
  Primary:    até 4 por disco (MBR)
  Extended:   container de logicals
  Logical:    dentro de extended
  LVM:        abstraction acima de partições físicas

Filesystems principais:
  ext4    → estável, Linux genérico
  btrfs   → snapshots, COW, RAID
  xfs     → alta performance grande storage
  zfs     → advanced, enterprise
  swap    → área de troca
  vfat    → EFI boot
```

### SSH

```txt
# configurar server
sudo systemctl enable --now sshd

# gerar chave
ssh-keygen -t ed25519 -C "gabriel@kryonix"

# copiar chave pro servidor
ssh-copy-id user@host

# config cliente (~/.ssh/config)
Host glacier
  HostName 192.168.1.100
  User rocha
  IdentityFile ~/.ssh/id_ed25519
```

### Hardening básico

```txt
1. Atualizar sistema regularmente
2. Firewall ativo (ufw, firewalld, ou nftables)
3. SSH: sem root login, só chave, porta alternativa
4. Fail2ban pra bloquear brute-force
5. AppArmor/SELinux ativos
6. Logs centralizados (journalctl remote, ou Loki)
7. Backups automatizados (borg, restic)
8. Usuários separados (nunca root no dia-a-dia)
9. sudo com NOPASSWD apenas se necessário
10. Auditoria periódica (lynis, chkrootkit)
```

## Procedimento — configurar servidor novo

```txt
1. INSTALAR distro base (ou usar ISO Kryonix quando disponível).
2. ATUALIZAR: `sudo <pkg-manager> update && upgrade`.
3. CRIAR usuário não-root com sudo.
4. CONFIGURAR SSH:
   - desabilitar login de root
   - só permitir key-based auth
   - porta custom (opcional)
5. CONFIGURAR firewall (ufw/firewalld):
   - permitir SSH (porta custom)
   - permitir serviços necessários (HTTP/HTTPS)
   - default deny
6. HABILITAR fail2ban.
7. CONFIGURAR backups.
8. CONFIGURAR monitoring (Prometheus node exporter).
9. AUDITAR com lynis.
10. DOCUMENTAR tudo no vault (evidência).
```

## Checklist — healthcheck de máquina Linux

```txt
- [ ] Sistema atualizado?
- [ ] Firewall ativo e regras corretas?
- [ ] SSH seguro (sem root, só chave)?
- [ ] Usuário não-root com sudo (NOPASSWD auditado)?
- [ ] Swap configurado?
- [ ] Timezone correta?
- [ ] NTP ativo?
- [ ] Logs centralizados/rotacionados?
- [ ] Backup automatizado testado?
- [ ] Monitoring ativo?
```

## Aplicação no Kryonix

```txt
Cenário: preparar Glacier como servidor IA headless
- Install via ISO Kryonix oficial (P3 do roadmap)
- SSH config: sem root, só ed25519
- Firewall: só porta SSH do Inspiron + Prometheus se exposto
- LVM: /dev/sda1 (boot 1G, EFI) + /dev/sda2 (VG kryonix)
  - LV root 50G, LV home 200G, LV ai-models 500G
- Backup: restic pra Inspiron via SSH
- Monitoring: node_exporter + grafana no Inspiron
```

## Riscos

- Configurar firewall sem teste: pode se bloquear.
- `chmod 777` "pra resolver rápido": vira buraco de segurança.
- `rm -rf /` por engano: sempre revisar caminho.
- Editar /etc/sudoers sem visudo: pode perder acesso root.

## Token-saving mechanism

Consolida 2 livros (~290 páginas) em comandos + fluxos + checklist. Uso: consulta rápida quando estiver configurando máquina.

## Base prompt

```txt
Atue como sysadmin Linux sênior.
Dada a tarefa abaixo, aplique a skill [[04-Recursos/skills/livros/linux-sysadmin-fundamentals/SKILL]].
Produza: (1) comandos a executar, (2) ordem, (3) riscos,
(4) alternativas declarativas (NixOS se aplicável).
```

## Livros-fonte

```txt
04-Recursos/livros/Guia prático do servidor Linux - Administração Linux para iniciantes - Autor (Casa do Código).pdf
04-Recursos/livros/Começando com o Linux - Comandos, serviços e administração - Autor (Casa do Código).pdf
```

## Links relacionados

- [[04-Recursos/skills/livros/devops-ci-cd-practices/SKILL]]
- [[04-Recursos/skills/livros/git-github-operacional/SKILL]]
- [[04-Recursos/skills/revisao-nixos-flake/SKILL]]
- [[01-MOCs/Mapa - Biblioteca]]
- [[01-MOCs/Mapa - NixOS e Infra Declarativa]]
