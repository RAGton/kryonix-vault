---
type: validation-log
project: Kryonix
component: kryxd
status: validated
created: 2026-07-27
updated: 2026-07-27
tags: [kryonix, kryxd, kcp, capabilities, testing, kve, think]
links:
  - "[[MOC - Installer]]"
  - "[[Testing]]"
  - "[[Validation Matrix]]"
---

# Gate 1 — testes V2 e drift do capability registry

## Objetivo

Registrar o fechamento do Gate 1 das rotas stub KVE/Think e separar esse resultado do drift preexistente de contagem do capability registry.

## Resultado do Gate 1

Branch:

```text
test/reactivate-v2-stub-routes
```

Commit:

```text
949e015b9abd1f538214e1c5ceddc59a54c8479d
test(api): reactivate KVE and Think v2 stub routes
```

Arquivos alterados:

```text
src/api/v2/kve.rs
src/api/v2/think.rs
```

Diff informado:

```text
2 files changed
158 insertions
26 deletions
```

Validação em target limpo:

```bash
CARGO_TARGET_DIR=/tmp/kryxd-gate1-target \
  nix develop -c \
  cargo test -p kryxd api::v2 --locked -- --nocapture
```

Resultado:

```text
10 passed
0 failed
0 ignored
120 filtered out
```

## Cobertura comprovada

- quatro handlers stub testados diretamente;
- quatro rotas HTTP corretas retornam `200`;
- respostas continuam contendo `status: "stub"`;
- listas stub continuam vazias;
- duas rotas com prefixo duplicado retornam `404`;
- nenhum provider Incus ou ZFS real foi introduzido;
- nenhum `AppState::default_for_tests()` artificial foi criado.

## Capability registry

Fonte canônica:

```text
kryxd/schemas/capabilities.json
```

Consumidor Rust:

```text
kryxd/crates/kryx/src/domain/capabilities.rs
```

O módulo Rust declara explicitamente que o JSON é a única fonte de dados e o incorpora por `include_str!`.

O registry atual contém 43 capabilities. O teste `canonical_registry_has_expected_shape` ainda espera 42.

Capability associada à expansão:

```text
virtualization.incus
```

Metadados atuais:

```text
wireKey: incus
level: system
domain: virtualization
name: KVE — Kryonix Virtualization Engine (Incus)
status: ready
requires: storage.srv-data
conflicts: virtualization.libvirt
```

## Diagnóstico

O drift `42 × 43` não foi causado pelo Gate 1:

```text
Gate 1 alterou: kve.rs + think.rs
Registry canônico: não alterado no Gate 1
Teste de contagem: ainda fixo em 42
```

Veredito:

```text
expansão do catálogo para 43: coerente com virtualization.incus
teste numérico: desatualizado
remoção da capability: não recomendada
```

## Nuance de maturidade

A capability `virtualization.incus` está marcada como `ready` no catálogo, mas as rotas KVE verificadas neste gate ainda são stubs.

Isso não deve ser documentado como KVE completo. Existem camadas diferentes:

```text
registro da capability              presente
configuração NixOS/Incus            evidência separada
provider kryxd Incus real            pendente
rotas KVE com dados reais            pendente
experiência completa no KCP          pendente
```

O status do catálogo precisa ser revisado futuramente para esclarecer se `ready` significa "feature NixOS disponível" ou "fluxo KCP completo disponível".

## Gate 1.5 recomendado

Escopo exclusivo:

1. atualizar a contagem deliberada para 43;
2. manter o teste de IDs únicos;
3. adicionar teste explícito para `virtualization.incus`;
4. validar `requires = storage.srv-data`;
5. validar `conflicts = virtualization.libvirt`;
6. executar os testes completos do crate `kryx`.

Não misturar nesse gate:

- provider Incus real;
- UI KCP;
- comandos `kryx vm`/`kryx ct`;
- documentação ampla;
- alterações em hosts.

## Segurança

- nenhum secret foi necessário para o Gate 1;
- nenhum host foi alterado;
- nenhuma porta foi aberta;
- `/etc/kryonix` e `/etc/kryonixos` permaneceram fora do escopo;
- endpoints continuam explicitamente marcados como stub.

## Próxima ação

Executar o Gate 1.5 em branch nova criada diretamente de `origin/main`.

## Links relacionados

- [[Testing]]
- [[Validation Matrix]]
- [[MOC - Installer]]
