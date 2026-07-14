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

Após a unificação dos repositórios legados do ecossistema (`ragos` e `ragos-installer`) para dentro do monorepo principal `kryonix`, a arquitetura evoluiu para uma abordagem **Single Consolidated CLI (`kryx node`)**.

Havia a necessidade de manter a lógica de gestão de infraestrutura de **Endpoints (Clientes Diskless)**, mas sem fragmentar a experiência de linha de comando. A operação agora funciona através de um único binário mestre de orquestração unificada (`kryx`), que encapsula o gerenciamento de clientes através de subcomandos lógicos.

## 1. `kryx` (O Mestre de Orquestração Unificada)
- **Tecnologia**: Rust (Workspace Unificado com o `kryonix-installer`).
- **Localização**: `repos/kryonix/packages/kryx/`
- **Escopo**: É o cérebro que opera e modifica tanto o **servidor host** quanto os **nodos clientes**.
- **Como funciona**: Absorveu as responsabilidades do antigo `ragos-installer` e das reconstruções do NixOS local (`switch`). Recebe o `InstallPlanV2`, traduz para configurações Nix nativas (através de sua nova `Translator API` em `lib.rs`) e roda os deploys e diagnósticos físicos da máquina hospedeira.

## 2. `kryx node` (Antigo `ragc`)
- **Escopo**: Focado estritamente no lifecycle da **imagem do cliente diskless (PXE)**.
- **O status de deploy do cliente**: O `kryx node` expõe comandos nativos Rust (`publish`, `rollback`, `gc`, `status`) que atuam como proxy para manter compatibilidade com a mecânica interna consolidada em `modules/ragos/core/ragc/`.
- **Como funciona**: 
  - Ele opera os comandos `kryx node publish`, `kryx node rollback`, `kryx node gc` e `kryx node status`.
  - Controla os links simbólicos das gerações NixOS do cliente no servidor (`/srv/data/images`), garantindo previsibilidade para as máquinas atreladas na topologia *Think*.
  - O Rust invoca processos delegados isolando as operações antigas do shell de maneira invisível ao usuário.

## Integração Monorepo
Essa topologia isola o risco através de subcomandos, mas oferece uma interface única e elegante (`kryx`). Ao realizar um deploy do servidor (`kryx switch`), a imagem que o cliente PXE enxerga via HTTP (`kryx node status`) permanece intocável, prevenindo falhas em cascata nos endpoints quando o backend sofre manutenção.
