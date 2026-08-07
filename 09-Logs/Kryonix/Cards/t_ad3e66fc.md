---
card_id: t_ad3e66fc
status: scheduled
type: 
priority: 3
created_at: 2026-08-07T15:15:40+00:00
started_at: 
completed_at: 
last_sync_at: 2026-08-07T18:38:30.127513+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# [tech-debt][kryonix-assets] nixpkgs should follow motor (kryonix) — currently standalone

**Card:** `t_ad3e66fc` | **Status:** `scheduled`

## Descrição

kryonix-assets/flake.nix:5 currently pins nixpkgs directly to github:nixos/nixpkgs/nixos-unstable. Should follow kryonix motor via inputs.nixpkgs.follows = "kryonix/nixpkgs" for SSOT discipline. See 02-Areas/Kryonix/canonical/nixpkgs-versioning.md.

To fix:
1. Add kryonix input to kryonix-assets/flake.nix
2. Add inputs.nixpkgs.follows = "kryonix/nixpkgs"
3. Verify kryonix-assets still builds
4. Update kryonix-assets/flake.lock
5. Commit and PR

## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-08-07T15:15:47+00:00` | `scheduled` | {"reason": "Tech-debt: not urgent. Documented in 02-Areas/Kryonix/canonical/nixpkgs-versioning.md."} |
| `2026-08-07T15:15:47+00:00` | `commented` | {"author": "default", "len": 97} |
| `2026-08-07T15:15:40+00:00` | `created` | {"assignee": "default", "status": "ready", "parents": [], "tenant": "kryonix", "workspace_kind": "scratch", "workspace_path": null, "branch_name": null, "project_id": null, "skills": null, "goal_mode"... |

## Execuções recentes

| Run ID | Status | Outcome | Início | Fim |
|--------|--------|---------|--------|-----|
| `293` | scheduled | scheduled | 2026-08-07T15:15:47+00:00 | 2026-08-07T15:15:47+00:00 |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T18:38:30.127516+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._