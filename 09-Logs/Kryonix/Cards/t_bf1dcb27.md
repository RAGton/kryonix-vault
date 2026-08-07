---
card_id: t_bf1dcb27
status: scheduled
type: 
priority: 2
created_at: 2026-07-30T12:40:19+00:00
started_at: 2026-07-30T12:47:41+00:00
completed_at: 
last_sync_at: 2026-08-07T18:38:30.132541+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# [agents] LightRAG: limitar resposta a Top-K=3 e 3000 caracteres

**Card:** `t_bf1dcb27` | **Status:** `scheduled`

## Descrição

Limitar a resposta do LightRAG a Top-K=3 e 3000 caracteres para evitar crashes na janela de contexto dos agentes de IA. Isso requer ajustes na configuração de geração de resposta e validação de que os limites estão sendo respeitados durante a execução.

## Last failure

```
worker exited cleanly (rc=0) without calling kanban_complete or kanban_block — protocol violation
```

## Execução timestamps

- **Iniciado:** `2026-07-30T12:47:41+00:00`

## Assignment

- **Criado por:** `gabriel`
- **Assignee:** `aura-decision`

## Workspace

`/home/rocha/.hermes/kanban/boards/kryonix/workspaces/t_bf1dcb27`

## External ID

`jenpex-016-agents-lightrag-tokens`

## Eventos recentes

| Timestamp | Tipo | Payload |
|-----------|------|---------|
| `2026-07-30T14:33:42+00:00` | `scheduled` | {"reason": null} |
| `2026-07-30T13:58:41+00:00` | `gave_up` | {"failures": 4, "effective_limit": 1, "limit_source": "dispatcher", "error": "worker exited cleanly (rc=0) without calling kanban_complete or kanban_block — protocol violation", "trigger_outcome": "cr... |
| `2026-07-30T13:58:41+00:00` | `protocol_violation` | {"pid": 984529, "claimer": "inspiron:926619", "exit_code": 0} |
| `2026-07-30T13:57:12+00:00` | `heartbeat` | None |
| `2026-07-30T13:56:39+00:00` | `spawned` | {"pid": 984529} |
| `2026-07-30T13:56:39+00:00` | `claimed` | {"lock": "inspiron:926619", "expires": 1785420699, "run_id": 250} |
| `2026-07-30T13:56:39+00:00` | `promoted` | None |
| `2026-07-30T13:56:12+00:00` | `status` | {"status": "todo"} |
| `2026-07-30T13:56:05+00:00` | `status` | {"status": "ready"} |
| `2026-07-30T13:55:46+00:00` | `status` | {"status": "todo"} |

## Execuções recentes

| Run ID | Status | Outcome | Início | Fim |
|--------|--------|---------|--------|-----|
| `250` | crashed | crashed | 2026-07-30T13:56:39+00:00 | 2026-07-30T13:58:41+00:00 |
| `222` | reclaimed | reclaimed | 2026-07-30T13:55:38+00:00 | 2026-07-30T13:55:46+00:00 |
| `173` | crashed | crashed | 2026-07-30T13:40:35+00:00 | 2026-07-30T13:43:36+00:00 |
| `148` | crashed | crashed | 2026-07-30T13:37:33+00:00 | 2026-07-30T13:39:35+00:00 |
| `116` | crashed | crashed | 2026-07-30T13:35:30+00:00 | 2026-07-30T13:37:33+00:00 |

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T18:38:30.132545+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._