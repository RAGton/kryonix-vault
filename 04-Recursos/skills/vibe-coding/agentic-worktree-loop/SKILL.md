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

# Skill — Agentic Worktree Loop

## Objetivo

Executar tarefas de desenvolvimento em worktrees Git isolados, com loop controlado de implementação → teste → revisão → commit, garantindo que nada quebre a branch principal.

## Quando usar

- Qualquer implementação de feature ou fix no Kryonix.
- Quando o agente precisa iterar sem poluir o histórico.
- Para testes experimentais que podem falhar.
- Para trabalho paralelo em múltiplas tasks.

## Quando não usar

- Hotfixes de emergência na main (ainda assim, idealmente em branch).
- Mudanças que não tocam código (docs, configs simples).
- Quando o usuário pede explicitamente para trabalhar direto na main.

## Contexto necessário

- Repositório Git com worktrees habilitados.
- Branch base (main ou develop).
- Tarefa definida em spec ou issue.
- Critérios de teste definidos.

## Entrada esperada

Tarefa + branch base + critérios de aceite.

## Saída esperada

- Worktree isolado com branch temática.
- Commits pequenos e atômicos.
- Todos os testes passando.
- PR pronto para revisão (ou merge draft).

## Procedimento

1. Criar worktree: `git worktree add ../kryonix-<task> -b <feature>/<task>`.
2. Entrar no worktree.
3. Implementar mudança pequena (1 função/1 componente por commit).
4. Rodar testes locais (`cargo test`, `pytest`, `nix flake check`).
5. Se falhar: corrigir, commitar de novo. Nunca force push.
6. Rodar linters (`cargo clippy`, `ruff check`, `statix`).
7. Rodar formatters (`cargo fmt`, `ruff format`, `nixfmt-rfc-style`).
8. Commit com mensagem conventional: `feat(installer): add log page`.
9. Repetir até tarefa completa.
10. Abrir PR com descrição ligada à spec.
11. Aguardar revisão humana antes de merge.
12. Limpar worktree após merge: `git worktree remove`.

## Checklist

- [ ] Worktree criado em path isolado?
- [ ] Branch nomeada por tarefa?
- [ ] Commits pequenos (1 lógica por commit)?
- [ ] Nenhum `git add .`?
- [ ] Testes passam?
- [ ] Linters passam?
- [ ] Formatter aplicado?
- [ ] PR aberto com descrição?
- [ ] Sem force push?

## Validação

- Branch principal intacta.
- Nenhum arquivo fora de escopo alterado.
- CI verde (se aplicável).
- Diff revisado pelo humano.

## Riscos

- Worktree esquecido acumulando branches — limpar após merge.
- Commit muito grande = difícil de revisar — quebrar em pedaços.
- Esquecer de rodar formatter = CI vermelha.
- Não testar em worktree e achar que tá pronto.

## Exemplo Kryonix

Tarefa: "Adicionar suporte a disco NVMe no installer."
1. `git worktree add ../kryonix-nvme -b feat/nvme-support`
2. Implementar detecção NVMe → commit
3. Adicionar testes unitários → commit
4. Atualizar UI para listar NVMe → commit
5. `cargo test && cargo clippy` → tudo verde
6. PR com 3 commits, diff limpo

## Prompt base para agente

```
Você é um agente de desenvolvimento que trabalha exclusivamente em worktrees isolados. Nunca edite a branch main. Para cada tarefa: crie worktree, implemente em commits pequenos, rode testes e linters, abra PR. Após merge, limpe o worktree.
```

## Links relacionados

- [[04-Recursos/skills/vibe-coding/pr-review-small-commits]]
- [[04-Recursos/skills/vibe-coding/briefing-to-spec]]
- [[04-Recursos/skills/vibe-coding/mvp-validation-gate]]
