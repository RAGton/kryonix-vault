---
title: Kryonix Entity Schema
type: documentation
status: stub
tags: [kryonix, schema, entity, canonical, json]
project: kryonix
created: 2026-06-15
updated: 2026-06-15
---

# Kryonix Entity Schema

## Objetivo

Definir o schema JSON canônico para entidades do ecossistema Kryonix: hosts, services, repos, issues, PRs, commands. Usado para validação de registro automático de hosts no Kryonix Brain via mTLS.

## Resumo

Stub criado durante a criação de `Kryonix Installer - Requisitos Técnicos` (jun/2026). O schema real deve definir todos os campos obrigatórios e opcionais de cada tipo de entidade, com validação JSON Schema.

## Quando usar

- Ao implementar o registro automático de hosts no Kryonix Brain.
- Ao validar payloads de API do Kryonix Brain.
- Ao criar novas entidades no vault via templates.

## Procedimento / Conteúdo

- (vazio) — definir JSON Schema para cada tipo de entidade:
  - Host (IP, MAC, specs, status, tags)
  - Service (name, port, healthcheck, dependencies)
  - Repository (url, branch, description, owner)
  - Issue/PR (number, title, status, labels)
  - Command (name, args, description, execution context)

## Checklist

- [ ] Definir JSON Schema v1 para Host.
- [ ] Definir JSON Schema v1 para Service.
- [ ] Definir JSON Schema v1 para Repository.
- [ ] Adicionar validação em CI.
- [ ] Conectar com [[02-Areas/Kryonix/canonical/Architecture]].

## Riscos

Nota stub: schema não validado em produção.

## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]
- [[02-Areas/Kryonix/canonical/Architecture]]
- [[02-Areas/Kryonix/canonical/Install]]
- [[02-Areas/Kryonix/installer/Kryonix Installer - Requisitos Técnicos]]
- [[02-Areas/Kryonix/entities/Repositories/kryonix]]

## Próxima ação

Definir JSON Schema v1 para cada tipo de entidade.
