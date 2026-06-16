---
type: ai-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, brain, neo4j, graph]
links:
  - "[[MOC - AI Brain]]"
  - "[[RAG CAG GraphRAG]]"
---

# Neo4j — Kryonix

Grafo de conhecimento do Kryonix Brain.

## Deploy

- Módulo NixOS: parte de `modules/nixos/services/brain.nix`.
- Restrito a Tailscale (não exposto na internet pública).
- Local-only para gravação destrutiva.

## Estado persistente

- `/var/lib/kryonix/brain/neo4j/` (via `kryonix-state.nix`).

## Credenciais

- Em `/etc/kryonix/neo4j.env` (`0600`, gitignored).
- Nunca em código, docs ou logs.

## CLI

```bash
kryonix graph status
kryonix graph stats
kryonix graph query --cypher 'MATCH (n) RETURN COUNT(n)'
kryonix graph repair         # critical, requires sudo
```

## MCP

- Servidor MCP Neo4j inicia como **read-only**.
- Destrutivo bloqueado na raiz.

Ver: [[Security Model]] · [[MCP]]
