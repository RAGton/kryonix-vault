---
card_id: t_adbd3ed6
status: scheduled
type: 
priority: 3
created_at: 2026-08-07T13:48:16+00:00
started_at: 
completed_at: 
last_sync_at: 2026-08-07T13:48:22.028892+00:00
last_kanban_state: scheduled
result: None
auto_generated: true
audits: []
---

# [tech-debt][kanban-sync] smart sync: só atualiza last_sync_at se houve mudança real

**Card:** `t_adbd3ed6` | **Status:** `scheduled`

## Descrição

## Problema
kanban-sync v1 atualiza `last_sync_at` em **TODOS os 99 cards** a cada sync, mesmo que nada tenha mudado.

Resultado:
- 97 cards com drift acumulado entre syncs
- Polui git history do vault com commits feios ("97 timestamp updates")
- Dificulta revisão real do que mudou
- Mascara mudanças reais (timestamps artificiais competem com mudanças legítimas)

## Sintoma observado
Apos 1 sync do kanban-sync: 97 cards modificados + 1 novo + 2 metadata = 100 arquivos. Destes, 97 sao so timestamp.

## Fix v2
Comparar campos relevantes antes de escrever:

```python
def render_card_markdown(card) -> tuple[str, bool]:
    new_md = build_markdown(card)
    old_md = read_existing(card.id)  # do vault
    has_changed = (new_md != old_md) or (old_md is None)
    return new_md, has_changed
```

`sync_card` deve pular o `write` se `has_changed == False`, exceto na primeira vez (criacao).

## Criterios de mudanca real
Comparar:
- `status`
- `priority`
- `body`
- `task_events` novos desde ultimo sync (por ID)
- `task_runs` novos desde ultimo sync (por ID)
- `result` field
- `completed_at`

**NAO comparar**: `last_sync_at` (e o que estamos evitando atualizar), `claim_lock`, `claim_expires` (runtime state).

## Esforco
~30-60min.

## Mudancas necessarias
1. `kanban-sync.py` `render_card_markdown()` retorna tupla
2. `kanban-sync.py` `sync_card()` checa `has_changed` antes de write
3. Adicionar flag `--force` pra bypassar (full resync quando quiser)
4. Manter `--check` funcionando (drift = has_changed E last_sync_at divergente)

## Compatibilidade
- Output structure no vault: identico
- Logs: adicionar "skipped N cards (no change)"
- Frontmatter: identico (last_sync_at so atualiza quando muda)

## Bloqueia
Nada urgente. So qualidade do sync.

## Assignment

- **Criado por:** `aura`

---

_Auto-gerado por `kanban-sync.py` em 2026-08-07T13:48:22.028896+00:00. Para parar de sobrescrever, adicione `<!-- manual-override -->` no topo. Para editar metadados, edite o card no Kanban (este arquivo é derivado)._