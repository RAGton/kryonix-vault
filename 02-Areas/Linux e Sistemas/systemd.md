---
title: "systemd"
type: area
status: active
area: linux
project: global
tags:
  - type/area
  - status/active
  - area/linux
  - linux/debug
created: 2026-04-26
updated: 2026-04-26
---
# systemd

## Objetivo

Gerenciar serviços Linux de forma confiável.

## Comandos

```bash
systemctl status nome.service
journalctl -u nome.service -f
systemctl daemon-reload
systemctl restart nome.service
```

## Hardening básico

- usuário dedicado;
- diretórios de estado;
- sandboxing;
- restart policy;
- logs claros;
- limites de recursos.

## Links

- [[01-MOCs/Mapa - Linux e Sistemas]]
- [[02-Areas/NixOS/Deploy e Rollback]]
