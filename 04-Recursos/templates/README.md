---
title: Convenções dos Templates
type: meta
tags: [template, convencoes, kryonix-vault]
created: 2026-06-14
updated: 2026-06-14
---

# Convenções dos Templates Kryonix Vault

Templates pensados para **dois consumidores**: humano (Obsidian) e agentes de IA
(Claude, Codex, Kryonix Brain). A estrutura segue três camadas.

## 1. YAML Frontmatter — Properties do Obsidian

Cada nota começa com frontmatter parseável (filtros, Dataview, sort). Campos
mínimos:

```yaml
---
title: <título legível>
type: project | adr | nota | skill | playbook | prompt | moc | log | issue
status: draft | active | done | archived
tags: [t1, t2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Adicione campos específicos por tipo (ex.: `severity` em ADR, `category` em
skill). Mantenha tudo lower-case e kebab-case — Obsidian é case-sensitive em
properties.

## 2. XML Tags Claude — para Agentes de IA

Use tags XML semânticas dentro do corpo Markdown para sinalizar ao LLM o papel
de cada bloco. Práticas oficiais Anthropic recomendam:

| Tag                | Quando usar                                              |
| ------------------ | -------------------------------------------------------- |
| `<context>`        | informações de fundo, estado atual, motivação            |
| `<task>`           | o que precisa ser feito (verbo imperativo)               |
| `<input>`          | dados/arquivos/links que o agente deve consumir          |
| `<constraints>`    | regras invioláveis (segurança, escopo, custo)            |
| `<output_format>`  | formato exato esperado (markdown, json, código, …)       |
| `<examples>`       | 1-3 exemplos curtos (few-shot)                           |
| `<acceptance>`     | critérios objetivos de pronto                            |
| `<risks>`          | falhas conhecidas, anti-padrões                          |

Tags XML são tokens baratos, drasticamente reduzem ambiguidade, e funcionam em
Markdown sem quebrar a renderização do Obsidian.

## 3. TOON — só para listas com alta redundância

TOON (Token Oriented Object Notation) elimina repetição de chaves em arrays.
Use dentro de bloco fenced quando a nota contiver listas que o agente vai
consumir e que se repetem.

```toon
items[8]{id,titulo,prio,status}:
1,Setup repo,high,done
2,Auth JWT,high,wip
3,Migration users,med,todo
```

**Quando usar TOON**

- backlog com mais de 5 itens
- catálogo de comandos/endpoints
- listagem de hosts/serviços
- memória/contexto injetado em prompt do agente
- qualquer array onde o nome do campo é maior que o valor

**Quando NÃO usar TOON**

- prosa, parágrafos, runbook narrativo
- listas curtas (até cerca de 5 itens) — Markdown bullets é mais legível
- conteúdo que humanos vão editar com frequência (TOON é fácil de quebrar)
- armazenamento de longo prazo — TOON é formato de transmissão, não de
  storage. JSON/YAML continuam sendo a fonte de verdade.

A economia de tokens chega a 53% em arrays grandes. Em objetos simples,
3-11%.

## Fluxo de uso

1. Escolha o template (`template-<tipo>.md`) e copie para a pasta correta.
2. Preencha o YAML frontmatter — todos os campos não opcionais.
3. Substitua placeholders `<...>` pelo conteúdo real.
4. Mantenha as tags XML — não substitua por headings Markdown, isso quebra o
   contrato com os agentes.
5. Converta listas grandes para TOON só se elas serão consumidas por IA.

## Lista de templates

- [[template-projeto]] — projeto PARA
- [[template-adr]] — decisão arquitetural
- [[template-nota-tecnica]] — conhecimento reutilizável
- [[template-skill]] — Skill para agente
- [[template-playbook]] — procedimento operacional
- [[template-prompt]] — prompt reutilizável
- [[template-moc]] — Map of Content
- [[template-issue-codex]] — issue pequena para Codex/Claude
- [[template-daily-log]] — log diário/decisões


- [[template-loop]] — Autonomous engineering loop (STATE/EVENTS/EVIDENCE/FINAL_REPORT, L0–L4)