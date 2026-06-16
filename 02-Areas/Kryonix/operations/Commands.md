---
type: ops-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, cli, operations, reference]
links:
  - "[[MOC - Operations]]"
  - "[[Safe Git Workflow]]"
---

# Commands — Kryonix CLI

`kryonix` é o ponto único de entrada para operações. Implementado em
`packages/kryonix-cli/` (shell + completions).

## Preflight obrigatório (agentes)

```bash
cd /home/rocha/kryonix/kryonix || exit 1
test "$(pwd -P)" = "/home/rocha/kryonix/kryonix" || exit 1
```

## Comandos essenciais

| Comando | Propósito | Notas |
|---------|-----------|-------|
| `kryonix env [status]` | Detecta DEV/PROD + matriz de policy | PR #62 |
| `kryonix status` | Diagnóstico rápido host + dual-flake | |
| `kryonix check` | `nix flake check --keep-going` | |
| `kryonix fmt` | Formata via formatter da flake | |
| `kryonix diff` | Compara `/run/current-system` vs próxima geração | |
| `kryonix test` | Aplica configuração não-persistente (`switch-to-configuration test`) | |
| `kryonix boot` | Registra próxima geração no bootloader | |
| `kryonix switch` | Ativa nova configuração | só após check/diff/test |
| `kryonix update` | DEV: `nix flake update`; PROD: `git pull --ff-only` + check + diff | PR #62 / #72 |
| `kryonix pull` | `git pull --ff-only` (era `--rebase` antes do #62) | |
| `kryonix iso` | Build da ISO em `result/iso/` | |
| `kryonix brain ...` | Operações Brain/RAG/CAG | |

## Flags importantes

- `--host <h>` — operar host remoto (não usar sintaxe `.#host`).
- `--update` — força `nix flake update` antes de switch/boot (DEV only).
- `--dry` — `--dry` no `nh`.

## Proibições documentadas

- `sudo kryonix test` — sudo é interno; `test` roda em user space.
- `kryonix check .#host` ou `kryonix test .#host` — rejeitado pelo
  wrapper. Use `--host`.
- `nh os switch ...` direto — pula hooks Kryonix.

Detalhes: `docs/CLI.md`, `docs/USAGE.md`.
