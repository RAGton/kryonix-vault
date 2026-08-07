---
card_id: t_f6ac831b
status: scheduled
type: 
priority: 0
created_at: 2026-07-30T12:44:26+00:00
started_at: 2026-07-30T12:44:35+00:00
completed_at: 
last_sync_at: 2026-08-07T03:41:11.684653+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# Add 'switch check' subcommand to kryx-cli

**Card:** `t_f6ac831b` | **Status:** `scheduled`

## Descrição

Implement a new subcommand 'kryx switch check' in the kryx-cli Rust project. This command should be read-only and act as a pre-flight check before a real system switch. It must execute 'cargo check' and 'nix build .#default --no-link' sequentially, capture their outputs, and report success or failure with clear messages. The command should exit with a non-zero status if either step fails. Acceptance criteria: the subcommand is registered in the CLI parser, runs both commands, and exits appropriately based on results.

## Last failure

```
worker exited cleanly (rc=0) without calling kanban_complete or kanban_block — protocol violation
```

## Execução timestamps

- **Iniciado:** `2026-07-30T12:44:35+00:00`

## Assignment

- **Criado por:** `auto-decomposer`
- **Assignee:** `default`

## Workspace

`/home/rocha/.hermes/kanban/boards/kryonix/workspaces/t_f6ac831b`

## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-07-30T14:33:42+00:00` | `scheduled` | {"reason": null} |
| `2026-07-30T13:57:41+00:00` | `gave_up` | {"failures": 3, "effective_limit": 1, "limit_source": "dispatcher", "error": "worker exited cleanly (rc=0) without calling kanban_complete or kanban_block — protocol violation", "trigger_outcome": "cr... |
| `2026-07-30T13:57:41+00:00` | `protocol_violation` | {"pid": 984537, "claimer": "inspiron:926619", "exit_code": 0} |
| `2026-07-30T13:57:17+00:00` | `heartbeat` | None |
| `2026-07-30T13:56:40+00:00` | `spawned` | {"pid": 984537} |
| `2026-07-30T13:56:40+00:00` | `claimed` | {"lock": "inspiron:926619", "expires": 1785420700, "run_id": 258} |
| `2026-07-30T13:56:39+00:00` | `promoted` | None |
| `2026-07-30T13:56:12+00:00` | `status` | {"status": "todo"} |
| `2026-07-30T13:56:05+00:00` | `status` | {"status": "ready"} |
| `2026-07-30T13:56:05+00:00` | `promoted` | None |

## Execuções recentes

| Run ID | Status | Outcome | Início | Fim |
|--------|--------|---------|--------|-----|
| `258` | crashed | crashed | 2026-07-30T13:56:40+00:00 | 2026-07-30T13:57:41+00:00 |
| `230` | reclaimed | reclaimed | 2026-07-30T13:55:38+00:00 | 2026-07-30T13:55:46+00:00 |
| `198` | crashed | crashed | 2026-07-30T13:42:36+00:00 | 2026-07-30T13:43:36+00:00 |
| `178` | crashed | crashed | 2026-07-30T13:41:35+00:00 | 2026-07-30T13:42:36+00:00 |
| `147` | crashed | crashed | 2026-07-30T13:36:32+00:00 | 2026-07-30T13:37:33+00:00 |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T03:41:11.684657+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._