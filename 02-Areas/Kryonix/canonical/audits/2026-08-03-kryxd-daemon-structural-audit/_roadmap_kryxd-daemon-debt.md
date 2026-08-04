---
title: Roadmap kryxd-daemon debt
date: 2026-08-04
tags: [kryonix, kryxd, roadmap, debt, blocked]
status: in-progress
ssot: Kanban Hermes (este arquivo é espelho)
---

# Roadmap kryxd-daemon debt

> Espelho do Kanban Hermes. SSOT é o Kanban.
> Última sincronização: 2026-08-04

## Status atual de TODOS os KCRs: BLOCKED

Motivo: baseline de compilação não passou (ver [[2026-08-03-kryxd-daemon-structural-audit/20-build-baseline]]).

## Tabela de KCRs

| KCR | Status | Esforço | Bloqueado por |
|-----|--------|---------|---------------|
| KCR-ROUTER-1 | blocked | 1-2h | baseline verde |
| KCR-TRANSLATOR-1 | blocked | 30-60min | baseline verde |
| KCR-V1-DEPRECATE | blocked | 2h | baseline verde |
| KCR-PARTITIONER-1 | blocked | 2-3h | baseline verde |
| KCR-TARGETTREE-1 | blocked | 1 dia | baseline + PARTITIONER-1 |
| KCR-REFACTOR-1 | blocked | 2-3 dias | baseline + TARGETTREE-1 |

## Próximo passo crítico

Desbloquear baseline via Opção A do `20-build-baseline.md`:

1. Regenerar `npmDepsHash` do `kryxd-ui` (lib.fakeHash → build → copiar got: sha256)
2. Atualizar `nix/ui.nix:11` com hash correto
3. `nix develop`
4. `cargo fmt --check && cargo build --workspace && cargo test --workspace`

Só então promover qualquer KCR de `blocked` para `ready`.

## Sincronização com Kanban

Cartões Kanban correspondentes: _a cruzar via `hermes kanban list | grep kryxd`_
