---
title: Manifesto - Lixo do Inbox (jun-2026)
type: manifest
status: cleanup
tags: [vault, cleanup, lixo, manifesto, inbox, 2026-06]
---

# Manifesto - Lixo do Inbox (jun-2026)

## Objetivo

Catalogar todo o conteúdo movido do `00-Inbox/` (snapshot antigo do vault capturado em 7 de maio de 2026) para `04-Archive/_lixo_inbox_2026-06-15/` durante a reorganização de junho. Permite revisão antes de deleção definitiva e serve de histórico de decisão arquitetural.

## Resumo

Capturado em 2026-06-15. Total: **144 arquivos .md** + **6 arquivos raiz** + **1 script** em **19 pastas**. Maioria são duplicatas de conteúdo já migrado pra estrutura oficial 00-09 do vault.

## Estatísticas (TOON)

```toon
pasta_origem,    arquivos,  o_que_e
00-Inbox,        2,         recursao do snapshot (Inbox.md, IMPLEMENTAR_EM_OUTROS_PROJETOS.md)
01-Canonical,    10,        docs canonicos Kryonix (Agents, Architecture, Install, Main, etc) - duplicatas de 02-Areas/Kryonix/canonical/
01-MOCs,         10,        Mapas antigos (mesmos 10 da raiz, com paths desatualizados)
02-Areas,        45,        duplicatas de areas (Backend, Dados, DevOps, Engenharia, IA, Linux, NixOS, Produto, Seguranca)
02-Systems,      7,         duplicatas de 02-Areas/Kryonix/systems/ (Brain, Glacier, Inspiron, LightRAG, MCP, Ollama, Vault)
03-Projetos,     7,         duplicatas de 03-Projetos/ + template antigo
03-Runbooks,     2,         Docs Audit, Doctor Full (tambem estao em 04-Recursos/playbooks/runbooks/)
04-Recursos,     4,         templates antigos (Template - ADR, Issue Codex, Nota Tecnica, Projeto)
05-Evidence,     1,         README identico ao 09-Logs/evidence/README.md
05-Skills,       20,        20 skills duplicadas (ja estao em 04-Recursos/skills/)
06-Playbooks,    12,        12 playbooks duplicados (ja estao em 04-Recursos/playbooks/)
07_Branding,     0,         pasta vazia (conteudo ja migrado)
07-Prompts,      14,        14 prompts duplicados (ja estao em 04-Recursos/prompts/)
08-Referencias,  4,         4 notas duplicadas (ja estao em 08-Referencias/)
08_Sessions,     0,         pasta vazia (sessoes ja migradas pra 09-Logs/sessions/)
09-Logs,         3,         3 logs duplicados (ja estao em 09-Logs/)
90-Archive,      2,         AGENTS_LEGACY, VAULT_INDEX_LEGACY (mais legados)
scripts,         1,         check_obsidian_links.py (identico a scripts/ da raiz)
_templates,      0,         pasta vazia (templates ja migraram)
```

## Arquivos da raiz (TOON)

```toon
arquivo,                       tipo,    motivo_do_arquivamento
AGENTS.md,                     politica, versao antiga com paths 06-Playbooks/ ao inves de 04-Recursos/playbooks/
PROMPT_MASTER.md,              prompt,  versao antiga (6.3KB vs 4.0KB da raiz)
README.md,                     doc,     versao antiga (1KB vs 1.9KB da raiz)
VAULT_INDEX.md,                indice,  versao antiga (2.3KB vs 4.2KB da raiz)
IMPLEMENTAR_EM_OUTROS_PROJETOS.md, doc,  doc de transferencia entre projetos
justfile,                      build,   identico ao justfile da raiz
```

## Política de retenção

- **Manter até**: 2026-07-15 (30 dias após captura)
- **Após 30 dias**: deletar `04-Archive/_lixo_inbox_2026-06-15/` se Gabriel confirmar que não precisa restaurar nada
- **Razão**: o conteúdo está integralmente disponível na nova estrutura 00-09 + nas subpastas de `02-Areas/Kryonix/`

## Como restaurar uma nota específica (se necessário)

```bash
# Exemplo: restaurar 02-Areas/IA e Agentes/MCP Architecture.md do lixo
cd /home/rocha/kryonix/kryonix-vault
cp "04-Archive/_lixo_inbox_2026-06-15/02-Areas/IA e Agentes/MCP Architecture.md" \
   "02-Areas/IA e Agentes/"
git add "02-Areas/IA e Agentes/MCP Architecture.md"
git commit -m "restore: MCP Architecture do snapshot antigo"
```

## Links relacionados

- [[MANIFESTO]] (lixo da raiz, paralelo)
- [[04-Recursos/templates/_legacy/INDICE]] (compara templates raiz vs legacy)
- [[AGENTS]] · [[VAULT_INDEX]]
- [[04-Archive/_lixo_raiz_2026-06-15]]
