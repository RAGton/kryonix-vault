---
type: ops-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, runbook, operations]
links:
  - "[[MOC - Operations]]"
  - "[[Safe Git Workflow]]"
---

# Runbooks — Kryonix

Procedimentos passo-a-passo críticos. Versões completas vivem em
`docs/operations/` no repo.

## Sincronizar PROD após PR mergeado

```bash
cd /etc/kryonix
sudo git fetch --all --prune --tags
sudo git status --short
sudo git pull --ff-only origin main

kryonix env status   # PROD-MOTOR
kryonix check
kryonix diff
# decisão humana antes de:
kryonix test
kryonix boot
kryonix switch
```

## Release ISO (visão geral)

```bash
cd /home/rocha/kryonix/kryonix
kryonix iso
( cd result/iso && sha256sum *.iso ) > SHA256SUMS

git tag -a v0.X.Y -m "Kryonix OS v0.X.Y"
git push origin v0.X.Y

gh release create v0.X.Y \
  result/iso/*.iso SHA256SUMS \
  --title "Kryonix OS v0.X.Y" \
  --notes-file docs/releases/v0.X.Y.md
```

Detalhes: `docs/operations/RELEASE_ISO.md`.

## Rollback por geração NixOS

```bash
sudo nixos-rebuild --rollback switch
# ou reboot e escolher geração anterior no bootloader
```

## Rollback por tag git

```bash
cd /etc/kryonix
sudo git fetch --all --tags
sudo git checkout v0.X.Y
kryonix check
kryonix diff
kryonix boot       # nunca switch direto
```

Detalhes: `docs/operations/ROLLBACK_TAGS.md`.

## Limpeza pós-sessão de agente

```bash
cd /etc/kryonix
git worktree remove /etc/kryonix/.claude/worktrees/<nome>
git branch -D worktree-<nome>
rmdir .claude/worktrees 2>/dev/null || true
```

Ver: [[Validation Matrix]]
