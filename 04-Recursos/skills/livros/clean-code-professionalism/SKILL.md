---
title: clean-code-professionalism
type: skill
status: ativo_revisao_pendente
purpose: Aplicar princípios de código limpo, profissionalismo e artesanato de software baseados nos clássicos de Robert C. Martin, Sandro Mancuso, Chad Fowler e Pete Goodliffe
validade: revisao_humana_pendente
tipo: skill
projeto: kryonix
componente: engenharia-software
fonte_verdade: livro (The Clean Coder, The Software Craftsman, The Passionate Programmer, Como Ser um Programador Melhor)
confianca: media
rag: baixo_peso
graph: true
validado_em: 2026-06-20
operation_mode: inspiron-local-hermes-openrouter
author: aura
source_book: "The Clean Coder (Martin), The Software Craftsman (Mancuso), The Passionate Programmer (Fowler), Como ser um Programador Melhor (Goodliffe)"
source_path: 04-Recursos/livros/
tags: [kryonix, skill, clean-code, craftsmanship, books]
---

# clean-code-professionalism

## Objetivo

Aplicar princípios de código limpo e profissionalismo no desenvolvimento diário do Kryonix, baseados nos quatro pilares dos clássicos: **The Clean Coder** (Martin), **The Software Craftsman** (Mancuso), **The Passionate Programmer** (Fowler) e **Como ser um Programador Melhor** (Goodliffe).

## Resumo

Skill consolidada a partir de 4 obras canônicas. Não substitui leitura integral — serve como checklist operacional para revisão de código, decisões de carreira e postura profissional. Foca no que é **acionável**: regras de nomenclatura, tamanho de função, tratamento de erro, testes, mentoria e responsabilidade.

> **⚠️ Amostragem parcial** — Esta skill é derivada de amostragem limitada (apenas 15 páginas por livro + metadados via `pdfinfo`) e consolidação de múltiplas fontes. **NÃO é verdade operacional do Kryonix.** Requer validação prática em uso real antes de ser promovida para confiança alta. Use como checklist orientativo; para decisão crítica, consulte o livro original.

## Quando usar

- Antes de abrir PR ou submeter diff para revisão.
- Durante code review do Kryonix (kryonix, kryonixos, kryonix-installer).
- Ao mentorar alguém ou avaliar qualidade de código.
- Quando detectar "cheiros" de código ruim (variável mal-nomeada, função longa, try/catch gigante).
- Reflexão pessoal sobre postura profissional.

## Quando não usar

- Não serve para decisão de arquitetura (>2 componentes) — usar `ddd-architecture-patterns`.
- Não serve para revisão de flakes NixOS — usar `revisao-nixos-flake`.
- Não serve para segurança — usar `auditoria-secrets`.

## Princípios-chave consolidados

### Martin (Clean Coder, Clean Code)

1. **Código é comunicação** — nomes revelam intenção, comentários são fracasso.
2. **Função faz UMA coisa** — se precisa de `e` pra descrever, ela faz mais.
3. **Tratamento de erro é separável** — `try`/`catch` em função própria, nunca misturado com lógica normal.
4. **Testes são spec** — se não tem teste, não está pronto. TDD é disciplina, não técnica.
5. **Dizer "não" é profissional** — não prometa prazo que sabe que não cumpre.
6. **Mentoria e leitura contínua** — 1h/dia de estudo é mínimo.
7. **Refatoração é contínua** — boy scout rule: deixe o código melhor do que achou.

### Mancuso (Software Craftsman)

1. **Pragmatismo sobre dogma** — regras existem pra serem aplicadas, não seguidas cegamente.
2. **Orgulho do ofício** — você é responsável pelo que entrega.
3. **Parcerias com negócios** — dev e PO são time, não adversários.
4. **Aprendizado deliberado** — prática > teoria, mas prática sem reflexão é vício.

### Fowler (Passionate Programmer)

1. **Seja generalista-T** — profundidade em 1-2 áreas, largura em muitas.
2. **Invista em projetos paralelos** — código fora do trabalho expande repertório.
3. **Mantenha o currículo vivo** — cada mês, algo novo.
4. **Networking > cargo** — quem conhece você importa mais que seu título.

### Goodliffe (Programador Melhor)

1. **Aprenda a aprender** — metacognição: por que esse código funciona?
2. **Padrões de pensamento** — antes de escrever, entenda o domínio.
3. **Leitura de código** — mais importante que escrita: leia código de outros.
4. **Humildade técnica** — ninguém sabe tudo; saber onde procurar é a skill.

## Procedimento — checklist de revisão

Ao revisar código (seu ou de outro):

```txt
1. NOMES claros? (sugerem tipo, propósito, escopo)
2. FUNÇÃO pequena? (<20 linhas idealmente, faz UMA coisa)
3. SEM side effects inesperados? (getters não modificam estado)
4. ERROS tratados em camada própria? (try/catch enxuto)
5. COMENTÁRIOS desnecessários removidos? (código explica)
6. TESTE cobre happy path + edge cases?
7. DUPLICAÇÃO eliminada? (DRY consciente, não dogmático)
8. DEPENDÊNCIAS injetadas? (sem `new` espalhado)
9. FORMATO consistente? (lint + formatter aplicados)
10. LEGÍVEL pra outro dev em 5 min? (teste de legibilidade)
```

## Checklist profissional

```txt
- [ ] Li código de outro dev hoje? (>=30 min)
- [ ] Refatorei algo pequeno hoje? (boy scout)
- [ ] Escrevi teste antes/imediatamente após o código?
- [ ] Disse "não" a prazo impossível esta semana?
- [ ] Anotei 1 aprendizado novo? (MOC pessoal)
- [ ] Compartilhei conhecimento com alguém?
```


## Aplicação no Kryonix

```txt
Cenário: revisar PR no kryonix/kryonix (Rust + Nix modules)
1. Rodar checklist de revisão (10 pontos) sobre o diff.
2. Verificar nomes (snake_case + inglês técnico consistente com repo).
3. Verificar se função faz UMA coisa (split se necessário).
4. Verificar que erros são tratados em camada própria.
5. Verificar que testes cobrem happy path + edge cases.
6. Se detectar boy-scout opportunity (código melhor possível) — refatorar em PR separado, nunca no mesmo.
7. Citar skill em relatório final: "Skill usada: [[04-Recursos/skills/livros/clean-code-professionalism/SKILL]]"
```

## Riscos

- Aplicar regras dogmaticamente sem contexto — Martin mesmo diz que regras têm exceções.
- Confundir "código limpo" com "minimalismo estético" — legibilidade > elegância.
- Mentorar sem experiência real de produção — princípios precisam de caso concreto.
- Ler só a skill e nunca os livros — skill é checklist, não é substituto.

## Token-saving mechanism

Consolida 4 livros (~1200 páginas) em ~12 princípios acionáveis + 2 checklists. Quando o contexto do PR for simples, a skill já basta; só busca o livro quando precisa de profundidade.

## Base prompt

```txt
Atue como engenheiro sênior com mentalidade de craftsman.
Aplique os princípios da skill [[04-Recursos/skills/livros/clean-code-professionalism/SKILL]]
ao código/diff abaixo. Produza revisão em categorias:
nomenclatura, tamanho de função, tratamento de erro, testes, legibilidade.
```

## Livros-fonte (no vault)

```txt
04-Recursos/livros/Clean Coder, The - A Code of Conduct for Professional Programmers - Autor (Robert C. Martin).pdf
04-Recursos/livros/The Software Craftsman - Professionalism, Pragmatism, Pride - Autor (Sandro Mancuso).pdf
04-Recursos/livros/The Passionate Programmer - Creating a Remarkable Career in Software Development - Autor (Chad Fowler).pdf
04-Recursos/livros/Como ser um Programador Melhor - um Manual Para Programadores que se Importam com Código - Autor (Pete Goodliffe).pdf
```

## Links relacionados

- [[04-Recursos/skills/livros/pragmatic-programmer-workflow/SKILL]]
- [[04-Recursos/skills/livros/ddd-architecture-patterns/SKILL]]
- [[04-Recursos/skills/revisao-nixos-flake/SKILL]]
- [[01-MOCs/Mapa - Biblioteca]]
- [[01-MOCs/Mapa - Engenharia de Software]]
