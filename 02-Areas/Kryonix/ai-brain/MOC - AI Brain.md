---
type: moc
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, brain, ai, moc]
links:
  - "[[MOC - Kryonix]]"
---

# MOC — AI Brain

Stack de IA do Kryonix: Ollama + LightRAG + Neo4j + MCP + Brain API.

## Notas

- [[Aura]] — agente operador (esta sessão)
- [[Hermes]] — agente legacy (purgado em 2026-06-06)
- [[RAG CAG GraphRAG]] — modelos de retrieval
- [[Neo4j]]
- [[Ollama]]
- [[MCP]]

## Componentes principais (no repo)

- `packages/kryonix-brain-lightrag/` (Python)
- `modules/nixos/services/brain.nix` (systemd: ollama, lightrag, brain-api)
- `.mcp.example.json` (template MCP versionado)
- `.codex/config.toml` (Codex MCP)

## CLI

```bash
kryonix brain {health, doctor, stats, search, ask, sync, ...}
kryonix mcp {check, doctor, print-config}
kryonix graph {status, stats, query, repair}
```

Detalhes: `docs/CLI.md`, `docs/USAGE.md`.

Tags: #kryonix #brain #ai
