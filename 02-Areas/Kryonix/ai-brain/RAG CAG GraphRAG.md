---
type: ai-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, brain, rag, cag, graphrag]
links:
  - "[[MOC - AI Brain]]"
  - "[[Neo4j]]"
  - "[[Ollama]]"
---

# RAG · CAG · GraphRAG

Três modos de retrieval usados pelo Kryonix Brain.

## CAG — Context-Augmented Generation

- Fonte: código + docs do repo Kryonix (`.nix`, `.md`, `.sh`).
- Comando: `kryonix brain cag {status, ask, route, build}`.
- Ideal para perguntas técnicas sobre o próprio sistema.

## RAG — Retrieval-Augmented Generation

- Fonte: vault Obsidian + histórico de conversas.
- Comando: `kryonix brain {search, sync}`.
- Ideal para conhecimento pessoal e notas.

## GraphRAG

- Fonte: grafo Neo4j (entidades + relações extraídas do vault/repo).
- Comando: `kryonix graph {status, stats, query, repair}`.
- Ideal para perguntas que exigem traversal de relações.

## Hierarquia de resposta (`kryonix brain search`)

1. **CAG** — pergunta técnica/repo.
2. **RAG** — conhecimento geral / vault.
3. **Fallback** — sem grounding técnico.

Tags: #kryonix #brain #rag #graphrag
