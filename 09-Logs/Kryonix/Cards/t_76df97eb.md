---
card_id: t_76df97eb
status: scheduled
type: 
priority: 0
created_at: 2026-07-30T12:47:21+00:00
started_at: 
completed_at: 
last_sync_at: 2026-08-07T13:48:22.024475+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# Automatizar fallback de Secure Boot via kryonix

**Card:** `t_76df97eb` | **Status:** `scheduled`

## Descrição

Implementar automação que desative kryonix.features.secureboot.enable = false em caso de detecção de perda de chaves CMOS. Garantir que o sistema permaneça em estado seguro até regeneração criptográfica. Incluir logs e mecanismo de reativação automática pós-regeneração.

## Assignment

- **Criado por:** `auto-decomposer`
- **Assignee:** `default`

## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-07-30T14:33:41+00:00` | `scheduled` | {"reason": null} |
| `2026-07-30T13:55:46+00:00` | `status` | {"status": "todo"} |
| `2026-07-30T13:55:35+00:00` | `status` | {"status": "todo"} |
| `2026-07-30T12:47:21+00:00` | `linked` | {"parent": "t_28b1cd48", "child": "t_76df97eb"} |
| `2026-07-30T12:47:21+00:00` | `created` | {"by": "auto-decomposer", "from_decompose_of": "t_ae5ad7fd"} |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T13:48:22.024478+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._