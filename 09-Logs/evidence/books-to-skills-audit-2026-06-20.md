---
status: ativo
validade: validado_por_inventario
tipo: relatorio_auditoria
projeto: kryonix
componente: biblioteca
fonte_verdade: vault
confianca: alta
rag: baixo_peso
graph: true
validado_em: 2026-06-20
author: aura
tags: [kryonix, auditoria, livros, skills, bibliografia]
---

# Auditoria books-to-skills — 2026-06-20

## Resumo executivo

Auditoria da biblioteca de livros em PDF (109 PDFs, ~800 MB) com triagem temática, extração de sumários via `poppler-utils`, criação de **8 skills temáticas** consolidadas e **1 MOC** de biblioteca.

## Comandos executados

```bash
# Fase 0 — validação de ferramentas
nix-shell -p poppler-utils --run "pdfinfo -v; pdftotext -v"

# Criados scripts reutilizáveis:
# /home/rocha/.local/bin/hermes-pdf-read
# /home/rocha/.local/bin/hermes-pdf-index

# Fase 1 — inventário completo (109 PDFs, 1 nix-shell)
# Output: 09-Logs/evidence/books-pdf-inventory-2026-06-20.tsv (26 KB)

# Fase 2 — amostragem segura (8 livros-chave, páginas 1-15)
# Output: /tmp/pdf-summaries/*.txt (144 KB)

# Fase 3+4 — skills consolidadas + MOC + relatório via write_file
```

## PDFs analisados (amostragem de 15 páginas cada)

| # | Livro | Páginas | Resultado |
|---|---|---|---|
| 1 | Código limpo (Robert Martin) | 398 | **METADADOS ENGANOSOS** — na verdade é Dreamweaver CS4 |
| 2 | Clean Coder (Martin) — **substituto** | 247 | ✓ Sumário extraído |
| 3 | O Programador Pragmático | 348 | ✓ |
| 4 | Entendendo Algoritmos | 354 | ✓ |
| 5 | DDD Referência (Evans) | 62 | ✓ |
| 6 | TDD (Kent Beck) | 215 | ✓ |
| 7 | DevOps na Prática | 262 | ✓ |
| 8 | Controlando Versões com Git | 209 | ✓ |
| 9 | Guia prático do servidor Linux | 151 | ✓ |

## Skills criadas (8)

```
04-Recursos/skills/livros/
├── clean-code-professionalism/SKILL.md      (6.2 KB, 140 linhas)
├── pragmatic-programmer-workflow/SKILL.md   (6.4 KB, 150 linhas)
├── algorithms-data-structures-fundamentals/SKILL.md (6.8 KB, 176 linhas)
├── ddd-architecture-patterns/SKILL.md       (9.2 KB, 211 linhas)
├── test-driven-development/SKILL.md         (6.7 KB, 171 linhas)
├── devops-ci-cd-practices/SKILL.md          (6.8 KB, 186 linhas)
├── git-github-operacional/SKILL.md          (5.4 KB, 182 linhas)
└── linux-sysadmin-fundamentals/SKILL.md     (8.1 KB, 285 linhas)
```

Cada skill segue frontmatter completo do `RAG_POLICY_LOCAL.md` (status, validade, tipo, projeto, componente, fonte_verdade, confianca, rag, graph, validado_em, operation_mode, tags) e template operacional (Objetivo, Resumo, Quando usar, Quando não usar, Princípios-chave consolidados, Procedimento, Checklist, Riscos, Token-saving, Base prompt, Livros-fonte, Links).

## Livros no MOC (sem skill)

| Tema | Livros | Racional |
|---|---|---|
| aws-cloud | 10 | Fora do foco atual (Inspiron + NixOS local) |
| agile-scrum-kanban | 12 | Gabriel trabalha solo no Kryonix |
| gestao-produto-ux | 3 | Relevante só com usuários finais |
| api-web | 15 | Diverso; split futuro em 2-3 skills |
| carreira-soft-skills | 10 | Parcialmente em pragmatic-programmer-workflow |
| outros | 13 | Miscelânea sem skill dedicada |

## Arquivos alterados

```
CRIADOS (vault):
  04-Recursos/skills/livros/<8 skills>/SKILL.md
  01-MOCs/Mapa - Biblioteca.md
  09-Logs/evidence/books-to-skills-audit-2026-06-20.md

CRIADOS (fora do vault):
  /home/rocha/.local/bin/hermes-pdf-read
  /home/rocha/.local/bin/hermes-pdf-index
```

## Confirmações

- ✅ Nenhum PDF foi movido, renomeado ou apagado.
- ✅ Nenhum livro foi copiado integralmente para o Vault (apenas sumários curtos em /tmp).
- ✅ Nenhum commit ou push foi realizado.
- ✅ Brain/LightRAG/Neo4j não foram tocados (Glacier congelado).
- ✅ Todas as skills seguem `RAG_POLICY_LOCAL.md` e `SOURCE_AUTHORITY.md`.

## Riscos

1. **PDF enganoso** — `Código limpo.pdf` é na verdade Dreamweaver CS4. Requer correção manual.
2. **Skills não validadas em uso real** — precisam ser testadas em próximos PRs/reviews.
3. **13 livros em "outros"** — reclassificar quando houver tempo.

## Pendências

- [ ] Corrigir "Código limpo" enganoso (renomear/substituir)
- [ ] Testar skills em uso real (PRs, code reviews, config de servidor)
- [ ] Reclassificar os 13 livros em "outros"
- [ ] Considerar 2-3 skills adicionais (aws-cloud, agile-scrum, api-rest)

## Validação

```bash
cd /home/rocha/kryonix/kryonix-vault
git status --short
find 04-Recursos/skills/livros -maxdepth 2 -type f -name 'SKILL.md' | wc -l
# Esperado: 8
```
