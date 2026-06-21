---
title: test-driven-development
type: skill
status: ativo_revisao_pendente
purpose: Aplicar TDD e práticas de testes automatizados baseadas em Kent Beck, Casa do Código e Agile Testing
validade: revisao_humana_pendente
tipo: skill
projeto: kryonix
componente: testes
fonte_verdade: livro (TDD Kent Beck, Testes Automatizados de Software, Teste e Design no Mundo Real, BDD in Action, More Agile Testing)
confianca: media
rag: baixo_peso
graph: true
validado_em: 2026-06-20
operation_mode: inspiron-local-hermes-openrouter
author: aura
source_book: "TDD (Kent Beck), Test-Driven Development - Teste e Design no Mundo Real (Casa do Código), Testes Automatizados de Software (Casa do Código), BDD in Action (Smart), More Agile Testing (Crispin)"
source_path: 04-Recursos/livros/
tags: [kryonix, skill, tdd, testes, bdd, books]
---

# test-driven-development

## Objetivo

Aplicar o ciclo **RED-GREEN-REFACTOR** do TDD e práticas complementares (BDD, testes de integração, testes de contrato) em código do Kryonix (Rust, Nix flake validation, CLI), baseado em 5 obras canônicas.

## Resumo

5 pilares: **Beck** (TDD clássico com 2 ciclos: test-first e design-first); **CdC Testes Automatizados** (prática brasileira com foco em unitários, integração e E2E); **CdC TDD no Mundo Real** (TDD aplicado fora da utopia); **Smart** (BDD com Gherkin/Cucumber); **Crispin** (Agile Testing quadrantes). A skill consolida em workflow operacional, não em manifesto filosófico.

> **⚠️ Amostragem parcial** — Esta skill é derivada de amostragem limitada (apenas 15 páginas por livro + metadados via `pdfinfo`) e consolidação de múltiplas fontes. **NÃO é verdade operacional do Kryonix.** Requer validação prática em uso real antes de ser promovida para confiança alta. Use como checklist orientativo; para decisão crítica, consulte o livro original.

## Quando usar

- Ao implementar nova feature (especialmente em Rust).
- Ao escrever teste para código existente que não tem.
- Ao validar comportamento do CLI `kryonix`.
- Ao escrever testes para módulos Nix (validar opções, imports).
- Em entrevista ou avaliação técnica.

## Quando não usar

- Não serve para validar comportamento de UI (usar E2E tools específicas).
- Não serve como único teste de segurança (usar skills de segurança).

## Princípios-chave consolidados

### Beck (TDD clássico)

1. **RED-GREEN-REFACTOR** — 3 fases estritas. Nunca pule pra refator sem teste passar.
2. **Baby steps** — mudança mínima por ciclo. Se testou muito, reduza o passo.
3. **Testa comportamento, não implementação** — nomes de funções mudam; comportamento fica.
4. **Dup code é sinal** — duplicação entre teste e código indica abstração faltando.
5. **Listas de teste** — mantenha uma lista de testes a escrever (externaliza memória).
6. **Test-first vs test-after** — test-first guia design; test-after documenta.

### CdC Testes Automatizados

1. **Pirâmide de Miller** — unitários (muitos) > integração (médios) > E2E (poucos).
2. **Teste rápido = teste executado** — >5s por teste você para de rodar.
3. **Isolamento** — mocks pra tudo externo (DB, rede, clock).
4. **Arrange-Act-Assert** — 3 fases explícitas em cada teste.
5. **Nomes são specs** — nome do teste = descrição do comportamento.

### CdC TDD no Mundo Real

1. **TDD pragmático** — nem tudo precisa test-first.
2. **Legacy code** — caracterização primeiro, depois TDD.
3. **Teste de integração** — nem unitário, nem E2E; o meio-termo.
4. **Dívida de teste** — como dívida técnica: paga com juros.

### Smart (BDD)

1. **Given-When-Then** — linguagem de negócio no teste.
2. **Living documentation** — specs que viram testes.
3. **Feature files** — compartilháveis entre dev, QA e PO.
4. **Examples Tables** — parametrização de cenários.

### Crispin (Agile Testing Quadrants)

1. **Q1 (tech-facing, support team)** — unit, component, functional.
2. **Q2 (business-facing, support team)** — stories, prototypes, spiked solutions.
3. **Q3 (business-facing, critique product)** — usability, UAT, exploratory.
4. **Q4 (tech-facing, critique product)** — performance, security, portability.

## Procedimento — ciclo TDD (Beck)

```txt
1. RED:    escrever teste que FALHA (comporta behavior novo ou broken).
2. Verificar que falha pela RAZÃO certa (não por syntax error).
3. GREEN:  escrever MENOR código que faz teste passar.
4. Refatorar SEM adicionar funcionalidade (tests verdes durante).
5. Repetir até feature completa.
6. Revisar: nomes fazem sentido? Cobertura suficiente? Sem duplicação?
```

## Procedimento — escrever teste legível (Arrange-Act-Assert)

```rust
#[test]
fn deve_calcular_desconto_de_10_pct_para_clientes_premium() {
    // Arrange
    let cliente = Cliente::new("Alice", Plano::Premium);
    let produto = Produto::new(100.0);
    
    // Act
    let preco_final = cliente.calcular_preco(&produto);
    
    // Assert
    assert_eq!(preco_final, 90.0);
}
```

## Checklist — qualidade de bateria de testes

```txt
- [ ] Testes rodam em <5s total (ou rodam em paralelo)?
- [ ] Nomes são frases em português (ou inglês do projeto)?
- [ ] 1 asserção por teste (ou 1 conceito)?
- [ ] Sem dependência entre testes (independentes)?
- [ ] Sem `sleep()` hardcoded?
- [ ] Mocks usados em camadas externas (DB, rede, clock)?
- [ ] Edge cases cobertos (vazio, None, negativo, overflow)?
- [ ] Pirâmide respeitada (muitos unitários, poucos E2E)?
- [ ] Cobertura > 70% em código crítico?
- [ ] Testes de integração têm fixture isolada?
```

## Aplicação no Kryonix

```txt
Exemplo: feature "detectar hardware e sugerir perfil"
- Unit: cada detector (CPU, GPU, RAM) com mock de /proc/cpuinfo
- Integration: detector + parser de sistema (sem hardware real)
- Contract: output do detector consome input do perfil selector
- E2E: `kryonix detect --format json` em máquina real
```

## Riscos

- TDD dogmático: gastar mais tempo em teste do que em feature.
- Mock everything: testes passam mas código real quebra.
- E2E demais: suite lenta, ninguém roda.
- Cobertura = qualidade? não. Teste ruim com cobertura alta engana.

## Token-saving mechanism

Consolida 5 livros (~1500 páginas) em 5 blocos de princípios + 2 procedimentos + 1 checklist. Uso: antes de escrever teste, consulta o workflow.

## Base prompt

```txt
Atue como engenheiro sênior especialista em testes.
Dado o código ou feature abaixo, aplique o workflow TDD da skill [[04-Recursos/skills/livros/test-driven-development/SKILL]].
Produza: (1) lista de testes a escrever, (2) primeiro teste (RED), (3) código mínimo (GREEN),
(4) refatoração (REFACTOR), (5) checklist de cobertura.
```

## Livros-fonte

```txt
04-Recursos/livros/TDD - Desenvolvimento Guiado por Testes - Autor (Ken Beck).pdf
04-Recursos/livros/Test-Driven Development - Teste e Design no Mundo Real - Autor (Casa do Código).pdf
04-Recursos/livros/Testes Automatizados de Software - Um Guia Prático - Autor (Casa do Código).pdf
04-Recursos/livros/BDD in Action - Behavior-Driven Development - Autor (John Ferguson Smart).pdf
04-Recursos/livros/More Agile Testing - Learning Journeys for the Whole Team - Autor (Lisa Crispin).pdf
```

## Links relacionados

- [[04-Recursos/skills/livros/clean-code-professionalism/SKILL]]
- [[04-Recursos/skills/livros/devops-ci-cd-practices/SKILL]]
- [[04-Recursos/skills/test-driven-development]] (skill operacional existente, se houver)
- [[01-MOCs/Mapa - Biblioteca]]
