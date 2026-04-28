---
title: "Idempotencia e Jobs"
type: area
status: active
area: backend
project: global
tags:
  - type/area
  - status/active
  - area/backend
  - eng/api
created: 2026-04-26
updated: 2026-04-26
---
# Idempotencia e Jobs

## Objetivo

Evitar duplicidade em operações retryáveis.

## Usar quando

- pagamento;
- criação de pedido;
- webhooks;
- jobs com retry;
- deploy/reconcile;
- operações distribuídas.

## Técnicas

- idempotency key;
- unique constraint;
- tabela de processamento;
- dedupe por evento;
- transação;
- lock.

## Links

- [[01-MOCs/Mapa - Backend e APIs]]
