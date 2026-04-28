---
title: "README"
type: index
status: active
area: ia
project: global
tags:
  - type/index
  - status/active
  - area/ia
created: 2026-04-26
updated: 2026-04-26
---
# Kryonix Vault

Vault Obsidian para funcionar como **cérebro operacional de IA, engenharia e produto**.

Este repositório centraliza padrões, prompts, Skills, playbooks, mapas de conhecimento e decisões técnicas para usar IA como amplificador profissional em múltiplos projetos.

## Objetivo

Criar uma base única, versionada e pesquisável para:

- reduzir repetição e custo com tokens;
- padronizar qualidade de código;
- orientar agentes de IA e Codex;
- documentar decisões técnicas;
- acelerar projetos backend/API, frontend, Linux, NixOS, Proxmox e automações;
- manter segurança, testes, clean code e arquitetura como padrão mínimo.

## Entrada principal no Obsidian

Abra primeiro:

- [[VAULT_INDEX]]
- [[MANUAL_ATIVAR_SEGUNDO_CEREBRO_IA]]
- [[01-MOCs/Mapa - Cerebro Supremo de IA]]
- [[PROMPT_MASTER]]
- [[AGENTS]]
- [[IMPLEMENTAR_EM_OUTROS_PROJETOS]]

## Projetos principais

- [[03-Projetos/Ragos VE]]: Proxmox, PXE/iPXE, NFS, homelab, Linux, NixOS e infraestrutura.
- [[03-Projetos/Kryonix]]: SaaS, backend/API, frontend moderno, automações e produto vendável.
- [[03-Projetos/Ragos Think]]: IA, agentes, RAG local, Skills, prompts e Obsidian como cérebro técnico.

## Estrutura

```txt
kryonix-vault/
├── AGENTS.md
├── PROMPT_MASTER.md
├── VAULT_INDEX.md
├── IMPLEMENTAR_EM_OUTROS_PROJETOS.md
├── 00-Inbox/
├── 01-MOCs/
├── 02-Areas/
├── 03-Projetos/
├── 04-Recursos/
├── 05-Skills/
├── 06-Playbooks/
├── 07-Prompts/
├── 08-Referencias/
├── 09-Logs/
├── scripts/
└── .github/workflows/
```

## Como usar este vault com IA

Regra de prioridade:

```txt
1. Vault local
2. Documentação do projeto atual
3. Documentação oficial
4. Memória do modelo
```

Antes de pedir algo para uma IA ou agente, forneça estes arquivos:

```txt
VAULT_INDEX.md
AGENTS.md
PROMPT_MASTER.md
01-MOCs/Mapa - Cerebro Supremo de IA.md
07-Prompts/PROMPT_IA_CONSUMIR_OBSIDIAN.md
```

Para projeto específico, inclua também:

```txt
03-Projetos/Ragos VE.md
03-Projetos/Kryonix.md
03-Projetos/Ragos Think.md
```

## Como implementar em outro projeto

Veja:

- [[IMPLEMENTAR_EM_OUTROS_PROJETOS]]
- [[06-Playbooks/Como Fazer Outra IA Consumir Este Vault]]
- [[07-Prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]]
- [[07-Prompts/PROMPT_SUPREMO_DEEP_RESEARCH]]

Resumo rápido:

1. Copie `AGENTS.md` para o projeto alvo.
2. Crie `PROJECT_CONTEXT.md` no projeto alvo.
3. Crie `ARCHITECTURE.md`, `SECURITY.md` e `OPERATIONS.md` quando fizer sentido.
4. Aponte a IA para este vault como referência principal.
5. Use issues pequenas para Codex/agentes.
6. Exija testes, validação e menor diff correto.
7. Nunca deixe agente mexer em secrets, deploy ou produção sem revisão humana.

## Comandos úteis

```bash
just check-links
```

Ou:

```bash
python3 scripts/check_obsidian_links.py
```

## Regra principal

Este vault não é um depósito infinito de texto.

Ele é um **sistema operacional de conhecimento** para engenharia, IA, produto, infraestrutura e aprendizado contínuo.

Cada nota deve ter:

- objetivo claro;
- links internos;
- uso prático;
- checklist quando aplicável;
- distinção entre fato, decisão, hipótese e opinião técnica.
