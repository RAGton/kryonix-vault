---
title: algorithms-data-structures-fundamentals
type: skill
status: ativo_revisao_pendente
purpose: Aplicar algoritmos e estruturas de dados fundamentais, da base didática até Cormen, com foco em resolução de problemas de engenharia
validade: revisao_humana_pendente
tipo: skill
projeto: kryonix
componente: algoritmos
fonte_verdade: livro (Entendendo Algoritmos, Algoritmos - Teoria e Prática, Cracking the Coding Interview)
confianca: media
rag: baixo_peso
graph: true
validado_em: 2026-06-20
operation_mode: inspiron-local-hermes-openrouter
author: aura
source_book: "Entendendo Algoritmos (Bhargava), Algoritmos Teoria e Prática (Cormen), Cracking the Coding Interview (McDowell)"
source_path: 04-Recursos/livros/
tags: [kryonix, skill, algoritmos, estruturas-dados, complexidade, books]
---

# algorithms-data-structures-fundamentals

## Objetivo

Aplicar algoritmos e estruturas de dados clássicos em problemas reais do Kryonix (processamento de flakes, busca em índices, ordenação de dependências) e em entrevistas/avaliações técnicas, baseando-se em 3 obras: **Entendendo Algoritmos** (Bhargava, didática), **Algoritmos - Teoria e Prática** (Cormen, canônico) e **Cracking the Coding Interview** (McDowell, aplicação).

## Resumo

Consolidação didática + teórica + prática. Começa pelo **visual** (Bhargava), aprofunda no **formal** (Cormen), aplica em **entrevista** (McDowell). Não substitui leitura integral — serve como mapa mental rápido e checklist de aplicação.

> **⚠️ Amostragem parcial** — Esta skill é derivada de amostragem limitada (apenas 15 páginas por livro + metadados via `pdfinfo`) e consolidação de múltiplas fontes. **NÃO é verdade operacional do Kryonix.** Requer validação prática em uso real antes de ser promovida para confiança alta. Use como checklist orientativo; para decisão crítica, consulte o livro original.

## Quando usar

- Ao modelar problema complexo (ex: ordenação topológica de módulos Nix).
- Ao escolher estrutura de dados apropriada.
- Ao resolver desafios de entrevista.
- Ao avaliar complexidade de algoritmo no código do Kryonix (Rust).
- Em disciplina da faculdade (IFMT, Algoritmos e Estruturas de Dados).

## Quando não usar

- Não serve para ML/Data Science — usar skills específicas de IA.
- Não serve para otimização de queries SQL — usar skills de BD.

## Princípios-chave consolidados

### Análise de complexidade

```txt
O(1)    → acesso direto (array, hashmap) — melhor caso
O(log n) → busca binária, BST balanceada — muito bom
O(n)    → varredura linear — aceitável
O(n log n) → merge sort, quicksort médio — bom para ordenação
O(n²)   → bubble, insertion, loops aninhados — evite em n grande
O(2^n)  → força bruta, subconjuntos — exponencial, evite
O(n!)   → permutações — impraticável
```

### Estruturas fundamentais

```txt
ARRAY         — contíguo, acesso O(1), inserção O(n)
LINKED LIST   — disperso, inserção O(1) conhecendo pos, busca O(n)
HASH TABLE    — acesso O(1) amortizado, colisões importantes
STACK         — LIFO, recursão, parser, undo
QUEUE         — FIFO, BFS, jobs, buffer
BINARY TREE   — hierarquia, BST: busca O(log n) se balanceada
HEAP          — priority queue, top-K, scheduling
GRAPH         — redes, dependências, caminhos
```

### Algoritmos fundamentais (Bhargava)

1. **Busca binária** — array ordenado, O(log n).
2. **Seleção** — menor elemento, O(n) por iteração.
3. **Recursão** — caso base + caso recursivo.
4. **Divide and conquer** — quicksort, mergesort.
5. **Hash functions** — mapeamento consistente.
6. **BFS** — menor caminho em grafo não-pesado.
7. **Dijkstra** — menor caminho com pesos (não-negativos).
8. **Greedy** — seleção local ótima, quando funciona.
9. **Dynamic programming** — sobreposição de subproblemas + subestrutura ótima.

### Cormen — conceitos canônicos

1. **Notação assintótica rigorosa** — Big-O, Big-Ω, Big-Θ.
2. **Amortized analysis** — custo médio de operações.
3. **Red-black tree** — BST auto-balanceada formal.
4. **Matroid** — generalização de greedy correctness.
5. **NP-completeness** — redução, Cook-Levin.

### McDowell — abordagem de entrevista

1. **BUD** — Bottlenecks, Unnecessary work, Duplicated work.
2. **DIY** — resolver um caso à mão antes de codificar.
3. **Base case and build** — de pequeno para grande.
4. **Data structure brainstorm** — listar estruturas relevantes antes.
5. **Test with edge cases** — vazio, único, duplicado, negativo.

## Procedimento — resolver problema algorítmico

```txt
1. ENTENDER o problema (ler 2x, anotar input/output/exemplos).
2. EXEMPLOS à mão (casos pequenos → padrão).
3. BRUTE FORCE primeiro (corrige > otimiza).
4. IDENTIFICAR padrões:
   - É ordenação? → O(n log n) target
   - É busca? → O(log n) possível?
   - Tem subestrutura? → DP ou greedy
   - É caminho? → BFS/Dijkstra
   - Tem "melhor subconjuto"? → DP
5. MODELAR com estrutura adequada:
   - Grafo? → adj list / matrix
   - Fila prioridade? → heap
   - Cache de resultados? → hashmap
6. IMPLEMENTAR em linguagem do projeto (Rust pro Kryonix).
7. TESTAR: edge cases + casos médios + grandes.
8. ANALISAR complexidade (tempo + espaço).
```

## Checklist — avaliação de código algorítmico

```txt
- [ ] Complexidade de tempo aceitável pro caso de uso?
- [ ] Complexidade de espaço não explode (>O(n)?)
- [ ] Edge cases cobertos (vazio, n=1, duplicados, negativos, máx int)?
- [ ] Sem loop infinito possível (condição de parada)?
- [ ] Sem off-by-one (limites do array)?
- [ ] Sem int overflow (usar i64 em Rust quando n > 1e9)?
- [ ] Algoritmo estável/ordenado quando necessário?
```

## Aplicação no Kryonix

```txt
Cenário: resolver ordem de aplicação de módulos NixOS
→ Modelo: DAG (grafo acíclico direcionado) das dependências
→ Algoritmo: ordenação topológica (Kahn's ou DFS)
→ Edge case: detectar ciclo (dependência circular)
→ Saída: ordem linear de módulos a aplicar
```

## Riscos

- Aplicar DP sem necessidade (problema tem greedy ótimo).
- Ignorar custo de memória (hash tables gigantes em sistemas embarcados).
- "Decoreba" em vez de compreensão — o padrão não aparece em variação.
- Subotimizar código que não é bottleneck (Mede primeiro, otimiza depois).

## Token-saving mechanism

Consolida ~2100 páginas (Cormen + Bhargava + McDowell) em 4 seções de referência + procedimentos + checklist. Uso: quando tiver problema algorítmico, consulta o mapa antes.

## Base prompt

```txt
Atue como engenheiro especialista em algoritmos.
Dado o problema abaixo, aplique o workflow da skill [[04-Recursos/skills/livros/algorithms-data-structures-fundamentals/SKILL]]
Produza: (1) formulação, (2) estrutura de dados recomendada,
(3) algoritmo escolhido com justificativa, (4) complexidade,
(5) implementação em Rust/Python, (6) testes de edge cases.
```

## Livros-fonte

```txt
04-Recursos/livros/Entendendo Algoritmos - Um Guia Ilustrado - Autor (Aditya Y. Bhargava).pdf
04-Recursos/livros/Algoritmos - Teoria e Prática - Autor (Thomas Cormen).pdf
04-Recursos/livros/Cracking the Coding Interview - 189 Programming Questions and Solutions - Autor (Gayle Laakmann McDowell).pdf
04-Recursos/livros/Introdução a data science - Algoritmos de machine learning - Autor (Casa do Código).pdf
```

## Links relacionados

- [[04-Recursos/skills/livros/pragmatic-programmer-workflow/SKILL]]
- [[04-Recursos/skills/livros/ddd-architecture-patterns/SKILL]]
- [[01-MOCs/Mapa - Biblioteca]]
- [[01-MOCs/Mapa - Ciência da Computação]]
