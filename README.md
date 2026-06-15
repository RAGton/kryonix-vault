---
title: Kryonix Vault
type: readme
status: active
tags: [vault, readme]
created: 2026-06-14
updated: 2026-06-14
---

# Kryonix Vault

Cérebro técnico e base de conhecimento (RAG) do ecossistema **Kryonix**.
Estrutura PARA (Projects · Areas · Resources · Archive) com extensões MOCs e
Logs.

## Entrada

Sempre comece por [[VAULT_INDEX]]. Para agentes IA, leia também [[AGENTS]] e
[[PROMPT_MASTER]] antes de operar.

## Layout

```
00-Inbox/        captura rápida, temporário
01-Projects/     trabalho ativo com prazo
02-Areas/        conhecimento de longo prazo
  └── Kryonix/   docs canônicas + hosts/sistemas
03-Resources/    reutilizáveis
  ├── templates/   YAML + XML Claude + TOON
  ├── skills/      Skills de agentes
  ├── playbooks/   procedimentos operacionais
  │   └── runbooks/  procedimentos atrelados a comandos
  ├── prompts/     prompts reutilizáveis
  └── references/  curadoria externa
04-Archive/      inativo / legacy
10-MOCs/         mapas de navegação
99-Logs/         revisões, decisões, evidências
  └── evidence/    artefatos de validação
```

Razão de `10-` e `99-`: separar MOCs e Logs do bloco PARA principal sem
quebrar a ordem alfabética de pastas.

## Convenções

- **Templates**: [[03-Resources/templates/README]] — YAML frontmatter + XML
  Claude + TOON em listas grandes.
- **Wikilinks**: caminho completo a partir da raiz, ex.
  `[[03-Resources/skills/revisao-pr/SKILL]]`.
- **Nomes**: kebab-case para arquivos novos; arquivos legados em Capitalizado
  com espaços são tolerados.

## Validação

```bash
just check-links          # roda scripts/check_obsidian_links.py
just list                 # lista todos os .md
```

## Licença

Source Available / Proprietário — Todos os Direitos Reservados.
Leitura e estudo permitidos; redistribuição comercial requer autorização
escrita de Gabriel Aguiar Rocha.
