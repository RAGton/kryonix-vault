---
title: Kryonix Host Inventory
type: documentation
status: stub
tags: [kryonix, hosts, inventory, hardware, provisioning]
project: kryonix
created: 2026-06-15
updated: 2026-06-15
---

# Kryonix Host Inventory

## Objetivo

Inventário centralizado de hosts físicos e virtuais do ecossistema Kryonix: specs, localização, status, role, associação a projetos.

## Resumo

Stub criado durante a criação de `Kryonix Installer - Requisitos Técnicos` (jun/2026). O inventário real deve listar todos os hosts gerenciados pelo ecossistema, com specs completas e status de provisioning.

## Quando usar

- Ao provisionar novo host via Kryonix Installer.
- Ao auditar capacidade do homelab.
- Ao planejar capacidade para novos workloads.
- Ao registrar host no Kryonix Brain pós-instalação.

## Procedimento / Conteúdo

- (vazio) — preencher com inventário por host:
  - Identificação: hostname, IP, MAC, localização física
  - Specs: CPU, RAM, storage (tipo, tamanho, ZFS pool), GPU
  - Estado: provisionado, em uso, manutenção, descomissionado
  - Role: brain-node, worker, storage, gateway, dev
  - Associação: projeto Kryonix, RAGOS, etc.
  - Histórico: data de provisionamento, última atualização

## Checklist

- [ ] Inventariar Glacier (host principal).
- [ ] Inventariar Inspiron (host secundário).
- [ ] Definir campos padrão de inventário.
- [ ] Conectar com [[02-Areas/Kryonix/hosts/MOC - Hosts]].

## Riscos

Nota stub: inventário desatualizado leva a decisões erradas de provisionamento.

## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]
- [[01-MOCs/Mapa - Proxmox PXE NFS Homelab]]
- [[02-Areas/Kryonix/hosts/MOC - Hosts]]
- [[02-Areas/Kryonix/hosts/Glacier]]
- [[02-Areas/Kryonix/hosts/Inspiron]]
- [[02-Areas/Kryonix/installer/Kryonix Installer - Requisitos Técnicos]]

## Próxima ação

Inventariar hosts existentes (Glacier, Inspiron) e definir campos padrão.
