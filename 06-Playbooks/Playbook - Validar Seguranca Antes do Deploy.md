---
title: "Playbook - Validar Seguranca Antes do Deploy"
type: playbook
status: active
area: null
project: global
tags:
  - type/playbook
  - status/active
created: 2026-04-26
updated: 2026-04-26
---
# Playbook - Validar Seguranca Antes do Deploy

## Objetivo

Bloquear riscos óbvios antes de produção.

## Checklist

- [ ] secrets fora do repo
- [ ] auth obrigatória onde precisa
- [ ] autorização por recurso
- [ ] input validation
- [ ] rate limit
- [ ] logs sem dados sensíveis
- [ ] dependências revisadas
- [ ] CI passa
- [ ] rollback definido

## Links

- [[01-MOCs/Mapa - Segurança]]
