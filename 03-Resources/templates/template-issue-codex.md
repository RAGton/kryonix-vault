---
title: "Issue - <verbo curto + alvo>"
type: issue
status: open
tags: [issue, codex]
agent_target: codex | claude
repo: <ex: kryonix | kryonix-installer | kryonix-vault>
estimate: <ex: pequena | media | grande>
created: 2026-06-14
updated: 2026-06-14
---

# Issue — <verbo curto + alvo>

<context>
  Estado atual do repo/módulo, link para arquivo principal afetado, motivo
  pelo qual a mudança é necessária.
</context>

<task>
  Implementar <objetivo específico>. Saída esperada: diff pequeno e revisável.
</task>

<input>
  Arquivos relevantes:
  - <path/arquivo1.ext>
  - <path/arquivo2.ext>

  Linhas/funções-chave (se útil):
  - file:linha — descrição curta
</input>

<constraints>
  - menor mudança correta
  - sem refator global
  - sem novas dependências sem justificativa explícita
  - sem mudança de contrato público não solicitada
  - manter testes existentes passando
</constraints>

## Escopo permitido

- <arquivo/pasta 1>
- <arquivo/pasta 2>

## Fora do escopo

- refator global
- novas deps sem aval
- mudança de contrato público
- formatação de arquivos não tocados

<output_format>
  ```diff
  --- a/path/file
  +++ b/path/file
  @@ ...
  ```

  Mais:
  - resumo da abordagem (3 linhas)
  - notas de teste
</output_format>

<acceptance>
  - [ ] comportamento X implementado
  - [ ] teste Y criado/atualizado
  - [ ] documentação/contrato atualizado se necessário
  - [ ] sem regressão em testes existentes
</acceptance>

## Validação

```bash
just test
just lint
just check
```

<risks>
  - <risco 1>
  - <risco 2>
</risks>

## Links relacionados

- [[../../10-MOCs/Mapa - <Área>]]
- [[../templates/template-prompt]]
