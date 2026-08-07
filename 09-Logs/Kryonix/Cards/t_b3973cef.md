---
card_id: t_b3973cef
status: scheduled
type: 
priority: 0
created_at: 2026-07-30T12:53:24+00:00
started_at: 2026-07-30T12:53:24+00:00
completed_at: 
last_sync_at: 2026-08-07T18:38:30.130012+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# Configurar Plymouth para identidade visual única

**Card:** `t_b3973cef` | **Status:** `scheduled`

## Descrição

Selecionar ou instalar um tema do Plymouth que reflita a identidade visual desejada (ex: 'spinner', 'details', ou um tema customizado). Defin-lo como padrão via sudo plymouth-set-default-theme <tema>. Garantir que o Plymouth inicie precocemente no boot (verificar /etc/initramfs-tools/conf.d/splash e adicionar 'splash' se ausente) e rode sudo update-initramfs -u. Critério de aceitação: a animação do Plymouth aparece imediatamente após o GRUB e dura até o carregamento do SDDM, sem piscar ou mostrar mensagens do kernel.

## Last failure

```
worker exited cleanly (rc=0) without calling kanban_complete or kanban_block — protocol violation
```

## Execução timestamps

- **Iniciado:** `2026-07-30T12:53:24+00:00`

## Assignment

- **Criado por:** `auto-decomposer`
- **Assignee:** `aura-decision`

## Workspace

`/home/rocha/.hermes/kanban/boards/kryonix/workspaces/t_b3973cef`

## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-07-30T14:33:42+00:00` | `scheduled` | {"reason": null} |
| `2026-07-30T13:58:41+00:00` | `gave_up` | {"failures": 3, "effective_limit": 1, "limit_source": "dispatcher", "error": "worker exited cleanly (rc=0) without calling kanban_complete or kanban_block — protocol violation", "trigger_outcome": "cr... |
| `2026-07-30T13:58:41+00:00` | `protocol_violation` | {"pid": 984558, "claimer": "inspiron:926619", "exit_code": 0} |
| `2026-07-30T13:57:13+00:00` | `heartbeat` | None |
| `2026-07-30T13:56:40+00:00` | `spawned` | {"pid": 984558} |
| `2026-07-30T13:56:40+00:00` | `claimed` | {"lock": "inspiron:926619", "expires": 1785420700, "run_id": 276} |
| `2026-07-30T13:56:39+00:00` | `promoted` | None |
| `2026-07-30T13:56:12+00:00` | `status` | {"status": "todo"} |
| `2026-07-30T13:56:06+00:00` | `status` | {"status": "ready"} |
| `2026-07-30T13:56:05+00:00` | `promoted` | None |

## Execuções recentes

| Run ID | Status | Outcome | Início | Fim |
|--------|--------|---------|--------|-----|
| `276` | crashed | crashed | 2026-07-30T13:56:40+00:00 | 2026-07-30T13:58:41+00:00 |
| `248` | reclaimed | reclaimed | 2026-07-30T13:55:39+00:00 | 2026-07-30T13:55:46+00:00 |
| `219` | crashed | crashed | 2026-07-30T13:43:37+00:00 | 2026-07-30T13:45:37+00:00 |
| `195` | crashed | crashed | 2026-07-30T13:41:36+00:00 | 2026-07-30T13:43:36+00:00 |
| `166` | crashed | crashed | 2026-07-30T13:37:34+00:00 | 2026-07-30T13:39:35+00:00 |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T18:38:30.130019+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._