---
status: draft
date: 2026-06-23
area: Kryonix
type: migration-audit
scope:
  - upstream
  - features
  - ai
  - brain
  - services
---

# AI Feature Migration Audit

## Objetivo

Auditar a feature AI antes de migrar `features/ai.nix` para `modules/nixos/features/ai.nix`.

## Contexto

A ADR-001 define `modules/nixos/features/` como árvore canônica e `features/` como legado temporário.

## Arquivos analisados

- `features/ai.nix`
- `modules/nixos/features/ai.nix`
- `modules/nixos/features/schema.nix`
- `modules/nixos/features/registry.nix`
- Perfis downstream e logs de arquitetura

## Estado atual

### Legado: `features/ai.nix`

Declara:
- `kryonix.features.ai.enable` (Kryonix Brain - LightRAG + Ollama)
- Opções de rede: `serverHost`, `brainPort`, `ollamaPort`
- `kryonix.features.ai.role`
- `kryonix.features.ai.codex.enable` (OpenAI Codex CLI e pacotes relacionados)

### Canônico atual: `modules/nixos/features/ai.nix`

Declara de forma isolada:
- `ollama.enable`
- `openWebui.enable`
- `neo4j.enable`
- `lightrag.enable`
- `kryonixBrain.enable`
Além disso, ativa diretamente os serviços `services.ollama` e `services.neo4j`.

### Schema/Registry

Listar entradas já previstas:

- `kryonix.features.ai.brain.client.enable`
- `kryonix.features.ai.brain.server.enable`
- `kryonix.features.ai.ollama.enable`
- `kryonix.features.ai.lightrag.enable`
- `kryonix.features.ai.neo4j.enable`

## Mapa de namespace

| Conceito | Namespace legado | Namespace canônico alvo | Status | Observação |
|---|---|---|---|---|
| Brain client | `kryonix.features.ai.enable` (em hosts cliente) | `kryonix.features.ai.brain.client.enable` | planned | |
| Brain server | `kryonix.features.ai.enable` (no Glacier) | `kryonix.features.ai.brain.server.enable` | planned | |
| Ollama | Implícito no Brain | `kryonix.features.ai.ollama.enable` | planned | |
| LightRAG | Implícito no Brain | `kryonix.features.ai.lightrag.enable` | planned | |
| Neo4j | Implícito no Brain | `kryonix.features.ai.neo4j.enable` | planned | |
| CUDA/GPU | Desconectado do AI base | `kryonix.features.gpu.cuda.enable` / `gpu.nvidia.enable` | external dependency | não misturar neste PR |
| MCP | `mcp.*` em profiles | `kryonix.features.mcp.*` | separate feature | não misturar se possível |
| F5-TTS | `features/f5-tts-server/` | `kryonix.features.ai.f5tts.*` | separate future PR | |
| Codex CLI | `kryonix.features.ai.codex.enable` | (Decidir destino: dev ou ai.codex) | needs review | |

## Serviços envolvidos

| Serviço | Ativado por | Porta | Storage | Secrets | Risco |
|---|---|---|---|---|---|
| Neo4j | neo4j.enable | 7474, 7687 | /var/lib/kryonix/neo4j | Nenhum/Implícito | Alto |
| Ollama | ollama.enable | ollamaPort (11434) | /var/lib/kryonix/ollama | Nenhum | Alto |
| LightRAG | lightrag.enable | N/A | /var/lib/kryonix/lightrag | apiKey/tokens | Médio |
| Brain Server | kryonixBrain.enable | brainPort | /var/lib/kryonix/brain | Tokens/Local Auth | Médio/Alto |
| OpenWebUI | openWebui.enable | Web (8080/outra) | /var/lib/kryonix/webui | Tokens/OAuth | Médio |

## Storage envolvido

Listar todos os paths encontrados:

- `/var/lib/kryonix/neo4j` (possível)
- `/var/lib/kryonix/ollama` (possível, caches locais)
- Caches do LightRAG.

## Portas envolvidas

- `11434` (Ollama)
- `7474`, `7687` (Neo4j)
- Portas customizáveis: `brainPort`, `ollamaPort` passadas via host.

## Secrets envolvidos

- Env files/variables (`brain.env`, `neo4j.env`, `hermes.env`, `kora.env`)
- Tokens de API externas requeridas pelos clientes Codex / Anthropic (MCP).
- NOTA: Nenhum token explícito em plain text; todos estão isolados, geridos por wrappers `.env`.

## Dependências perigosas

- GPU/NVIDIA/CUDA (Atualmente configurado no Glacier separadamente)
- services systemd (Ollama, Neo4j)
- firewall/ports
- storage persistente (`/var/lib/kryonix`)
- modelos locais grandes (LLMs baixados localmente)
- Neo4j data dir

## Riscos

A migração cega de `features/ai.nix` que não respeitar os profiles do Glacier pode ativar Ollama ou Neo4j no hardware errado (Inspiron, que é cliente apenas). Além disso, há mistura de definições de portas, secrets (`.env`) e namespaces nas definições atuais do legaddo.

## Resultado do PR #106

- `brain.client.enable` e `brain.server.enable` agora pertencem somente ao `schema.nix`.
- `ai.nix` não duplica mais essas opções.
- `ai.nix` segue compat-only para `ollama`/`openWebui`/`neo4j`/`lightrag`/`kryonixBrain`.
- Nenhum runtime foi alterado.

## Próximos passos

1. Auditar `features/ai.nix` legado.
2. Separar Brain client/server runtime em PR próprio.
3. Separar Ollama/OpenWebUI em PR próprio.
4. Separar Neo4j/LightRAG em PR próprio.
5. Não misturar GPU/CUDA.
6. Não misturar MCP.
7. Não misturar F5-TTS.

## Critérios para PR de migração AI

- Sem alterar downstream.
- Sem alterar installer.
- Sem ativar serviço por padrão.
- Sem secrets em Git.
- Sem mudar portas/firewall por padrão.
- `nix flake check --keep-going --show-trace` obrigatório.
