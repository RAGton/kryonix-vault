---
card_id: t_bb8c7db5
status: scheduled
type: 
priority: 3
created_at: 2026-08-07T15:15:39+00:00
started_at: 
completed_at: 
last_sync_at: 2026-08-07T19:38:07.020739+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# [tech-debt][kryx-cli] nixpkgs should follow motor (kryonix) — currently standalone

**Card:** `t_bb8c7db5` | **Status:** `scheduled`

## Descrição

kryx-cli/flake.nix:5 currently pins nixpkgs directly to github:NixOS/nixpkgs/nixos-unstable. Should follow kryonix motor via inputs.nixpkgs.follows = "kryonix/nixpkgs" for SSOT discipline. See 02-Areas/Kryonix/canonical/nixpkgs-versioning.md.

To fix:
1. Add kryonix input to kryx-cli/flake.nix
2. Add inputs.nixpkgs.follows = "kryonix/nixpkgs"
3. Verify kryx-cli still builds: nix flake check --keep-going --impure
4. Update kryx-cli/flake.lock
5. Commit and PR

Also: github:NixOS -> github:nixos (lowercase) for naming consistency.

## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-08-07T15:15:46+00:00` | `scheduled` | {"reason": "Tech-debt: not urgent. Documented in 02-Areas/Kryonix/canonical/nixpkgs-versioning.md."} |
| `2026-08-07T15:15:46+00:00` | `commented` | {"author": "default", "len": 97} |
| `2026-08-07T15:15:39+00:00` | `created` | {"assignee": "default", "status": "ready", "parents": [], "tenant": "kryonix", "workspace_kind": "scratch", "workspace_path": null, "branch_name": null, "project_id": null, "skills": null, "goal_mode"... |

## Execuções recentes

| Run ID | Status | Outcome | Início | Fim |
|--------|--------|---------|--------|-----|
| `292` | scheduled | scheduled | 2026-08-07T15:15:46+00:00 | 2026-08-07T15:15:46+00:00 |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T19:38:07.020743+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._