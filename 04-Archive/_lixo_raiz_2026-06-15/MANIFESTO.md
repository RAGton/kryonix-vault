---
title: Manifesto - Arquivos soltos na raiz do vault (jun-2026)
type: manifest
status: cleanup
tags: [vault, cleanup, lixo, manifesto, n8n, academico]
---

# Manifesto - Arquivos soltos na raiz do vault (jun-2026)

## Objetivo

Catalogar e isolar arquivos que apareceram na raiz do kryonix-vault sem
pertencer à estrutura do vault. Preserva histórico e facilita revisão antes
da deleção definitiva.

## Resumo

Capturado em 2026-06-15 durante a reorganização. Nenhum dos 4 arquivos
tinha relação com notas, wikilinks, MOCs ou qualquer outro conteúdo do vault.
A maioria é material de estudo/produtividade que caiu na raiz por descuido
(provavelmente export ou download direto pro HOME do vault).

## Inventário (TOON)

```toon
arquivo,                                                           tipo,       bytes,  origem_provavel,    destino_sugerido
Atividade_Avaliativa__Elaboracao_de_Trabalho_Academico-*.docx,    docx,       19240,  download_estudante, 04-Recursos/personal/_estudos/
Gemini File Search RAG.json,                                       n8n_flow,   14975,  export_n8n,         04-Recursos/personal/_n8n_flows/
RAG___AULA_SKOOL___SUPABASE (1).json,                              n8n_flow,    9612,  export_n8n,         04-Recursos/personal/_n8n_flows/
Seu_Primeiro_Agente_IA__DEMO_YT_.json,                             n8n_flow,   19594,  export_n8n,         04-Recursos/personal/_n8n_flows/
```

## Decisão

Por enquanto, **mover para `04-Archive/_lixo_raiz_2026-06-15/`** (esta pasta).
Não deleto pois pode ter valor pessoal pra Gabriel.

## Próxima ação

- [ ] Gabriel revisar conteúdo dos 4 arquivos
- [ ] Mover para `04-Recursos/personal/` se quiser manter
- [ ] Deletar definitivamente se for lixo
- [ ] Sugerir `.gitignore` para `04-Recursos/personal/` (não versionar)

## Links relacionados

- [[AGENTS]] · [[VAULT_INDEX]]
- [[04-Archive/_lixo_inbox_2026-06-15]] (lixo do inbox, paralelo)
