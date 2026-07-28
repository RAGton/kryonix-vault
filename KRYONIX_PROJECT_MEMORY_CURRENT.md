---
title: Kryonix - Memória de Projeto Atual
type: memoria_projeto
status: active
validity: validated_by_human_decision
type: memoria_projeto
project: kryonix
component: memory
source_of_truth: decision_human
confidence: high
rag: active
graph: true
validated_on: 2026-06-19
tags:
  - kryonix
  - memory
  - project-memory
  - current
links:
  - "[[MOC - Kryonix]]"
  - "[[AGENTS]]"
  - "[[VAULT_INDEX]]"
  - "[[PROMPT_MASTER]]"
---

# Kryonix - Memória de Projeto Atual

> DRAFT proposto em 2026-06-19 pelo dono do projeto apos auditoria do Vault.
> AINDA NAO FOI CRIADO NO VAULT REAL. Aguarda aprovacao humana.

## Decisão

**Glacier esta congelado para runtime/servicos por enquanto.**

O projeto Kryonix continuara usando ate segunda ordem:

- **Inspiron** como maquina operacional ativa
- **Hermes local** como agente principal de IA
- **OpenRouter** como provider/modelos externos
- **Obsidian Vault local** em `/home/rocha/kryonix/kryonix-vault` (vault real)
- **Codigo fonte operacional**:
  - `/home/rocha/kryonix/kryonix` para desenvolvimento ativo
  - `/etc/kryonix` como checkout operacional em sistema instalado
- **CLI `kryonix`** como ponto de entrada oficial
- **Foco principal**: finalizar o installer e gerar a ISO oficial Kryonix

## Fora de escopo temporario

Nao validar, corrigir ou depender de:

> Qualquer validacao envolvendo Glacier deve ser registrada como `SKIPPED_BY_OPERATION_MODE`, nao como PASS nem FAIL.

- `glacier` (host)
- `ssh glacier`
- `ollama.service` no Glacier
- `neo4j.service` no Glacier
- `kryonix-lightrag` no Glacier
- `kryonix-brain-api.service` no Glacier
- `/var/lib/kryonix` no Glacier
- LightRAG remoto
- MCP remoto via Glacier
- Storage compartilhado entre Inspiron e Glacier

## Roadmap de execucao

```
P0 - Finalizar installer
P1 - Gerar ISO oficial Kryonix
P2 - Preparar perfil first-install do Glacier
P3 - Reinstalar Glacier com ISO Kryonix (instalacao limpa)
P4 - So entao ativar Brain / Ollama / LightRAG / Neo4j no Glacier

P0 paralelo - Hermes local + OpenRouter + Vault local bem curado
```

## Implicacoes para RAG / GraphRAG

- Politica RAG aplica-se **apenas** ao Vault local real (`/home/rocha/kryonix/kryonix-vault`)
- Nao configurar LightRAG remoto, Neo4j remoto ou Brain API remoto
- Indexacao local no Hermes/OpenRouter pode ser feita a partir do subset curado
- `LIGHTRAG_VAULT_DIR` permanece apontando para o path antigo vazio ate Glacier ser reinstalado; enquanto isso, indexacao automatica nao e prioridade

## Links relacionados

- [[Mapa - Kryonix]]
- [[AGENTS]]
- [[VAULT_INDEX]]
- [[PROMPT_MASTER]]
- Relatorio de auditoria do Vault (2026-06-19) - ver `/tmp/kryonix-vault-audit-20260619-081042/RELATORIO.md`

## Validacao

Este modo operacional foi validado por decisao humana em 2026-06-19. Nao requer evidencia runtime alem da observacao de que Inspiron e a maquina operacional onde o Hermes esta rodando via OpenRouter.

## Proximas revisoes

- Re-validar este modo apos P0 (installer finalizado) e P3 (Glacier reinstalado).
- Atualizar este arquivo quando Glacier voltar a ser runtime ativo.