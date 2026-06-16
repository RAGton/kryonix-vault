---
title: <Nome da Skill>
type: skill
status: active
tags: [skill]
category: <ex: revisao | analise | geracao | debug>
agent_target: claude | codex | kryonix-brain | any
token_budget: <ex: ~2k input / ~1k output>
created: 2026-06-14
updated: 2026-06-14
---

# Skill: <Nome>

<context>
  Esta Skill encapsula um workflow recorrente. Substitui prompts longos
  repetidos pelo equivalente "use a Skill X com entrada Y".
</context>

<task>
  <descrever em 1 frase o que a Skill produz>
</task>

## Quando usar

- gatilho 1
- gatilho 2
- gatilho 3

## Quando não usar

- anti-gatilho 1
- anti-gatilho 2

<input>
  Campos esperados:
  - objetivo (string)
  - contexto curto (string, máx 500 tokens)
  - arquivos/links relevantes (lista)
  - restrições (lista)
  - critério de aceite (string)
</input>

<output_format>
  ```md
  # Diagnóstico
  ...
  # Plano curto
  ...
  # Recomendações / Patch
  ...
  # Checklist de validação
  - [ ] ...
  # Riscos restantes
  - ...
  ```
</output_format>

## Procedimento

1. Confirmar escopo (rejeitar se ambíguo).
2. Identificar risco principal antes de qualquer recomendação.
3. Aplicar a menor mudança correta.
4. Separar fato, prática, opinião, hipótese.
5. Sugerir validação executável.

<constraints>
  - sem hype
  - sem secrets
  - sem refator global sem ordem explícita
  - sem invenção de API/biblioteca
</constraints>

<examples>
  <example>
    <input>Objetivo: revisar PR #42 de auth JWT</input>
    <output>Diagnóstico: faltam testes de expiração e revogação ...</output>
  </example>
</examples>

<acceptance>
  - [ ] escopo respeitado
  - [ ] saída no formato exato
  - [ ] trade-offs explícitos
  - [ ] links Obsidian adicionados quando útil
</acceptance>

<risks>
  - recomendação genérica
  - falso senso de segurança
  - aceitar saída de IA sem revisão humana
</risks>

## Como economiza tokens

Centraliza instruções recorrentes. O usuário envia apenas o contexto variável.
Estimativa: economia de ~70% em tokens de input para uso repetido.

## Prompt base

```txt
Use a Skill "<Nome>".

Objetivo: <objetivo>
Contexto: <contexto curto>
Entrada: <dados/arquivos relevantes>
Restrições: <restrições>
Saída esperada: ver <output_format>
Critério de aceite: <validação>
```

## Links relacionados

- [[../../01-MOCs/Mapa - <Área>]]
- [[../templates/template-prompt]]
