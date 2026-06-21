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

# Skill — Security Before Scale

## Objetivo

Bloquear escalada de MVP/solução quando há vulnerabilidades de segurança não resolvidas. Segurança é pré-requisito, não pós-pensamento.

## Quando usar

- Antes de escalar qualquer solução para produção.
- Antes de expor sistema a usuários externos.
- Após detectar falha de segurança em revisão.
- Antes de integrar com APIs/serviços de terceiros.

## Quando não usar

- Para experimentos locais sem dados reais.
- Para protótipos descartáveis (spikes).
- Quando não há dados sensíveis envolvidos (mas verificar primeiro).

## Contexto necessário

- Código funcional do MVP/sistema.
- Fluxo de dados sensíveis (se houver).
- Ambiente de deployment.
- Ameaças conhecidas do contexto.

## Entrada esperada

MVP/sistema para auditoria + contexto de uso + dados envolvidos.

## Saída esperada

Relatório de segurança com:
- Vulnerabilidades encontradas (CRITICAL, HIGH, MEDIUM, LOW).
- Superfícies de ataque identificadas.
- Recomendações de mitigação.
- Bloqueadores de escala (ninguém passa sem resolver CRITICAL/HIGH).
- Checklist de segurança para antes do deploy.

## Procedimento

1. Mapear superfícies de ataque:
   - Endpoints expostos
   - Inputs do usuário
   - Autenticação/autorização
   - Secrets/credentials
   - Logs (vazam dados?)
   - Dependências (CVEs conhecidas?)
2. Verificar:
   - Secrets hardcoded? (grep por patterns)
   - Paths de arquivo controlados pelo usuário? (path traversal)
   - SQL/NoSQL injection? (queries dinâmicas)
   - XSS? (output não escapado)
   - CORS liberal demais?
   - HTTPS obrigatório?
   - Rate limiting?
3. Rodar ferramentas automatizadas:
   - `cargo audit` / `pip audit` / `npm audit`
   - Scanner de secrets (trufflehog, gitleaks)
   - SAST (se disponível)
4. Classificar achados por severidade.
5. CRITICAL/HIGH = bloqueio obrigatório.
6. MEDIUM = mitigar antes de escalar.
7. LOW = registrar no backlog.
8. Gerar relatório em `04-Recursos/templates/vibe-coding/security-gate.md`.
9. Salvar em `09-Logs/evidence/`.

## Checklist

- [ ] Superfícies de ataque mapeadas?
- [ ] Secrets verificados (nenhum hardcoded)?
- [ ] Inputs validados/sanitizados?
- [ ] Auth/authz funcionando corretamente?
- [ ] Logs não vazam dados sensíveis?
- [ ] Dependências sem CVEs críticos?
- [ ] HTTPS configurado?
- [ ] Rate limiting implementado?
- [ ] Nenhum CRITICAL/HIGH sem mitigação?

## Validação

- Nenhum CRITICAL/HIGH sem plano de mitigação.
- Relatório revisado por humano antes de escalar.
- Secrets não estão no relatório (só referências).

## Riscos

- Subestimar superfície de ataque.
- Ignorar "low impact" que vira vetor em escala.
- Auditoria superficial = falsa segurança.
- Bloquear tudo = nunca lança.

## Exemplo Kryonix

Sistema: "API de registros de rebuilds."
Achados: (1) token da API hardcoded no código (CRITICAL), (2) endpoint sem auth (HIGH), (3) logs mostram paths do sistema (MEDIUM).
Veredito: BLOQUEADO — resolver (1) e (2) antes de qualquer deploy.

## Prompt base para agente

```
Você é um auditor de segurança. Mapeie superfícies de ataque, verifique secrets, inputs, auth, logs e dependências. Classifique por severidade. CRITICAL/HIGH bloqueiam escala. Nunca exponha o valor de um secret no relatório.
```

## Links relacionados

- [[04-Recursos/templates/vibe-coding/security-gate]]
- [[04-Recursos/skills/vibe-coding/mvp-validation-gate]]
- [[04-Recursos/skills/auditoria-secrets]]
