---
title: Kryonix Capability Registry
type: contract
status: active
project: kryonix
component: kryxd
created: 2026-07-27
updated: 2026-07-27
version: "1.0.0"
source_of_truth: RAGton/kryxd:schemas/capabilities.json
confidence: verified
tags:
  - kryonix
  - kryxd
  - capabilities
  - contract
  - api
  - kve
  - incus
---

# Kryonix Capability Registry

## Objetivo

Definir como o ecossistema Kryonix representa, valida e distribui capabilities entre o Installer, o `kryxd`, a API v2 e a UI capability-driven.

## Resumo

**Fato verificado:** o registry canônico atual possui **43 capabilities**.

A mudança de 42 para 43 ocorreu de forma deliberada com a adição de:

```text
virtualization.incus
```

no commit `c544d415f9c11f4039343b09f02b4211a68e5cb9` do repositório `RAGton/kryxd`.

O problema observado posteriormente não era uma capability extra acidental. Dois consumidores permaneceram esperando 42:

```text
crates/kryx/src/domain/capabilities.rs
scripts/generate-ui-contracts.mjs
```

Portanto, o incidente é classificado como **drift de propagação de contrato**, não como corrupção do registry.

## Fonte de verdade

A única fonte de dados deve ser:

```text
RAGton/kryxd/schemas/capabilities.json
```

Fluxo:

```text
schemas/capabilities.json
        │
        ├── crates/kryx: tipagem e validação server-side
        ├── /api/v2/capabilities: projeção pública e enrichment runtime
        └── scripts/generate-ui-contracts.mjs: projeção para a UI
```

O JSON declara:

```text
wireContract = InstallPlanV2.features
registryVersion = 1
schemaVersion = 1
```

## A 43ª capability

```text
id: virtualization.incus
wireKey: incus
domain: virtualization
level: system
requires: storage.srv-data
conflicts: virtualization.libvirt
status declarativo: ready
```

### Significado

- representa o KVE baseado em Incus;
- permite que a UI capability-driven reconheça hosts com virtualização Incus;
- impede seleção conjunta com `virtualization.libvirt`;
- exige a fundação de storage `storage.srv-data`;
- não significa, sozinha, que o daemon esteja ativo.

O endpoint do `kryxd` enriquece o status de `virtualization.incus` em runtime:

```text
ready   = socket Incus existe e incus.service está ativa
stub    = socket e serviço estão ausentes
partial = apenas uma das duas evidências está presente
```

## Regra arquitetural

A quantidade total não deve ser tratada como a principal invariante.

Contagens são úteis para auditoria e versionamento, mas o contrato deve priorizar:

- IDs únicos;
- referências existentes;
- ausência de ciclos;
- dependências satisfeitas;
- conflitos bloqueados;
- `unsupported` com `blockReason`;
- ausência de secrets;
- presença das capabilities estruturais obrigatórias;
- mesma fonte para Rust, API e UI.

## Capabilities estruturais obrigatórias

```text
storage.srv-data
storage.topology.manual
storage.topology.raid
storage.encryption.luks2
virtualization.incus
virtualization.libvirt
```

A presença de uma capability não implica implementação completa. O campo `status` deve continuar distinguindo:

```text
ready
partial
stub
legacy
unsupported
```

## Política de evolução

Ao adicionar ou remover uma capability:

1. alterar o JSON canônico;
2. registrar o motivo e o status;
3. validar dependências e conflitos;
4. atualizar testes semânticos;
5. regenerar a UI;
6. validar `/api/v2/capabilities`;
7. atualizar documentação e Vault;
8. evitar números mágicos duplicados em consumidores.

## Diagnóstico do drift 42 × 43

| Componente | Estado |
|---|---|
| `schemas/capabilities.json` | correto, 43 capabilities |
| `src/api/capabilities.rs` | correto, espera 43 e verifica `virtualization.incus` |
| `crates/kryx/src/domain/capabilities.rs` | desatualizado, teste espera 42 |
| `scripts/generate-ui-contracts.mjs` | desatualizado, generator rejeita quantidade diferente de 42 |
| UI gerada | deriva do JSON, mas regeneration fica bloqueada pelo guard antigo |

## Riscos

- remover `virtualization.incus` apenas para obter testes verdes quebraria o contrato capability-driven;
- atualizar somente `42` para `43` manteria o mesmo problema para a próxima capability;
- documentar `ready` como garantia operacional confundiria estado declarativo com estado runtime;
- duplicar o registry em `kryx-cli`, UI ou documentação criaria novas fontes concorrentes.

## Validação recomendada

```bash
python3 - <<'PY'
import json
from collections import Counter
from pathlib import Path

items = json.loads(Path("schemas/capabilities.json").read_text())["capabilities"]
ids = [item["id"] for item in items]
duplicates = [identifier for identifier, count in Counter(ids).items() if count > 1]

assert len(items) == 43
assert not duplicates
assert "virtualization.incus" in ids
print("capability registry: PASS")
PY
```

## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]
- [[09-Logs/Kryonix/2026-07-25-kcp-foundation-phase-1]]
- [[09-Logs/Kryonix/2026-07-27-capability-registry-drift-42-43]]
- [[09-Logs/Kryonix/2026-07-16-kve-architecture-reference]]
- [[02-Areas/Kryonix/architecture/Installer]]

## Próxima ação

Corrigir os dois consumidores desatualizados sem modificar `schemas/capabilities.json`, substituindo a dependência em número mágico por validações semânticas e mantendo a contagem 43 apenas como evidência versionada.
