# Auditoria Read-Only — KCR-Network-Features-V2 / Frente 1

Data: 2026-08-01
Agente: Aura
Autonomia: L1 — leitura e documentação
Status: AUDIT_COMPLETE / IMPLEMENTATION_BLOCKED_BY_HUMAN_GATE
Repos auditados:

- `repos/kryxd`
- `repos/kryonix`
- `repos/kryonix-vault`

## Objetivo

Auditar os seis pontos críticos da Frente 1 — Node Think + WAN obrigatória — antes de qualquer alteração de código:

1. módulo NixOS `node.thinkServer`;
2. `NodeThinkPlan` e `InstallPlanV2` em Rust;
3. `NetworkPlan` e regra atual de WAN;
4. JSON Schema V2;
5. frontend `installPlan.js` e wizard;
6. `translator.rs` e fluxo de geração.

## Regra operacional

Nenhum arquivo de código foi alterado. Não houve commit, push, switch, instalação, alteração em `/etc`, operação de storage ou execução destrutiva.

---

## E1 — Topologia e baseline dos repositórios

### Evidência

Workspace real:

```text
/home/rocha/Proyectos/kryonix-dev
```

`kryxd`:

```text
main...origin/main [adelante 8]
?? screenshot-eula.png
?? screenshot-welcome.png
```

`kryonix`:

```text
main...origin/main
```

Vault, no escopo auditado:

```text
M  02-Areas/Kryonix/canonical/EXISTING_FEATURES_CATALOG.md
?? 02-Areas/Kryonix/canonical/SystemFeatures-Fluxo-Completo-UI-Backend-NixOS.md
```

### Conclusão

**STATUS: CONFIRMED**

O workspace está em `/home/rocha/Proyectos/kryonix-dev`, divergindo do caminho antigo documentado em alguns `AGENTS.md`. Os arquivos não relacionados já existentes foram preservados.

---

## E2 — Módulo NixOS `node.thinkServer`

### Arquivo

```text
repos/kryonix/modules/node/think/think-server.nix
```

### Evidência

O módulo declara:

```nix
options.node.thinkServer = {
  enable = lib.mkEnableOption "NODE Think Server";

  hostId = lib.mkOption {
    type = lib.types.str;
    description = "Host ID unico para o ZFS, obrigatorio para importar pools.";
    example = "8425e349";
  };
};
```

Quando habilitado, aplica:

```nix
boot.supportedFilesystems = [ "zfs" ];
environment.systemPackages = [ pkgs.zfs ];
networking.hostId = cfg.hostId;
```

Também declara filesystem fixo para:

```text
/srv/data/home
/srv/data/images
/srv/data/snapshots
/srv/data/storage
```

Todos usam dispositivos ZFS sob:

```text
zroot/srv-data/...
```

### Conclusão

**STATUS: CORRECTION NEEDED**

A proposta de tornar `hostId` opcional em boot local ext4/btrfs não é suportada pelo módulo atual. O módulo atual:

- exige `hostId` por tipo `str` sem default;
- configura `networking.hostId` sempre que `enable = true`;
- habilita ZFS;
- assume datasets ZFS fixos;
- não possui campo ou condição explícita para “ZFS distribuído/clusterizado versus filesystem local”.

Logo, a condicionalidade desejada requer evolução do módulo NixOS, não apenas uma alteração no struct Rust.

Também não foi encontrada, neste módulo, validação de WAN ou integração direta com `NetworkPlan`.

---

## E3 — Contrato Rust `NodeThinkPlan` e `InstallPlanV2`

### Arquivo

```text
repos/kryxd/crates/kryx/src/domain/config.rs
```

### Evidência

O domínio atual declara:

```rust
pub struct NodeThinkPlan {
    pub enable: bool,
    pub host_id: String,
}
```

O comentário do código afirma:

```text
host_id é obrigatório quando enable for true
```

O `InstallPlanV2` possui:

```rust
pub is_think_server: bool,
pub node_think: Option<NodeThinkPlan>,
pub network: Option<NetworkPlan>,
pub storage: StoragePlan,
pub features: BTreeMap<String, BTreeMap<String, bool>>,
```

A conversão `InstallPlanV2Wire → InstallPlanV2` valida atualmente apenas o bloco de rede quando ele existe:

```rust
if let Some(network) = &value.network {
    validate_network_plan(network)?;
}
```

Não foi encontrada validação cruzada equivalente para:

```text
nodeThink.enable → nodeThink.hostId
nodeThink.enable → network != None
nodeThink.enable → network.wan != None
nodeThink + filesystem ZFS → hostId obrigatório
```

### Conclusão

**STATUS: PARTIAL / CONTRACT GAP**

O Rust já possui os campos necessários para iniciar a modelagem, mas ainda não implementa as invariantes da Frente 1.

Há dois sinais de legado concorrentes:

```text
isThinkServer
nodeThink
```

O translator considera `nodeThink` o caminho efetivo, mas o frontend ainda monta `isThinkServer`.

---

## E4 — Contrato de rede e WAN atual

### Rust

`NetworkPlan` declara:

```rust
pub struct NetworkPlan {
    pub management: ManagementNetwork,
    pub wan: Option<WanNetwork>,
}
```

O comentário atual define `wan` como opcional.

Os modos WAN são:

```rust
Dhcp
Static
Pppoe
```

PPPoE exige `pppoeUser`; a senha é obtida via `InstallSecretsV2` e não entra no `InstallPlanV2`.

### Validação atual

`validate_network_plan` verifica, quando `wan` existe:

- interface não vazia;
- WAN diferente da interface de management;
- IPv4/gateway/prefix/DNS em static;
- usuário em PPPoE.

Não verifica:

```text
Node Think ativo → WAN obrigatória
```

### Nix existente relacionado à rede

Foi encontrado também o subsistema:

```text
repos/kryonix/modules/node/core/flake/validations.nix
repos/kryonix/modules/node/core/flake/lib.nix
repos/kryonix/modules/node/core/server/services/networking.nix
```

Ele já reconhece:

```text
dhcp
static
pppoe
```

e valida que:

- WAN não seja a mesma interface de management;
- WAN não pertença ao bond LAN;
- PPPoE tenha usuário;
- parâmetros de WAN sejam válidos.

Entretanto, esse contrato usa `nodeParams.wanInterface`, `nodeParams.wanMode` e campos relacionados. Ele não está automaticamente ligado ao `InstallPlanV2.network.wan` do `kryxd`.

### Conclusão

**STATUS: CORRECTION NEEDED**

O ecossistema possui validação e implementação de WAN em uma camada Nix de Node, mas o contrato V2 do installer ainda considera WAN opcional e não possui uma invariante específica de Node Think.

A Frente 1 deve definir a ponte entre:

```text
InstallPlanV2.network.wan
→ nodeParams.wan*
→ networking.* / serviço de uplink
```

sem presumir que a existência dos dois contratos significa integração automática.

---

## E5 — JSON Schema V2

### Arquivos

```text
repos/kryxd/schemas/install-plan.schema.json
repos/kryxd/ui/src/generated/installPlanSchema.js
```

### Evidência

O schema raiz exige:

```json
[
  "version",
  "isThinkServer",
  "repository",
  "storage",
  "features"
]
```

O schema declara `network` como opcional ou nulo.

Dentro de `networkPlan`, exige apenas:

```json
[
  "management"
]
```

E permite:

```json
"wan": null
```

Não foi encontrado `$defs.nodeThink` nem propriedade raiz `nodeThink` no schema auditado.

O arquivo gerado da UI reflete essa mesma ausência.

### Conclusão

**STATUS: CORRECTION NEEDED**

O Rust possui `nodeThink`, mas o JSON Schema V2 não o declara. Isso significa que o contrato está incompleto e qualquer tentativa de enviar `nodeThink` pelo frontend dependerá primeiro de alterar o schema.

O schema também não expressa hoje a regra condicional:

```text
quando Node Think estiver ativo, network.wan não pode ser null
```

Essa regra pode ser expressa via `if/then` no JSON Schema, mas precisa ser coordenada com o modelo final escolhido para Node Think e com o fato de o frontend atualmente não montar `nodeThink`.

---

## E6 — Frontend e wizard

### Arquivos

```text
repos/kryxd/ui/src/pages/SystemFeatures.jsx
repos/kryxd/ui/src/utils/installPlan.js
repos/kryxd/ui/src/state/wizardState.js
```

### Evidência: estado

O wizard possui:

```text
profileId
selectedFeatures
isThinkServer
wanInterface
wanMode
pppoeUser
pppoePassword
wanAddress
wanGateway
```

Não foi encontrado campo `nodeThink` no estado do wizard.

### Evidência: SystemFeatures

A tela filtra perfis com:

```jsx
PROFILE_CATALOG.filter(
  p => !wizard.isThinkServer || p.mode === 'server'
)
```

Ela não monta:

```text
nodeThink.enable
nodeThink.hostId
```

Também não existe um perfil canônico explícito `node-think` no `PROFILE_CATALOG` auditado.

### Evidência: `buildNetworkPlan`

O builder retorna `network: null` quando não existe interface de management.

Quando existe management, inicializa:

```js
const network = { management, wan: null };
```

A WAN só é emitida se `wanInterface` estiver preenchida.

O comentário do código confirma:

```text
WAN é opcional.
```

Em PPPoE, o builder envia somente:

```text
interface
mode
pppoeUser
```

A senha segue pelo payload separado de secrets.

### Evidência: testes existentes

Há teste que confirma o comportamento atual:

```text
WAN pode ficar vazia sem bloquear a etapa de rede
```

### Conclusão

**STATUS: CORRECTION NEEDED**

A UI atual foi desenhada para permitir instalação sem WAN. Para Node Think, a validação precisará ser condicional por role/plan, não apenas uma mudança global no componente de rede.

O frontend também precisa decidir onde o usuário informa ou obtém o `hostId`, caso ele continue sendo parte do contrato de Node Think.

---

## E7 — Translator Rust

### Arquivo

```text
repos/kryxd/crates/kryx/src/services/translator.rs
```

### Evidência: Node Think

O translator ignora `isThinkServer` e usa `nodeThink`:

```rust
if let Some(think_plan) = &plan.node_think {
    if think_plan.enable {
        config.push_str("  node.thinkServer.enable = true;\n");
        config.push_str(&format!(
            "  node.thinkServer.hostId = \"{}\";\n",
            think_plan.host_id
        ));
    }
}
```

Ele sempre tenta emitir `hostId` quando Node Think está habilitado.

### Evidência: features

Capabilities são emitidas genericamente como:

```nix
kryonix.features.<category>.<feature> = true;
```

### Evidência: rede

O translator emite management e WAN apenas quando `plan.network` existe. WAN só é traduzida quando `plan.network.wan` existe.

PPPoE gera referência a arquivo:

```nix
networking.pppoe.<iface>.passwordFile = "/etc/kryonix/secrets/pppoe-<iface>";
```

A senha não é inserida no Nix gerado.

### Conclusão

**STATUS: PARTIAL**

O translator tem proteção correta contra vazamento de senha e já tem o ponto de integração Node Think, mas não possui uma validação interna para impedir:

```text
Node Think ativo sem WAN
Node Think ativo sem hostId
```

A recomendação é manter essas regras no domínio/validador, não espalhá-las apenas no translator. O translator deve receber um plano já validado e gerar uma saída determinística.

---

## E8 — Fluxo de persistência e tradução no endpoint V2

### Evidência

As rotas V2 incluem:

```text
POST /api/v2/plan
POST /api/v2/secrets
POST /api/v2/dry-run
POST /api/v2/install
```

`POST /api/v2/plan` desserializa diretamente para `InstallPlanV2` e chama o serviço de persistência.

O serviço chama:

```rust
validate_plan_capabilities(plan)?;
```

A geração Nix no fluxo de instalação chama:

```rust
kryx::services::translator::generate_nix_config(&plan)
```

### Conclusão

**STATUS: CONFIRMED**

Existe um gate backend de capabilities antes da persistência e existe geração Nix posterior no fluxo de instalação. A nova validação cruzada Node Think/WAN deve entrar no contrato/domain antes da persistência, para que planos inválidos não recebam digest como se fossem válidos.

---

# Diagnóstico consolidado

## O que já está alinhado

- DHCP, Static e PPPoE existem no modelo Rust de WAN.
- PPPoE mantém a senha fora do `InstallPlanV2`.
- `virtualization.incus` continua separado conceitualmente de Node Think.
- O translator possui saída especializada para `node.thinkServer`.
- Há validações Nix de WAN no subsistema de Node, mas em contrato diferente do V2 do installer.

## Desalinhamentos confirmados

1. O módulo Nix atual exige `hostId` sempre que Node Think está ativo.
2. O módulo Nix atual assume ZFS e datasets fixos quando Node Think está ativo.
3. O Rust possui `nodeThink`, mas o JSON Schema não possui `nodeThink`.
4. O frontend não monta `nodeThink`.
5. `isThinkServer` ainda é o campo principal usado no frontend.
6. WAN é opcional no Rust, schema e frontend.
7. Não existe validação cruzada Node Think → WAN obrigatória.
8. A camada Nix de Node possui `nodeParams.wan*`, mas a ponte com `InstallPlanV2.network.wan` ainda precisa ser desenhada.
9. `hostId` condicional por filesystem simples não pode ser implementado isoladamente no Rust enquanto o módulo Nix continuar com `hostId` obrigatório e filesystem ZFS fixo.

# Decisões necessárias no gate do KCR

Antes da implementação, Gabriel precisa aprovar explicitamente:

1. Node Think continuará sempre baseado no módulo ZFS atual, ou o módulo ganhará um modo local ext4/btrfs?
2. “ZFS clusterizado/distribuído” será um campo explícito do contrato, uma topologia de storage existente ou uma capability separada?
3. `hostId` será `Option<String>` no Rust, ou continuará `String` com validação condicional antes da tradução?
4. O contrato canônico será `nodeThink` e `isThinkServer` ficará somente como compatibilidade temporária?
5. WAN obrigatória será exigida somente para `nodeThink.enable`, independentemente de `network` existir?
6. DHCP e PPPoE são os únicos uplinks permitidos na Frente 1, deixando WAN Static fora do requisito operacional?

# Critério para liberar implementação

A implementação só pode começar depois de existir uma decisão para os seis pontos acima e depois que o KCR for aprovado.

Nenhuma alteração de código foi feita nesta auditoria.
