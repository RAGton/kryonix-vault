---
title: Mapa - Kryonix
type: moc
status: active
tags: [kryonix, mapa, raiz, ecossistema]
---

# Mapa - Kryonix

## Objetivo

Navegação central do ecossistema Kryonix: motor, site, installer, IA brain, branding, hosts e operações. Toda nota em `02-Areas/Kryonix/*` deve linkar para este MOC (regra do AGENTS.md).

## Resumo

Kryonix é o projeto-flagship. O conteúdo vive em `02-Areas/Kryonix/` organizado em 10 subsistemas. Este MOC serve de hub de navegação entre eles e de ponto de entrada único para IAs que carregam contexto do projeto.

## Estrutura (TOON)

```toon
subsistema,       o_que_e,                                                        nota_moc_interna
canonical,        Documentos canonicos do projeto (Architecture, Install, etc),    02-Areas/Kryonix/canonical/Architecture
systems,          Servicos e infraestruturas declaradas (Brain, MCP, Vault, etc), 02-Areas/Kryonix/systems/Brain
architecture,     Decisoes de arquitetura (DEV-PROD flow, Security, NixOS Flakes), 02-Areas/Kryonix/architecture/MOC - Architecture
operations,       Comandos, runbooks, validacao, safe git workflow,               02-Areas/Kryonix/operations/MOC - Operations
ai-brain,         Cérebro IA: Hermes, Aura, MCP, Neo4j, RAG, Ollama,              02-Areas/Kryonix/ai-brain/MOC - AI Brain
installer,        Installer do ecossistema (Backend Routes, Network, UI, Flake v2, Requisitos Técnicos), 02-Areas/Kryonix/installer/MOC - Installer
hosts,            Hosts fisicos do homelab (Glacier, Inspiron, ISO),               02-Areas/Kryonix/hosts/MOC - Hosts
branding,         Identidade KryonixOS (Boot, Terminal, Identity),                 02-Areas/Kryonix/branding/MOC - Branding
kryonix-meta,     Meta-documentos (ACTIVE_WORK, DECISIONS, CURRENT_STATE, ROADMAP), 02-Areas/Kryonix/kryonix-meta/MOC - Kryonix
entities,         Entidades externas rastreadas (repos, services, issues, PRs),   02-Areas/Kryonix/entities/Repositories/kryonix
```

## Documentos canônicos

- [[02-Areas/Kryonix/canonical/Kryonix Capability Registry]] — fonte de verdade, invariantes e política de evolução das capabilities do `kryxd`.
- [[02-Areas/Kryonix/canonical/Kryonix Entity Schema]] — schema das entidades persistidas do ecossistema.
- [[02-Areas/Kryonix/canonical/CURRENT_OPERATION_MODE]] — modo operacional e regras atuais do projeto.

## Estado atual (junho 2026)

```toon
item,                       estado
Motor (RAGton/kryonix),     DEV em /home/rocha/kryonix/kryonix, PROD em /etc/kryonix
Site (RAGton/Kryonixos),    separado, ainda em planejamento de fluxo DEV-PROD
Installer,                  migrado para RAGton/kryxd (PR #1, jun 2026)
Brain,                      Aura/Hermes locais + Neo4j + Ollama em Glacier
Identidade,                 KryonixOS como padrao (PR #71 + PR #80 merged)
CI,                         debt aberto em issue #79 (workflows quebrados)
Sessão Aura 2026-06,        documentada em 03-Projetos/Kryonix-Aura-2026-06
```

## Links externos

- Repo motor: <https://github.com/RAGton/kryonix>
- Repo site: <https://github.com/RAGton/Kryonixos>
- Repo installer: <https://github.com/RAGton/kryxd>
- Issue CI: <https://github.com/RAGton/kryonix/issues/79>

## Projetos relacionados

- [[03-Projetos/Kryonix System]] · [[03-Projetos/Kryonix Installer]] · [[03-Projetos/Kryonix VE]]
- [[03-Projetos/Kryonix-Aura-2026-06/00 Index]] (sessão Aura documentada)
- [[03-Projetos/RAGOS]] · [[03-Projetos/RAGOS Installer]] · [[03-Projetos/Ragos VE]]

## MOCs adjacentes (outros mapas temáticos)

- [[01-MOCs/Mapa - IA e Agentes]] (Kryonix usa IA extensivamente)
- [[01-MOCs/Mapa - NixOS e Infra Declarativa]] (Kryonix é NixOS-first)
- [[01-MOCs/Mapa - Proxmox PXE NFS Homelab]] (hosts do Kryonix)
- [[01-MOCs/Mapa - DevOps e SRE]] (operações Kryonix)
- [[01-MOCs/Mapa - Backend e APIs]] (Kryonix Brain API)
- [[01-MOCs/Mapa - Segurança]] (Security Model Kryonix)

## Prompts relacionados

- [[04-Recursos/prompts/PROMPT_AGENT_KRYONIX_VAULT]] (system prompt para IAs que editam o vault)
- [[04-Recursos/prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]] (system prompt para IAs que leem o vault)

## Próxima ação

- [x] Adicionar `[[01-MOCs/Mapa - Kryonix]]` em todas as notas de `02-Areas/Kryonix/*/` (feito em jun/2026)
- [x] Conectar o contrato canônico de capabilities do `kryxd`.
- [ ] Adicionar seção "Próximos marcos" com base em ROADMAP
- [ ] Conectar com kryonix-meta/ROADMAP
