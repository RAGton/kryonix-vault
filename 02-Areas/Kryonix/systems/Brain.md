---
source: docs/brain/README.md
status: derived
canonical: false
last_sync: 2026-05-01
---

# Kryonix Brain

> [!IMPORTANT]
> Esta nota é derivada de `docs/`. Em caso de divergência, `docs/` vence.

O **Kryonix Brain** é a central de processamento e conhecimento de IA do projeto.

Ele orquestra a inteligência local, unificando:
- [[02-Areas/Kryonix/systems/LightRAG|LightRAG]]: Estrutura de Retrievial-Augmented Generation baseada em grafos.
- [[02-Areas/Kryonix/systems/MCP|MCP (Model Context Protocol)]]: Exposição segura de ferramentas de sistema, conhecimento e contexto.
- [[02-Areas/Kryonix/systems/Vault|Vault (Obsidian)]]: A base real de conhecimento e anotações.
- [[02-Areas/Kryonix/systems/Ollama|Ollama]]: Motor local de LLMs.

## Topologia Cliente-Servidor

A arquitetura do projeto é distribuída.
O [[02-Areas/Kryonix/systems/Glacier|Glacier]] roda o ambiente "pesado": Ollama, armazenamento LightRAG, grafos (GraphML) e vector DB.
O [[02-Areas/Kryonix/systems/Inspiron|Inspiron]] (cliente) realiza requisições remotas (via HTTP ou SSH) sem sobrecarregar sua própria máquina com infraestrutura de IA, usando os binários da CLI `kryonix` conectada à variável `KRYONIX_BRAIN_API`.

## Componentes
- [[02-Areas/Kryonix/systems/LightRAG|LightRAG]]
- [[02-Areas/Kryonix/systems/MCP|MCP]]
- [[02-Areas/Kryonix/systems/Vault|Vault]]
