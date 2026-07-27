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

## Repositórios relacionados (ecossistema Kryonix)

O vault é a fonte canônica de documentação; o código vive em repos separados:

- `kryonix` — motor / engine NixOS (módulos, features, ISO).
- `kryxd` — installer daemon (Axum + React/Vite) + capability registry + KVE.
- `kryx-cli` — CLI unificada `kryx` de runtime (switch, update, kcp, kve, think).
- `kryonixos` — instância downstream (hosts: glacier, inspiron, inspiron-nina).
- `kryonix-assets` — marca, boot Plymouth, SDDM, wallpapers.
- `kryonix-brain-lightrag` — pacote Python de RAG via grafo (LightRAG).
- `kryonix-aura` — agente Aura (launcher/provider hermes).
- `kryonix-home` — ferramenta Rust de autopilot do Home Manager.

> Wiki GitHub amigável: `github:RAGton/kryonix/wiki` (porta de entrada para
> humanos; o vault é canônico para agentes).

## Layout

```
00-Inbox/        captura rápida, temporário
01-MOCs/         mapas de navegação
02-Areas/        conhecimento de longo prazo
  └── Kryonix/   docs canônicas + hosts/sistemas
03-Projetos/     trabalho ativo com prazo
04-Archive/      inativo / legacy
04-Recursos/     reutilizáveis
  ├── templates/   YAML + XML Claude + TOON
  ├── skills/      Skills de agentes
  ├── playbooks/   procedimentos operacionais
  │   └── runbooks/  procedimentos atrelados a comandos
  └── prompts/     prompts reutilizáveis
08-Referencias/  curadoria externa de fontes/código
09-Logs/         revisões, decisões, evidências
  └── evidence/    artefatos de validação
```

Numeração por área (não é PARA puro): MOCs em `01-`, Logs em `09-`;
`04-Archive` e `04-Recursos` compartilham o prefixo `04-`. Referências de
curadoria externa ficam em `08-Referencias/`, fora de `04-Recursos/`.

## Convenções

- **Templates**: [[04-Recursos/templates/README]] — YAML frontmatter + XML
  Claude + TOON em listas grandes.
- **Wikilinks**: caminho completo a partir da raiz, ex.
  `[[04-Recursos/skills/revisao-pr/SKILL]]`.
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
