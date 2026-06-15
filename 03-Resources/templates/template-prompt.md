---
title: "Prompt - <Nome>"
type: prompt
status: active
tags: [prompt]
role: <ex: arquiteto-senior | revisor-seguranca | debug-prod>
agent_target: claude | codex | kryonix-brain | any
model_hint: <ex: opus-4.7 | sonnet-4.6 | haiku-4.5>
context_size: <ex: ~3k tokens>
created: 2026-06-14
updated: 2026-06-14
---

# Prompt — <Nome>

<context>
  Para que serve este prompt e quando usá-lo. Quem é o público (humano que vai
  enviar) e o agente que vai executar.
</context>

## Prompt copiável

```txt
<role>
Você é <papel específico> com experiência em <domínio>.
</role>

<context>
<resumo do estado/projeto/repo necessário para a tarefa>
</context>

<task>
<tarefa em verbo imperativo, escopo bem definido>
</task>

<input>
- <campo 1>
- <campo 2>
- <campo 3>
</input>

<constraints>
- menor mudança correta
- sem refator global sem pedido explícito
- sem invenção de API
- secrets nunca em log/repo
- separar fato, boa prática, opinião, hipótese
</constraints>

<output_format>
# Plano
# Diff/Implementação
# Testes
# Riscos
# Validação
# Próxima ação
</output_format>

<acceptance>
- [ ] saída no formato exato
- [ ] cobre todos os <campos críticos>
- [ ] sem alucinação
</acceptance>
```

## Quando usar

- gatilho 1
- gatilho 2

## Quando NÃO usar

- anti-gatilho 1

## Exemplo de chamada

```txt
<role>Você é arquiteto backend sênior...</role>
<context>Repo Kryonix Brain, FastAPI + LightRAG, ...</context>
<task>Propor schema Postgres para tabela `documents`...</task>
...
```

<risks>
  - prompt genérico demais → saída inútil
  - falta de constraints → modelo "sai do trilho"
</risks>

## Links relacionados

- [[../templates/template-skill]]
- [[../../10-MOCs/Mapa - <Área>]]
