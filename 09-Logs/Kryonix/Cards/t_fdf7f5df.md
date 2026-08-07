---
card_id: t_fdf7f5df
status: ready
type: 
priority: 2
created_at: 2026-08-07T03:37:46+00:00
started_at: 
completed_at: 
last_sync_at: 2026-08-07T18:38:30.105899+00:00
last_kanban_state: ready
result: None
auto_generated: true
audits: []
---

# [bug][kryonix-guard] nix flake check quebrado em background

**Card:** `t_fdf7f5df` | **Status:** `ready`

## Descrição

Kryonix Guard (shim /etc/profiles/per-user/rocha/bin/nix) bloqueia nix direto em shell interativo. Em background tasks (cron, agents, scripts) deveria permitir. Hoje: retorna exit 1 sem executar. Bug separado de t_ac17626c. Fix: bypass oficial PATH=/run/current-system/sw/bin:/run/wrappers/bin:/usr/bin:/usr/local/bin nix --extra-experimental-features nix-command flakes ... funciona, mas deve ser documentado como interface estável.

## Assignment

- **Criado por:** `aura`
- **Assignee:** `default`

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T18:38:30.105903+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._