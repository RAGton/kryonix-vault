---
type: installer-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, installer, testing, cargo, npm]
links:
  - "[[MOC - Installer]]"
  - "[[Validation Matrix]]"
---

# Testing — Installer

## Backend Rust

```bash
cd packages/kryxd
cargo fmt --check
cargo test --locked            # 42/42 após PR #72
cargo clippy --all-targets --all-features -- -D warnings   # gate desde PR #78
```

Testes principais (não exaustivo):
- `network.rs::tests::test_parse_interfaces_full`
- `network.rs::tests::test_validate_apply_dhcp_ok`
- `network.rs::tests::test_validate_apply_rejects_invalid_ipv4_address`
- `network.rs::tests::test_validate_apply_rejects_invalid_gateway`
- `network.rs::tests::test_validate_apply_rejects_invalid_prefix`
- `network.rs::tests::test_validate_apply_rejects_invalid_dns`
- `main.rs::tests::test_dry_run_rejects_hostname_with_shell_metas`
- `main.rs::tests::test_dry_run_rejects_hostname_with_path_traversal`
- `main.rs::tests::test_dry_run_manual_*`
- `executor/safety.rs::tests::*`
- `executor/verify.rs::tests::*`
- `executor/target_tree.rs::tests::*`

## Frontend (Vite + node test)

```bash
cd packages/kryxd/ui
npm install
npm test                       # 47/47 após PR #80
npm run build                  # 240 modules
```

Suites:
- `installPlan.test.js` (schema + payload)
- `installExecution.test.js` (logs + console banner)
- `localizationCatalog.test.js`
- `storagePlanner.test.js`
- `wizardState.test.js`

## Build Nix

```bash
nix build .#kryxd --no-link -L --show-trace
```

Inclui cargo test no sandbox de build.

## Pendências de teste

- Testes E2E HTTP em harness (P2 backend).
- Payload gigante / null bytes / path traversal (sem panic).
- Smoke-test em VM libvirt — fora de auditoria-Nix, requer infra.


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]