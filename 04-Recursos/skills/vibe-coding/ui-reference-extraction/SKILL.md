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

# Skill — UI Reference Extraction

## Objetivo

Extrair padrões de design, layouts e componentes de referências visuais (screenshots, sites, apps) para usar como inspiração — nunca como cópia literal — em implementações de UI.

## Quando usar

- Quando há referência visual aprovada (screenshot, Figma, site).
- Para traduzir "quero que fique assim" em especificação técnica.
- Antes de implementar UI nova com base em inspiração externa.
- Para documentar padrões de design do Kryonix.

## Quando não usar

- Quando não há referência (usar briefing-to-spec primeiro).
- Para copiar 1:1 UI de produto concorrente (questão legal/ética).
- Quando o usuário quer design próprio sem referências.

## Contexto necessário

- Imagem/URL da referência.
- Stack de UI do projeto (React, CSS framework).
- Design system existente (se houver).
- Público-alvo e contexto de uso.

## Entrada esperada

Screenshot, URL, ou descrição visual detalhada.

## Saída esperada

Documento com:
- Padrões visuais identificados (cores, espaçamento, tipografia).
- Componentes extraídos (navbar, card, modal, etc).
- Layout grid/flex sugerido.
- Acessibilidade observada (contraste, foco).
- Adaptação para stack do Kryonix.
- Aviso explícito se há risco de cópia.

## Procedimento

1. Receber referência visual.
2. Identificar padrão de layout (grid, sidebar, dashboard, wizard).
3. Extrair componentes visuais (cards, botões, inputs, tabelas).
4. Anotar cores principais e paleta aproximada.
5. Observar tipografia (serif? sans? tamanho base?).
6. Avaliar espaçamento (denso? respirado?).
7. Verificar acessibilidade básica (contraste, tamanhos de toque).
8. Traduzir para stack do projeto (Tailwind? CSS Modules? styled-components?).
9. Documentar adaptação: o que muda do original pro nosso contexto.
10. Salvar como nota de referência com link pra imagem original.

## Checklist

- [ ] Referência visual identificada e salva?
- [ ] Componentes listados?
- [ ] Paleta de cores documentada?
- [ ] Tipografia observada?
- [ ] Acessibilidade básica verificada?
- [ ] Adaptação para stack Kryonix definida?
- [ ] Risco de cópia avaliado e mitigado?

## Validação

- Especificação permite implementar sem ver a referência de novo.
- Nenhum elemento copiado literalmente (é inspiração, não clone).
- Stack do Kryonix respeitada.

## Riscos

- Copiar UI de produto proprietário = risco legal.
- Ignorar acessibilidade da referência original.
- Adaptar mal (stack diferente da referência = gambiarra).
- Focar no visual e esquecer funcionalidade.

## Exemplo Kryonix

Referência: "Tela de instalação do Ubuntu com sidebar de passos."
Extração: wizard vertical à esquerda, conteúdo à direita, barra de progresso no topo.
Adaptação: React + Tailwind, componentes StepIndicator, ContentPanel, ProgressBar.

## Prompt base para agente

```
Você é um analista de UI. Receba uma referência visual e extraia padrões de layout, componentes, cores e tipografia. NÃO copie — interprete. Traduza para a stack do projeto. Documente diferenças entre referência e adaptação.
```

## Links relacionados

- [[04-Recursos/skills/vibe-coding/briefing-to-spec]]
- [[04-Recursos/skills/vibe-coding/mvp-validation-gate]]
