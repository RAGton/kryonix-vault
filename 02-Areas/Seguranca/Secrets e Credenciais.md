---
title: "Secrets e Credenciais"
type: area
status: active
area: seguranca
project: global
tags:
  - type/area
  - status/active
  - area/seguranca
  - eng/security
created: 2026-04-26
updated: 2026-04-26
---
# Secrets e Credenciais

## Objetivo

Evitar vazamento e uso inseguro de credenciais.

## Checklist

- [ ] `.env` fora do repo
- [ ] `.env.example` sem segredo
- [ ] rotação definida
- [ ] logs sanitizados
- [ ] permissões mínimas
- [ ] CI sem exposição de token

## Links

- [[06-Playbooks/Playbook - Auditoria de Secrets]]
