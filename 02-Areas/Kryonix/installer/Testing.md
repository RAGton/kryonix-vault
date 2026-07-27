---
type: installer-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-07-27
tags: [kryonix, installer, testing, cargo, npm, capabilities, kve, think]
links:
  - "[[MOC - Installer]]"
  - "[[Validation Matrix]]"
  - "[[2026-07-27-kryxd-gate1-capability-registry]]"
---

# Testing — Installer e KCP

## Workspace canônico

```bash
cd /home/rocha/Proyectos/kryonix-dev/repos/kryxd
```

Não usar paths históricos como fonte operacional sem nova validação.

## Ambiente Rust/Nix

O projeto depende de bibliotecas de sistema, incluindo headers PAM. O caminho canônico é executar os testes dentro do devShell do Flake:

```bash
nix develop -c cargo test --workspace --locked
```

Para evitar interferência de caches produzidos por outra versão de Rust, usar um target isolado:

```bash
CARGO_TARGET_DIR=/tmp/kryxd-test-target \
  nix develop -c \
  cargo test --workspace --locked
```

Não instalar headers globalmente e não usar `apt` no NixOS.

## Gate 1 — rotas V2 KVE e Think

O Gate 1 reativou a cobertura dos endpoints stub existentes:

```text
GET /api/v2/kve/instances
GET /api/v2/kve/storage
GET /api/v2/think/topology
GET /api/v2/think/storage/zfs
```

Os endpoints continuam explicitamente classificados como stub. O Gate 1 não implementa providers Incus ou ZFS reais.

Validação com target limpo:

```text
10 passed
0 failed
0 ignored
120 filtered out
```

Cobertura adicionada:

- chamada direta dos quatro handlers;
- resposta HTTP `200` das quatro rotas corretas;
- campo `status: "stub"` preservado;
- listas vazias preservadas;
- paths duplicados retornando `404`.

Commit informado:

```text
949e015b9abd1f538214e1c5ceddc59a54c8479d
test(api): reactivate KVE and Think v2 stub routes
```

O commit foi criado na branch `test/reactivate-v2-stub-routes` e, no fechamento do Gate 1, ainda não havia sido enviado para o remoto.

## Capability registry — estado atual

Fonte de verdade:

```text
schemas/capabilities.json
```

Consumidor tipado:

```text
crates/kryx/src/domain/capabilities.rs
```

O módulo Rust incorpora o JSON canônico por `include_str!`, valida IDs, dependências, conflitos, ciclos e capabilities `unsupported` sem `blockReason`.

### Drift conhecido: 42 × 43

O registry atual contém 43 capabilities. O teste `canonical_registry_has_expected_shape` ainda espera 42:

```rust
assert_eq!(registry.capabilities.len(), 42);
```

A capability adicional identificada é:

```text
virtualization.incus
```

Metadados:

```text
domain: virtualization
wireKey: incus
status: ready
requires: storage.srv-data
conflicts: virtualization.libvirt
```

Interpretação atual:

```text
registry alterado deliberadamente: provável
registry corrompido pelo Gate 1: não
teste numérico desatualizado: confirmado
```

O Gate 1 modificou somente `src/api/v2/kve.rs` e `src/api/v2/think.rs`; portanto, ele não introduziu o drift do registry.

### Correção recomendada para o Gate 1.5

Não remover `virtualization.incus` apenas para retornar à contagem 42.

A correção deve:

1. atualizar a expectativa deliberada para 43;
2. manter a validação de IDs únicos;
3. verificar explicitamente a presença de `virtualization.incus`;
4. verificar `requires` e `conflicts`;
5. registrar a expansão do contrato no changelog/log do Gate.

Importante: uma capability registrada como `ready` não prova que toda a experiência KVE esteja pronta. Os endpoints KVE auditados ainda retornam `status: "stub"`. A documentação deve separar:

```text
capability declarada no catálogo
implementação de provider
maturidade da API
maturidade da UI
```

## Backend Rust — comandos

Testes focados da API V2:

```bash
CARGO_TARGET_DIR=/tmp/kryxd-api-v2-target \
  nix develop -c \
  cargo test -p kryxd api::v2 --locked -- --nocapture
```

Teste focado do registry:

```bash
CARGO_TARGET_DIR=/tmp/kryxd-capability-target \
  nix develop -c \
  cargo test -p kryx canonical_registry_has_expected_shape \
  --locked -- --nocapture
```

Suite do crate compartilhado:

```bash
nix develop -c cargo test -p kryx --locked
```

Suite do workspace:

```bash
nix develop -c cargo test --workspace --locked
```

Clippy:

```bash
nix develop -c \
  cargo clippy --workspace --all-targets --all-features \
  --locked -- -D warnings
```

Não usar `cargo fix` durante gates de auditoria.

## Frontend

```bash
cd /home/rocha/Proyectos/kryonix-dev/repos/kryxd/ui
npm ci
npm test
npm run build
```

Falhas globais fora do escopo de um gate devem ser registradas separadamente; não devem ser mascaradas como sucesso.

## Build Nix

```bash
cd /home/rocha/Proyectos/kryonix-dev/repos/kryxd
nix flake check --keep-going
```

Executar somente depois de fechar o diff do gate atual.

## Checklist por gate

- [ ] branch criada diretamente de `origin/main`;
- [ ] working tree limpo no início;
- [ ] escopo limitado a uma responsabilidade;
- [ ] target limpo quando houver suspeita de cache Rust;
- [ ] testes focados executados;
- [ ] suite ampliada executada ou bloqueio ambiental comprovado;
- [ ] `git diff --check` passa;
- [ ] stage com paths explícitos;
- [ ] nenhum secret no diff;
- [ ] `/etc/kryonix` e `/etc/kryonixos` intactos;
- [ ] status `stub`, `partial` e `ready` descritos sem exagero.

## Pendências

- Gate 1.5: corrigir e fortalecer o teste de contagem do registry.
- Substituir gradualmente stubs KVE/Think por providers reais.
- Adicionar contract test UI → schema → Rust.
- Revisar a coerência entre `status: ready` da capability `virtualization.incus` e a maturidade ainda stub das rotas KVE.
- Manter a documentação alinhada ao runtime real.

## Links relacionados

- [[MOC - Installer]]
- [[Validation Matrix]]
- [[2026-07-27-kryxd-gate1-capability-registry]]
