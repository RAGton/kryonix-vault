---
status: ativo_revisao_pendente
validade: revisao_humana_pendente
tipo: skill
projeto: kryonix
componente: vibe-coding
fonte_verdade: curso_transformado
confianca: media
rag: baixo_peso
graph: true
created: 2026-06-21
updated: 2026-06-21
author: aura
aliases: []
tags: [vibe-coding, ai-agent, hermes, aura, workflow]
---

# Skill — Tool Bakeoff

## Objetivo

Comparar sistematicamente múltiplas ferramentas de vibe coding (Cursor, Windsurf, Copilot, Hermes, etc.) aplicando o mesmo prompt/tarefa em cada uma, gerando relatório objetivo.

## Quando usar

- Antes de adotar uma nova ferramenta no workflow Kryonix.
- Quando há dúvida entre 2-3 ferramentas similares.
- Para validar se a ferramenta entrega resultado real ou só parece boa no demo.
- Para documentar trade-offs antes de decisão.

## Quando não usar

- Quando a ferramenta já foi validada e está em uso estável.
- Para comparações superficiais sem tarefa real.
- Quando o tempo disponível é menor que 2h por ferramenta.

## Contexto necessário

- Lista de ferramentas candidatas.
- Tarefa real e representativa (não toy example).
- Critérios de avaliação (velocidade, qualidade, segurança, custo).
- Ambiente isolado para cada teste.

## Entrada esperada

Nome das ferramentas + tarefa de referência + critérios de avaliação.

## Saída esperada

Relatório comparativo em `04-Recursos/templates/vibe-coding/tool-bakeoff-report.md` com:
- Setup de cada ferramenta
- Mesma tarefa aplicada
- Resultados客观os (tempo, linhas de código, bugs)
- Resultados subjetivos (DX, curva de aprendizado)
- Recomendação final com justificativa

## Procedimento

1. Definir tarefa de referência real (não "hello world").
2. Definir 5-7 critérios de avaliação ponderados.
3. Para cada ferramenta:
   a. Isolar ambiente (branch/worktree/container).
   b. Aplicar exatamente o mesmo prompt.
   c. Cronometrar tempo até resultado funcional.
   d. Avaliar qualidade do output (testes passam?).
   e. Registrar diff, erros, e observações.
4. Consolidar em relatório comparativo.
5. Incluir veredito: qual usar para qual cenário.
6. Salvar em `09-Logs/evidence/`.

## Checklist

- [ ] Tarefa é representativa de uso real?
- [ ] Ambiente isolado para cada ferramenta?
- [ ] Mesmo prompt/tarefa para todas?
- [ ] Critérios definidos ANTES de testar?
- [ ] Resultados objetivos (tempo, testes)?
- [ ] Resultados subjetivos documentados?
- [ ] Recomendação final com justificativa?

## Validação

- Relatório permite decisão informada.
- Nenhum viés: se a pior ferramenta ganhou em algo, registrar.
- Custo (tokens, tempo) documentado.

## Riscos

- Teste enviesado (prompt mais detalhado pra ferramenta favorita).
- Ignorar diferenças de contexto (cada ferramenta tem setup diferente).
- Decidir pela mais bonita e não pela mais funcional.

## Exemplo Kryonix

Teste: "Adicionar página de logs no installer com filtros e export CSV".
Ferramentas: Cursor vs Windsurf vs Hermes+Aura.
Critérios: tempo, qualidade do código, testes, segurança de paths.

## Prompt base para agente

```
Você é um avaliador imparcial de ferramentas de desenvolvimento. Para cada ferramenta, aplique exatamente a mesma tarefa no mesmo repositório. Registre tempo, qualidade, diffs e erros. Gere relatório comparativo objetivo.
```

## Links relacionados

- [[04-Recursos/templates/vibe-coding/tool-bakeoff-report]]
- [[04-Recursos/templates/vibe-coding/tool-matrix]]
- [[04-Recursos/skills/vibe-coding/briefing-to-spec]]
