# CLI RAGOS - Cheat Sheet

## 🖥️ CLI Cliente: `ragc` (Gerenciar Imagens)

**Localização**: [`ragc/`](ragc/)

```bash
# Listar versões de imagem
ragc list

# Ver versão ativa
ragc status

# Construir nova versão
ragc switch [--channel lab] [--target desktop-lab]

# Reverter para versão anterior
ragc rollback

# Limpar versões antigas (manter N)
ragc gc 5

# Diagnóstico de infraestrutura
ragc doctor

# Ajuda
ragc help
```

---

## 🖱️ CLI Servidor: `ragos` (Gerenciar Sistema)

**Localização**: [`server/ragos-cli.nix`](server/ragos-cli.nix)

### Gerenciamento de Sistema

```bash
# Sincronizar repositório Git
ragos sync

# Aplicar configuração
ragos switch

# Testar configuração (sem fixar boot)
ragos test

# Voltar geração anterior
ragos rollback

# Atualizar flake.lock e aplicar
ragos update

# Limpar gerações antigas
ragos clean

# Validar flake
ragos check

# REPL Nix do flake
ragos repl

# Mostrar caminho do flake
ragos path

# Shell no diretório do flake
ragos enter

# Status geral do sistema
ragos status

# Ajuda
ragos help
```

### 👥 Gerenciamento de Usuários (COM GRUPOS)

```bash
# Criar novo usuário com quota BTRFS
ragos user add <nome> --quota 20G [--password SENHA] [--group <grupo>]
ragos user add aluno --quota 20G --password Aluno123 --group students
ragos user add professor --quota 50G --password Prof123 --group teaching

# Listar todos os usuários com uso e quota
ragos user list

# Alterarquota de usuário
ragos user resize <nome> --quota 40G [--force]
ragos user resize professor --quota 100G --force

# Deletar usuário com archival (automático BTRFS snapshot)
ragos user delete <nome> --archive
ragos user delete professor --archive

# Ver histórico de login/logout do usuário
ragos user activity <nome>
ragos user activity aluno

# Diagnóstico detalhado de usuário (home, quotas, permissões)
ragos user doctor <nome>
ragos user doctor professor

# Sincronizar quotas do metadata (recuperação após problema)
ragos user quota-sync
```

### 🎨 Diagnósticos

```bash
# Diagnóstico de branding (temas SDDM, Plymouth, wallpapers)
ragos branding doctor

# Diagnóstico de sessão cliente (session, mounts, NFS)
ragos client session-doctor
```

### 👫 Gerenciamento de Grupos e Setores

#### Estrutura de Grupo (ADMIN é Permanente)

**Grupo "admin"**: Criado automaticamente no servidor + exposto no cliente apenas depois de login real, em `~/Setores/admin` para quem participa do grupo

- **GID fixo**: 3000
- **Storage**: `/srv/data/storage/admin` (servidor) → `~/Setores/admin` (cliente do usuario membro)
- **Permissões padrão**: `0750` (owner:admin, leitura/escrita para membros)
- **Nunca pode ser deletado** (permanente por design)
- **Ordem do mount**: login -> `/home/<usuario>` -> `~/Setores/<grupo>`

#### Criar, Listar e Deletar Grupos

```bash
# Criar novo grupo com storage dedicado
ragos group add <nome> [--description DESC] [--storage-quota 100G]
ragos group add students --description "Grupo de alunos" --storage-quota 150G
ragos group add teaching --description "Professores" --storage-quota 200G

# Listar todos os grupos e salas compartilhadas  
ragos group list

# Deletar grupo com archival de storage
# IMPORTANTE: admin NUNCA pode ser deletado (erro se tentar)
ragos group delete <nome> --archive
ragos group delete students --archive
```

#### Gerenciar Permissões de Grupo

```bash
# Ver permissões atuais do grupo
ragos group permissions <nome>
ragos group permissions admin

# Mudar modo (permissões)
ragos group chmod <nome> <perms>
ragos group chmod admin 0750           # rwxr-x---
ragos group chmod students 0755        # rwxr-xr-x (mais aberto)
ragos group chmod teaching 0700        # rwx------ (restrito)

# Sintaxe aceita:
#  - Modo octal: 0750, 0755, 0700, etc
#  - chmod syntax: g+w, o-rx, +x, etc
```

#### Adicionar/Remover Usuários em Grupos

```bash
# Adicionar usuário ao grupo (será membro)
ragos group members <nome> --add <usuario>
ragos group members admin --add professor              # professor acessa ~/Setores/admin apos login
ragos group members students --add aluno1
ragos group members students --add aluno2
ragos group members teaching --add professor

# Remover usuário do grupo
ragos group members <nome> --remove <usuario>
ragos group members students --remove aluno1

# Listar membros atuais
ragos group members <nome>
ragos group members admin                              # Mostra todos em admin
```

#### Storage - Como Funciona no Cliente

**Montagem automática depois do login real** (via NFS):

```
Servidor                      Cliente
─────────────────────────────────────────
/srv/data/storage/admin/    →  /home/<usuario>/Setores/admin/
/srv/data/storage/students/ →  /home/<usuario>/Setores/students/
/srv/data/storage/teaching/ →  /home/<usuario>/Setores/teaching/
```

**Exemplo na prática**:

```bash
# No servidor: criar arquivo em admin
echo "Recurso compartilhado" > /srv/data/storage/admin/recurso.txt
chmod 0640 /srv/data/storage/admin/recurso.txt

# No cliente (como usuário em grupo admin):
cat "$HOME/Setores/admin/recurso.txt"  # Acesso de leitura/escrita
```

**Permissões respeitadas**:

- Mode: Preservado via NFS (0750 = owner rw, group rx, others --)
- Owner:Group: Mantido (admin:admin para /srv/data/storage/admin)
- Acesso: Usuário precisa estar NO GRUPO para ter acesso

---

## 📊 Operações Comuns

### Setup Inicial: Criar Grupos, Usuários e Definir Permissões

```bash
# 1. Grupo "admin" JÁ EXISTE (criado automaticamente)
#    - Localização server: /srv/data/storage/admin
#    - Localização clientes: ~/Setores/admin
#    - Permissões default: 0750
#    - Membros: (nenhum por padrão, adicionar conforme necessário)

# 2. Criar grupos adicionais conforme demanda
sudo ragos group add students \
  --description "Alunos da escola" \
  --storage-quota 150G

sudo ragos group add teaching \
  --description "Professores e educadores" \
  --storage-quota 200G

sudo ragos group add staff \
  --description "Administrativo" \
  --storage-quota 50G

# 3. Criar usuários e atribuir a grupos
sudo ragos user add aluno1 \
  --quota 20G \
  --password Aluno123 \
  --group students

sudo ragos user add professor \
  --quota 50G \
  --password Prof123 \
  --group teaching

sudo ragos user add admin_user \
  --quota 100G \
  --password AdminPass123 \
  --group staff

# 4. Adicionar acesso a grupos compartilhados (ex: professor acessa admin)
sudo ragos group members admin --add professor      # professor pode acessar ~/Setores/admin apos login
sudo ragos group members teaching --add aluno1      # aluno pode ler recursos de teaching (se 0755)

# 5. Configurar permissões por necessidade

# Fazer admin mais restritivo (apenas owner)
sudo ragos group chmod admin 0700          # rwx------ (só admin user)

# Fazer teaching mais aberto (todos do grupo podem ler/escrever)
sudo ragos group chmod teaching 0770       # rwxrwx--- (owner + group FULL)

# Fazer students mais restritivo (apenas ler)
sudo ragos group chmod students 0750       # rwxr-x--- (owner rw, group read/list only)

# 6. Listar tudo para validar
sudo ragos group list                       # Ver todos os grupos
sudo ragos user list                        # Ver todos os usuários
sudo ragos group permissions admin          # Ver permissões do admin
sudo ragos group members admin              # Ver membros do admin
```

### Monitorar Usuários e Storage

```bash
# Ver uso de todos os usuários
sudo ragos user list

# Ver histórico de login do aluno
sudo ragos user activity aluno1

# Ver storage por grupo
sudo ragos group list
```

### Gerenciar Quotas (Operações do Dia-a-dia)

```bash
# Aluno usando mais espaço que quota
sudo ragos user list  # Ver uso

# Aumentar quota (20G → 30G)
sudo ragos user resize aluno1 --quota 30G

# Ver resultado confirmado
sudo ragos user list
```

### Backup e Arquivação

```bash
# Deletar usuário com segurança (cria snapshot automático)
sudo ragos user delete aluno_antiga --archive

# Resultado:
# - Snapshot read-only em /srv/data/snapshots/users/aluno_antiga-20260402-143000
# - Home arquivada em /srv/data/home/.archive/aluno_antiga-20260402-143000
# - Removido de client-users.json

# Listar arquivos na área archive
ls -lh /srv/data/home/.archive/
ls -lh /srv/data/snapshots/users/
```

### Criar Ambiente de Laboratório

```bash
# 1. Criar sala de informática
sudo ragos group add lab01 --description "Lab-01 (50 máquinas)" --storage-quota 200G

# 2. Criar usuário de teste para a turma
sudo ragos user add teste_lab --quota 5G --password Teste123 --group lab01

# 3. Criar usuário professor da sala
sudo ragos user add prof_lab --quota 50G --password ProfLab123 --group lab01

# 4. Verificar estrutura
sudo ragos user list
sudo ragos user doctor teste_lab
sudo ragos group list
```

### Deletar Usuário (com Segurança)

```bash
# O arquivo será:
# 1. Snapotado via BTRFS (read-only)
# 2. Movido para /srv/data/home/.archive/
# 3. Removido de client-users.json

sudo ragos user delete aluno --archive

# Confirmação
sudo ragos user list  # Aluno não aparece mais
```

### Recuperação de Quota Após Problema

```bash
# Se arquivos .ragos-home-meta forem perdidos
sudo ragos user quota-sync

# Reaplica todas as quotas baseado em metadata
```

---

## 🔑 Argumentos Comuns (Completo)

### `ragos user add` — Criar Usuário

| Argumento | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-----------|-----------|---------|
| `<nome>` | positional | ✅ | Nome do usuário (regex: `^[a-z_][a-z0-9_-]{0,30}$`) | `aluno`, `professor` |
| `--quota` | flag | ✅ | Tamanho em formato humano (`20G`, `50G`, `100G`, `1T`) | `--quota 20G` |
| `--password` | flag | ❌ | Senha em plaintext (recomendado) | `--password Aluno123!` |
| `--password-hash` | flag | ❌ | Hash SHA-512 pré-computado (ex: `$6$...`) | `--password-hash $6$...` |
| `--group` | flag | ❌ | Grupo do usuário (students, teaching, staff, admin, public) | `--group students` |

**Exemplos**:

```bash
# Usuário do grupo students com senha
ragos user add aluno --quota 20G --password Aluno123 --group students

# Professor com quota maior
ragos user add prof --quota 50G --password Prof456 --group teaching

# Admin com quota maior
ragos user add admin_lab --quota 100G --password Adm789 --group admin
```

**Nota**: Se não passar `--password` ou `--password-hash`, usuário fica bloqueado (sem login gráfico).

### `ragos user resize` — Alterar Quota

| Argumento | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-----------|-----------|---------|
| `<nome>` | positional | ✅ | Nome do usuário existente | `aluno`, `professor` |
| `--quota` | flag | ✅ | Nova quota em formato humano | `--quota 40G` |
| `--force` | flag | ❌ | Força se nova quota < uso atual (redução) | `--force` |

**Exemplos**:

```bash
# Aumentar quota de 20G para 30G (sem force)
ragos user resize aluno --quota 30G

# Reduzir quota (requer --force para segurança)
ragos user resize aluno --quota 10G --force
```

### `ragos user delete` — Deletar Usuário

| Argumento | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-----------|-----------|---------|
| `<nome>` | positional | ✅ | Nome do usuário a deletar | `aluno`, `professor` |
| `--archive` | flag | ✅ | Obrigatório (segurança: evita acidentes) | `--archive` |

**Comportamento**:

1. Cria snapshot BTRFS read-only em `/srv/data/snapshots/users/<nome>-<timestamp>`
2. Move home para `/srv/data/home/.archive/<nome>-<timestamp>`
3. Remove entrada de `client-users.json`
4. Remove usuário do sistema

**Exemplos**:

```bash
# Deletar aluno com arquivação automática
ragos user delete aluno --archive
# Resultado: home em /srv/data/home/.archive/aluno-20260402-143000
```

### `ragos user activity` — Histórico de Login/Logout

| Argumento | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-----------|-----------|---------|
| `<nome>` | positional | ✅ | Nome do usuário | `aluno`, `professor` |

**Campos retornados**:

- `timestamp`: Data e hora ISO 8601
- `action`: `login`, `logout`, `heartbeat`
- `tty`: Terminal (tty000 para SDDM, `/dev/pts/1` para SSH)
- `ip`: IP do cliente (se disponível)
- `sessionid`: ID da sessão

**Exemplos**:

```bash
# Ver todos os logins do aluno
ragos user activity aluno

# Saída expected:
# [2026-04-02T14:30:00+00:00] [login] tty=tty000 ip=192.168.100.11
# [2026-04-02T15:45:23+00:00] [logout] tty=tty000 ip=192.168.100.11
# [2026-04-02T16:00:05+00:00] [login] tty=tty000 ip=192.168.100.11
```

### `ragos user doctor` — Diagnóstico de Usuário

| Argumento | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-----------|-----------|---------|
| `<nome>` | positional | ✅ | Nome do usuário | `aluno`, `professor` |

**Verifica**:

- Home existe em `/srv/data/home/<nome>`
- Owner/group corretos
- Quota BTRFS aplicada
- Permissões (0700)
- Estrutura mínima (`.config`, `.cache`, `.local`, etc)
- Integração com `client-users.json`

**Exemplos**:

```bash
ragos user doctor aluno
# Retorna diagnóstico completo do usuário
```

### `ragos group add` — Criar Grupo

| Argumento | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-----------|-----------|---------|
| `<nome>` | positional | ✅ | Nome do grupo (novo setor) | `students`, `teaching` |
| `--description` | flag | ❌ | Descrição do grupo | `--description "Alunos do 1º ano"` |
| `--storage-quota` | flag | ❌ | Quota total do setor (padrão: `100G`) | `--storage-quota 150G` |

**Comportamento**:

1. Cria diretório `/srv/data/storage/<nome>`
2. Armazena metadata em `.group-meta`
3. Registra quota em JSON runtime
4. Cria entry NixOS group se necessário

**Exemplos**:

```bash
# Criar grupo de alunos com quota de 150GB
ragos group add students --description "Alunos da escola" --storage-quota 150G

# Criar grupo de professores
ragos group add teaching --storage-quota 200G
```

### `ragos group delete` — Deletar Grupo

| Argumento | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-----------|-----------|---------|
| `<nome>` | positional | ✅ | Nome do grupo existente | `students`, `teaching` |
| `--archive` | flag | ✅ | Obrigatório (segurança) | `--archive` |

**Comportamento**:

1. Valida que não há usuários ativos no grupo
2. Move `/srv/data/storage/<nome>` para `/srv/data/storage/.archive/<nome>-<timestamp>`
3. Remove entry JSON
4. Remove grupo do sistema

**Exemplos**:

```bash
ragos group delete students --archive
```

---

## 📂 Estrutura de Storage (COMPLETA)

```
/srv/data/
├── home/                          ← Homes persistentes de usuários (BTRFS subvolumes)
│   ├── aluno/
│   │   ├── .ragos-home-meta       ← Metadata (USER, HOME, QUOTA, CREATED_AT)
│   │   ├── .config/               ← Configurações de aplicações
│   │   ├── .cache/                ← Cache (temporário)
│   │   ├── .local/                ← Dados locais (share, state)
│   │   ├── Desktop/
│   │   ├── Documents/
│   │   ├── Downloads/
│   │   ├── Pictures/
│   │   ├── Music/
│   │   ├── Videos/
│   │   └── [Conteúdo adicional do usuário]
│   │
│   ├── professor/
│   │   └── [idem aluno]
│   │
│   ├── admin/
│   │   └── [idem, mas com quota maior]
│   │
│   └── .archive/                  ← Homes de usuários deletados
│       ├── aluno-20260402-143000/
│       ├── professor-20260402-143001/
│       └── ...
│
├── storage/                       ← Compartilhado por GRUPO (NOVO)
│   ├── students/                  ← Setor de alunos
│   │   ├── .group-meta            ← Metadata do grupo
│   │   ├── projects/              ← Projetos compartilhados
│   │   ├── resources/             ← Recursos da turma
│   │   └── ...
│   │
│   ├── teaching/                  ← Setor de professores
│   │   ├── .group-meta
│   │   ├── lessons/
│   │   ├── materials/
│   │   └── ...
│   │
│   ├── staff/                     ← Setor administrativo
│   │   └── [idem]
│   │
│   └── .archive/
│       ├── students-20260402-143002/
│       └── ...
│
├── images/                        ← Imagens de cliente (netboot)
│   ├── current -> v20260402-150000/
│   ├── v20260402-150000/
│   │   ├── bzImage
│   │   ├── initrd
│   │   ├── manifest.json
│   │   └── modules.tgz
│   │
│   └── v20260401-100000/
│       └── ...
│
└── snapshots/
    ├── users/                     ← Snapshots BTRFS de usuários deletados
    │   ├── aluno-20260402-143000/ ← read-only snapshot
    │   ├── professor-20260402-143001/
    │   └── ...
    │
    └── images/
        └── images-pre-gc-*/       ← Snapshots pré-GC (cleanup)
```

**Pontos importantes**:

- **BTRFS subvolumes**: Cada home de usuário é um subvolume separado (quotas independentes)
- **Metadata**: `.ragos-home-meta` armazena USER, HOME, QUOTA, CREATED_AT
- **Archive**: Deletados ficam em `.archive` com timestamp
- **Snapshots**: Snapshots read-only para redundância
- **Storage de grupo**: Setor separado de storage compartilhado
- **NFS**: Todo `/srv/data/home` é exportado via NFS (bind mount `/srv/nfs/srv/data/home`)

---

## 🔐 Permissões de Execução

| Comando | Requer Root? | Detalhes |
|---------|--------------|---------|
| `ragos user add` | ✅ | Auto-promove via sudo; preserva variáveis de ambiente |
| `ragos user list` | ✅ | Lê `/var/lib/ragos/runtime/client-users.json` |
| `ragos user resize` | ✅ | Modifica quota BTRFS; requer mount de `/srv/data/home` |
| `ragos user delete` | ✅ | Cria snapshot; move arquivos para archive |
| `ragos user doctor` | ✅ | Valida estado do usuário (permissões, ownership) |
| `ragos user activity` | ✅ | Lê `/var/lib/ragos/audit/login-history.json` |
| `ragos user quota-sync` | ✅ | Reaplica quotas BTRFS |
| `ragos group add` | ✅ | Cria diretório; registra metadata |
| `ragos group list` | ✅ | Lista storage de grupos |
| `ragos group delete` | ✅ | Move storage para archive |
| `ragos switch` | ✅ | Aplica configuração; requer `nixos-rebuild` |
| `ragos sync` | ✅ | Executa `git pull` no repositório |
| `ragos clean` | ✅ | Limpa gerações antigas |
| `ragos update` | ✅ | Atualiza flake.lock; executa rebuild |
| `ragos check` | ❌ | Valida flake (pode rodar sem root) |
| `ragos branding doctor` | ✅ | Verifica temas (requer acesso a paths do sistema) |
| `ragos client session-doctor` | ✅ | Verifica mounts e NFS |

**Nota**: Se você não for root, a CLI automaticamente reexecuta com `sudo`, preservando:

- `RAGOS_FLAKE_PATH`
- `RAGOS_TARGET_HOST`
- Outras variáveis de ambiente importantes

**Teste sem root**:

```bash
# Sem sudo (será auto-promovido)
ragos user list

# Com sudo explícito (também funciona)
sudo ragos user list
```

---

## 🗂️ Arquivos Principais

| Arquivo | Responsabilidade |
|---------|---|
| [`server/ragos-cli.nix`](server/ragos-cli.nix) | ⭐ Implementação completa de `ragos` (900 linhas) |
| [`ragc/package.nix`](ragc/package.nix) | Construção do pacote `ragc` |
| [`server/services/ragos-users-btrfs.nix`](server/services/ragos-users-btrfs.nix) | NixOS module para BTRFS quotas |
| [`server/roles/base.nix`](server/roles/base.nix) | Integração com pacotes do sistema |
| [`server/services/storage.nix`](server/services/storage.nix) | Layout de storage BTRFS |

---

## 🔄 Fluxo de Login de Usuário

```
Cliente tenta fazer login
        ↓
PAM/SDDM lê client-users.json
        ↓
Verifica hashedPassword
        ↓
Se OK → monta NFS home
        ↓
Sessão de usuário iniciada
```

**Arquivo de catálogo**: `/var/lib/ragos/runtime/client-users.json`

---

## � Auditoria de Sessões (NOVO)

### Visualizar Histórico de Login

```bash
# Ver todos os logins de um usuário
sudo ragos user activity aluno

# Saída esperada:
# [2026-04-02T14:30:00+00:00] [login] tty=tty000 ip=192.168.100.11
# [2026-04-02T15:45:23+00:00] [logout] tty=tty000 ip=192.168.100.11
# [2026-04-02T16:00:05+00:00] [login] tty=tty000 ip=192.168.100.11
```

### Arquivos de Auditoria

```
/var/lib/ragos/audit/
└── login-history.json          ← Histórico completo (JSON)
```

**Estrutura do JSON**:

```json
{
  "sessions": {
    "aluno": [
      {
        "action": "login",
        "timestamp": "2026-04-02T14:30:00+00:00",
        "tty": "tty000",
        "ip": "192.168.100.11",
        "sessionid": "xyz-123"
      }
    ]
  },
  "last_update": "2026-04-02T16:00:05+00:00"
}
```

### Limpeza Automática

- **Retenção padrão**: 90 dias
- **Cleanup**: Executado via systemd timer (`ragos-audit-cleanup.timer`)
- **Frequência**: Uma vez por dia
- **Arquivo de controle**: `server/roles/ragos-operational.nix`

```bash
# Ver logs de limpeza
journalctl -u ragos-audit-cleanup.service -n 50

# Aumentar retenção para 180 dias (em /etc/ragos)
# ragos.audit.retentionDays = 180
```

---

## �🐛 Troubleshooting

### Usuário não consegue fazer login na sessão cliente

```bash
# Verificar se entrada existe no catálogo
sudo jq '.aluno' /var/lib/ragos/runtime/client-users.json

# Se não existir, recriar entrada
sudo ragos user doctor aluno
```

### Quota não está sendo aplicada

```bash
# Verificar se BTRFS está ativo
mount | grep /srv/data/home

# Se não, verificar storage.nix
sudo ragos user quota-sync
```

### Problema ao deletar usuário

```bash
# Verificar se home existe
ls -la /srv/data/home/aluno

# Verificar snapshot
btrfs subvolume list /srv/data/snapshots

# Se snapshot falhar, tentar forçar delete
sudo userdel -r aluno  # ⚠️ Cuidado!
```

---

## 📈 Quota BTRFS - Conceitos

- **Quota**: Limite de espaço em disco por usuário
- **qgroup**: "quota group" - identificador BTRFS para quota
- **Soft limit**: Aviso ao atingir 90% (não implementado)
- **Hard limit**: Bloqueia escrita ao atingir 100%

### Comandos BTRFS Diretos

```bash
# Ativar quotas em /srv/data/home
btrfs quota enable /srv/data/home

# Ver quotas de um usuário
btrfs qgroup show -f /srv/data/home/aluno

# Alterar limite de quota (direto)
btrfs qgroup limit 30G /srv/data/home/aluno

# Rescanear quotas (se corrompidas)
btrfs quota rescan /srv/data/home
```

---

## � Troubleshooting Completo

### Usuário não consegue fazer login na sessão cliente

```bash
# 1. Verificar se entrada existe no catálogo
sudo jq '.aluno' /var/lib/ragos/runtime/client-users.json

# Se campo vazio, recriá-lo
sudo ragos user add aluno --quota 20G --password Aluno123 --group students

# 2. Verificar se home foi criada
ls -lh /srv/data/home/aluno

# Se não existe, criar manualmente
sudo mkdir -p /srv/data/home/aluno
sudo chown aluno:users /srv/data/home/aluno
sudo chmod 700 /srv/data/home/aluno

# 3. Testar hash de senha
sudo jq '.aluno.hashedPassword' /var/lib/ragos/runtime/client-users.json

# Se retorna "!", usuário está bloqueado (sem senha)
# Solução:
sudo ragos user delete aluno --archive
sudo ragos user add aluno --quota 20G --password NovaAluno123 --group students

# 4. Revisar journalctl para PAM errors
journalctl -u login -n 50
journalctl -u sddm -n 50
```

### Quota não está sendo aplicada

```bash
# 1. Verificar se BTRFS está ativo
mount | grep /srv/data/home

# Se não montado:
sudo mount /srv/data/home

# 2. Validar que quotas estão habilitadas
sudo btrfs quota enable /srv/data/home

# 3. Sincronizar quotas (recuperação de metadata perdido)
sudo ragos user quota-sync

# 4. Verificar quota aplicada
sudo btrfs qgroup show -f /srv/data/home/aluno

# 5. Listar todos os usuários (deve mostrar % de uso)
sudo ragos user list
```

### Usuário não aparece em `ragos user list`

```bash
# 1. Verificar JSON
sudo jq 'keys' /var/lib/ragos/runtime/client-users.json

# Se não listado, verificar home
ls -lh /srv/data/home/ | grep aluno

# 2. Se home existe mas não aparece no JSON, reescrever catalog
sudo ragos user doctor aluno
```

### Erro ao deletar usuário: Falha ao criar snapshot

```bash
# 1. Verificar se /srv/data/snapshots existe
ls -lh /srv/data/snapshots/users/

# Se não, criar:
sudo mkdir -p /srv/data/snapshots/users
sudo chmod 700 /srv/data/snapshots/users

# 2. Verificar se home é realmente um subvolume BTRFS
btrfs subvolume list /srv/data/home | grep aluno

# Se comverter para subvolume:
sudo btrfs subvolume create /srv/data/home/aluno_new
sudo cp -r /srv/data/home/aluno/* /srv/data/home/aluno_new/
sudo rm -rf /srv/data/home/aluno
sudo mv /srv/data/home/aluno_new /srv/data/home/aluno

# 3. Tentar deletar novamente
sudo ragos user delete aluno --archive
```

### Grupo não aparece em `ragos group list`

```bash
# 1. Verificar JSON
sudo jq 'keys' /var/lib/ragos/runtime/user-groups.json

# 2. Verificar storage no disco
ls -lh /srv/data/storage/ | grep students

# Se não existe, criar manualmente:
sudo mkdir -p /srv/data/storage/students
sudo chown root:students /srv/data/storage/students
sudo chmod 770 /srv/data/storage/students

# 3. Validar metadata do grupo
sudo cat /srv/data/storage/students/.group-meta
```

### Senha de usuário rejeitada no SDDM

```bash
# 1. Verificar hash no catálogo
sudo jq '.aluno.hashedPassword' /var/lib/ragos/runtime/client-users.json

# Hash "!" = usuário bloqueado
# Hash "!" com $6$ = SHA-512 correto

# 2. Se problema, recriá-lo
sudo ragos user delete aluno --archive
sudo ragos user add aluno --quota 20G --password NovaAluno123 --group students

# 3. Testar (sem reboot)
echo 'NovaAluno123' | sudo -u aluno bash -c 'whoami'
```

### Histórico de login vazio

```bash
# 1. Verificar arquivo
sudo jq '.sessions.aluno' /var/lib/ragos/audit/login-history.json

# Se vazio: usuário nunca fez login, ou history foi limpo (>90 dias)

# 2. Confirmar auditoria ativada
sudo grep 'ragos.audit.enable' /etc/nixos/configuration.nix

# 3. Verificar logs de PAM
journalctl -u login -n 100
journalctl -u sddm -n 100

# 4. Tentar novo login
sudo ragos user activity aluno
```

### Storage de grupo cheio

```bash
# 1. Verificar tamanho
du -sh /srv/data/storage/*

# 2. Aumentar quota BTRFS
sudo btrfs qgroup limit 200G /srv/data/storage/students

# 3. Limpar deletando usuários antigos
sudo ragos user delete aluno_antiga --archive

# 4. Ver espaço livre
df -h /srv/data/storage
```

### Erro: nova quota menor que uso atual

```bash
# Verificar uso
sudo ragos user list
# OUTPUT: aluno       8G/5G    160%   <- uso=8G, quota=5G

# Aumentar sem force (se novo > uso):
sudo ragos user resize aluno --quota 15G

# Forçar redução (perigoso):
sudo ragos user resize aluno --quota 10G --force

# Ver o que ocupa espaço:
du -sh /srv/data/home/aluno/*
```

### Storage /srv/data/home não disponível

```bash
# 1. Verificar se montado
mount | grep /srv/data/home

# Montar manualmente:
sudo mount /srv/data/home

# 2. Verificar logs
journalctl -xeu srv-data-home.mount

# 3. Se corrompido, re-criar:
sudo btrfs subvolume delete /srv/data/home
sudo btrfs subvolume create /srv/data/home
sudo chmod 755 /srv/data/home
```

### PAM Mount não ativa (NFS home falha)

```bash
# 1. Verificar config PAM
sudo cat /etc/pam.d/login | grep pam_mount

# Deve conter: auth optional pam_mount.so

# 2. Testar NFS manualmente
sudo showmount -e servidor_ragos
sudo mount -t nfs4 servidor_ragos:/srv/nfs/srv/data/home /mnt/test

# 3. Ver logs
journalctl -u pam_mount -n 100
```

### SDDM tema não mostra imagens

```bash
# 1. Verificar se tema instalado
ls -la /run/current-system/share/sddm/themes/ragos-sugar-light/

# 2. Ver logs de SDDM
journalctl -u sddm -n 100

# 3. Recompilar tema
sudo ragos switch
```

### Plymouth (boot splash) não aparece

```bash
# 1. Verificar se enabled
sudo grep 'boot.plymouth' /etc/nixos/configuration.nix

# Deve ter:
# boot.plymouth.enable = true;
# boot.plymouth.theme = "ragos";

# 2. Ver logs
journalctl -b | grep -i plymouth

# 3. Reconstruir
sudo ragos switch
sudo reboot
```

---

## �🔗 Variáveis de Ambiente

```bash
# Caminhos operacionais (em server/ragos-cli.nix)
export RAGOS_FLAKE_PATH=/etc/ragos
export RAGOS_TARGET_HOST=srv-rag
export RAGOS_HOME_BASE=/srv/data/home
export RAGOS_HOME_ARCHIVE_BASE=/srv/data/home/.archive
export RAGOS_CLIENT_USERS_FILE=/var/lib/ragos/runtime/client-users.json
```

---

## ✅ Checklist: Configurar Ambiente de Lab

- [ ] Server instalado (NixOS com RAGOS)
- [ ] `/srv/data/home/` montado em BTRFS
- [ ] Quotas BTRFS ativadas
- [ ] CLI `ragos` disponível no PATH
- [ ] Criar usuário `aluno`: `sudo ragos user add aluno --quota 20G`
- [ ] Criar usuário `professor`: `sudo ragos user add professor --quota 50G`
- [ ] Verificar listagem: `sudo ragos user list`
- [ ] Verificar client-users.json: `cat /var/lib/ragos/runtime/client-users.json`
- [ ] Diagnóstico: `sudo ragos user doctor aluno`
- [ ] Boot imagem cliente (deve ler catálogo)
- [ ] Testar login com usuário `aluno`
