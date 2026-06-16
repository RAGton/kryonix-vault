---
type: ops-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, validation, operations, ci]
links:
  - "[[MOC - Operations]]"
---

# Validation Matrix — Kryonix

Matriz de validações por escopo de mudança.

| Escopo | Comandos mínimos |
|--------|------------------|
| Documentação pura | `git diff --check` |
| Skill ou docs/operations | `git diff --check` · `rg` por refs quebradas |
| Nix (qualquer) | `nix fmt` · `nix flake show --all-systems` · `git diff --check` |
| Host (`hosts/<h>`) | `+` `nix build .#nixosConfigurations.<h>.config.system.build.toplevel --no-link -L` |
| ISO | `+` `nix build .#nixosConfigurations.iso.config.system.build.toplevel --no-link -L` |
| Installer Rust | `cargo fmt --check` · `cargo test --locked` · `cargo clippy --all-targets --all-features -- -D warnings` · `nix build .#kryonix-installer --no-link -L` |
| Installer UI | `npm test` · `npm run build` |
| Home Manager (upstream) | `nix flake show` · validação real via downstream build |
| Branding (motd/issue/os-release) | `+` inspecionar `$TOP/etc/{motd,issue,os-release,kryonix-version}` |
| ISO label | `+` `cat $TOP/nixos-version` |

## CI status (atual em main)

Ver [[02-Areas/Kryonix/entities/Issues/Issue 79]]. Workflows falhando há tempos:

- Build & Test ISO
- Nix Validation
- Rust Audit (Home)
- Security Scan
- Claude Code Action

Workflows verdes: Python Audit (Brain), Shell & Documentation.

## Política de merge com CI vermelho

[[DECISIONS]] D-009: aceitável **se** validações locais passam e diff
não toca os arquivos do workflow afetado.


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]