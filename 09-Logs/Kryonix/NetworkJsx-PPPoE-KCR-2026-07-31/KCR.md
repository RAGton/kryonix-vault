# KCR-2026-07-31-01 — PPPoE no InstallPlanV2 + translator.rs

## Status

- **Tipo:** Mudança de contrato V2 + tradução Nix declarativa
- **Severidade:** alta — Débito arquitetural P1 (Node Think Day-0 PPPoE)
- **Owner:** Gabriel (Kryonix)
- **Autor:** Aura
- **Decisão de produto:** V2 assume rede declarativa (Caminho 1, 2026-07-31)
- **Promoção para canonical:** após validação E2E (testes Rust + npm + build)

---

## Contexto

RAGOS Think / Node Think exige autenticação PPPoE no Day-0 (primeiro
boot), tanto bare-metal quanto edge virtualizado. Hoje a UI recolhe
`pppoeUser` + `pppoePassword` (WanCard.jsx) e o backend Rust já tem
`InstallSecretsV2.pppoe_password`, mas:

1. O bloco `network.wan` **não é emitido** no payload V2 pela UI
   (`buildInstallPlanPayload` retorna só `version/isThinkServer/repository/storage/features`).
2. O `InstallPlanV2` Rust struct (`crates/kryx/src/domain/config.rs`)
   **não tem** campo `network`.
3. O schema JSON V2 (`schemas/install-plan.schema.json`) **não tem**
   `$defs.networkPlan`.
4. O `translator.rs` **não gera** nenhuma diretiva `networking.*`.

Resultado: a senha PPPoE flui via `/api/v2/secrets` mas o `pppoeUser`
se perde entre UI e NixOS, e nenhuma config PPPoE vai pro
`configuration.nix` gerado.

---

## Estado Atual da Auditoria (Etapa 0)

### `crates/kryx/src/domain/config.rs` (InstallPlanV2 struct)

```rust
pub struct InstallPlanV2 {
    pub version: u8,                          // const 2 enforced via custom deserializer
    pub is_think_server: bool,
    pub node_think: Option<NodeThinkPlan>,    // substituiu o legado is_think_server
    pub repository: RepositoryPlan,
    pub storage: StoragePlan,                  // try_from StoragePlanWire com validação ZFS/BTRFS
    pub features: BTreeMap<String, BTreeMap<String, bool>>,
}
```

Tem `try_from` em `StoragePlan` (validação rica via `StoragePlanWire`).
**Não tem** `network: Option<NetworkPlan>`.

### `crates/kryx/src/services/translator.rs` (110 linhas)

Gera Nix declarativo a partir de `InstallPlanV2`. Emite:
- `{ config, lib, ... }:` header
- `node.thinkServer.enable/hostId` (de `node_think`)
- `kryonix.storage.{topology, systemDisks, dataDisks, root.filesystem, data.filesystem, zfs.userRefquota, btrfs.userQgroupLimit}`
- `kryonix.features.{category}.{feature} = true`

**Zero diretivas `networking.*`.** Padrão test-friendly (testa via
`assert!(result.contains(...))`).

### `schemas/install-plan.schema.json` (fonte canônica)

- `required` no top-level: `version, isThinkServer, repository, storage, features`
- `properties` não inclui `network`
- `$defs` tem: `repositoryPlan, mountPlan, zfsStoragePlan, btrfsStoragePlan, storagePlan, featureSelection, features`
- **Não tem** `networkPlan`

### `src/api/install.rs` (handler `/api/v2/secrets`)

Já consome `InstallSecretsV2 { admin_password, pppoe_password }`. Linha 317: `pub async fn put_secrets`. **Funcionando.** Nada a fazer aqui — só garantir que o `pppoe_password` continua chegando.

### `ui/src/components/network/WanCard.jsx`

Coleta: `wizard.wanInterface`, `wizard.wanMode` (dhcp/static/pppoe),
`wizard.wanAddress`, `wizard.wanNetmask`, `wizard.wanGateway`,
`wizard.wanDns`, `wizard.pppoeUser`, `wizard.pppoePassword`,
`wizard.wanIdentified`. Tudo já no `wizardState`.

---

## Desenho da Mudança

### Decisão arquitetural (Caminho 1)

`network` vira **campo top-level opcional** do `InstallPlanV2`,
com 2 sub-blocos: `management` (LAN/PXE, sempre presente quando há
rede) e `wan` (opcional, presente quando `wanInterface` != '').

### Contrato V2 proposto

#### Top-level (adicionar em InstallPlanV2)

```rust
pub network: Option<NetworkPlan>,  // None = wizard pulou rede
```

#### NetworkPlan

```rust
pub struct NetworkPlan {
    pub management: ManagementNetwork,  // sempre presente
    pub wan: Option<WanNetwork>,       // None = sem uplink
}

pub struct ManagementNetwork {
    pub interface: String,             // mgmtInterface (ex: "enp1s0")
    pub mode: NetworkMode,             // dhcp | static
    pub address: Option<String>,      // serverIp (static only)
    pub prefix_length: u8,             // 0-32 (24 default)
    pub gateway: Option<String>,       // mgmtGateway (static only)
    pub dns: Vec<String>,              // mgmtDns split (CSV->array)
    pub hostname: String,              // hostName
}

pub struct WanNetwork {
    pub interface: String,             // wanInterface (ex: "enp2s0")
    pub mode: WanNetworkMode,          // dhcp | static | pppoe
    pub address: Option<String>,       // wanAddress (static only)
    pub prefix_length: Option<u8>,     // wanNetmask (static only)
    pub gateway: Option<String>,       // wanGateway (static only)
    pub dns: Vec<String>,              // wanDns (static only)
    pub pppoe_user: Option<String>,    // pppoeUser (pppoe only)
    // NOTE: pppoe_password NUNCA entra aqui. Flui via InstallSecretsV2.
}

pub enum NetworkMode { Dhcp, Static }
pub enum WanNetworkMode { Dhcp, Static, Pppoe }
```

### Validações necessárias

- Se `management.mode = static`, então `address`, `prefix_length`, `gateway`
  são obrigatórios e `dns.len() >= 1`.
- Se `wan.mode = pppoe`, então `pppoe_user` é obrigatório (`pppoe_password`
  vem via `/api/v2/secrets`).
- IPv4 validity (regex `ipv4Pattern` igual ao `installPlan.js:20` da UI).
- `prefix_length` ∈ 1..=32.
- `mode = dhcp` ⇒ `address/gateway/dns` vazios (UI zera).

### Schema JSON V2 (adicionar)

```json
{
  "network": {
    "oneOf": [
      { "$ref": "#/$defs/networkPlan" },
      { "type": "null" }
    ]
  }
}
```

E na raiz, adicionar `"network"` aos opcionais (`required` não inclui,
mas `properties` sim).

### translator.rs — diff proposto

Bloco 5 (novo, após storage):

```rust
// 5. Network — emite networking.* conforme o wizard
if let Some(network) = &plan.network {
    // Interface de management (sempre presente)
    let mgmt = &network.management;
    config.push_str(&format!(
        "  networking.hostName = \"{}\";\n", mgmt.hostname
    ));
    config.push_str(&format!(
        "  networking.interfaces.{}.ipv4.addresses = [ {{ address = \"{}\"; prefixLength = {}; }} ];\n",
        mgmt.interface,
        mgmt.address.as_deref().unwrap_or("0.0.0.0"),
        mgmt.prefix_length
    ));
    if !mgmt.dns.is_empty() {
        let dns_list = mgmt.dns.iter()
            .map(|d| format!("\"{}\"", d))
            .collect::<Vec<_>>()
            .join(" ");
        config.push_str(&format!(
            "  networking.nameservers = [ {} ];\n", dns_list
        ));
    }
    if let Some(gw) = &mgmt.gateway {
        config.push_str(&format!(
            "  networking.defaultGateway = \"{}\";\n", gw
        ));
    }

    // WAN (opcional) — pode ser DHCP, Static ou PPPoE
    if let Some(wan) = &network.wan {
        match wan.mode {
            WanNetworkMode::Dhcp => {
                config.push_str(&format!(
                    "  networking.interfaces.{}.ipv4.addresses = [ {{ address = \"0.0.0.0\"; prefixLength = 0; }];\n",
                    wan.interface
                ));
                // dhcpcd default on NixOS — sem diretiva explícita
            }
            WanNetworkMode::Static => {
                config.push_str(&format!(
                    "  networking.interfaces.{}.ipv4.addresses = [ {{ address = \"{}\"; prefixLength = {}; }} ];\n",
                    wan.interface,
                    wan.address.as_deref().unwrap_or("0.0.0.0"),
                    wan.prefix_length.unwrap_or(24)
                ));
                if let Some(gw) = &wan.gateway {
                    config.push_str(&format!(
                        "  networking.defaultGateway = \"{}\";\n", gw
                    ));
                }
            }
            WanNetworkMode::Pppoe => {
                // username vem do plan; password vem de InstallSecretsV2 via proxy
                let user = wan.pppoe_user.as_deref().unwrap_or("");
                // Emitimos referência à senha que será provisionada em runtime
                // pelo secret manager — placeholder explícito
                config.push_str(&format!(
                    "  networking.pppoe.{}.enable = true;\n", wan.interface
                ));
                config.push_str(&format!(
                    "  networking.pppoe.{}.username = \"{}\";\n", wan.interface, user
                ));
                config.push_str(&format!(
                    "  networking.pppoe.{}.passwordFile = \"/etc/kryonix/secrets/pppoe-{}\";\n",
                    wan.interface, wan.interface
                ));
            }
        }
    }
}
```

**Sobre a senha PPPoE:** ela NÃO entra no `InstallPlanV2` (segredos
fora do Nix store). O translator emite **apenas referência** ao
`passwordFile` (`/etc/kryonix/secrets/pppoe-<iface>`). O arquivo é
criado pelo `/api/v2/secrets` handler existente durante o
provisionamento, usando `SecretString` + `atomic_write` em modo 0600
(mesmo padrão de `adminPasswordFile` — ver `src/api/install.rs:1019`).

### UI — `buildInstallPlanPayload` diff proposto

```js
// ANTES (installPlan.js:298-309)
return {
  version, isThinkServer, repository, storage, features,
};

// DEPOIS
const network = buildNetworkPlan(draft);
return {
  version, isThinkServer, repository, network, storage, features,
};
```

`buildNetworkPlan(draft)`:
- Se `!wizard.mgmtInterface`, retorna `null` (sem rede — caso offline puro).
- Se sim, monta `management` + opcional `wan` quando `wanInterface != ''`.

### Testes obrigatórios

1. **Rust unit (config.rs):**
   - `deserializes_plan_with_network_dhcp` — LAN DHCP sem WAN
   - `deserializes_plan_with_pppoe_wan` — LAN DHCP + WAN PPPoE com user
   - `rejects_pppoe_without_user` — WAN PPPoE sem pppoe_user → erro
   - `rejects_static_without_address` — LAN Static sem IP → erro

2. **Rust unit (translator.rs):**
   - `test_translates_dhcp_management_only` — emite `networking.hostName` + `interfaces.<iface>` DHCP
   - `test_translates_pppoe_wan_emits_password_file_reference` — emite `networking.pppoe.<iface>.passwordFile = ...`
   - `test_translates_no_network_emits_nothing` — `network: None` → sem diretivas

3. **JS unit (`installPlan.test.js`):**
   - `buildInstallPlanPayload_includes_network_block_when_mgmtInterface_set`
   - `buildInstallPlanPayload_excludes_network_when_mgmtInterface_empty` (offline)
   - `buildInstallPlanPayload_includes_wan_pppoe_user` (senha **NUNCA** no payload)

4. **E2E manual (não automatizável):**
   - Instalar com WAN PPPoE → verificar `/etc/kryonix/secrets/pppoe-<iface>` existe e é 0600
   - Verificar `configuration.nix` gerado contém `networking.pppoe.<iface>.enable = true`

---

## Sequência de execução

1. **Backend Rust** (`crates/kryx/src/domain/config.rs`):
   - Adicionar `NetworkPlan`, `ManagementNetwork`, `WanNetwork`, enums
   - Adicionar `try_from` para validação (espelhar padrão `StoragePlanWire`)
   - Adicionar testes unit (4 cenários acima)

2. **Schema JSON** (`schemas/install-plan.schema.json`):
   - Adicionar `$defs.networkPlan`, `$defs.managementNetwork`, `$defs.wanNetwork`
   - Adicionar `network` em `properties` (oneOf: ref ou null)
   - Regenerar `ui/src/generated/installPlanSchema.js` via `scripts/generate-ui-contracts.mjs`

3. **UI** (`ui/src/utils/installPlan.js`):
   - Adicionar `buildNetworkPlan(draft)`
   - Injetar `network` no return de `buildInstallPlanPayload`
   - Adicionar testes unit (3 cenários acima)

4. **translator.rs** (`crates/kryx/src/services/translator.rs`):
   - Bloco 5 novo conforme diff acima
   - Testes unit (3 cenários acima)

5. **Validação**:
   - `cargo fmt --check && cargo clippy -- -D warnings` (com libclang)
   - `cd ui && npm test` (suite completa)
   - `npm run build` (Vite)

6. **Commit escopado por arquivo** (não misturar):
   - `feat(contract): add NetworkPlan to InstallPlanV2` (Rust + schema)
   - `feat(ui): emit network block in InstallPlanV2 payload`
   - `feat(translator): emit networking.* and pppoe.* directives`

---

## Riscos

| Risco | Mitigação |
|---|---|
| Senha PPPoE vazar pro Nix store via plan | Senha **só** via `/api/v2/secrets` (já validado em `src/domain/secrets.rs:14`); translator emite só `passwordFile` reference |
| Quebrar validação AJV existente | Schema vira `additionalProperties: false` ainda — só adiciona campos opcionais |
| Inverter ordem DHCP/Static/Pppoe no match | 3 testes unit (um por modo) |
| UI mandar `network: undefined` quebrando serde | `network` é `Option<NetworkPlan>` — `None` deserializa como ausente |
| `buildInstallPlanPayload` falhar quando wizard vazio (caso offline puro) | Documentado: `mgmtInterface === ''` → `network: null` (não vai pro payload) |

---

## Pendências (fora do escopo deste KCR)

1. **Conexão `/etc/kryonix/secrets/pppoe-<iface>` → systemd activation**
   — exige `activationScript` no Flake base (não no nosso escopo).
2. **UI exibir "PPPoE backend OK" após provisionar** — exige refactor do
   `WanCard` para consumir `/api/v2/secrets/result` (futuro).
3. **Migrar `InstallPlan` V1 (legado em `src/main.rs:128-151`) pra V2** —
   decisão de deprecation: nada por ora.

---

## Próximo passo

Aguardando Gabriel aprovar este KCR. Se aprovado, executo na ordem
1→6 acima. Cada commit escopado, com log de progresso incremental no
Vault (`09-Logs/Kryonix/`).