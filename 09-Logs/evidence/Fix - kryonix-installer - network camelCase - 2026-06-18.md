# Fix P0 — `network: missing field server_ip`

> **Data:** 2026-06-18
> **Repositório:** `github:RAGton/kryonix-installer`
> **Commit fixado em:** `src/main.rs` (não pushed — aguarda revisão)
> **Bloqueio:** Instalação não iniciava; `/dry-run` e `/install` retornavam 422

---

## Causa Raiz

**Divergência camelCase ↔ snake_case no bloco `network` do payload.**

A UI (`buildInstallPlanPayload` → `buildKryonixInstallPlan`) monta e envia:
```json
{
  "network": {
    "serverIp": "10.0.0.10",
    "prefixLength": 24,
    "httpPort": 8080,
    "pppoeUser": null
  }
}
```

O Rust (`NetworkPlan` / `WanPlan`) esperava os mesmos campos em snake_case:
```
server_ip, prefix_length, http_port, pppoe_user
```

Por ausência de `#[serde(rename_all = "camelCase")]`, serde não encontrava
`server_ip` no JSON e retornava:

```
Failed to deserialize the JSON body into the target type: network: missing field `server_ip`
```

---

## Mapeamento Completo da Divergência

| Campo Rust | Enviado pela UI | Status antes | Status depois |
|---|---|---|---|
| `server_ip` | `serverIp` | ❌ missing field | ✅ ok |
| `prefix_length` | `prefixLength` | ❌ missing field | ✅ ok |
| `http_port` | `httpPort` | ❌ missing field | ✅ ok |
| `pppoe_user` | `pppoeUser` | ❌ missing field | ✅ ok |

---

## Caminho do Bug (Stack)

```
UI: buildInstallPlanPayload()     → network.serverIp (camelCase)
    buildKryonixInstallPlan()     → passa network literalmente (linha 98: planPayload.network || {})
    POST /dry-run  (ou /install)  → body JSON com serverIp
    axum Json<InstallPlan>         → serde_json::from_str()
    NetworkPlan                   → esperava server_ip → ERRO 422
```

---

## Fix Aplicado

**Arquivo:** `src/main.rs`
**Mudança:** +2 linhas de atributo serde

```diff
-#[derive(Serialize, Deserialize, Clone, Default)]
+#[derive(Serialize, Deserialize, Clone, Default)]
+#[serde(rename_all = "camelCase")]
 pub struct NetworkPlan {
     pub hostname: String,
     pub interface: String,
     pub server_ip: String,       // Rust field name unchanged
     pub prefix_length: u8,
     pub mode: String,
     pub gateway: String,
     pub dns: Vec<String>,
     pub http_port: u16,
     #[serde(default)]
     pub wan: WanPlan,
 }

-#[derive(Serialize, Deserialize, Clone, Default)]
+#[derive(Serialize, Deserialize, Clone, Default)]
+#[serde(rename_all = "camelCase")]
 pub struct WanPlan {
     pub interface: String,
     pub mode: String,
     pub address: Option<String>,
     pub prefix_length: Option<u8>,
     pub gateway: Option<String>,
     pub dns: Vec<String>,
     pub pppoe_user: Option<String>,
 }
```

> **Por quê neste sentido:** A UI é a fonte de verdade do wire format. Alterar a UI para emitir snake_case exigiria mudar buildInstallPlanPayload + todos os testes UI; o Rust aceita qualquer rename sem lógica extra.

---

## Testes Adicionados

### `test_network_plan_accepts_camelcase_from_ui` (novo, regressão)
- Reproduz exatamente o payload que a UI envia no modo DHCP
- Verificava antes: `serde_json::from_value` → `Err("missing field server_ip")`
- Verifica agora: `Ok(...)` + `plan.network.server_ip == "0.0.0.0"`

### `test_install_plan_deserializes_real_ui_payload` (corrigido)
- Fixture corrigida de snake_case para camelCase no bloco `network`
- Adicionadas asserções: `server_ip`, `prefix_length`, `http_port`

---

## Evidências de Validação

```
cargo fmt --check        → OK (sem diff)
cargo clippy -D warnings → OK (51 checks, 0 warnings)
cargo test               → OK (51 passed, 0 failed)
npm test                 → OK (65 passed, 0 failed)
npm run build            → OK (448KB bundle)
git diff --check         → OK (sem whitespace issues)
git status --short       →  M src/main.rs
```

---

## Riscos Restantes

| # | Risco | Status |
|---|---|---|
| R1 | `target_tree.rs` usa `net.server_ip` (campo Rust) — **não afetado** pelo rename | ✅ Verificado |
| R2 | Serialização inversa (Rust → JSON) agora emitirá `serverIp` — **intencionado** (UI consome) | ✅ OK |
| R3 | Testes de fixtura snake_case em outros módulos (safety.rs, partition.rs) usam `Default::default()` para `network` — não afetados | ✅ OK |
| R4 | `schemas/install-plan.schema.json` (backend) não tem `network` documentado — backlog Doc F4 | ⚠️ Backlog |

---

## O que NÃO foi feito

- Sem push
- Sem merge
- Sem refactor de main.rs
- Sem OpenAPI
- Sem tracing
- Sem branding
- Sem `.md` na raiz do repo

---

## Links

- [[09-Logs/evidence/Avaliacao - kryonix-installer - 2026-06-18]]
- [[03-Projetos/KryonixOS Installer]]

#kryonix #installer #bugfix #p0 #serde #camelcase
