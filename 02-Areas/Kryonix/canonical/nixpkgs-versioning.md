---
doc_id: nixpkgs-versioning
date: 2026-08-07
status: active
applies_to: kryonix, kryonixos, kryx-cli, kryonix-assets, kryxd
author: aura (sessão KCR-A audit)
---

# Nixpkgs Versioning Policy — Kryonix

> Guia operacional de versioning de nixpkgs no ecossistema Kryonix.
> Captura o estado em 2026-08-07 e as regras pra evoluir sem quebrar.

## Princípio

**Hybrid deliberado:** trunk unstable pra pacotes novos, stable pra pacotes que precisam de estabilidade. **`kryonix` (motor) é single source of truth (SSOT)** pros inputs `nixpkgs` e `nixpkgs-stable`.

## Estado atual (2026-08-07)

| Repo | File | Linha | Input | URL | Razão |
|---|---|---|---|---|---|
| `kryonix` (motor) | `flake.nix` | 40 | `nixpkgs` | `github:nixos/nixpkgs/nixos-unstable` | SSOT trunk, features novos (KDE 6.2.x+) |
| `kryonix` (motor) | `flake.nix` | 41 | `nixpkgs-stable` | `github:nixos/nixpkgs/nixos-26.05` | Referência estável (bonafides-theme, etc.) |
| `kryonixos` (hosts) | `flake.nix` | 21 | `nixpkgs` | follows `kryonix/nixpkgs` | Disciplina: motor decide |
| `kryonixos` (hosts) | `flake.nix` | 38 | `nixpkgs-stable` | follows `kryonix/nixpkgs-stable` | Disciplina: motor decide |
| `kryxd` (installer) | `flake.nix` | 5 | `nixpkgs` | `github:nixos/nixpkgs/nixos-26.05` | Installer deliberadamente estável |
| `kryx-cli` | `flake.nix` | 5 | `nixpkgs` | `github:NixOS/nixpkgs/nixos-unstable` | Standalone (debt: deveria seguir motor) |
| `kryonix-assets` | `flake.nix` | 5 | `nixpkgs` | `github:nixos/nixpkgs/nixos-unstable` | Standalone (debt: deveria seguir motor) |

## Naming convention

- **Padrão:** `github:nixos/nixpkgs/...` (lowercase)
- **Aceito:** `github:NixOS/nixpkgs/...` (uppercase) — funciona, mas normalizar pra lowercase pra consistência
- **Inconsistência atual:** `kryx-cli/flake.nix:5` usa uppercase. Cosmético, sem impacto funcional.

## Sistema runtime de referência

- **Inspiron roda:** NixOS 26.11 unstable (Zokor), commit `20260719.241313f`
- **Pinned atualmente:** `nixpkgs` → `nixos-unstable` (trunk)
- **26.11 NÃO é release estável** — `channels.nixos.org/nixos-26.11` retorna 404. Só existe como branch unstable no github.
- **Estável oficial:** `nixos-26.05` (Zokor é o codename, mas 26.11)

## Quando bumpar

| Evento | Mudança |
|---|---|
| **`nixos-26.11` virar release** | `nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.11"` (motor). Trunk `nixos-unstable` continua. |
| **`kryx-cli` ou `kryonix-assets` virarem SSOT-aware** | Adicionar `inputs.nixpkgs.follows = "kryonix/nixpkgs"` no flake de cada |
| **`kryxd` decidir seguir trunk** | Decisão explícita. Hoje fica em 26.05 por design (installer deve ser estável). |
| **Limpar naming inconsistency** | `kryx-cli/flake.nix:5` → `github:nixos/...` (lowercase) |

## Quando NÃO mexer

- **Tema visual (KDE) quebrou?** Bug de **declaração** (lookAndFeel vs colorScheme vs Kvantum theme), não de versão. Resolver no `users/rocha/inspiron/default.nix` ou `desktop/kde/*.nix`. Ver [[KDE_Theme_Bug_2026-08-07]] (link a ser criado quando FASE 2 fechar).
- **Pacote faltando?** Conferir se existe no `nixpkgs` unstable (consultar `nix search nixpkgs <pkg>`) **antes** de mexer em versão.
- **Build quebrou depois de `nix flake update`?** Reverter lock (`git checkout flake.lock`) e abrir card pra investigar diff.

## Disciplina de bump

1. **NUNCA** `nix flake update` sem plano escrito.
2. **SEMPRE** rodar `nix flake check --keep-going --impure` em todos os 3 hosts (inspiron, glacier, inspiron-nina) antes de commitar lock.
3. **SEMPRE** passar pelo **bypass oficial** do Kryonix Guard (ver `kryonix-dev/AGENTS.md` §6).
4. **Separate:** pin bump vs actual code change. Lock file bump vai em commit sozinho, semanticamente neutro.

## Referências

- `kryonix-dev/AGENTS.md` §6 (Kryonix Guard bypass)
- `kryonix/flake.nix` (linhas 1-100)
- `kryonixos/flake.nix` (linhas 1-86)
- `kryonix-dev/CLAUDE.md` (regra de inputs follows)
- [[Architecture]] — MOC de arquitetura

## Pendências / Debt cards

- `t_<novo>` — `[tech-debt][kryx-cli] nixpkgs should follow motor (kryonix) — currently standalone`
- `t_<novo>` — `[tech-debt][kryonix-assets] nixpkgs should follow motor (kryonix) — currently standalone`

## Histórico

- **2026-08-07** — doc criada (aura, sessão KCR-A audit). Estado espelhado do `kryonix/flake.nix` real.


## Tentativa de validação (2026-08-07, FASE 2 inconclusiva)

Tentamos `nix flake update --override-input nixpkgs github:nixos/nixpkgs/nixos-26.05` + `nix flake check` em branch isolada. Resultado: override não persistiu (`nix flake check` reescreve o lock seguindo `.follows`). Check passou em 51s, mas **testou o nixpkgs trunk que já estava lá** — não é evidência de bump seguro.

Lição: pra validar bump de channel, precisa modificar `flake.nix` direto, não só override. Fica como trabalho futuro se virar prioridade.
