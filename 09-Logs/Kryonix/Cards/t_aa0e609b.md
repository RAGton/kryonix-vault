---
card_id: t_aa0e609b
status: partial
type: 
priority: 2
created_at: 2026-07-30T15:23:17+00:00
started_at: 
completed_at: 2026-07-30T21:26:15+00:00
last_sync_at: 2026-08-07T13:48:22.051692+00:00
last_kanban_state: partial
result: None
auto_generated: true
audits:
  - kanban-drift-2026-08-04
---

# [enhancement] kryx check: wrapper de nix flake check para fluxo de agentes

**Card:** `t_aa0e609b` | **Status:** `partial`

## Descrição

## PRIORIDADE: P2 (pos-Jenpex)

## Sintoma

O `kryx` CLI (Kryonix Unified CLI) não tem subcomando para validação
estática de flake. Subcomandos existentes: `switch, factory-reset, system,
doctor, identity, setup, theme, update, status, shell, search, clean, build,
run, develop, repl, fmt, completion`. Nenhum equivalente a `nix flake check`.

Consequência: agentes em background que tentam `kryx check` recebem
`error: unrecognized subcommand 'check'`. Agentes que tentam `nix flake check`
são bloqueados pelo `[Kryonix Guard]` no shell interativo.

## Causa

O `kryx` foi desenhado para ser o único entry point de comandos Nix no
sistema, mas o time ainda não implementou o wrapper para validação estática
(`nix flake check`, `nh os check`, `nix-instantiate --eval`).

## Objetivo

Adicionar `kryx check` que internamente delega para `nix flake check`
usando o path absoluto `/run/current-system/sw/bin/nix` (bypass do Guard).

## Comportamento esperado

```
$ kryx check
[INFO] Avaliando flake via /run/current-system/sw/bin/nix...
warning: Git tree '/etc/kryonixos' is dirty
evaluating flake...
checking flake output 'nixosConfigurations'...
checking NixOS configuration 'nixosConfigurations.inspiron'...
...
all checks passed!
[OK] Validacao estatica concluida.

$ kryx check --host glacier
(somente avalia configurations.glacier)

$ kryx check --strict  (faz build em vez de eval)
[INFO] Build real (closure inteira) — pode levar 10-30 min.
```

## Implementacao sugerida

Adicionar em `/etc/kryonix/scripts/kryx-check.sh` (PATH via wrapper):

```bash
#!/usr/bin/env bash
# Wrapper kryx check: bypass Kryonix Guard via path absoluto
set -euo pipefail
NIX_BIN="${KRYX_NIX_BIN:-/run/current-system/sw/bin/nix}"
if [[ ! -x "$NIX_BIN" ]]; then
  echo "kryx check: nix binary not found at $NIX_BIN" >&2
  exit 2
fi
HOST="${1:-}"
case "${1:-}" in
  --strict) shift; "$NIX_BIN" --extra-experimental-features 'nix-command flakes' flake check --keep-going --impure "$@";;
  --host)   shift; HOST="$1"; shift; "$NIX_BIN" --extra-experimental-features 'nix-command flakes' \
            eval --raw ".#nixosConfigurations.${HOST}.config.system.build.toplevel.drvPath" "$@" >/dev/null; echo "OK: $HOST evaluated";;
  --help|-h) echo "Usage: kryx check [--strict] [--host <name>]"; exit 0;;
  *)        "$NIX_BIN" --extra-experimental-features 'nix-command flakes' flake check --keep-going --impure "$@";;
esac
```

## Criterio de aceitacao

1. `kryx check` retorna 0 com `all checks passed!` no inspiron
2. `kryx check --host glacier` valida só glacier
3. `kryx check --strict` faz build (não eval)
4. Bypass documentado no AGENTS.md e linkado ao help do kryx

## Nao-objetivos

- NAO desativar o Kryonix Guard (continua protegendo `nix` interativo)
- NAO copiar o binario nix fora do /run/current-system (link simbolico basta)
- NAO introduzir `nix` no PATH do shell (mantem defesa em profundidade)

## Riscos

- Wrapper pode cair se Nix for reinstalado em path diferente. Mitigacao:
  variavel `KRYX_NIX_BIN` configuravel (com default sensato).
- Build em `--strict` consome ~46 GB de disco. Mitigacao: `--dry-run` flag
  e documentar espaco minimo.

## Rollback

- Remover o script `/etc/kryonix/scripts/kryx-check.sh`
- Remover a entrada no AGENTS.md
- Nenhum commit no flake.nix (puro script)

## Referencia

- Cartao Kolossal t_ac17626c (urgencia maxima, ja cria dependencia)
- kryonix-dev/AGENTS.md (regra dos agentes)
- ~/Proyectos/kryonix-dev/repos/kryonixos/AGENTS.md (Valid vs Build)
- Card t_03e3dfb6 (bug kryx switch, mesma raiz)

## Execução timestamps

- **Concluído:** `2026-07-30T21:26:15+00:00`

## Audits

This card is part of the following audit(s):

- `[kanban-drift-2026-08-04](../Audits/kanban-drift-2026-08-04/STATE.md)` — **Kanban × Vault drift audit** (2026-08-04)
  - 7 cards flagged for drift; 1 urgent (clobber-protection), 6 batch-reopen
## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-08-07T03:36:50+00:00` | `reopened` | {"from": "done", "to": "partial", "notes": "Reaberto: wrapper existe no source (kryx-cli/src/cli/check.rs), kryx 0.1.0 responde a kryx check --help, mas implementa\u00e7\u00e3o \u00e9 stub (wrapper va... |
| `2026-07-30T21:26:15+00:00` | `completed` | {"result_len": 17, "summary": "kryx check subcommand operational in PROD (validated via 'all checks passed!' on /home/rocha/Proyectos/kryonix-dev/repos/kryonixos flake, exit 0). Metadata version drift... |
| `2026-07-30T15:23:17+00:00` | `created` | {"assignee": "default", "status": "ready", "parents": [], "tenant": "kryonix", "workspace_kind": "scratch", "workspace_path": null, "branch_name": null, "project_id": null, "skills": null, "goal_mode"... |

## Execuções recentes

| Run ID | Status | Outcome | Início | Fim |
|--------|--------|---------|--------|-----|
| `289` | completed | completed | 2026-07-30T21:26:15+00:00 | 2026-07-30T21:26:15+00:00 |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T13:48:22.051696+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._