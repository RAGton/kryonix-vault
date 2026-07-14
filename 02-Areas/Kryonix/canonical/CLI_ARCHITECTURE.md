---
title: Arquitetura de CLIs (Server vs Client)
type: architecture_decision
status: active
projeto: kryonix
componente: cli
validado_em: 2026-07-13
tags: [kryonix, cli, ragc, kryx, pxe, diskless]
---

# Arquitetura de CLIs: Server vs Client

Após a unificação dos repositórios legados do ecossistema (`ragos` e `ragos-installer`) para dentro do monorepo principal `kryonix`, a arquitetura "Dual-CLI" foi estrategicamente mantida. 

Havia a necessidade de separar a gestão de infraestrutura de **Host (Servidor)** da gestão de infraestrutura de **Endpoints (Clientes Diskless)**. Atualmente, a operação funciona com dois motores distintos, agora nativamente integrados como pacotes Nix no ecossistema:

## 1. `kryx` (O Gerenciador do Servidor)
- **Tecnologia**: Rust (Workspace Unificado com o `kryonix-installer`).
- **Localização**: `repos/kryonix/packages/kryx/`
- **Escopo**: É o cérebro que opera e modifica o **servidor host**.
- **Como funciona**: Ele absorveu as responsabilidades do antigo `ragos-installer` e das reconstruções do NixOS local (`switch`). Recebe o `InstallPlanV2`, traduz para configurações Nix nativas (através de sua nova `Translator API` em `lib.rs`) e roda os deploys e diagnósticos físicos da máquina hospedeira.

## 2. `ragc` (O Gerenciador da Imagem do Cliente)
- **Tecnologia**: Shell Bash Avançado estruturado como pacote Nix (`pkgs.writeShellApplication`).
- **Localização**: `repos/kryonix/modules/ragos/core/ragc/`
- **Escopo**: Focado estritamente no lifecycle da **imagem do cliente diskless (PXE)**.
- **O status de deploy do cliente**: O `ragc` está **pronto e fully-featured** para gerenciar os binários (`bzImage`, `initrd`) nos canais de PXE HTTP (`/srv/http/netboot`). 
- **Como funciona**: 
  - Ele opera os comandos `publish`, `rollback`, `gc`, `switch` e `status`.
  - Controla os links simbólicos das gerações NixOS do cliente no servidor (`/srv/data/images`), garantindo previsibilidade para as máquinas atreladas na topologia *Think*.
  - *Nota Roadmap:* A emissão de SquashFS/netboot ainda é mantida como milestone em evolução, mas a mecânica de versionamento e roteamento pelo `ragc` que suporta esses clientes já está ativa na infraestrutura.

## Integração Monorepo
Essa topologia isola o risco. Ao realizar um deploy do servidor (`kryx switch`), a imagem que o cliente PXE enxerga via HTTP (`ragc status`) permanece intocável, prevenindo falhas em cascata nos endpoints quando o backend sofre manutenção.
