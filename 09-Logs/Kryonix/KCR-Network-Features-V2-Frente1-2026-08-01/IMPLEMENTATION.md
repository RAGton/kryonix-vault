# Frente 1 — Node Think + WAN Obrigatória (Log de Implementação)

Data: 2026-08-01
Agente: Aura
Autonomia: L1 (código) + L2 (escopo bem definido com gate humano)
Tipo: Execução do KCR [[KCR]]
Antecessor: [[AUDIT]]

## Repos afetados

- `repos/kryxd` (único repo com código alterado)
- `repos/kryonix-vault` (este log)

Não houve alteração em:
- `repos/kryonix` (motor NixOS) — fora do escopo desta frente
- `repos/kryonixos`, `repos/kryonix-installer`, `repos/kryonix-home`, `repos/kryonix-brain-lightrag`, `repos/kryonix-aura`, `repos/kryonix-assets`, `repos/kryx-cli` — escopo da Frente 1 cobre apenas `kryxd`

---

## Objetivo

Executar a Fase 1 do KCR [[KCR]]: implementar a invariante de
Node Think exigir WAN obrigatória, tornar `hostId` condicional ao uso
de ZFS, e sincronizar contrato Rust, schema JSON e tradutor.

---

## Decisão arquitetural registrada (gate humano)

**Opção B escolhida** (com autorização verbal durante a sessão):

```text
hostId é condicional ao uso de ZFS:
  - Btrfs / XFS / Ext4 -> hostId opcional/omitido
  - ZFS                -> hostId estritamente obrigatorio
```

**Compatibilidade com legado:** `isThinkServer` (boolean simples) é
mantido temporariamente. O tradutor unifica para o bloco canônico
`nodeThink`. Validador aceita ambos.

---

## Commits executados (5 commits, todos pushed)

```
8cef5cc  style(kryx): cargo fmt for Frente 1 files
e50b0cb  test(kryx): nodeThink+WAN mandatory + ZFS conditional hostId
66c7b80  feat(schema): add nodeThink to InstallPlanV2 JSON schema
83bd5ae  feat(translator): conditional hostId + legacy isThinkServer
eeb846c  feat(kryx): conditional hostId + mandatory WAN for nodeThink
```

Push: `e500a55..8cef5cc main -> main` (fast-forward limpo, sem rebase)

---

## Mudanças realizadas

### Fase 1 — `crates/kryx/src/domain/config.rs` (commit `eeb846c`)

1. `NodeThinkPlan.host_id` agora é `Option<String>` (era `String`).
   `serde(default, skip_serializing_if = "Option::is_none")` para
   serialização limpa.

2. Nova função `validate_node_think_plan` chamada no `TryFrom<InstallPlanV2Wire>`
   antes de `validate_network_plan`. Duas invariantes:
   - `hostId` condicional ao ZFS: rejeita `(enable=true, usa ZFS, sem hostId)`
   - WAN obrigatória: rejeita `enable=true` se `network` é null ou `network.wan` é null

3. Documentação inline expandida explicando a relação ZFS<->hostId
   e a dependência de WAN.

4. Três testes legados do translator atualizados de `host_id: "..."`
   para `host_id: Some("...")` (mudança de tipo).

### Fase 3 — `crates/kryx/src/services/translator.rs` (commit `83bd5ae`)

1. `hostId` só é emitido quando `Some(_)` e não-vazio (sem inferência).
2. Flag legada `isThinkServer = true` é tratada como
   `node_think.enable = true` sem `hostId` (compatibilidade).
3. Output sempre unificado no bloco canônico `node.thinkServer.*`.

### Fase 2 — `schemas/install-plan.schema.json` (commit `66c7b80`)

1. Nova propriedade `nodeThink` no top-level (oneOf: object|null).
2. Novo `$defs/nodeThinkPlan` com `enable` (obrigatório, boolean) e
   `hostId` (opcional, oneOf: string|null).
3. Três blocos `allOf/if/then` para cross-validation:
   - `hostId` obrigatório se `storage.root.filesystem == "zfs"`
   - `hostId` obrigatório se `storage.data.filesystem == "zfs"`
   - `network.wan` obrigatório se `nodeThink.enable == true`

Nota: schema usa formato flat (3 if/then separados) em vez de
`if/then/if/then` aninhado. O AJV 8 não dispara corretamente
`if/then` aninhado com `anyOf` sob `strict: false`, então a forma
flat garante a validação. Documentado inline.

### Fase 4 — Testes em `config.rs::tests` (commit `e50b0cb`)

5 testes novos + 4 helpers:
- `node_think_btrfs_without_host_id_is_accepted` (Btrfs+WAN OK)
- `node_think_xfs_without_host_id_is_accepted` (XFS+WAN OK)
- `node_think_zfs_without_host_id_is_rejected` (ZFS sem hostId)
- `node_think_without_wan_is_rejected` (network null e wan null)
- `node_think_disabled_does_not_require_wan_or_host_id` (enable=false)

Helper notável: `storage_btrfs_single_json` usa topologia `split` com
`data=btrfs` (não `root=btrfs`) porque o validador de storage
exige o bloco `btrfs` apenas quando `data.filesystem==btrfs`.

### Style — `cargo fmt` (commit `8cef5cc`)

Aplicado rustfmt nos dois arquivos da Frente 1. NÃO tocado em
arquivos preexistentes com drift de formatação
(`virtualization.rs`, `media_storage.rs`, `incus.rs`, `kve.rs`,
`storage.rs`) — fora do escopo da entrega.

---

## Validações executadas

| Validação | Resultado |
|---|---|
| `cargo check -p kryx --lib` | OK (compila limpo) |
| `cargo test -p kryx --lib` | **46/47 passam** |
| `rustfmt --check` (Frente 1 files) | OK (sem diffs) |
| AJV 8 + ajv-formats (5 fixtures) | **5/5 passam** |

**Único teste falhando:** `domain::capabilities::tests::canonical_registry_has_expected_shape`
esperava 43 capabilities, registry tem 50. Drift **preexistente**
(último commit relacionado: `155fbaa test(capabilities): align registry
expectations with Incus`). Não tocado por esta entrega. Não é
regressão.

---

## Evidência das validações AJV (5 fixtures)

| Fixture | Esperado | Resultado |
|---|---|---|
| `ok-btrfs-dhcp` (Btrfs+WAN DHCP, sem hostId) | válido | ✅ válido |
| `ok-zfs-hostid` (ZFS+PPPoE+hostId) | válido | ✅ válido |
| `invalid-zfs-no-hostid` (ZFS sem hostId) | inválido | ✅ rejeitado |
| `invalid-no-wan` (Node Think com `wan: null`) | inválido | ✅ rejeitado |
| `invalid-null-net` (Node Think com `network: null`) | inválido | ✅ rejeitado |

---

## Pendências explícitas (não cobertas pela Frente 1)

1. **Frontend não emite `nodeThink`** — `SystemFeatures.jsx` e
   `installPlan.js` ainda montam `isThinkServer`. A UI precisa
   migrar para emitir `nodeThink` quando o user selecionar perfil
   Node Think. Fora do escopo desta fase.

2. **Módulo NixOS `think-server.nix` não foi tocado** — ele
   ainda exige `hostId` como `lib.types.str` sem default. Quando
   a UI passar a emitir `nodeThink` sem `hostId` (caso Btrfs),
   o módulo Nix vai falhar em avaliar. **Trabalho futuro
   necessário**: refatorar `think-server.nix` para tornar
   `hostId` opcional e condicionar a montagem dos datasets ZFS
   à presença de `hostId`.

3. **`ui/src/generated/installPlanSchema.js`** — schema gerado
   da UI não foi regenerado. Como o schema fonte mudou
   (adicionou `nodeThink`), a UI precisa rodar o gerador (não
   identificado nesta entrega).

4. **Sincronização com `repos/kryx-cli`** — existe cópia idêntica
   do código em `kryx-cli/crates/kryx/src/domain/config.rs`.
   **Não sincronizado nesta entrega** (escopo definido: `kryxd`
   apenas). Pendente decisão sobre como manter os dois
   repos em paridade.

---

## Riscos residuais

- **Compat AJV 8 vs CLI ajv-cli 5.0.0**: a CLI do AJV não suporta
  draft 2020-12, então a validação usada foi via Node direto
  (`ajv@8/dist/2020`). Se a CI usar ajv-cli, ela falhará por
  outro motivo. Recomenda-se atualizar `ajv-cli` ou usar
  `ajv-cli@>=6` na CI.

- **Drift de capabilities**: o teste
  `canonical_registry_has_expected_shape` está com 43 vs 50.
  Não relacionado a esta frente, mas pode mascarar regressões
  futuras se a CI estiver usando apenas o `cargo test` do kryx.

- **`isThinkServer` legado**: a compatibilidade foi mantida por
  decisão operacional, mas isso significa que o contrato V2
  aceita **dois** caminhos para expressar a mesma coisa. Risco
  de divergência futura. Recomenda-se deprecar formalmente em
  um KCR futuro.

---

## Status final

- **Frente 1 Rust+schema: IMPLEMENTED, EVAL-VALIDATED, PUSHED**
- **Runtime test (kryx switch real): NOT EXECUTED** — fora do
  escopo desta entrega, é trabalho de QA/installer

---

## Próximos passos recomendados

1. **Refatorar `think-server.nix`** para suportar Node Think
   sem ZFS (Btrfs/XFS/Ext4). Pré-requisito para o frontend
   emitir `nodeThink` sem `hostId`.

2. **Atualizar `SystemFeatures.jsx`** para emitir `nodeThink`
   no payload V2. Decidir onde o user informa o `hostId`
   (auto-gerado? wizard?).

3. **Regenerar `installPlanSchema.js`** via gerador do
   repositório `kryxd`.

4. **Sincronizar `kryx-cli`** (decidir estratégia: subtree,
   submodule, ou divergência controlada).

5. **Deprecar formalmente `isThinkServer`** em um KCR futuro,
   após UI migrar completamente.

---

## Links relacionados

- [[KCR]] — Proposta original da Frente 1
- [[AUDIT]] — Auditoria read-only pré-implementação
- [[../../02-Areas/Kryonix/canonical/SystemFeatures-Fluxo-Completo-UI-Backend-NixOS]] — Fluxo completo de features
- [[../../02-Areas/Kryonix/canonical/EXISTING_FEATURES_CATALOG]] — Catálogo de features existentes

#kryonix #kryxd #frente1 #node-think #wan #v2-contract
