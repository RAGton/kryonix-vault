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

# Skill — Vault Memory After Action

## Objetivo

Registrar aprendizados, decisões e resultados no Vault após cada task/projeto/validação, criando memória institucional para consultas futuras.

## Quando usar

- Após completar uma task/projeto.
- Após validação (MVP, security gate).
- Após revisão (PR, code review).
- Após resolver bug complexo.
- Após descobrir algo não óbvio (tooling, workflow, edge case).

## Quando não usar

- Para trabalho rotineiro sem aprendizado novo.
- Quando o registro já existe em outro lugar (issue, PR).
- Para informações temporárias (status de task em andamento).

## Contexto necessário

- Task/projeto concluído.
- Resultados obtidos.
- Decisões tomadas.
- Lições aprendidas.
- Artefatos gerados (logs, relatórios, specs).

## Entrada esperada

Resumo da task + resultados + decisões + lições.

## Saída esperada

- Nota no Vault (09-Logs/evidence/ ou 03-Projetos/) com:
  - Objetivo
  - O que foi feito
  - Decisões e justificativas
  - Lições aprendidas
  - Artefatos (links para relatórios, PRs, specs)
  - Próximos passos (se houver)
- MOC atualizada (se aplicável).
- Skills atualizadas (se aprendizado relevante).

## Procedimento

1. Identificar o que merece registro:
   - Decisão não óbvia?
   - Bug complexo resolvido?
   - Workflow novo descoberto?
   - Falha evitada?
   - Validação concluída?
2. Escolher local no Vault:
   - Projeto específico: `03-Projetos/<projeto>/`.
   - Aprendizado geral: `09-Logs/evidence/`.
   - MOC temática: atualizar se relevante.
3. Criar/atualizar nota com template:
   - Objetivo
   - Contexto
   - O que foi feito
   - Decisões (com justificativa)
   - Resultados
   - Lições aprendidas
   - Artefatos (links)
   - Próximos passos
4. Adicionar tags Obsidian (#vibe-coding, #kryonix, etc).
5. Linkar para notas relacionadas.
6. Atualizar MOC se a nota é referência importante.
7. Atualizar skill se aprendizado é reutilizável.
8. Não commitar imediatamente — deixar usuário decidir.

## Checklist

- [ ] Aprendizado identificável?
- [ ] Local correto no Vault?
- [ ] Nota segue template?
- [ ] Tags adicionadas?
- [ ] Links para notas relacionadas?
- [ ] MOC atualizada (se aplicável)?
- [ ] Skill atualizada (se reutilizável)?
- [ ] Sem secrets na nota?

## Validação

- Nota permite reconstruir decisão sem reler toda conversa.
- Links não estão quebrados.
- Tags consistentes.

## Riscos

- Registrar demais = ruído.
- Registrar de menos = perde aprendizado.
- Nota muito longa = ninguém lê.
- Esquecer de linkar = nota isolada.

## Exemplo Kryonix

Task: "Implementar detecção NVMe no installer."
Registro: `09-Logs/evidence/nvme-detection-implementation-2026-06-21.md`
Conteúdo: objetivo, stack (Rust + udev), decisão de usar libaio vs mio, bug com discos hotplug, lição: sempre testar com disco real.

## Prompt base para agente

```
Você é o guardião da memória institucional do Kryonix. Após cada task, identifique aprendizados, decisões e resultados. Registre no Vault de forma concisa e linkada. Atualize MOCs e skills quando relevante.
```

## Links relacionados

- [[04-Recursos/skills/vibe-coding/agentic-worktree-loop]]
- [[04-Recursos/skills/vibe-coding/mvp-validation-gate]]
- [[01-MOCs/Mapa - Vibe Coding]]
