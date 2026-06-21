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

# Skill — PR Review & Small Commits

## Objetivo

Criar e revisar PRs com commits pequenos, atômicos e significativos, facilitando revisão humana e rollback cirúrgico.

## Quando usar

- Após implementação em worktree isolada.
- Antes de solicitar merge na main.
- Para revisar código de colegas ou da IA.
- Para documentar mudanças de forma granular.

## Quando não usar

- Para mudanças triviais (typo, whitespace) — commit direto.
- Quando o usuário pede explicitamentesquash commit.
- Para branches experimentais sem intenção de merge.

## Contexto necessário

- Branch com commits prontos.
- Spec/issue vinculada.
- Critérios de aceite.
- Base de comparação (main ou develop).

## Entrada esperada

Branch com implementação + spec vinculada.

## Saída esperada

- PR com descrição clara.
- Commits pequenos e coerentes.
- Diff revisado.
- Comentários inline (se necessário).
- Status: ready for merge / changes requested.

## Procedimento

1. Verificar branch: `git log --oneline main..HEAD`.
2. Cada commit deve:
   - Ter mensagem conventional (`feat:`, `fix:`, `docs:`, etc).
   - Conter 1 mudança lógica (não 5 coisas misturadas).
   - Passar testes e linters.
3. Abrir PR:
   - Título: `feat(installer): add NVMe disk detection`.
   - Descrição: linkar issue/spec, listar mudanças, screenshots se UI.
   - Base: main ou develop.
4. Revisar diff:
   - Ler cada arquivo modificado.
   - Verificar: lógica correta? testes? edge cases?
   - Identificar: code smells, bugs potenciais, melhorias.
5. Comentar inline:
   - Ser específico (linha + sugestão de código).
   - Distinguir: blocking vs suggestion.
   - Não nitpick estilo (formatter faz isso).
6. Decisão:
   - Ready: aprovar.
   - Changes: comentar com pedidos claros.
   - Blocker: segurança/testes quebrados = rejeitar.
7. Após aprovação: merge (squash se muitos commits pequenos).
8. Limpar branch e worktree.

## Checklist

- [ ] Commits pequenos (1 lógica por commit)?
- [ ] Mensagens conventional commits?
- [ ] Testes passam?
- [ ] Linters passam?
- [ ] PR vinculado à spec/issue?
- [ ] Diff revisado linha por linha?
- [ ] Comentários inline (se necessário)?
- [ ] Sem arquivos fora de escopo?
- [ ] No secrets no diff?

## Validação

- PR pode ser revertido sem quebrar outros commits.
- Revisor entende a mudança lendo título + descrição.
- Nenhum bug óbvio no diff.

## Riscos

- Commit grande = revisão superficial = bug passa.
- Squash sem revisão = perde granularidade.
- Aprovar sem ler diff = risco.
- Comentários vagos = autor não sabe o que corrigir.

## Exemplo Kryonix

PR: `feat(installer): add NVMe disk detection`
Commits:
1. `feat(disk): detect NVMe devices`
2. `test(disk): add NVMe detection tests`
3. `feat(ui): list NVMe disks in selector`
Diff revisado: lógica OK, testes cobrem edge cases, UI responsiva. Aprovado.

## Prompt base para agente

```
Você é um revisor de PR rigoroso. Verifique commits pequenos e coerentes, testes, linters, diff limpo. Comente inline com sugestões específicas. Aprove apenas se sem blockers. Nunca aprove sem ler o diff.
```

##Links relacionados

- [[04-Recursos/skills/vibe-coding/agentic-worktree-loop]]
- [[04-Recursos/skills/vibe-coding/briefing-to-spec]]
- [[04-Recursos/skills/revisao-pr]]
