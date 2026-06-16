---
type: agent-spec
project: Kryonix
status: retired
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, agent, hermes, legacy, retired]
links:
  - "[[MOC - AI Brain]]"
  - "[[Aura]]"
---

# Hermes — Agente (purgado)

Agente legacy desativado em **2026-06-06**.

## O que era

`services.hermes` — daemon de roteamento de inteligência entre
`kryonix-brain-lightrag` e o desktop (Hyprland/Caelestia). Substituía
Kora (assistente de voz) em parte da estratégia "Aura agent migration".

## Por que foi purgado

- Quebrava boot em hosts que importavam `kryonix.services.hermes`.
- Acoplamento desnecessário com o desktop.
- Substituído pela arquitetura Aura (agente operacional) + Brain
  direto.

## Limpeza realizada

- Motor `/etc/kryonix`: módulo `services.hermes` removido.
- Downstream `kryonixos`: `flake.nix` + `hosts/{inspiron,glacier}/`
  perderam refs.
- Após cleanup, `switch` e `build` do Inspiron voltaram a funcionar.

## Referências históricas

- Memória local: `project_hermes_service.md` no `~/.claude/projects/.../memory/`.
- Worktree antiga em `/etc/kryonix/.worktrees/hermes-0d83fb58` — limpa
  na fase F3 da migração DEV/PROD (2026-06-13).

## Substituição

[[Aura]] cobre o papel operacional. Funcionalidade de roteamento
inteligente migra para o motor `kryonix-brain-lightrag` direto.

Tags: #kryonix #retired


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]