---
card_id: t_fcd2ec73
status: ready
type: 
priority: 2
created_at: 2026-08-07T03:37:46+00:00
started_at: 
completed_at: 
last_sync_at: 2026-08-07T03:41:11.555076+00:00
last_kanban_state: ready
result: None
auto_generated: true
audits: []
---

# [bug][kanban-ui] UI Kanban dessincronizada (estado vs display)

**Card:** `t_fcd2ec73` | **Status:** `ready`

## Descrição

UI do Kanban mostra estado que não corresponde ao SQLite. Exemplos vistos: t_aa0e609b done na UI mas result=None real; t_37589718 done na UI mas sem implementação. Bug separado de t_ac17626c. Próximo: investigar root cause (cache stale? optimistic update? falta de reload?).

## Assignment

- **Criado por:** `aura`
- **Assignee:** `default`

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T03:41:11.555080+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._