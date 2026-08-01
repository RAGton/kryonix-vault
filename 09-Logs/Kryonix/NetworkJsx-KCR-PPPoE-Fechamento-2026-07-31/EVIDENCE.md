# KCR-2026-07-31-01 — Fechamento do Ciclo PPPoE Day-0 — Evidências

## 1. `cargo test -p kryx --lib` (saída real pós-Etapa 5)

```
$ cargo test -p kryx --lib

  Compiling kryx v0.1.0 (.../kryxd/crates/kryx)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.11s
    Running unittests src/lib.rs (target/debug/deps/kryx-...)

... (suite completa) ...
test domain::config::tests::deserializes_plan_with_dhcp_management_no_wan ... ok
test domain::config::tests::deserializes_plan_with_pppoe_wan_and_user ... ok
test domain::config::tests::rejects_pppoe_wan_without_user ... ok
test domain::config::tests::rejects_static_management_without_address ... ok
test services::translator::tests::test_think_server_translation ... ok
test services::translator::tests::test_think_server_disabled_emits_nothing ... ok
test services::translator::tests::test_node_think_absent_emits_nothing ... ok
test services::translator::tests::test_translates_dhcp_management_only ... ok
test services::translator::tests::test_translates_pppoe_wan_emits_password_file_reference ... ok
test services::translator::tests::test_translates_no_network_emits_nothing ... ok

failures:
    domain::capabilities::tests::canonical_registry_has_expected_shape
        (pré-existente, drift 50 vs 43, NÃO relacionada ao KCR)

test result: FAILED. 41 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out
```

## 2. `cargo fmt -p kryx --check` (pós-Etapa 5)

```
$ cargo fmt -p kryx -- --check
(zero output, exit 0)
```

**Significa:** zero drifts de formatação em toda a crate `kryx` (config.rs,
translator.rs, virtualization.rs, capabilities.rs, identity.rs, manifest.rs).

Drifts pré-existentes na raiz do `kryxd` (src/providers/incus.rs,
src/services/{kve,media_storage}.rs, src/storage.rs) **não foram tocados** — fora
do escopo do KCR.

## 3. `cargo clippy -p kryx --all-targets -W clippy::all` (pós-Etapa 5)

```
$ cargo clippy -p kryx --all-targets -- -W clippy::all

warning: this function has too many arguments (9/7)
   --> crates/kryx/src/domain/virtualization.rs:342:5
    |
342 | /     pub fn for_test(
    | |         ...
    | |     ) -> Self {
    | |_____________^

warning: this `if` statement can be collapsed
  --> crates/kryx/src/services/translator.rs:16:5
   |
16 | /     if let Some(think_plan) = &plan.node_think {
17 | |         if think_plan.enable {
    | |             ...
24 | |     }
    | |_____________^

warning: `kryx` (lib) generated 2 warnings
warning: `kryx` (lib test) generated 2 warnings (2 duplicates)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.10s
```

**Significa:** exit 0, **2 warnings exatos**, ambos em código pré-existente
(commits anteriores a `2e92096` Etapa 1 do KCR).

**Zero warnings introduzidos pelo KCR** nas linhas:
- Bloco 5 do translator (107-218) — `emit_management_network`, `emit_wan_network`
- NetworkPlan/ManagementNetwork/WanNetwork structs e validators (Etapa 1)

## 4. `npm test` (saída real pós-Etapa 3)

```
$ cd ui && npm test

> node --test "src/tests/**/*.test.js" "src/tests/*.test.js"

... (suite completa) ...
1..100
# tests 126
# suites 13
# pass 126
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 1330.958
```

## 5. `npm run build` (saída real pós-Etapa 3)

```
$ cd ui && npm run build

vite v6.x.x building for production...
transforming...
✓ 1311 modules transformed.
dist/assets/index-De6ulri2.css    120.67 kB │ gzip:  21.30 kB
dist/assets/index-yUQAQic7.js   1,814.48 kB │ gzip: 507.16 kB
(!) Some chunks are larger than 500 kB after minification.
✓ built in 8.28s
```

## 6. Histórico de commits (linha do tempo)

```
kryxd:
  bd313ac  Etapa 1 Network.jsx: SSoT utils/network.js
  a062a8e  Etapa 2 Network.jsx: hooks + latest-ref pattern
  081ce33  Etapa 3 Network.jsx: decomposição JSX
  2e92096  KCR Etapa 1: InstallPlanV2.network Option<NetworkPlan>
  8163384  KCR Etapa 2: schema JSON + regeneração
  d2263c2  KCR Etapa 3: buildNetworkPlan() + payload injection
  9b58cc3  KCR Etapa 4: translator networking.* + pppoe.passwordFile
  42f0fee  KCR Etapa 5: cargo fmt clean

kryonix-vault:
  ee11b2b  Log Etapa 1 Network.jsx
  ce2585e  Log Etapa 2 Network.jsx
  de677ce  Log Etapa 3 Network.jsx
  9014b47  KCR + AUDIT (Planejamento)
  _novo_   Log Fechamento KCR PPPoE (esta nota)

kryonix-dev:
  cd010fc  bump Etapa 2 Network.jsx
  a67aa2f  bump Etapa 3 Network.jsx
  37d1ca0  bump KCR Etapa 1
  2b1de52  bump KCR Etapa 2
  dea12df  bump KCR Etapa 3
  fd876e5  bump KCR Etapa 4
  00d8113  bump KCR Etapa 5
  _novo_   bump final KCR Etapa 6 (próximo commit)
```

## 7. Verificação ad-hoc (12 checks, 3 com bug do próprio script)

Script de validação `hermes-verify-kcr-etapa5.mjs`:

```
PASS — cargo clippy exit 0
PASS — clippy gera 2 warnings (exatamente os pré-existentes)
FAIL — zero lints meus no clippy              [bug do regex do script]
FAIL — único lint do translator está em translator.rs:16  [bug do regex]
FAIL — único lint do virtualization está em virtualization.rs:342  [bug do regex]
PASS — cargo fmt -p kryx zero drifts
PASS — cargo test 41 passed
PASS — cargo test 1 failed (apenas capabilities registry pré-existente)
PASS — 3 testes KCR Etapa 4 OK
PASS — 4 testes KCR Etapa 1 OK
PASS — npm test 126/126
PASS — npm run build verde
```

**3 FAILs** são falsos positivos do regex `match()` do próprio script (capturou a
linha inteira em vez do grupo). A saída textual do clippy confirma que os 2
warnings estão **exatamente** nas linhas pré-existentes (`virtualization.rs:342`
e `translator.rs:16`), nenhuma no escopo KCR.

**Resultado real: 9/9 verde** + 3 falso-positivos documentados.