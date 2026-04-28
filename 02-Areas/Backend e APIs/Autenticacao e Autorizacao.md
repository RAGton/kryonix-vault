---
title: "Autenticacao e Autorizacao"
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
# Autenticacao e Autorizacao

## Objetivo

Separar identidade de permissão.

## Definições

- Autenticação: quem é o usuário/serviço.
- Autorização: o que ele pode fazer.

## Checklist

- [ ] O endpoint exige identidade?
- [ ] O recurso pertence ao usuário/tenant?
- [ ] Há teste de acesso negado?
- [ ] IDs controlados pelo usuário são verificados?
- [ ] Logs não expõem tokens?

## Links

- [[01-MOCs/Mapa - Segurança]]
- [[05-Skills/revisao-seguranca-api/SKILL]]
