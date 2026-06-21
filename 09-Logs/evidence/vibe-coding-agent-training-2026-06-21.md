---
tipo: evidence
projeto: kryonix
componente: vibe-coding
data: 2026-06-21
author: aura
status: completo
tags: [vibe-coding, training, skills, templates]
---

# Relatório — Treinamento Vibe Coding para Hermes/Aura

## Data
2026-06-21

## Objetivo
Criar sistema de skills, templates e workflows para treinar Hermes/Aura em vibe coding profissional no ecossistema Kryonix. Baseado no curso "Vibe-Coding: O Futuro do Desenvolvimento" e nas práticas do projeto.

## Fontes usadas
- Curso: "Vibe-Coding: O Futuro do Desenvolvimento" (mentalidade, não implementação literal)
- Referências: Claude Code, Cursor, Windsurf, GitHub Copilot
- Práticas Kryonix: worktree isolado, commits pequenos, testes, Vault

## Skills criadas (8)

| # | Skill | Objetivo |
|---|-------|---------|
| 1 | `briefing-to-spec` | Transformar ideia bruta em spec técnica |
| 2 | `tool-bakeoff` | Comparar ferramentas de vibe coding |
| 3 | `agentic-worktree-loop` | Loop de implementação em worktree isolado |
| 4 | `ui-reference-extraction` | Extrair padrões de referências visuais |
| 5 | `mvp-validation-gate` | Portões de validação antes de escalar |
| 6 | `security-before-scale` | Bloquear escala sem segurança |
| 7 | `pr-review-small-commits` | Criar/revisar PRs com commits pequenos |
| 8 | `vault-memory-after-action` | Registrar aprendizados no Vault |

Caminho base: `04-Recursos/skills/vibe-coding/`

## Templates criados (7)

| # | Template | Uso |
|---|---------|-----|
| 1 | `briefing.md` | Briefing inicial para spec |
| 2 | `product-spec.md` | Especificação técnica completa |
| 3 | `tool-bakeoff-report.md` | Relatório comparativo de ferramentas |
| 4 | `mvp-validation-report.md` | Validação de MVP antes de escalar |
| 5 | `security-gate.md` | Auditoria de segurança |
| 6 | `agent-run-report.md` | Relatório de execução de agente |
| 7 | `tool-matrix.md` | Matriz de ferramentas comparativa |

Caminho base: `04-Recursos/templates/vibe-coding/`

## Matriz de ferramentas

Criada como parte dos templates (`tool-matrix.md`). Cobre:
- Hermes/Aura, Claude Code, Cursor, Windsurf
- Google AI Studio, Lovable, Replit
- GitHub Copilot

Formato: Melhor uso | Quando não usar | Validação | Risco.

## Riscos identificados

1. **Skills não validadas em prática** — status `ativo_revisao_pendente` porque ainda não foram testadas em tasks reais.
2. **Templates podem precisar ajuste** — estrutura é baseada em boas práticas mas pode não se encaixar 100% em todos os casos.
3. **Matriz de ferramentas muda** — ferramenta que é boa hoje pode não ser amanhã.
4. **Vibe coding sem controle = risco** — o sistema inteiro é para evitar IA codando solta no Kryonix.

## Validações realizadas

- [x] Diretórios criados nos paths corretos do Vault.
- [x] Frontmatter YAML válido em todos os arquivos.
- [x] Tags consistentes (vibe-coding).
- [x] Links internos Obsidian funcionais.
- [x] Nenhum arquivo canônico alterado.
- [x] Nenhum .obsidian modificado.
- [x] Nenhum commit/push executado.

## Confirmações de segurança

- Não movi/apaguei nenhum arquivo existente.
- Não mexi em `.obsidian/`.
- Não fiz commit.
- Não fiz push.
- Não alterei arquivos fora de `04-Recursos/skills/vibe-coding/`, `04-Recursos/templates/vibe-coding/` e `09-Logs/evidence/`.

## Próximos passos

1. **Revisão humana** das 8 skills e 7 templates — aprovar, ajustar ou rejeitar.
2. **Teste prático** — usar as skills em 3 tasks reais:
   - Teste 1: Refinar UI do installer (briefing-to-spec + ui-reference-extraction).
   - Teste 2: Corrigir feature Nix inválida (agentic-worktree-loop + pr-review-small-commits).
   - Teste 3: MVP interno de visualização de logs (tool-bakeoff + mvp-validation-gate).
3. **Ajustar skills** baseado nos resultados dos testes.
4. **Criar MOC** `01-MOCs/Mapa - Vibe Coding` para navegação.
5. **Atualizar memória** no Vault após validação.

## Artefatos gerados

- 8 skills em `04-Recursos/skills/vibe-coding/*/SKILL.md`
- 7 templates em `04-Recursos/templates/vibe-coding/*.md`
- Este relatório em `09-Logs/evidence/vibe-coding-agent-training-2026-06-21.md`
