---
type: glossary
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, glossary, reference]
links:
  - "[[MOC - Kryonix]]"
---

# Glossário Kryonix

Termos e siglas usadas no projeto.

| Termo | Definição |
|-------|-----------|
| **KryonixOS** | Branding visível do sistema operacional (`NAME`, `PRETTY_NAME`). `ID=nixos` preservado. |
| **DEV-MOTOR** | `/home/rocha/kryonix/kryonix` — repo motor de desenvolvimento. |
| **DEV-SITE** | `/home/rocha/kryonix/kryonixos` — repo downstream/site/ISO de desenvolvimento. |
| **PROD-MOTOR** | `/etc/kryonix` — motor instalado em produção. |
| **PROD-SITE** | `/etc/kryonixos` — downstream em produção. |
| **Aura** | Agente operador/auditor (Claude). Padrão em [[Aura]]. |
| **Hermes** | Agente legacy purgado em 2026-06-06. Resíduos limpos em PR #69 + cleanup. |
| **Brain** | Stack de IA do projeto: Ollama + LightRAG + Neo4j + API. Detalhe em [[MOC - AI Brain]]. |
| **RAG** | Retrieval-Augmented Generation (vault Obsidian → Brain). |
| **CAG** | Context-Augmented Generation (código/repo → Brain). |
| **GraphRAG** | Variante RAG baseada em grafo Neo4j. |
| **MCP** | Model Context Protocol. Servidores expostos em `.mcp.json` (gitignored). |
| **`kryonix env status`** | Comando CLI que detecta DEV-MOTOR/DEV-SITE/PROD-MOTOR/PROD-SITE/UNKNOWN. |
| **`kryonix update`** | DEV: `nix flake update`. PROD: `git pull --ff-only` + check + diff. |
| **Target Flake v2** | Arquitetura do installer onde o target gera flake autocontido em `/mnt/etc/kryonixos`. Ver [[Target Flake v2]]. |
| **Preflight** | `cd /home/rocha/kryonix/kryonix && test "$(pwd -P)" = "..."`. Obrigatório em todo comando do agente. |
| **PR draft archive** | Branches `archive/etc-*` que preservam trabalho histórico do `/etc/kryonix` legado. #65–#69. |
| **MOC** | Map of Content. Hub linkando notas relacionadas (estilo PARA/Obsidian). |
| **Vault** | `/home/rocha/Documents/Obsidian Vault` — cérebro de memória do projeto. |

Ver: [[MOC - Kryonix]]
