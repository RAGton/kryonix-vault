---
title: VAULT_INDEX — Cérebro Kryonix
type: moc
status: active
tags: [moc, home, indice]
created: 2026-06-14
updated: 2026-06-14
---

# VAULT_INDEX

> Home do cérebro técnico. **Comece por aqui** sempre que abrir o vault ou
> quando um agente IA precisar se orientar.

<context>
  Vault Obsidian organizado em estrutura PARA:
  00-Inbox → captura
  01-Projects → trabalho ativo com prazo
  02-Areas → conhecimento de longo prazo
  03-Resources → templates, skills, playbooks, prompts, references
  04-Archive → tudo inativo
  10-MOCs → mapas de navegação
  99-Logs → diário, revisões, evidências
</context>

## 1. Entrada para agentes IA

Leia nessa ordem antes de operar o vault:

1. [[AGENTS]] — contrato curto + regras invioláveis
2. [[PROMPT_MASTER]] — identidade operacional padrão
3. [[01-MOCs/Mapa - Cerebro Supremo de IA]] — visão de topo
4. [[04-Recursos/prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]] — protocolo de consulta
5. [[04-Recursos/templates/README|Convenções de templates]] — YAML/XML/TOON

## 2. Projetos ativos

- [[03-Projetos/Kryonix System]] — meta-distro NixOS (motor)
- [[03-Projetos/Kryonix Installer]] — instalador headless
- [[03-Projetos/Kryonix VE]] — PXE/Proxmox
- [[03-Projetos/RAGOS]] — sistema de retrieval
- [[03-Projetos/RAGOS Installer]]
- [[03-Projetos/Ragos VE]]

## 3. Áreas de conhecimento (PARA)

- [[02-Areas/Kryonix/canonical/Architecture|Kryonix · Architecture]]
- [[02-Areas/Kryonix/canonical/Usage|Kryonix · CLI Usage]]
- [[02-Areas/Kryonix/canonical/Operations|Kryonix · Operations]]
- [[02-Areas/Kryonix/canonical/Security|Kryonix · Security]]
- [[02-Areas/Kryonix/canonical/Testing|Kryonix · Testing]]
- [[02-Areas/Kryonix/canonical/Troubleshooting|Kryonix · Troubleshooting]]
- [[02-Areas/Kryonix/canonical/Roadmap|Kryonix · Roadmap]]
- [[02-Areas/Kryonix/systems/Inspiron|Host: Inspiron]]
- [[02-Areas/Kryonix/systems/Glacier|Host: Glacier]]
- [[02-Areas/Kryonix/systems/Brain|Kryonix Brain]]
- [[02-Areas/Kryonix/systems/Ollama|Ollama]]
- [[02-Areas/Kryonix/systems/LightRAG|LightRAG]]
- [[02-Areas/Kryonix/systems/MCP|MCP]]
- [[02-Areas/Kryonix/systems/Vault|Vault]]

## 4. Mapas (MOCs)

```toon
mocs[10]{slug,titulo,foco}:
backend,Mapa - Backend e APIs,APIs vendáveis
dados,Mapa - Dados e Algoritmos,DS&A aplicado
devops,Mapa - DevOps e SRE,confiabilidade
eng,Mapa - Engenharia de Software,fundamentos
ia,Mapa - IA e Agentes,LLMs aplicados
linux,Mapa - Linux e Sistemas,SO
nixos,Mapa - NixOS e Infra Declarativa,reprodutibilidade
produto,Mapa - Produto e SaaS,monetização
seg,Mapa - Segurança,defensiva
cerebro,Mapa - Cerebro Supremo de IA,navegação geral
```

Lista expandida em `10-MOCs/`.

## 5. Resources

- **Templates**: [[04-Recursos/templates/README|convenções]] + 9 templates kebab-case
- **Skills**: 20 Skills agrupadas em `03-Resources/skills/`
- **Playbooks**: procedimentos em `03-Resources/playbooks/` (+ `runbooks/`)
- **Prompts**: prompts reutilizáveis em `03-Resources/prompts/`
- **References**: curadoria em `03-Resources/references/`

## 6. Prompts-âncora

- [[04-Recursos/prompts/PROMPT_AGENT_BACKEND_API]]
- [[04-Recursos/prompts/PROMPT_AGENT_INFRA_LINUX]]
- [[04-Recursos/prompts/PROMPT_AGENT_SITE_MODERNO]]
- [[04-Recursos/prompts/PROMPT_SUPREMO_DEEP_RESEARCH]]
- [[04-Recursos/prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]]

## 7. Curadoria e qualidade

- [[04-Recursos/references/Politica de Curadoria de Fontes e Codigo]]
- [[04-Recursos/references/Radar de Documentacao Engenharia]]
- [[04-Recursos/references/Checklist de Avaliacao de Codigo Externo]]
- [[04-Recursos/references/Fontes Oficiais]]

## 8. Rotina

- [[00-Inbox/Inbox]] — captura rápida
- [[09-Logs/Revisao Semanal]]
- [[09-Logs/Decisoes Recentes]]
- [[09-Logs/Backlog de Estudos]]
- [[09-Logs/evidence/README|Evidências]]

## Regra de ouro

> Se uma informação será reutilizada **mais de duas vezes**, transforme em:
> nota técnica, prompt reutilizável, Skill, checklist, playbook ou ADR.

<constraints>
  - Nunca dois números de pasta iguais — colisão = bug.
  - Nunca duplicar templates — só atualizar.
  - Sempre seguir as convenções em [[04-Recursos/templates/README]].
</constraints>
