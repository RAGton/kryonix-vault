---
title: DEV / PROD Layout Oficial
date: 2026-06-13
type: architecture
status: implemented
tags: [kryonix, dev-prod, layout, governança, nixos]
related:
  - "[[00 Index]]"
  - "[[03 Skills git-dev-prod]]"
---

# DEV / PROD Layout Oficial

## Mapa de ambientes

```txt
/home/rocha/kryonix/             ← DEV (única área normal de alteração)
├── kryonix/                     ← motor — origin RAGton/kryonix      (DEV-MOTOR)
└── kryonixos/                   ← downstream/site/ISO — RAGton/Kryonixos (DEV-SITE)

/etc/kryonix/                    ← PROD (motor instalado)            (PROD-MOTOR)
/etc/kryonixos/                  ← PROD (downstream instalado)        (PROD-SITE)
```

⚠️ Quirk do GitHub: o repositório downstream se chama `RAGton/Kryonixos`
(K maiúsculo). Diretórios locais usam `kryonixos` em minúsculo por
convenção. URLs HTTPS e git@ aceitam ambas as formas.

## Matriz de permissões

| Ambiente   | Editar | Commit | `nix flake update` | `git push` | `kryonix switch`     |
|------------|:------:|:------:|:------------------:|:----------:|:--------------------:|
| DEV-MOTOR  | ✅     | ✅     | ✅                 | ✅         | ❌                   |
| DEV-SITE   | ✅     | ✅     | n/a                | ✅         | ❌                   |
| PROD-MOTOR | ❌     | ❌     | ❌                 | ❌         | ✅ (pós check+diff)  |
| PROD-SITE  | ❌     | ❌     | n/a                | ❌         | n/a                  |
| UNKNOWN    | abortar| abortar| abortar            | abortar    | abortar              |

## Detecção via CLI

`kryonix env status` (implementado em PR #62, refinado em PR #71/#72):

```bash
kryonix env status
# Environment    : DEV-MOTOR | DEV-SITE | PROD-MOTOR | PROD-SITE | UNKNOWN
# Repo           : /caminho/atual
# Branch         : <branch>
# Upstream       : origin/main
# Dirty          : yes/no
# Remote ahead   : 0
# Remote behind  : 0
# Policy:
#   edits_allowed        : yes/no
#   flake_update_allowed : yes/no
#   push_allowed         : yes/no
#   switch_allowed       : yes (com check+diff+test) / no / n/a
```

## Contrato de `kryonix update`

### DEV

```bash
git pull --ff-only origin <branch atual>
nix flake update                 # ok em DEV
# se flake.lock mudou:
kryonix fmt && kryonix check && kryonix test --host <h>
git diff --stat
# sugerir commit pequeno; nunca commitar/pushar automaticamente
```

### PROD

```bash
git pull --ff-only origin main   # única atualização permitida
kryonix check
kryonix diff
# NÃO rodar nix flake update.
# NÃO rodar kryonix switch automático.
```

## Bootstrap por máquina

```bash
# DEV (HOME)
mkdir -p /home/rocha/kryonix
git clone git@github.com:RAGton/kryonix.git    /home/rocha/kryonix/kryonix
git clone git@github.com:RAGton/Kryonixos.git  /home/rocha/kryonix/kryonixos

# PROD (/etc/*) — só se ainda não existir
sudo git clone git@github.com:RAGton/kryonix.git    /etc/kryonix
sudo git clone git@github.com:RAGton/Kryonixos.git  /etc/kryonixos
```

## Loop DEV (ciclo diário)

```bash
cd /home/rocha/kryonix/kryonix
git fetch --all --prune --tags
git pull --ff-only

# editar, validar
nix fmt
nix flake check --keep-going
kryonix test --host <host>           # se mexer em host

git add <arquivos>                   # NUNCA git add .
git diff --cached --stat
git commit -m "tipo(escopo): resumo curto"
git push origin <branch>
```

## Loop PROD (após PR mergeado)

```bash
cd /etc/kryonix
sudo git fetch --all --prune --tags
sudo git status --short              # tem que estar limpo
sudo git pull --ff-only origin main  # se falhar, parar e decisão humana

kryonix check
kryonix diff
kryonix test
# só então, conforme risco:
kryonix boot
kryonix switch
```

## Regras invioláveis

1. Não usar `git add .` em lugar nenhum.
2. Não usar `git reset --hard` sem aprovação explícita.
3. Não usar `git push --force` em `main`.
4. Não dar `kryonix switch` automático após `update`.
5. Não rodar `disko`, `mkfs`, `parted`, `wipefs`.
6. Não expor secrets. Secrets em `/etc/kryonix/*.env` (`0600`, gitignored).
7. Não commitar ISO no repo. ISO sobe como asset de Release.
8. PROD só consome commits/tags aprovados via `--ff-only`.
9. DEV no HOME é a única área normal de alteração.
10. Toda nova worktree nasce em `/home/rocha/kryonix/kryonix/.worktrees/`.

## Estado de migração (junho/2026)

- 30+ branches locais em `/etc/kryonix` foram limpas (PR #65-#69 draft
  preservam o histórico).
- 8 worktrees legadas em `/etc/kryonix/.claude/worktrees/` removidas
  com prune.
- Worktree `aura-git-dev-prod-skill` em `/etc/kryonix/.claude/worktrees/`
  fica até a sessão do agente terminar (auto-detectado como PROD-MOTOR
  por estar sob `/etc/kryonix*` — comportamento desejado).

## Backup de migração

`/home/rocha/kryonix/prod-cleanup-backup-20260613-143103/` contém:
- `etc-kryonix-before-cleanup.md` (status, worktrees, branches, stash
  diffs, log --graph)
- `untracked-list.txt`
- `.claude/scheduled_tasks.lock`
- `.worktrees/` (vazio)

## Veredito

A política DEV/PROD é a fundação de tudo que veio depois. Sem ela, os
PRs subsequentes (#70..#80) não teriam um ciclo confiável de validação.

Ver também: [[03 Skills git-dev-prod]] · [[02 PRs Mergeados]]
