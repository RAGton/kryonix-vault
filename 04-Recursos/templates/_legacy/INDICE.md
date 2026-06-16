---
title: Índice de Templates (raiz + legacy)
type: index
status: active
tags: [vault, templates, indice, comparativo]
---

# Índice de Templates (raiz + legacy)

## Objetivo

Mapear todos os templates disponíveis em `04-Recursos/templates/` (versão canônica) e `04-Recursos/templates/_legacy/` (versões antigas vindas do inbox). Ajudar Gabriel a decidir qual versão de cada um fica como oficial.

## Resumo

Capturado em 2026-06-15. Há **9 templates na raiz** (canônicos, AGENTS-aligned) e **5 templates legacy** (vindos do inbox, formato mais simples).

## Tabela comparativa (TOON)

```toon
tipo,                 raiz_canonico,          secoes_raiz,  bytes_raiz,  legacy_equivalente,  secoes_legacy,  bytes_legacy,  decisao_sugerida
ADR,                  template-adr,           5,            1784,        decision,            5,              293,           manter_raiz (mais completo, tem Plano de rollback)
Daily log,            template-daily-log,     6,            1051,        session,             9,              877,           hibrido: session.md e daily-log.md sao diferentes
Issue Codex,          template-issue-codex,   4,            1638,        -,                    -,              -,            manter_raiz (sem equivalente legacy)
MOC,                  template-moc,           9,            1076,        -,                    -,              -,            manter_raiz (sem equivalente legacy)
Nota tecnica,         template-nota-tecnica,  7,            1247,        project-note,        3,              202,           manter_raiz (mais secoes, mais orientacao)
Playbook,             template-playbook,      6,            1819,        runbook,             6,              381,           hibrido: runbook legacy e mais focado em comandos shell
Projeto,              template-projeto,       11,           2262,        project-note,        3,              202,           manter_raiz (cobre arquitetura, stack, seguranca)
Prompt,               template-prompt,        5,            1685,        -,                    -,              -,            manter_raiz (sem equivalente legacy)
Skill,                template-skill,         6,            2318,        -,                    -,              -,            manter_raiz (sem equivalente legacy)
Entidade,             -,                      -,            -,           entity,              5,              346,           criar template raiz para entity
```

## Detalhes de cada legacy (TOON)

```toon
arquivo,         secoes,                                            observacao
decision,        Contexto|Decisao|Alternativas|Consequencias|Refs,  mais simples que template-adr; sem Plano de rollback explicito
entity,          Identidade|Estado atual|Dependencias|Historico|Refs, USADO nos arquivos de 02-Areas/Kryonix/entities/; vale criar template raiz
project-note,    Conteudo|Contexto|Referencias,                    muito magro, sem orientacao de uso
runbook,         Quando usar|Pre-req|Procedimento|Validacao|Rollback, tem exemplo bash embutido, util para runbooks NixOS
session,         Objetivo|Estado inicial|Alteracoes|Commits|...,     maior, cobre alteracoes por sessao (util para 09-Logs/sessions/)
```

## Ações recomendadas

```toon
prioridade,  acao,                                                                           tipo
P1,          Criar 04-Recursos/templates/template-entity.md baseado no legacy/entity.md,    novo_template
P2,          Renomear template-daily-log.md -> template-session.md (ou vice-versa) e mesclar, consolidacao
P3,          Mover runbook.md, decision.md, project-note.md para 04-Archive/_templates_legacy/ se nao usar,    arquivamento
P4,          Adicionar secao "Comandos shell exemplo" ao template-playbook.md a partir do legacy/runbook.md,    melhoria
```

## Próxima ação

- [ ] Gabriel revisar tabela e decidir P1-P4
- [ ] Após decisão, deletar `04-Recursos/templates/_legacy/`

## Links relacionados

- [[04-Recursos/templates/README]]
- [[AGENTS]] (seção "Note quality standard" e "Skill rules")
