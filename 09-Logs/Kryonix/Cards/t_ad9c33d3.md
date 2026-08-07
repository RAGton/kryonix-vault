---
card_id: t_ad9c33d3
status: scheduled
type: 
priority: 0
created_at: 2026-07-30T12:49:29+00:00
started_at: 2026-07-30T12:49:29+00:00
completed_at: 
last_sync_at: 2026-08-07T03:41:11.614389+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# Research and select unified font packages for terminal and UI

**Card:** `t_ad9c33d3` | **Status:** `scheduled`

## Descrição

Research font packages suitable for both terminal and UI usage with HiDPI scaling support. Consider fonts like Fira Code, JetBrains Mono, or Cascadia Code for terminal use, and Noto, Inter, or Roboto for UI. Ensure selected fonts support HiDPI scaling and are available in Nixpkgs. Document the chosen font packages with their Nix attribute paths for terminal and UI contexts.

## Last failure

```
worker exited cleanly (rc=0) without calling kanban_complete or kanban_block — protocol violation
```

## Execução timestamps

- **Iniciado:** `2026-07-30T12:49:29+00:00`

## Assignment

- **Criado por:** `auto-decomposer`
- **Assignee:** `aura-decision`

## Workspace

`/home/rocha/.hermes/kanban/boards/kryonix/workspaces/t_ad9c33d3`

## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-07-30T14:33:41+00:00` | `scheduled` | {"reason": null} |
| `2026-07-30T13:58:41+00:00` | `gave_up` | {"failures": 3, "effective_limit": 1, "limit_source": "dispatcher", "error": "worker exited cleanly (rc=0) without calling kanban_complete or kanban_block — protocol violation", "trigger_outcome": "cr... |
| `2026-07-30T13:58:41+00:00` | `protocol_violation` | {"pid": 984553, "claimer": "inspiron:926619", "exit_code": 0} |
| `2026-07-30T13:57:15+00:00` | `heartbeat` | None |
| `2026-07-30T13:56:40+00:00` | `spawned` | {"pid": 984553} |
| `2026-07-30T13:56:40+00:00` | `claimed` | {"lock": "inspiron:926619", "expires": 1785420700, "run_id": 271} |
| `2026-07-30T13:56:39+00:00` | `promoted` | None |
| `2026-07-30T13:56:12+00:00` | `status` | {"status": "todo"} |
| `2026-07-30T13:56:06+00:00` | `status` | {"status": "ready"} |
| `2026-07-30T13:56:05+00:00` | `promoted` | None |

## Execuções recentes

| Run ID | Status | Outcome | Início | Fim |
|--------|--------|---------|--------|-----|
| `271` | crashed | crashed | 2026-07-30T13:56:40+00:00 | 2026-07-30T13:58:41+00:00 |
| `243` | reclaimed | reclaimed | 2026-07-30T13:55:39+00:00 | 2026-07-30T13:55:46+00:00 |
| `214` | crashed | crashed | 2026-07-30T13:43:36+00:00 | 2026-07-30T13:44:37+00:00 |
| `190` | crashed | crashed | 2026-07-30T13:41:35+00:00 | 2026-07-30T13:43:36+00:00 |
| `161` | crashed | crashed | 2026-07-30T13:37:33+00:00 | 2026-07-30T13:39:35+00:00 |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T03:41:11.614393+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._