---
tipo: template
status: ativo_revisao_pendente
projeto: kryonix
componente: vibe-coding
confianca: media
rag: baixo_peso
created: 2026-06-21
updated: 2026-06-21
author: aura
tags: [vibe-coding, template]
---

# Matriz de Ferramentas — Vibe Coding

> Atualizado: 2026-06-21 | Autor: Aura | Status: draft

## Legenda

- **Melhor uso:** quando a ferramenta brilha
- **Quando não usar:** limitações conhecidas
- **Validação:** como confirmar resultado
- **Risco:** o que pode dar errado

## Matriz

| Ferramenta | Melhor uso | Quando não usar | Validação | Risco |
|------------|-----------|----------------|-----------|-------|
| **Hermes/Aura** | Projeto Kryonix, NixOS, Vault, automação, workflows estruturados | UI visual pura sem terminal | Testes locais + revisão humana | Agir sem contexto suficiente |
| **Claude Code** | Features complexas, PRs, revisão de código no terminal | Mudanças sem diff visível | Diff + CI + revisão | Aceitar sugestão sem validar |
| **Cursor** | Edição IDE rápida com contexto do projeto | Mudanças destrutivas sem revisão | Diff + testes antes de aceitar | Copilot-itis (aceitar cegamente) |
| **Windsurf** | Fluxo IDE com agente integrado, checkpoints | Repo crítico sem branch isolada | Checkpoints + testes | Alterações amplas sem review |
| **Google AI Studio** | Protótipo visual, front-end, mockups | Backend real, segurança, dados | Screenshots + testes manuais | Protótipo sem persistência |
| **Lovable** | MVP com UI + backend simples | Escala, segurança crítica | Teste real com usuários | Vendor lock-in, controle limitado |
| **Replit** | Protótipo hospedado rápido, demo | Infra sensível, produção | Smoke test + deploy preview | Custo, limites, disponibilidade |
| **GitHub Copilot** | PR/revisão/branch, inline suggestions | Arquitetura sem contexto próprio | Diff + CI + revisão | Mudança superficial, sem visão sistêmica |

## Como usar essa matriz

1. **Identificar o tipo de tarefa** (UI, backend, infra, protótipo).
2. **Consultar "Melhor uso"** — a ferramenta certa para o job.
3. **Verificar "Quando não usar"** — evitar armadilhas.
4. **Aplicar "Validação"** — nunca confiar cegamente.
5. **Avaliar "Risco"** — mitigar antes de depender.

## Notas

- Nenhuma ferramenta substitui revisão humana.
- Ferramentas de IA aceleram, não automatizam decisão.
- No Kryonix: segurança > velocidade sempre.
- Documentar resultado em `agent-run-report` após uso significativo.

## Links relacionados

- [[04-Recursos/skills/vibe-coding/tool-bakeoff]]
- [[04-Recursos/templates/vibe-coding/tool-bakeoff-report]]
- [[04-Recursos/skills/vibe-coding/briefing-to-spec]]
