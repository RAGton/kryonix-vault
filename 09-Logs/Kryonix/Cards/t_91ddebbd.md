---
card_id: t_91ddebbd
status: scheduled
type: 
priority: 0
created_at: 2026-07-30T12:44:26+00:00
started_at: 
completed_at: 
last_sync_at: 2026-08-06T00:06:47.487771+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# Integrate audit script into 'switch check' subcommand

**Card:** `t_91ddebbd` | **Status:** `scheduled`

## Descrição

Connect the 'switch check' subcommand implementation to the audit verification script. Ensure the subcommand invokes the script, relays its output to the user, and propagates the exit code. Add any necessary error handling for cases where the script is missing or fails to execute. Acceptance criteria: running 'kryx switch check' triggers the audit script, displays results, and exits with the script's status code.

## Assignment

- **Criado por:** `auto-decomposer`
- **Assignee:** `default`

## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-07-30T14:33:41+00:00` | `scheduled` | {"reason": null} |
| `2026-07-30T13:55:46+00:00` | `status` | {"status": "todo"} |
| `2026-07-30T13:55:35+00:00` | `status` | {"status": "todo"} |
| `2026-07-30T12:44:26+00:00` | `linked` | {"parent": "t_97b982f7", "child": "t_91ddebbd"} |
| `2026-07-30T12:44:26+00:00` | `linked` | {"parent": "t_f6ac831b", "child": "t_91ddebbd"} |
| `2026-07-30T12:44:26+00:00` | `created` | {"by": "auto-decomposer", "from_decompose_of": "t_b1e7d239"} |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-06T00:06:47.487775+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._