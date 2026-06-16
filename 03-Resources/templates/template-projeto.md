---
title: <Nome do Projeto>
type: project
status: draft
tags: [projeto]
area: <ex: backend | infra | ia>
owner: <responsável>
created: 2026-06-14
updated: 2026-06-14
deadline: <YYYY-MM-DD ou "sem prazo">
---

# <Nome do Projeto>

<context>
  <problema>Problema real que justifica o projeto.</problema>
  <usuario>Quem usa, em que cenário, com que frequência.</usuario>
  <motivacao>Por que agora, qual o custo de não fazer.</motivacao>
</context>

<task>
  Entregar MVP funcional de <X> até <data>, com <métrica de sucesso>.
</task>

<constraints>
  - Stack: <linguagens/frameworks fixos>
  - Orçamento: <horas/custo>
  - Segurança: <ex: zero secret em log, OAuth obrigatório>
  - Compatibilidade: <ex: rodar no Inspiron sem build pesado>
</constraints>

## Arquitetura

Diagrama curto ou bullets. Foco em componentes e fronteiras.

## Stack

- linguagem: <ex: Rust + TS>
- runtime: <ex: NixOS + systemd>
- dados: <ex: Postgres + Redis>
- IA: <ex: Ollama local + LightRAG>

## Contratos / API

OpenAPI, gRPC proto, JSON schema. Sempre versionado.

## Banco de dados

Tabelas principais, índices, migrations seguras.

## Segurança

- autenticação:
- autorização (object-level):
- secrets:
- rate limit:
- entrada validada na borda:

## Observabilidade

- logs estruturados sem PII
- métricas (latência p95, erro %)
- traces nos hot paths

## Deploy / Rollback

- ambiente:
- estratégia de rollback:
- generation NixOS anterior preservada:

## Custos

- infra:
- IA (tokens/mês):

## Backlog

Use TOON quando o backlog passar de 5 itens — economia real para o agente que
vai consumir esta nota.

```toon
backlog[6]{id,titulo,prio,status,owner}:
1,Setup repo,high,done,rocha
2,Schema inicial,high,wip,rocha
3,Auth JWT,high,todo,rocha
4,Endpoints CRUD,med,todo,rocha
5,Testes integração,med,todo,rocha
6,Doc OpenAPI,low,todo,rocha
```

## Decisões

- [[../../03-Resources/templates/template-adr|ADR-001 — ...]]
- ...

## Links relacionados

- [[../../01-MOCs/Mapa - Produto e SaaS]]
- [[../../01-MOCs/Mapa - Engenharia de Software]]

<acceptance>
  - [ ] MVP rodando em ambiente alvo
  - [ ] Testes mínimos passando
  - [ ] Documentação de uso pronta
  - [ ] Plano de rollback validado
</acceptance>

<risks>
  - Risco 1 + mitigação
  - Risco 2 + mitigação
</risks>
