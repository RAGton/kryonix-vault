---
type: architecture-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, security, governança]
links:
  - "[[MOC - Architecture]]"
  - "[[Safe Git Workflow]]"
---

# Security Model — Kryonix

## Secrets (inviolável)

- **Nunca** commitar: `KRYONIX_BRAIN_KEY`, tokens, chaves SSH/GPG,
  `.env`, auth Tailscale.
- Runtime: `/etc/kryonix/brain.env` (modo `0600`, gitignored).
- Alternativas declarativas: sops-nix, agenix.
- Nada de secret em `.nix`, `flake.nix`, docs, logs de CI ou
  `/nix/store`.

## Gitleaks / scan

- `.gitleaks.toml` no repo.
- CI Security Scan workflow (atualmente FAIL pré-existente, ver
  [[02-Areas/Kryonix/entities/Issues/Issue 79]]).

## MCP (Model Context Protocol)

- Filesystem inicia como `read-only`.
- Acesso global a `/` é proibido.
- `.mcp.json` real é gitignored; `.mcp.example.json` é template versionado.
- Servidores devem comunicar JSON-RPC limpo no stdout; logs em stderr.
- Bancos (Neo4j, PostgreSQL): acesso inicial `read-only`.

Detalhes: `docs/mcp/SECURITY.md` no repo.

## Modificações NixOS seguras

- `nix flake check --keep-going` antes de qualquer switch.
- `kryonix switch` deve sempre ser revertível pela geração anterior do
  bootloader.
- Evitar `git add .` — preferir commits granulares e explícitos.

## Backend installer

- Validação de input em handlers axum (PR #72):
  - `validate_apply_network_request` rejeita IP/gateway/DNS/prefix
    inválidos.
  - `is_valid_hostname` rejeita shell metas e path traversal.
- Sem `sh -c` / `bash -c` em chamadas `Command::new`.
- `Json<T>` desserializa via serde com validação aplicada.

Ver: `docs/SECURITY.md`, [[DECISIONS]]


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]