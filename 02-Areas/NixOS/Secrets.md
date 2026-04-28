---
title: "Secrets"
type: area
status: active
area: nixos
project: global
tags:
  - type/area
  - status/active
  - area/nixos
  - nixos/modules
created: 2026-04-26
updated: 2026-04-26
---
# Secrets

## Objetivo

Gerenciar segredos sem vazar para repo, logs ou Nix store.

## Regras

- não commitar segredo;
- não colocar segredo em derivation output;
- não logar segredo;
- usar mecanismo aprovado como sops-nix, agenix ou Vault;
- documentar rotação.

## Links

- [[01-MOCs/Mapa - Segurança]]
- [[06-Playbooks/Playbook - Auditoria de Secrets]]
