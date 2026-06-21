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

# Skill — MVP Validation Gate

## Objetivo

Definir e executar portões de validação para MVPs antes de escalar, garantir segurança, ou投入 produção. Sem passar pelo gate, não escala.

## Quando usar

- Antes de lançar MVP para usuários reais.
- Antes de escalar solução (mais usuários, mais dados).
- Antes de integrar com sistemas de produção.
- Quando há dúvida se o MVP está "pronto".

## Quando não usar

- Para experimentos internos que não saem do localhost.
- Para protótipos descartáveis (spikes).
- Quando o objetivo é apenas validar hipótese com 1 pessoa.

## Contexto necessário

- MVP funcional rodando (mesmo que feio).
- Casos de uso definidos.
- Stakeholders identificados.
- Ambiente de teste isolado.

## Entrada esperada

MVP funcional + lista de funcionalidades + público-alvo.

## Saída esperada

Relatório de validação com:
- Portões avaliados (segurança, performance, UX, dados).
- Status: PASS / FAIL / CONDITIONAL.
- Bloqueadores identificados.
- Condições para escalar.
- Recomendação clara.

## Procedimento

1. Definir portões obrigatórios:
   - Segurança: secrets? paths expostos? auth?
   - Dados: backup? rollback? migração reversível?
   - Performance: carga esperada? gargalos?
   - UX: fluxo principal funciona? erros tratados?
   - Testes: cobertura mínima? cenários críticos?
2. Para cada portão, definir critérios de PASS.
3. Executar validação automatizada (testes, scans).
4. Executar validação manual (caminho feliz + erros).
5. Documentar cada portão com evidência.
6. Se algum portão falha: listar bloqueadores e corrigir.
7. Gerar relatório final em `04-Recursos/templates/vibe-coding/mvp-validation-report.md`.
8. Salvar em `09-Logs/evidence/`.

## Checklist

- [ ] Todos os portões definidos?
- [ ] Segurança validada (sem secrets expostos)?
- [ ] Dados protegidos (backup/rollback)?
- [ ] Performance aceitável?
- [ ] UX mínima funcional?
- [ ] Testes cobrem cenários críticos?
- [ ] Relatório salvo com evidências?
- [ ] Decisão documentada (escala ou não)?

## Validação

- Nenhum portão crítico em FAIL.
- Se há CONDITIONAL, condição está clara e verificável.
- Relatório permite decisão humana informada.

## Riscos

- Passar MVP sem validar segurança = vazamento.
- Escalar sem testar carga = queda.
- Ignorar UX = usuário desiste.
- Validar demais = nunca lança.

## Exemplo Kryonix

MVP: "Dashboard interno de rebuilds NixOS."
Portões: (1) auth via SSO (FAIL - não implementado), (2) dados não sensíveis em logs (PASS), (3) carregamento < 3s com 1000 registros (PASS), (4) fluxo de login funciona (PASS).
Veredito: CONDITIONAL — implementar auth antes de lançar.

## Prompt base para agente

```
Você é um gatekeeper de MVPs. Avalie cada portão (segurança, dados, performance, UX, testes) com critérios objetivos. Se algum falha, bloqueie a escala com justificativa. Gere relatório com decisão clara.
```

## Links relacionados

- [[04-Recursos/templates/vibe-coding/mvp-validation-report]]
- [[04-Recursos/skills/vibe-coding/security-before-scale]]
- [[04-Recursos/skills/vibe-coding/briefing-to-spec]]
