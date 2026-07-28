---
title: Projeto de Algoritmos - Nivio Ziviani - Resumo
type: nota-tecnica
status: validado
project: Kryonix
area: engenharia
tags:
  - algoritmos
  - livros
  - ciencia-da-computacao
  - clean-code
  - engenharia-software
  - estruturas-de-dados
  - ordenacao
  - complexidade
related:
  - "[[04-Recursos/principios/clean-coder-kryonix-profissionalismo.md]]"
  - "[[02-Areas/Engenharia de Software/Clean Code.md]]"
  - "[[04-Recursos/skills/livros/clean-code-professionalism/SKILL.md]]"
validated_on: 2026-07-28
---

# Projeto de Algoritmos - Nivio Ziviani - Resumo Integrado ao Clean Code

## Objetivo

Criar um resumo estruturado do livro **"Projeto de Algoritmos"** de Nivio Ziviani, integrando os conceitos ao framework de Clean Code do Kryonix.

---

## Sumário do Livro (288 páginas)

O livro é organizado em **5 capítulos principais**:

1. **Introdução** (p. 1-30) - Algoritmos, estruturas de dados, tipos abstratos, análise de desempenho
2. **Estruturas de Dados Básicas** (p. 35-58) - Listas, pilhas, filas
3. **Ordenação** (p. 69-99) - Ordenação interna e externa
4. **Pesquisa em Memória Primária** (p. 107-144) - Sequencial, binária, árvores, hashing
5. **Pesquisa em Memória Secundária** (p. 155-193) - Arquivos, árvores B

---

## Capítulo 1: Introdução

### 1.1 Algoritmos, Estruturas de Dados e Programas

**Definição de algoritmo** (Dijkstra, 1971):
> Uma seqüência de ações executáveis para a obtenção de uma solução para um determinado tipo de problema.

**Relação entre algoritmos e programas**:
- Programas = formulações concretas de algoritmos abstratos
- Linguagem de programação = técnica de notação para expressar raciocínio algorítmico

### 1.2 Tipos de Dados e Tipos Abstratos de Dados (TAD)

**Tipos simples**: `integer`, `boolean`, `char`, `real` (Pascal)

**Tipos estruturados**: Coleções de valores simples ou agregados de tipos diferentes

**Tipo Abstrato de Dados (TAD)**:
- Modelo temático com operações definidas
- Exemplo: Conjunto dos inteiros com operações de adição, subtração, multiplicação

### 1.3 Medida do Tempo de Execução

#### 1.3.1 Comportamento Assintótico de Funções

A análise de algoritmos estuda o **comportamento para valores grandes de n** (tamanho da entrada).

#### 1.3.2 Classes de Comportamento Assintótico

| Complexidade | Nome | Quando ocorre |
|--------------|------|---------------|
| O(1) | Constante | Operações de atribuição, leitura, escrita |
| O(log n) | Logarítmica | Divisão em problemas menores |
| O(n) | Linear | Pequeno trabalho sobre cada elemento |
| O(n log n) | Linearitária | Quebrar em problemas menores, resolver, unir |
| O(n²) | Quadrática | Itens processados aos pares |
| O(n³) | Cúbica | Apenas para problemas pequenos |
| O(2ⁿ) | Exponencial | Força bruta |

#### 1.4 Técnicas de Análise de Algoritmos

**Regras fundamentais**:
1. Atribuição, leitura, escrita = O(1)
2. Sequência de comandos = tempo do comando mais lento
3. Decisão = tempo do comando + avaliação da condição
4. Anel = (tempo do corpo × iterações) + avaliação da condição

---

## Capítulo 2: Estruturas de Dados Básicas

### 2.1 Listas Lineares

**Operações para um TAD Lista**:
1. Criar uma lista vazia
2. Inserir um novo item após o i-ésimo item
3. Retirar o i-ésimo item
4. Localizar o i-ésimo item
5. Combinar duas ou mais listas

**Implementações**:
- **Arranjos**: Economia de memória, custo para inserção/remover no meio
- **Apontadores**: Inserção/remoção O(1) em posições conhecidas, uso de memória extra

### 2.2 Pilhas

**Propriedade LIFO** (Last-In, First-Out):
- Último inserido é o primeiro a sair
- Aplicações: chamadas de função, estruturas aninhas, editor de texto (cancela-caractere)

**Operações do TAD Pilha**:
1. FPVazia(Pilha) - Faz a pilha vazia
2. Vazia(Pilha) - Retorna true se vazia
3. Empilha(x, Pilha) - Insere x no topo
4. Desempilha(Pilha, x) - Retorna e remove o item do topo
5. Tamanho(Pilha) - Número de itens

### 2.3 Filas

**Propriedade FIFO** (First-In, First-Out):
- Primeiro inserido é o primeiro a sair
- Aplicações: processamento por lotes, filas de impressão

---

## Capítulo 3: Ordenação

### 3.1 Ordenação Interna

#### 3.1.1 Seleção Direta

```pascal
{ Seleciona o menor elemento e troca com o primeiro }
for i := 1 to n-1 do
  min := i;
  for j := i+1 to n do
    if A[j] < A[min] then min := j;
  swap(A[i], A[min]);
```

**Complexidade**: O(n²) - sempre faz n-1 + n-2 + ... + 1 = n(n-1)/2 comparações

#### 3.1.2 Inserção Direta

```pascal
{ Constrói a lista ordenada à medida que avança }
for i := 2 to n do
  j := i;
  while j > 1 and A[j] < A[j-1] do
    swap(A[j], A[j-1]);
    j := j-1;
```

**Complexidade**: O(n) no melhor caso (já ordenada), O(n²) no pior caso

#### 3.1.4 Quicksort

```pascal
procedure Quicksort(A, low, high);
if low < high then
  p := Particao(A, low, high);
  Quicksort(A, low, p-1);
  Quicksort(A, p+1, high);
```

**Complexidade média**: O(n log n)  
**Pior caso**: O(n²) - evitar com pivô aleatório

#### 3.1.5 Heapsort

```pascal
procedure Heapsort(A, n);
BuildHeap(A, n);
for i := n downto 2 do
  swap(A[1], A[i]);
  Heapify(A, 1, i-1);
```

**Complexidade**: O(n log n) sempre

### 3.2 Ordenação Externa

**Intercalação Balanceada**:
- Divide o arquivo em blocos ordenados
- Intercala múltiplos arquivos simultaneamente
- Uso eficiente de memória secundária

---

## Capítulo 4: Pesquisa em Memória Primária

### 4.1 Pesquisa Sequencial

**Complexidade**: O(n)
**Vantagem**: Simples, funciona em qualquer estrutura
**Desvantagem**: Lento para grandes conjuntos

### 4.2 Pesquisa Binária

```pascal
function BuscaBinaria(A, n, x):
  low := 1; high := n;
  while low <= high do
    mid := (low + high) div 2;
    if x = A[mid] then return mid;
    if x < A[mid] then high := mid - 1;
    else low := mid + 1;
  return -1;
```

**Complexidade**: O(log n) - requer array ordenado

### 4.3 Árvores de Pesquisa

**Árvore Binária de Pesquisa (ABP)**:
- Filhos esquerdos < nó < filhos direitos
- Percurso em-ordem produz ordem crescente

### 4.5 Transformação de Chave (Hashing)

**Funções de Transformação**:
- `h(k) = k mod m`
- Tratamento de colisões: encadeamento ou open addressing

---

## Capítulo 5: Pesquisa em Memória Secundária

### 5.3 Árvores B

**Estrutura de página**:
- Cada página contém m chaves e m+1 ponteiros
- Todas as folhas estão no mesmo nível
- Altura: O(logₘ n)

**Operações**:
- Busca: O(logₘ n) acessos a disco
- Inserção: pode dividir página cheia
- Remoção: pode contraír página com poucos elementos

---

## Integração com Clean Code

### Princípio 1: Nomes Claros e Expressivos

```python
# RUIM - seguindo o estilo do livro original
def ordenacao_selecao(A, n):
    for i in range(n-1):
        min_idx = i
        for j in range(i+1, n):
            if A[j] < A[min_idx]:
                min_idx = j
        A[i], A[min_idx] = A[min_idx], A[i]

# BOM - Clean Code + Português do Brasil
def ordenar_por_selecao(vetor: list[int]) -> None:
    """Ordena o vetor usando o algoritmo de seleção direta (O(n²))."""
    tamanho = len(vetor)
    for i in range(tamanho - 1):
        indice_minimo = encontrar_indice_minimo(vetor, i, tamanho)
        trocar_posicoes(vetor, i, indice_minimo)

def encontrar_indice_minimo(vetor: list[int], inicio: int, fim: int) -> int:
    """Encontra o índice do menor elemento no intervalo [inicio, fim)."""
    indice_minimo = inicio
    for i in range(inicio + 1, fim):
        if vetor[i] < vetor[indice_minimo]:
            indice_minimo = i
    return indice_minimo

def trocar_posicoes(vetor: list[int], pos1: int, pos2: int) -> None:
    """Troca os elementos nas posições pos1 e pos2."""
    vetor[pos1], vetor[pos2] = vetor[pos2], vetor[pos1]
```

### Princípio 2: Funções Pequenas e Focadas

Seguindo o **Clean Coder Kryonix**:
> "Função faz UMA coisa — se precisa de `e` pra descrever, ela faz mais."

### Princípio 3: Tratamento de Erros Separável

```python
def buscar_em_arvore(arvore: NoArvore, chave: int) -> Optional[NoArvore]:
    """Busca uma chave em uma árvore binária de busca."""
    try:
        if arvore is None:
            raise ValueError("Árvore vazia")
        return _buscar_recursivo(arvore, chave)
    except ValueError as e:
        logger.error(f"Erro na busca: {e}")
        return None

def _buscar_recursivo(no: NoArvore, chave: int) -> Optional[NoArvore]:
    """Busca recursiva com tratamento de erros separado."""
    if no is None or no.chave == chave:
        return no
    if chave < no.chave:
        return _buscar_recursivo(no.esquerda, chave)
    return _buscar_recursivo(no.direita, chave)
```

### Princípio 4: Testes como Especificação

```python
def test_ordenacao_por_insercao_basico():
    """Testa ordenação por inserção com lista aleatória."""
    from random import sample
    entrada = sample(range(100), 20)
    esperado = sorted(entrada)
    assert ordenar_por_insercao(entrada.copy()) == esperado

def test_ordenacao_por_insercao_ja_ordenada():
    """Testa lista já ordenada (melhor caso)."""
    entrada = list(range(20))
    assert ordenar_por_insercao(entrada.copy()) == entrada

def test_ordenacao_por_insercao_reversa():
    """Testa lista em ordem reversa (pior caso)."""
    entrada = list(range(20, 0, -1))
    esperado = list(range(1, 21))
    assert ordenar_por_insercao(entrada.copy()) == esperado

def test_ordenacao_por_insercao_vazia():
    """Testa lista vazia."""
    assert ordenar_por_insercao([]) == []

def test_ordenacao_por_insercao_unico_elemento():
    """Testa lista com um único elemento."""
    assert ordenar_por_insercao([42]) == [42]
```

### Princípio 5: Refatoração Contínua (Boy Scout Rule)

**Exemplo de refatoração**:

```python
# Antes - misto e difícil de ler
def processar_lista(L):
    i = 0
    while i < len(L):
        if L[i] < 0:
            L.pop(i)
        else:
            i += 1
    return L

# Depois - Clean Code
def remover_elementos_negativos(lista: list[int]) -> list[int]:
    """Remove todos os elementos negativos da lista."""
    indice = 0
    while indice < len(lista):
        if _eh_negativo(lista[indice]):
            lista.pop(indice)
        else:
            indice += 1
    return lista

def _eh_negativo(valor: int) -> bool:
    """Verifica se o valor é negativo."""
    return valor < 0
```

---

## Checklist de Qualidade para Algoritmos

```txt
[ ] A notação Big O foi calculada corretamente?
[ ] Os nomes seguem convenção PT-BR (snake_case)?
[ ] Cada função tem um único propósito?
[ ] O tratamento de erro está separado da lógica?
[ ] Testes cobrem happy path + edge cases?
[ ] Não há duplicação de código?
[ ] O código é legível em 5 minutos?
[ ] A documentação explica o "porquê", não só o "como"?
[ ] Complexidade assintótica foi considerada?
[ ] Estruturas de dados apropriadas foram usadas?
```

---

## Relações com o Clean Coder Kryonix

```
Projeto de Algoritmos -> complementa -> Clean Code
Projeto de Algoritmos -> reforça -> AGENTS.md
Projeto de Algoritmos -> aplica-se a -> testes automatizados
Projeto de Algoritmos -> reforça -> menor mudança correta
Projeto de Algoritmos -> aplica-se a -> refatoração segura
Projeto de Algoritmos -> aplica-se a -> análise de complexidade
```

---

## Quando Usar

- **Projetar** novos algoritmos no Kryonix
- **Code review** de algoritmos
- **Otimizar** performance de código existente
- **Análise** de complexidade em sistemas NixOS
- **Estudo** de estruturas de dados para o Brain

---

## Arquivos Referenciados

- Texto completo extraído: `/tmp/algoritmos_ziviani_extracted.txt`
- PDF original: `/home/rocha/Proyectos/Rocha-Vault/04-Recursos/Livros/Projeto de Algoritmos - Nivio Ziviani.pdf`

---

## Próximos Passos

1. ✅ Extrair conteúdo do PDF
2. ✅ Criar resumo estruturado
3. ✅ Integrar com Clean Code
4. ⏳ Criar exemplos práticos no contexto do Kryonix
5. ⏳ Adicionar ao MOC de Engenharia de Software

---

## Links Relacionados

- [[02-Areas/Engenharia de Software/Arquitetura Limpa]]
- [[02-Areas/Engenharia de Software/Testes Automatizados.md]]
- [[04-Recursos/principios/clean-coder-kryonix-profissionalismo.md]]
- [[04-Recursos/skills/livros/clean-code-professionalism/SKILL.md]]
- [[01-MOCs/Mapa - Engenharia de Software]]