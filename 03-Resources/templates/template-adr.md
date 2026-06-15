---
title: "ADR-XXXX - <Título da decisão>"
type: adr
status: proposed
tags: [adr, decisao]
severity: low | medium | high
created: 2026-06-14
updated: 2026-06-14
deciders: [<nome>]
supersedes: <nenhum ou ADR-YYYY>
superseded_by: <nenhum ou ADR-ZZZZ>
---

# ADR-XXXX — <Título>

<context>
  <situacao>Estado atual e por que precisa decidir agora.</situacao>
  <forcas>
    - força 1 (ex: time pequeno)
    - força 2 (ex: deadline regulatório)
    - força 3 (ex: stack existente em Nix)
  </forcas>
</context>

<task>
  Decidir entre as alternativas listadas abaixo e registrar a escolha,
  consequências e plano de reversão.
</task>

## Decisão

> Estado da decisão em uma sentença imperativa.
> Ex: "Vamos usar Postgres com partição por mês ao invés de Cassandra."

## Alternativas consideradas

```toon
alts[3]{opcao,prós,contras,custo_implementacao}:
A,solução simples e conhecida,limitação em escala 10x,baixo
B,solução robusta para escala,curva alta e ops complexo,alto
C,solução intermediária com trade-off X,vendor lock-in parcial,medio
```

## Consequências

### Positivas
- consequência boa 1
- consequência boa 2

### Negativas
- consequência ruim 1 (mitigação)
- consequência ruim 2 (mitigação)

<risks>
  - risco residual 1
  - risco residual 2
</risks>

## Plano de rollback

Como reverter sem perda de dados / sem downtime crítico.

1. parar processo X
2. restaurar dump Y
3. reativar pipeline Z

## Links relacionados

- [[../../10-MOCs/Mapa - Engenharia de Software]]
- [[../../01-Projects/<projeto-afetado>]]
- referência externa: <link>

<acceptance>
  - [ ] decisão comunicada a quem precisa saber
  - [ ] consequências negativas têm mitigação documentada
  - [ ] plano de rollback testado em dev
  - [ ] ADR registrado e linkado do MOC correspondente
</acceptance>
