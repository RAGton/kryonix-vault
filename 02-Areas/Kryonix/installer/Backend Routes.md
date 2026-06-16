---
type: installer-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, installer, backend, rust, axum]
links:
  - "[[MOC - Installer]]"
  - "[[Network Flow]]"
  - "[[Testing]]"
---

# Backend Routes — Installer

`packages/kryonix-installer/src/main.rs:232` define o Router.

## Health / version / hardware

- `GET /health`
- `GET /version`
- `GET /hardware` (alias `/probe`)

## Network (PR #72 hardened)

- `GET /network/status`
- `GET /network/interfaces`
- `GET /network/wifi/scan`
- `POST /network/wifi/connect`
- `POST /network/wifi/disconnect`
- `POST /network/apply` ← `validate_apply_network_request` (PR #72)

## Auth GitHub OAuth Device Flow

- `POST /auth/github/device`
- `GET /auth/github/poll`
- `GET /repos`
- `POST /clone`

## Install orchestration

- `POST /plan`
- `POST /dry-run` ← `validate_plan` + `is_valid_hostname` (PR #72)
- `POST /install`
- `GET /install/status`
- `GET /install/progress`
- `GET /install/log`
- `GET /api/stream` (SSE)
- `POST /install/finalize`
- `GET /api/validate-install`

## Profiles / disk / partition

- `POST /profile/apply`
- `GET /api/disks`
- `GET /api/disks/:device/partitions`
- `POST /api/partition`
- `POST /disk/apply`
- `GET /disk/manual-setup`

## Detection / debug

- `GET /api/detection`
- `GET /debug/target` ← Target Flake v2 introspection
- `POST /api/reboot`

## Padrões de segurança (PR #72/#78)

- Todo `Command::new(...)` usa `.args([...])` (sem `sh -c`).
- Validação pura em funções extraíveis testáveis.
- `match` explícito sobre `Result` (sem `.unwrap()` em hot paths).
- clippy `-D warnings` é gate desde PR #78.

Ver: [[Target Flake v2]] · [[Testing]]


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]