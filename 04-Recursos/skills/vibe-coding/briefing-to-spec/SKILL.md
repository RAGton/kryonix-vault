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

# Skill — Briefing to Spec

## Objetivo

Transformar uma ideia bruta ou briefing informal em uma especificação técnica estruturada, pronta para implementação controlada.

## Quando usar

- O usuário traz uma ideia vaga ("quero um dashboard", "preciso de um instalador bonito").
- Antes de qualquer implementação — sempre.
- Quando há ambiguidade sobre escopo, stack, ou critérios de aceite.
- Para alinhar expectativas entre humano e agente antes de escrever código.

## Quando não usar

- Quando já existe uma spec escrita e aprovada.
- Para mudanças triviais (fix de typo, ajuste de cor).
- Quando o usuário explicitamente pede "só faz aí".

## Contexto necessário

- Descrição da ideia/problema pelo usuário.
- Repositórios e stack envolvidos.
- Restrições conhecidas (tempo, segurança, performance).
- Referências visuais ou funcionais (se houver).

## Entrada esperada

Briefing livre do usuário: texto, áudio transcrito, screenshot com annotation, ou descrição oral.

## Saída esperada

Documento de spec estruturado com:
- Objetivo claro e mensurável
- Escopo (o que entra / o que NÃO entra)
- Stack e dependências
- Requisitos funcionais e não-funcionais
- Critérios de aceite
- Riscos identificados
- Próximos passos

## Procedimento

1. Receber o briefing bruto do usuário.
2. Identificar lacunas: o que não foi dito? Stack? Escopo? Critérios?
3. Perguntar sobre lacunas críticas (máximo 3 perguntas).
4. Classificar a ideia: UI, backend, infra, produto, bug, feature.
5. Rascunhar spec usando template `04-Recursos/templates/vibe-coding/briefing.md`.
6. Incluir seção "O que NÃO entra" para evitar scope creep.
7. Listar riscos e dependências.
8. Apresentar spec para aprovação antes de qualquer código.
9. Após aprovação, salvar em `03-Projetos/` ou nota relevante.

## Checklist

- [ ] Objetivo está claro e uma frase basta explicar?
- [ ] Escopo delimitado (entra vs não entra)?
- [ ] Stack definida?
- [ ] Critérios de aceite listados?
- [ ] Riscos identificados?
- [ ] Usuário aprovou a spec antes de codar?

## Validação

- Spec lida pelo usuário sem ambiguidade.
- Nenhum item começa com "ver se dá pra..." — tudo é ação concreta.
- Se há UI, há referência visual ou descrição detalhada.

## Riscos

- Spec muito longa vira ruído — manter concisa.
- Perguntar demais paralisa — focar no essencial.
- Aprovação verbal sem registro = retrabalho.

## Exemplo Kryonix

Entrada: "Quero refinar a tela do installer, tá feia."

Saída: Spec com objetivo (melhorar UX do installer), escopo (apenas UI, sem lógica nova), stack (React + Tailwind), critérios (loading states, feedback visual, responsivo), riscos (quebrar layout mobile).

## Prompt base para agente

```
Você é uma agente de specs técnicas. Receba um briefing informal e transforme em spec estruturada. Identifique lacunas, pergunte o essencial (máx 3 perguntas), classifique o tipo, use o template de briefing. Nunca comece a implementar sem aprovação.
```

## Links relacionados

- [[04-Recursos/templates/vibe-coding/briefing]]
- [[04-Recursos/skills/vibe-coding/tool-bakeoff]]
- [[04-Recursos/skills/vibe-coding/mvp-validation-gate]]
