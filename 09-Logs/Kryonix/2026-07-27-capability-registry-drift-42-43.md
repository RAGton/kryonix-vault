---
title: Capability Registry — Auditoria do drift 42 × 43
type: log
status: validated
project: kryonix
component: kryxd
date: 2026-07-27
confidence: verified
tags:
  - kryonix
  - kryxd
  - capabilities
  - drift
  - audit
  - kve
---

# Capability Registry — Auditoria do drift 42 × 43

## Objetivo

Determinar se o total de 43 capabilities representa crescimento legítimo do contrato ou alteração incorreta do registry.

## Veredito

```text
AUMENTO LEGÍTIMO DO REGISTRY
```

A capability adicional é `virtualization.incus`, registrada deliberadamente no commit:

```text
c544d415f9c11f4039343b09f02b4211a68e5cb9
feat(capabilities): register virtualization.incus capability (v0.2.0) — V58b P1
```

O registry não deve ser revertido para 42.

## Evidências

### Registry canônico

Arquivo:

```text
RAGton/kryxd/schemas/capabilities.json
```

Estado confirmado:

```text
capabilities: 43
IDs duplicados: nenhum identificado pela validação Rust
wireContract: InstallPlanV2.features
```

### Capability adicionada

```text
id: virtualization.incus
wireKey: incus
domain: virtualization
requires: storage.srv-data
conflicts: virtualization.libvirt
status: ready
```

### Consumidor runtime

`RAGton/kryxd/src/api/capabilities.rs`:

- espera 43 capabilities;
- exige presença de `virtualization.incus`;
- verifica domínio `Virtualization`;
- enriquece status conforme socket Unix e `incus.service`;
- mantém resposta sem secrets.

### Consumidores desatualizados

```text
RAGton/kryxd/crates/kryx/src/domain/capabilities.rs
RAGton/kryxd/scripts/generate-ui-contracts.mjs
```

Ambos permaneceram com o valor 42.

## Causa raiz

A mudança de contrato foi aplicada parcialmente:

```text
registry JSON                   atualizado
endpoint de capabilities       atualizado
teste do endpoint              atualizado
teste do domínio Rust          não atualizado
guard do codegen da UI         não atualizado
```

Classificação:

```text
contract propagation drift
```

Não é:

```text
registry corrompido
capability duplicada
capability inventada sem contexto
```

## Decisão

- manter `virtualization.incus`;
- manter o total versionado atual em 43;
- não alterar o JSON para satisfazer testes antigos;
- corrigir validações antigas;
- priorizar invariantes semânticas sobre contagem mágica;
- documentar separadamente status declarativo e status runtime.

## Correção mínima recomendada

### Rust

Substituir a dependência exclusiva em:

```rust
assert_eq!(registry.capabilities.len(), 42);
```

por validações de:

- versões;
- unicidade;
- `wireContract`;
- presença de capabilities estruturais;
- dependências, conflitos e ciclos;
- `unsupported` com `blockReason`.

A contagem 43 pode permanecer como evidência versionada, mas não deve ser a única garantia.

### Codegen

Remover o bloqueio que exige exatamente 42 e validar:

- array não vazio;
- IDs únicos;
- presença de `virtualization.incus`;
- versões reconhecidas;
- contrato wire correto.

## Estado dos gates

| Gate | Estado |
|---|---|
| Registry JSON | PASS |
| Endpoint `/api/v2/capabilities` | alinhado com 43 |
| Teste do domínio `kryx` | BLOCKED por assert 42 |
| Codegen UI | BLOCKED por guard 42 |
| Documentação técnica | criada em `kryxd/docs/CAPABILITY_REGISTRY.md` |
| Vault canônico | criado em [[02-Areas/Kryonix/canonical/Kryonix Capability Registry]] |

## Riscos evitados

- remoção indevida de capability válida;
- falsa correção trocando apenas um número;
- quebra da UI capability-driven;
- confusão entre presença declarativa e daemon Incus ativo;
- novas listas manuais concorrentes.

## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]
- [[02-Areas/Kryonix/canonical/Kryonix Capability Registry]]
- [[09-Logs/Kryonix/2026-07-25-kcp-foundation-phase-1]]
- [[09-Logs/Kryonix/2026-07-16-kve-architecture-reference]]

## Próxima ação

Abrir correção pequena no `kryxd`, sem alterar o registry:

```text
crates/kryx/src/domain/capabilities.rs
scripts/generate-ui-contracts.mjs
```

Validar depois:

```text
cargo test -p kryx canonical_registry_has_expected_shape
npm run generate:contracts
npm run check:generated
```
