---
type: ops-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, git, dev-prod, operations, governança]
links:
  - "[[MOC - Operations]]"
  - "[[DEV PROD Flow]]"
  - "[[DECISIONS]]"
---

# Safe Git Workflow — Kryonix

Resumo operacional do fluxo Git DEV/PROD. Versão completa em
`docs/operations/GIT_DEV_PROD_WORKFLOW.md`.

## Detecção (kryonix CLI)

```bash
kryonix env status
# Environment    : DEV-MOTOR | DEV-SITE | PROD-MOTOR | PROD-SITE | UNKNOWN
```

Lógica: classifica `PWD` por prefixo (`/home/rocha/kryonix/kryonix*`,
`/etc/kryonix*`, etc.).

## Loop DEV diário

```bash
cd /home/rocha/kryonix/kryonix
git fetch --all --prune --tags
git pull --ff-only

# editar, validar
nix fmt && nix flake check --keep-going
kryonix test --host <host>

git add <arquivos explícitos>     # NUNCA git add .
git diff --cached --stat
git commit -m "tipo(escopo): resumo curto"
git push origin <branch>
```

## Loop PROD após merge

```bash
cd /etc/kryonix
sudo git fetch --all --prune --tags
sudo git pull --ff-only origin main   # se falhar, parar
kryonix env status
kryonix check
kryonix diff
# decisão humana: kryonix test → boot → switch
```

## `kryonix update` (PR #62)

- DEV: `git pull --ff-only` + `nix flake update` (se DEV-MOTOR) +
  sugestão de commit (não commita automaticamente).
- PROD: `git pull --ff-only origin main` + `kryonix check` + `kryonix diff`.
  **Bloqueia** `nix flake update`.

## Regras invioláveis

1. Não `git add .`.
2. Não `git reset --hard` sem aprovação.
3. Não `git push --force` em `main`.
4. Não `kryonix switch` automático após update.
5. Não `disko/mkfs/parted/wipefs`.
6. Não commit de ISO.
7. Não expor secrets.
8. ISO sobe via `gh release create`.

## Estratégia de merge

`gh pr merge <n> --merge --delete-branch` (sem `--squash`, preserva
commits pequenos). Política em [[DECISIONS]] D-008.

Ver: [[Commands]] · [[Runbooks]]
