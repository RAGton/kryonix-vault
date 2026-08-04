---
title: "Loop <loop-id> — <tópico>"
type: loop-state
status: active
tags: [loop, kryonix, autonomous]
loop_id: "<YYYY-MM-DD>-<kebab-topic>"
autonomy: L0 | L1 | L2 | L3 | L4
objective: "<uma sentença imperativa>"
metrics: "<comma-separated, ex: build green,tests pass,docs updated>"
boundary: "<o que está FORA do escopo>"
created: 2026-08-04
updated: 2026-08-04
human_gate_required: true | false
---

# Loop <loop-id> — <tópico>

> **Projeto:** [[03-Projetos/<Projeto>]] · **Área:** [[01-MOCs/Mapa - <Área>]]
>
> **Autonomy:** L0 (read) · L1 (suggest) · L2 (code+human review) · L3 (ops+human gate) · L4 (never autonomous)

<context>
  Por que este loop existe. Qual objetivo concreto, qual boundary, qual
  métrica define sucesso. Incluir referência ao objective/metrics/boundary
  definidos antes do kickoff.
</context>

## STATE — Estado Atual

```yaml
loop_id: <loop-id>
status: active | paused | closed | blocked
current_tick: <N>
started_at: <YYYY-MM-DD HH:MM>
last_update: <YYYY-MM-DD HH:MM>
budget_consumed:
  commands: <N>/<max>
  time_minutes: <N>/<max>
  tokens_estimate: <low|medium|high>
```

## Próxima ação

<um bullet único, imperativo, executável agora>

## Bloqueios ativos

- <bloqueio 1 com owner>

## EVENTS — Histórico

Registrar em `EVENTS.jsonl` (um evento por linha, NDJSON):

```jsonl
{"ts":"2026-08-04T14:30:00","tick":1,"actor":"aura","action":"read STATE","outcome":"ok","ref":"STATE.md"}
{"ts":"2026-08-04T14:31:12","tick":2,"actor":"aura","action":"git status --short","outcome":"clean","ref":"repos/kryonix"}
{"ts":"2026-08-04T14:35:00","tick":3,"actor":"aura","action":"edit modules/x.nix","outcome":"applied","ref":"hash abc123"}
{"ts":"2026-08-04T14:36:00","tick":4,"actor":"aura","action":"nix flake check","outcome":"fail","ref":"error: undefined variable Y","rollback":"git checkout modules/x.nix"}
```

Schema por evento:

```text
ts        ISO-8601 timestamp
tick      número sequencial do tick
actor     aura | codex | claude | human
action    verbo imperativo curto (read/edit/run/test/build/commit)
outcome   ok | fail | partial | blocked
ref       caminho/URL/hash do artefato
rollback  comando que desfaz, se aplicável
```

## EVIDENCE — Comprovações

Arquivo `EVIDENCE.md` contém: outputs literais de `cargo test`, `nix flake check`,
`obsidian search`, screenshots, diffs. **Não resuma**: copie o stdout real.

```bash
# Exemplo: trecho de EVIDENCE.md
$ cargo test --workspace
   Compiling kryx v0.3.0
    Finished `test` profile [unoptimized + debuginfo] in 12.34s
     Running unittests src/lib.rs
test result: ok. 142 passed; 0 failed; 0 ignored
```

## FINAL_REPORT — Fechamento

Preencher **somente ao fechar o loop** (status: closed).

```yaml
objective_met: true | false | partial
metrics_achieved:
  - "<metric>: <value>"
deviations:
  - "<o que mudou vs o plano>"
follow_up:
  - loop-id: "<próximo-loop>"
    reason: "<por que>"
```

### Resumo executivo

<3-5 bullets do que foi decidido, construído, validado.>

### Evidências canônicas

- [[../Loops/<loop-id>/EVIDENCE|EVIDENCE]]
- <links pros commits/PRs/docs gerados>

### Pendências transferidas

- <item com owner>

## Conexões

- [[01-MOCs/Mapa - <Área>]] — MOC pai
- [[03-Projetos/<Projeto>]] — projeto afetado
- [[../sessions/<YYYY-MM-DD>-<topic>|Session wrap]] — resumo da sessão

## Regras de operação

- L0: só leitura — livre.
- L1: leitura + sugestão — livre.
- **L2**: edição de código — exige human review antes de merge.
- **L3**: operação em runtime/prod — exige human gate explícito.
- **L4**: nunca autônomo — sempre humano no loop.

Nunca misturar escopos. Fechar este loop (mesmo parcial com drift documentado
e follow-up) antes de abrir o próximo.