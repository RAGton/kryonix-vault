---
title: Prioridade de Contexto por Projeto
type: nota
status: stub
tags: [ia, contexto, vault, projeto]
---

# Prioridade de Contexto por Projeto

## Objetivo

Definir, para cada projeto ativo, **quais notas do vault têm prioridade alta, média ou baixa** quando uma IA consome o vault para responder ou agir naquele contexto.

## Resumo

Stub criado durante a reorganização do vault (Fase 2, 2026-06-15). O conteúdo é uma matriz por projeto: o que carregar sempre, o que carregar sob demanda, o que ignorar.

## Quando usar

- Antes de invocar uma IA com tarefa relacionada a um projeto específico (Kryonix, RAGOS, etc).
- Ao definir o system prompt do agente de um projeto (qual parte do vault entra como contexto fixo).
- Ao auditar uso de tokens — cortar notas de prioridade baixa do contexto padrão.

## Procedimento / Conteúdo

Para cada projeto ativo, listar:

- **P0 (sempre)**: AGENTS.md, PROMPT_MASTER.md, MOC raiz do projeto, mapa de área principal.
- **P1 (sob demanda)**: Skills e Playbooks relevantes, runbooks, ADRs.
- **P2 (raramente)**: logs antigos, evidence, áreas adjacentes.

Projetos canônicos:

- **Kryonix (motor + site)**: [[03-Projetos/Kryonix System]] · [[03-Projetos/Kryonix Installer]] · [[01-MOCs/Mapa - NixOS e Infra Declarativa]]
- **RAGOS**: [[03-Projetos/RAGOS]] · [[01-MOCs/Mapa - IA e Agentes]]
- **RAG Pipeline / Brain**: [[02-Areas/IA e Agentes/RAG Pipeline Interno]] · [[02-Areas/IA e Agentes/Graph + Vector Hybrid Search]]

## Checklist

- [ ] Definir P0/P1/P2 por projeto.
- [ ] Conectar com [[04-Recursos/prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]].
- [ ] Validar economia de tokens: P0 não deve estourar ~3k tokens.

## Riscos

Matriz desatualizada leva a agente "esquecendo" contexto crítico. Rever a cada milestone do projeto.

## Links relacionados

- [[01-MOCs/Mapa - Cerebro Supremo de IA]]
- [[04-Recursos/prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]]
- [[04-Recursos/prompts/PROMPT_MASTER]] (carregado em [[PROMPT_MASTER]])
- [[02-Areas/IA e Agentes/Protocolo de Consulta do Vault por IA]]
- [[02-Areas/IA e Agentes/Skills Reutilizaveis]]

## Próxima ação

Preencher a matriz P0/P1/P2 com todos os projetos ativos.
