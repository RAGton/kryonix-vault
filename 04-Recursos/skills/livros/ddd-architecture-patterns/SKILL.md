---
title: ddd-architecture-patterns
type: skill
status: ativo_revisao_pendente
purpose: Aplicar Domain-Driven Design, arquitetura limpa, padrões de projeto e refatoração para modelar sistemas complexos no Kryonix
validade: revisao_humana_pendente
tipo: skill
projeto: kryonix
componente: arquitetura-software
fonte_verdade: livro (DDD Reference Evans + Clean Architecture Martin + GoF + Refatoração Fowler + DSL + SOA + Legacy Feathers)
confianca: media
rag: baixo_peso
graph: true
validado_em: 2026-06-20
operation_mode: inspiron-local-hermes-openrouter
author: aura
source_book: "DDD Referência (Evans), Clean Architecture (Martin), Padrões de Projetos (Gamma et al), Refactoring (Fowler), DSL (Fowler), Working Effectively with Legacy Code (Feathers), SOA Aplicado"
source_path: 04-Recursos/livros/
tags: [kryonix, skill, ddd, arquitetura, patterns, refatoracao, books]
---

# ddd-architecture-patterns

## Objetivo

Aplicar os princípios de **Domain-Driven Design** (Evans), **Clean Architecture** (Martin), **padrões de projeto** (GoF), **refatoração** (Fowler), **DSL** (Fowler) e **integração de sistemas legados** (Feathers) para modelar e evoluir sistemas complexos do Kryonix.

## Resumo

Consolida 7 obras de arquitetura. DDD dá o vocabulário estratégico (bounded context, ubiquitous language); Clean Architecture dá a estrutura de camadas; GoF dá o léxico de padrões táticos; Fowler de refatoração dá as técnicas de transformação; DSL dá a ponte domínio↔código; Feathers dá a estratégia para sistemas que não nasceram testáveis.

> **⚠️ Amostragem parcial** — Esta skill é derivada de amostragem limitada (apenas 15 páginas por livro + metadados via `pdfinfo`) e consolidação de múltiplas fontes. **NÃO é verdade operacional do Kryonix.** Requer validação prática em uso real antes de ser promovida para confiança alta. Use como checklist orientativo; para decisão crítica, consulte o livro original.

## Quando usar

- Ao desenhar novo módulo/subsistema do Kryonix.
- Ao integrar 2 ou mais domínios (Brain, CLI, installer).
- Ao decidir fronteiras entre serviços (micro vs monólito).
- Ao refatorar código legado do próprio projeto.
- Ao criar DSL interna (ex: linguagem de configuração de features).

## Quando não usar

- Não serve para implementação concreta de funções/código — usar `clean-code-professionalism`.
- Não serve para revisão de flakes NixOS — usar `revisao-nixos-flake`.

## Princípios-chave consolidados

### DDD — Evans (Ref + Rapido)

1. **Model é o coração** — código espelha modelo de domínio.
2. **Ubiquitous language** — termos usados por devs E negócio SEM tradução.
3. **Bounded context** — fronteira semântica clara entre modelos.
4. **Context map** — desenha relações entre contextos (Partnership, Customer-Supplier, Conformist, Anti-Corruption Layer, Published Language, Separate Ways, Open Host Service).
5. **Core domain** — o diferencial competitivo. Invista aqui.
6. **Supporting / Generic subdomains** — o resto. Não superengenhe.
##### Blocos de construção táticos: Entity, Value Object, Aggregate, Repository, Service, Domain Event, Module, Factory.

### Clean Architecture — Martin

1. **Concentric layers** com independência de framework.
2. **Dependency rule** — dependências só apontam pra dentro (domain no centro).
3. **4 camadas**: Entities (regra de negócio empresarial) → Use Cases (regra de aplicação) → Interface Adapters (controllers/presenters) → Frameworks/Drivers (UI/DB/web).
4. **The Screaming Architecture** — a estrutura do projeto deve gritar o domínio, não o framework.
5. **Plugin architecture** — cada camada é substituível (DB, UI, web).

### GoF (Padrões de Projeto)

Categorização essencial:
- **Criacionais**: Factory Method, Abstract Factory, Builder, Singleton, Prototype
- **Estruturais**: Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy
- **Comportamentais**: Chain of Responsibility, Command, Iterator, Mediator, Memento, Observer, State, Strategy, Template Method, Visitor

**Preferência moderna**: composição > herança; injeção de dependência > singleton.

### Refatoração — Fowler

1. **Dup code** → Extract Method/Class.
2. **Long method** → Extract Method, Replace Temp with Query.
3. **Large class** → Extract Class, Extract Subclass.
4. **Long parameter list** → Parameter Object, Preserve Whole Object.
5. **Divergent/Shotgun surgery** → Move Method, Inline Class.
6. **Feature envy** → Move Method.
7. **Primitive obsession** → Replace Type Code with Class.
8. **Switch statements** → Replace with Polymorphism, Strategy.
9. **Temporary field** → Extract Class.

**Regra geral**: refatorar em passos pequenos, com testes rodando entre cada passo.

### DSL — Fowler

1. **Internal (embedded)**: usa a linguagem hospedeira (Rust builder pattern, fluent API).
2. **External (standalone)**: define gramática própria (parser, ANTLR, nom em Rust).
3. **Semantic model** — representa a DSL internamente.
4. **Trade-off**: DSL externa é mais expressiva mas tem custo de manutenção do parser.

### Integração com Legado — Feathers

1. **Não reescreva do zero** — é quase sempre furada.
2. **Characterization tests** — teste que captura comportamento atual.
3. **Seam (costura)** — ponto onde você pode mudar comportamento sem tocar no código.
4. **Break dependencies** gradualmente.
5. **Strangler pattern** — substituir funcionalidade aos poucos.

## Procedimento — projetar módulo novo

```txt
1. MAPEAR o domínio:
   - Quem são os atores? (usuários, sistemas)
   - O que fazem? (casos de uso)
   - Que linguagem usam? (ubiquitous)

2. DELIMITAR bounded contexts:
   - Quais contextos existem?
   - Cada contexto tem seu próprio modelo.
   - Desenhar o context map entre eles.

3. MODELAR cada contexto (DDD tático):
   - Entities (com identidade)
   - Value Objects (sem identidade, imutáveis)
   - Aggregates (raiz + consistência transacional)
   - Repositories (persistência)
   - Domain Services (lógica entre entidades)
   - Domain Events (comunicação entre aggregates)

4. ORGANIZAR em camadas (Clean Architecture):
   - Domain (entities, VOs) — sem deps externas
   - Application (use cases) — depende só do domain
   - Infrastructure (DB, APIs) — pluggable
   - Presentation (CLI, web) — pluggable

5. APLICAR padrões (GoF + refatoração) quando fizer sentido:
   - Strategy pra variações de comportamento
   - Observer pra eventos
   - Factory pra criação complexa
   - Facade pra API simplificada

6. TESTAR cada camada:
   - Domain: unit tests (sem mocks)
   - Application: unit tests com mock de infra
   - Integration: contratos entre camadas
   - E2E: cenários de negócio
```

## Checklist — revisão de arquitetura

```txt
- [ ] Domain model reflete linguagem do negócio?
- [ ] Bounded contexts delimitados?
- [ ] Context map explícito entre contextos?
- [ ] Dependency rule respeitada (dependências apontam pra dentro)?
- [ ] Domain não conhece frameworks (DB, web)?
- [ ] Entities com identidade clara, VOs imutáveis?
- [ ] Aggregates com raiz e invariantes?
- [ ] Sem God objects (> 300 linhas ou 10+ métodos)
- [ ] Sem Feature Envy (método usa mais dados de outro objeto)?
- [ ] Sem Primitive Obsession (IDs, emails, valores monetários tipados)?
- [ ] Testes unitários sem mocks na camada de domínio?
```

## Aplicação no Kryonix

```txt
Cenário: instalar perfil "glacier-ai" via installer
- Bounded contexts: Installer, Configuration, Host Profile, Feature Flags
- Domain Entities: Profile, Host, Feature, Selection
- Use cases: DetectHardware, SelectProfile, GenerateConfig, ValidateConfig, ApplyConfig
- Infrastructure: NixOS backend, disk partitioner, package fetcher
- Presentation: TUI / CLI
```

## Riscos

- DDD dogmático: bounded contexts demais em projeto simples.
- GoF obcecado: forçar padrão onde função simples resolve.
- Refatorar sem teste: pedir pra quebrar em produção.
- Clean Architecture em CRUD: overengineering para API simples.
- DDD em time solo: exige alinhamento de linguagens (necessita alguém pra conversar).

## Token-saving mechanism

Consolida 7 livros (~3000 páginas) em 6 blocos de princípios + 2 procedimentos + 1 checklist. Uso: ao modelar módulo novo, consulta rápido antes de mergulhar.

## Base prompt

```txt
Atue como arquiteto de software sênior especialista em DDD.
Dado o problema de modelagem abaixo, aplique a skill [[04-Recursos/skills/livros/ddd-architecture-patterns/SKILL]].
Produza: (1) análise de domínio, (2) bounded contexts, (3) context map,
(4) model tático, (5) organização em camadas, (6) padrões aplicáveis,
(7) estratégia de teste.
```

## Livros-fonte

```txt
04-Recursos/livros/Domain-Driven Design Referência - Sumário de Padrões e Definições - Autor (Eric Evans).pdf
04-Recursos/livros/Domain Driven Design Rapido - Autor ( Eric Evans).pdf
04-Recursos/livros/Arquitetura Limpa - O Guia do Artesão para Estrutura e Design de Software - Autor (Robert C. Martin).pdf
04-Recursos/livros/Padrões de Projetos - Soluções Reutilizáveis de Software Orientados a Objetos - Autor (Erich Gamma).pdf
04-Recursos/livros/Refatoração - Aperfeiçoando o Design de Códigos Existentes - Autor (Martin Fowler).pdf
04-Recursos/livros/DSL - Quebre a barreira entre desenvolvimento e negócios - Autor (Casa do Código).pdf
04-Recursos/livros/SOA Aplicado - Integrando com web services e além - Autor (Casa do Código).pdf
04-Recursos/livros/Trabalho Eficaz com Código Legado - Autor (Michael C. Feathers).pdf
04-Recursos/livros/Desconstruindo a Web - As Tecnologias por Trás de uma Requisição - Autor (Casa do Código).pdf
04-Recursos/livros/Introdução à arquitetura de design de software - Autor (Paulo Silveira).pdf
```

## Links relacionados

- [[04-Recursos/skills/livros/clean-code-professionalism/SKILL]]
- [[04-Recursos/skills/livros/test-driven-development/SKILL]]
- [[04-Recursos/skills/revisao-nixos-flake/SKILL]]
- [[01-MOCs/Mapa - Biblioteca]]
- [[01-MOCs/Mapa - Engenharia de Software]]
