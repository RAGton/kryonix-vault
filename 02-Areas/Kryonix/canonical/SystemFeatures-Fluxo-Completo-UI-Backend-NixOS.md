---
type: canonical-architecture-note
project: Kryonix
status: active
created: 2026-08-01
updated: 2026-08-01
area: Kryonix
scope:
  - installer
  - frontend
  - backend
  - capabilities
  - nixos
  - kve
  - node-think
tags: [kryonix, features, systemfeatures, installer, react, rust, nixos, kve, node-think]
links:
  - "[[ADR-001-feature-tree-unification]]"
  - "[[EXISTING_FEATURES_CATALOG]]"
  - "[[Installer UI Flow]]"
  - "[[NixOS Flakes]]"
  - "[[MOC - Installer]]"
  - "[[MOC - Architecture]]"
---

# SystemFeatures — fluxo completo da tela até o NixOS

## Objetivo

Esta nota explica, passo a passo, como a tela de recursos do sistema funciona no ecossistema Kryonix — desde a interação do usuário no frontend do installer até a geração das diretivas declarativas que chegam ao NixOS.

A cadeia completa é:

```text
usuário
  ↓
SystemFeatures.jsx
  ↓
FEATURE_CATALOG / PROFILE_CATALOG
  ↓
wizard.selectedFeatures
  ↓
buildInstallPlanPayload()
  ↓
InstallPlanV2.features
  ↓
JSON Schema + validação Rust
  ↓
capabilities.json / capability registry
  ↓
crates/kryx/src/services/translator.rs
  ↓
features.generated.nix ou configuração Nix gerada
  ↓
modules/nixos/features/*
  ↓
kryonix.features.<domínio>.<feature>
  ↓
configuração final do NixOS
```

> Esta nota documenta o comportamento encontrado na auditoria de 2026-08-01. Ela diferencia o comportamento já confirmado das decisões ainda pendentes, principalmente na convergência de Node Think, KVE e Desktop.

---

## 1. Conceitos fundamentais

Antes de acompanhar o fluxo, é importante separar quatro conceitos que aparecem juntos, mas não são a mesma coisa.

### 1.1 Perfil

Um perfil é uma seleção conveniente de várias capabilities.

Exemplos atuais no frontend:

- `desktop`;
- `development`;
- `gamer`;
- `server`;
- `ai-local`;
- `full`;
- `custom`.

O perfil é principalmente uma abstração de UX. Ele ajuda o usuário a começar com uma combinação de recursos, mas não é enviado como entidade principal ao backend no `InstallPlanV2` atual.

```text
perfil Desktop
  ↓
lista de capabilities
  ↓
features.desktop.plasma = true
features.desktop.audio = true
features.remote.openssh = true
```

### 1.2 Capability

Capability é uma capacidade individual que pode ser ativada ou desativada.

Exemplos:

- `desktop.plasma`;
- `desktop.audio`;
- `gamer.steam`;
- `storage.srv-data`;
- `virtualization.incus`;
- `ai.ollama`.

A capability possui metadados como:

- ID canônico;
- `wireKey`;
- domínio;
- nível;
- dependências;
- conflitos;
- risco;
- status;
- motivo de bloqueio ou parcialidade.

### 1.3 Role ou modo de instalação

Node Think não é apenas uma feature comum. Ele representa um modo/role de instalação com requisitos próprios, como `hostId` e integração com `node.thinkServer`.

O contrato atual ainda carrega duas ideias concorrentes:

```text
isThinkServer
nodeThink.enable + nodeThink.hostId
```

O translator já usa `nodeThink` como caminho efetivo para ativar o módulo Nix.

### 1.4 Opção NixOS

A opção NixOS é a configuração declarativa final consumida pelos módulos do motor Kryonix.

Exemplos:

```nix
kryonix.features.desktop.plasma = true;
kryonix.features.virtualization.incus = true;
node.thinkServer.enable = true;
node.thinkServer.hostId = "...";
```

A capability não é a opção NixOS. Ela é o contrato intermediário que permite chegar à opção declarativa correta.

---

## 2. Onde a tela existe

Arquivo principal:

```text
repos/kryxd/ui/src/pages/SystemFeatures.jsx
```

Arquivos diretamente relacionados:

```text
repos/kryxd/ui/src/data/featureCatalog.js
repos/kryxd/ui/src/data/profileCatalog.js
repos/kryxd/ui/src/state/wizardState.js
repos/kryxd/ui/src/utils/installPlan.js
repos/kryxd/ui/src/generated/capabilities.js
repos/kryxd/ui/src/generated/installPlanSchema.js
repos/kryxd/schemas/capabilities.json
repos/kryxd/schemas/install-plan.schema.json
repos/kryxd/crates/kryx/src/domain/config.rs
repos/kryxd/crates/kryx/src/domain/capabilities.rs
repos/kryxd/crates/kryx/src/services/translator.rs
repos/kryxd/src/services/target_tree.rs
```

A tela faz parte do fluxo geral do installer:

```text
Welcome
Network
Disks
Machine Profile
Profile
Source
Host Selection
Remote Access
System Features
User Features
Summary
Install
```

A tela `SystemFeatures` não executa a instalação. Ela altera o draft do wizard. A execução ocorre posteriormente, quando o draft é serializado e enviado ao backend.

---

## 3. Passo a passo da interação no frontend

### Passo 1 — O wizard cria o estado inicial

O estado persistente do wizard contém campos como:

```js
profileId
selectedFeatures
isThinkServer
selectedDisks
storageMode
network fields
```

O valor inicial atual inclui:

```js
profileId: 'desktop'
selectedFeatures: []
isThinkServer: false
```

A lista de campos permitidos é controlada por:

```text
ui/src/state/wizardState.js
```

A tela recebe duas propriedades principais:

```jsx
SystemFeatures({ wizard, onChange })
```

- `wizard` contém o estado atual;
- `onChange` atualiza somente os campos permitidos do wizard.

### Passo 2 — A tela carrega o catálogo de features

O componente importa:

```jsx
import { FEATURE_CATALOG } from '../data/featureCatalog.js';
import { PROFILE_CATALOG, getFeaturesForProfile } from '../data/profileCatalog.js';
```

Ele filtra somente features de nível de sistema:

```js
const systemFeatures = FEATURE_CATALOG.filter(
  feature => feature.level === 'system'
);
```

Isso significa que `SystemFeatures.jsx` não deveria exibir features de usuário, como algumas configurações de Home Manager.

### Passo 3 — A UI transforma a seleção em um Set

O estado usa uma lista de IDs:

```js
wizard.selectedFeatures = [
  'desktop.plasma',
  'desktop.audio',
  'virtualization.incus'
]
```

Para consulta rápida, a tela cria:

```js
const selectedSet = new Set(wizard.selectedFeatures || []);
```

Esse Set é usado para:

- marcar cards ativos;
- contar features;
- verificar dependências;
- identificar se o KVE está selecionado;
- calcular disco e RAM estimados.

### Passo 4 — O usuário escolhe um perfil

Ao selecionar um perfil, a tela chama:

```js
getFeaturesForProfile(profileId)
```

Depois atualiza:

```js
onChange({
  profileId,
  selectedFeatures: defaultFeatures
})
```

O perfil substitui a seleção atual de features pelo conjunto padrão definido no `PROFILE_CATALOG`.

Exemplo conceitual:

```text
perfil gamer
  ↓
desktop.plasma
desktop.audio
desktop.bluetooth
gamer.steam
gamer.gamemode
gamer.mangohud
gamer.proton
gamer.controllers
security.firewall
remote.openssh
```

### Passo 5 — O usuário aplica um preset

Os presets implementados no `SystemFeatures.jsx` são:

```text
desktop-standard
desktop-ai
desktop-gamer
kve-server
```

O preset não altera features de usuário. Ele remove/ignora features de nível de sistema anteriores e combina o conjunto novo com as features de outros níveis.

O preset KVE atual seleciona:

```js
virtualization.incus
virtualization.podman
storage.srv-data
security.firewall
remote.openssh
observability.prometheus
```

A escolha de `storage.srv-data` é importante porque o registry atual declara que `virtualization.incus` exige essa capability.

### Passo 6 — O usuário clica numa feature

O fluxo de toggle é:

```text
handleToggle(feature)
  ↓
verifica status
  ↓
confirma partial, se necessário
  ↓
applyToggle(feature.id)
```

Features `stub` e `legacy` são bloqueadas pela UI.

Features `partial` abrem uma confirmação antes da ativação.

Para uma feature normal, a UI adiciona ou remove o ID:

```js
newSelected.add(featureId)
newSelected.delete(featureId)
```

### Passo 7 — Dependências podem ser adicionadas automaticamente

Ao ativar uma feature com `requires`, a UI procura as dependências no catálogo e adiciona as que não estão bloqueadas.

Exemplo:

```text
virtualization.incus
  requires:
    storage.srv-data
```

A intenção da UI é transformar:

```text
usuário escolhe virtualization.incus
```

em:

```text
virtualization.incus
storage.srv-data
```

Mesmo com essa automação, o backend também valida as dependências. A validação frontend nunca deve ser considerada suficiente.

### Passo 8 — A tela calcula indicadores visuais

A tela calcula:

- quantidade de features ativas;
- disco estimado;
- maior requisito de RAM;
- necessidade de `/srv/data`;
- presença do KVE;
- necessidade de GPU.

Esses indicadores são informativos. Eles não substituem as validações do backend, do storage planner ou do NixOS.

### Passo 9 — O usuário confirma e avança

A tela não envia diretamente o plano final ao backend. O estado continua no wizard.

A serialização ocorre mais tarde, no fluxo de execução da instalação.

---

## 4. Da lista de IDs ao payload `InstallPlanV2`

### Passo 10 — `buildInstallPlanPayload` recebe o draft

Arquivo:

```text
ui/src/utils/installPlan.js
```

A função principal é:

```js
buildInstallPlanPayload(draftInput)
```

Ela normaliza o draft e monta o contrato V2.

### Passo 11 — O frontend cria buckets de domínio

O payload não recebe diretamente uma lista como:

```json
{
  "selectedFeatures": ["desktop.plasma"]
}
```

O frontend cria:

```json
{
  "features": {
    "desktop": {},
    "virtualization": {},
    "storage": {},
    "ai": {},
    "server": {},
    "security": {},
    "remote": {}
  }
}
```

### Passo 12 — O ID completo é dividido em domínio e chave

Para cada ID:

```text
desktop.plasma
```

O frontend separa:

```text
domain = desktop
shortKey = plasma
```

E gera:

```json
{
  "desktop": {
    "plasma": true
  }
}
```

Para:

```text
virtualization.incus
```

gera:

```json
{
  "virtualization": {
    "incus": true
  }
}
```

Regra importante:

```text
features[domain][wireKey] = true
```

O backend não espera a lista bruta de IDs no payload V2.

### Passo 13 — O frontend deriva `/srv/data`

O builder determina se `/srv/data` deve ser habilitado com base em features e profiles.

Atualmente, a presença de recursos como:

```text
ai.ollama
ai.kryonix-brain
ai.neo4j
ai.lightrag
ai.open-webui
storage.srv-data
```

pode fazer `enableSrvData` ser considerado verdadeiro durante a montagem do plano.

O profile `server` possui uma regra diferente: ele recomenda `/srv/data`, mas não necessariamente o ativa sozinho em todos os caminhos.

Esse tipo de regra precisa continuar sendo revisado porque mistura:

- decisão de UI;
- requisito de storage;
- comportamento do profile;
- dependência de capability.

### Passo 14 — O frontend monta o restante do plano

O `InstallPlanV2` gerado inclui:

```json
{
  "version": 2,
  "isThinkServer": false,
  "repository": {
    "coreUrl": "...",
    "upstreamUrl": "...",
    "downstreamUrl": "...",
    "branch": "main"
  },
  "network": null,
  "storage": {},
  "features": {}
}
```

O payload também inclui storage e, quando configurado, rede.

Secrets não entram no plano. Senhas são enviadas por um payload separado de secrets e não devem aparecer em `features.generated.nix` ou no Nix Store.

### Passo 15 — O JSON Schema valida no frontend

O frontend valida o payload contra:

```text
schemas/install-plan.schema.json
```

A versão gerada usada no bundle é:

```text
ui/src/generated/installPlanSchema.js
```

O schema exige, entre outros:

```text
version
isThinkServer
repository
storage
features
```

O schema rejeita propriedades desconhecidas no nível definido por `additionalProperties: false`.

Essa validação verifica formato e estrutura. Ela não substitui a validação semântica do Rust.

---

## 5. O backend recebe e valida o plano

### Passo 16 — O plano chega ao endpoint de instalação

A API envia o payload para o backend por meio de:

```text
POST /api/v2/plan
```

A chamada frontend está em:

```text
ui/src/utils/installerApi.js
```

O backend recebe o JSON e desserializa para `InstallPlanV2`.

### Passo 17 — Rust aplica o contrato de domínio

O tipo Rust está em:

```text
crates/kryx/src/domain/config.rs
```

O contrato atual possui:

```rust
pub features: BTreeMap<String, BTreeMap<String, bool>>
```

O `rename_all = "camelCase"` faz a ponte entre nomes Rust e JSON.

Exemplo:

```rust
node_think
```

vira:

```json
nodeThink
```

### Passo 18 — O backend valida a rede e o storage

O backend valida, entre outros pontos:

- interface de gerenciamento;
- prefix length;
- hostname;
- IPv4 estático;
- gateway;
- DNS;
- WAN;
- PPPoE user;
- topologia de storage;
- requisitos de ZFS;
- requisitos de BTRFS.

O `InstallPlanV2` atual não é apenas um catálogo de features. Ele também contém o contrato de instalação física ou virtual.

### Passo 19 — Rust valida as capabilities

Arquivo:

```text
crates/kryx/src/domain/capabilities.rs
```

A fonte de dados é:

```text
schemas/capabilities.json
```

A função valida:

```text
validate_feature_selection(&plan.features)
```

Para cada entrada ativa, o backend:

1. combina `domain` e `wireKey`;
2. localiza o ID no registry;
3. rejeita capability desconhecida;
4. rejeita capability `unsupported`;
5. verifica `requires`;
6. verifica `conflicts`.

Exemplo:

```json
{
  "virtualization": {
    "incus": true
  }
}
```

vira o ID canônico:

```text
virtualization.incus
```

E o registry exige:

```text
storage.srv-data
```

Se a dependência não estiver ativa, o backend rejeita o plano mesmo que a UI tenha deixado passar.

---

## 6. O capability registry

### 6.1 Fonte atual

O registry do `kryxd` está em:

```text
repos/kryxd/schemas/capabilities.json
```

O Rust inclui esse JSON em tempo de compilação:

```rust
include_str!("../../../../schemas/capabilities.json")
```

A UI possui uma cópia gerada:

```text
ui/src/generated/capabilities.js
```

Essa cópia não deve ser tratada como uma fonte independente. Ela precisa ser regenerada a partir do contrato canônico.

### 6.2 Campos da capability

Uma definição contém campos como:

```json
{
  "id": "virtualization.incus",
  "wireKey": "incus",
  "level": "system",
  "domain": "virtualization",
  "name": "KVE — Kryonix Virtualization Engine (Incus)",
  "requires": ["storage.srv-data"],
  "conflicts": ["virtualization.libvirt"],
  "status": "ready"
}
```

### 6.3 Estados

O frontend conhece estados como:

```text
ready
partial
stub
legacy
```

O registry Rust conhece principalmente:

```text
ready
partial
stub
unsupported
```

Essa diferença de vocabulário é uma pendência de unificação. `legacy` é tratado especialmente pela UI, mas não possui o mesmo significado formal no enum backend.

---

## 7. Node Think

### 7.1 Conceito

Node Think é o nome atual do papel que substitui Ragos Think no ecossistema.

Definição conceitual:

```text
Node Think = infraestrutura centralizada, diskless ou orientada a node
```

Não deve ser confundido com:

```text
KVE = virtualização e orquestração Incus
Desktop = estação de trabalho local
```

### 7.2 Contrato backend atual

O domínio Rust possui:

```rust
pub struct NodeThinkPlan {
    pub enable: bool,
    pub host_id: String,
}
```

O `hostId` identifica o node no módulo Nix.

### 7.3 Tradução atual

Quando `nodeThink.enable` é verdadeiro, o translator emite:

```nix
node.thinkServer.enable = true;
node.thinkServer.hostId = "...";
```

### 7.4 Problema atual

O frontend ainda trabalha principalmente com:

```text
isThinkServer
```

Enquanto o translator usa:

```text
nodeThink.enable
nodeThink.hostId
```

Portanto, o caminho canônico ainda não está totalmente fechado.

Estado atual:

```text
isThinkServer = flag legada/transitória
nodeThink = estrutura efetivamente usada pelo translator
```

### 7.5 Requisito de convergência

Para fechar o contrato, o futuro fluxo deve definir:

```text
Como o usuário escolhe Node Think na UI?
Onde o hostId é informado ou descoberto?
Quando storage ZFS é obrigatório?
Quais requisitos de rede são obrigatórios?
Como Node Think convive com KVE?
```

Não se deve resolver isso criando uma capability artificial sem validar primeiro o contrato de role e instalação.

---

## 8. KVE — Kryonix Virtualization Engine

### 8.1 Conceito

KVE é o subsistema de virtualização e orquestração do Kryonix.

No estado atual, sua ativação é representada principalmente por:

```text
virtualization.incus
```

O backend nomeia essa capability como:

```text
KVE — Kryonix Virtualization Engine (Incus)
```

### 8.2 Fluxo atual

```text
usuário clica no preset KVE
  ↓
virtualization.incus
  ↓
features.virtualization.incus = true
  ↓
registry localiza virtualization.incus
  ↓
exige storage.srv-data
  ↓
translator gera kryonix.features.virtualization.incus = true
  ↓
módulo NixOS de virtualização aplica Incus
```

### 8.3 Dependência de storage

O KVE atual exige:

```text
storage.srv-data
```

Essa dependência representa a necessidade de um volume persistente para dados de instâncias, imagens, pools ou estado relacionado à virtualização.

### 8.4 Conflito com Libvirt

O registry atual declara:

```text
virtualization.incus conflicts with virtualization.libvirt
```

Portanto, a combinação não deve ser aceita automaticamente.

### 8.5 Limite do modelo atual

O translator trata KVE de maneira genérica como uma capability Nix:

```nix
kryonix.features.virtualization.incus = true;
```

Ele ainda não representa, no `InstallPlanV2.features`, toda a configuração de:

- nodes;
- pools;
- imagens;
- VMs;
- containers;
- remotes;
- cluster Incus;
- políticas de rede;
- storage do KVE.

Essas partes pertencem a contratos KVE específicos e não devem ser escondidas dentro de um booleano de capability.

---

## 9. Desktop

### 9.1 Conceito

Desktop é o perfil de estação de trabalho local.

Ele pode incluir:

- KDE Plasma;
- áudio;
- Bluetooth;
- impressão;
- otimizações locais;
- multimídia;
- gaming;
- desenvolvimento;
- IA local, quando selecionada.

### 9.2 Fluxo atual

```text
perfil desktop
  ↓
desktop.plasma
desktop.audio
desktop.bluetooth
security.firewall
remote.openssh
  ↓
features.desktop.*
features.security.*
features.remote.*
  ↓
translator genérico
  ↓
kryonix.features.desktop.*
```

### 9.3 Desktop Gamer

Gaming é uma especialização de Desktop no catálogo atual.

Exemplos:

```text
desktop.gamer
gamer.steam
gamer.gamemode
gamer.mangohud
gamer.proton
gamer.controllers
```

Mesmo quando o ID começa com `gamer.`, o catálogo atual usa o domínio `desktop` para algumas dessas features. O registry também mantém parte dessa composição no domínio desktop.

Esse ponto deve ser tratado com cuidado na futura SSoT, porque o prefixo do ID e o domínio do wire contract precisam continuar semanticamente previsíveis.

### 9.4 Desktop não é enviado como perfil ao backend

O backend não recebe:

```text
profileId: desktop
```

O backend recebe apenas o resultado:

```json
{
  "features": {
    "desktop": {
      "plasma": true,
      "audio": true,
      "bluetooth": true
    }
  }
}
```

Isso significa:

```text
perfil = conveniência da UI
capabilities = contrato backend
```

Essa separação é válida, mas deve ser documentada para evitar que o backend seja obrigado a conhecer todos os presets do frontend.

---

## 10. O translator Rust

Arquivo:

```text
crates/kryx/src/services/translator.rs
```

Função principal:

```rust
generate_nix_config(plan: &InstallPlanV2)
```

### 10.1 Cabeçalho

O translator começa a configuração como um módulo Nix:

```nix
{ config, lib, ... }:
{
```

### 10.2 Node Think

É tratado de forma especializada:

```nix
node.thinkServer.enable = true;
node.thinkServer.hostId = "...";
```

### 10.3 Storage

O translator emite opções como:

```nix
kryonix.storage.topology = "single";
kryonix.storage.systemDisks = [ "/dev/sda" ];
kryonix.storage.dataDisks = [ "/dev/sdb" ];
kryonix.storage.root.filesystem = "zfs";
kryonix.storage.data.filesystem = "btrfs";
kryonix.storage.zfs.userRefquota = "100G";
kryonix.storage.btrfs.userQgroupLimit = "100G";
```

A seleção da feature não substitui a validação de storage. O Disko e o storage planner possuem contratos próprios.

### 10.4 Capabilities

O bloco de capabilities é genérico:

```rust
for (category, feature_map) in &plan.features {
    for (feature, enabled) in feature_map {
        if *enabled {
            config.push_str(&format!(
                "  kryonix.features.{}.{} = true;\\n",
                category, feature
            ));
        }
    }
}
```

Isso transforma:

```json
"features": {
  "desktop": {
    "plasma": true
  },
  "virtualization": {
    "incus": true
  }
}
```

em:

```nix
kryonix.features.desktop.plasma = true;
kryonix.features.virtualization.incus = true;
```

### 10.5 Rede

O translator trata rede separadamente e emite diretivas NixOS nativas:

```nix
networking.hostName = "...";
networking.interfaces.enp1s0.useDHCP = true;
networking.interfaces.enp1s0.ipv4.addresses = [ ... ];
networking.nameservers = [ ... ];
networking.defaultGateway = "...";
networking.pppoe.enp2s0.passwordFile = "/etc/kryonix/secrets/pppoe-enp2s0";
```

Senha PPPoE não deve aparecer no arquivo Nix. O translator emite apenas a referência ao arquivo runtime.

---

## 11. Da configuração gerada até os módulos NixOS

### Passo 20 — O target tree prepara os arquivos

O backend prepara uma árvore de instalação contendo arquivos gerados, incluindo:

```text
generated/features.generated.nix
generated/users.generated.nix
generated/network.generated.nix
generated/hardware.generated.nix
```

O arquivo de features entra no target flake como uma camada de configuração gerada.

### Passo 21 — O target flake importa as configurações geradas

O target flake combina:

```text
configuração base
módulos Kryonix
features.generated.nix
users.generated.nix
network.generated.nix
hardware.generated.nix
features.local.nix, quando aplicável
```

`features.local.nix` pertence ao usuário e não deve ser sobrescrito pelo installer.

### Passo 22 — O namespace público é resolvido

O namespace público do motor é:

```nix
kryonix.features.*
```

Os módulos NixOS declaram opções, normalmente com:

```nix
options.kryonix.features.<domain>.<feature>.enable
```

E aplicam a configuração com:

```nix
config = lib.mkIf cfg.enable {
  ...
};
```

A convenção canônica do Kryonix é:

- `enable = false` por padrão;
- `lib.mkIf` para ativação condicional;
- `lib.mkDefault` quando o downstream deve poder sobrescrever defaults;
- opções tipadas com `lib.mkOption`.

### Passo 23 — O módulo executa a implementação

Exemplo conceitual:

```nix
kryonix.features.desktop.plasma = true;
```

ativa o módulo correspondente, que pode configurar:

- Plasma;
- display manager;
- sessão Wayland;
- pacotes desktop;
- serviços gráficos;
- integração Home Manager, quando aplicável.

Outro exemplo:

```nix
kryonix.features.virtualization.incus = true;
```

ativa a implementação do Incus/KVE, que pode configurar:

- serviço Incus;
- cliente;
- permissões;
- bridge ou rede;
- storage/pools;
- integração com os serviços do Kryonix.

A capability só é correta se o módulo NixOS correspondente realmente existir e usar o mesmo namespace.

### Passo 24 — O Flake avalia a configuração

Antes de uma ativação real, o sistema deve avaliar:

```bash
nix flake check --keep-going
```

ou construir o alvo:

```bash
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link -L
```

O objetivo dessa etapa é detectar:

- opção Nix inexistente;
- conflito entre módulos;
- sintaxe inválida;
- dependência ausente;
- caminho de import inválido;
- namespace divergente;
- erro de tipo.

### Passo 25 — Só depois ocorre ativação

A geração do NixOS precisa ser validada antes de qualquer ativação.

A ativação real altera a geração do sistema e exige autorização operacional própria. Uma auditoria ou build bem-sucedido não equivale a autorização para `switch`.

---

## 12. Relação entre upstream, installer e downstream

### Upstream/Core — `kryonix`

Responsável por:

- schema das features;
- registry canônico;
- módulos NixOS;
- namespace `kryonix.features.*`;
- implementação declarativa.

### Installer/Daemon — `kryxd`

Responsável por:

- UI React/Vite;
- catálogo ou consumo do registry;
- `InstallPlanV2`;
- validação de entrada;
- tradução para configuração Nix;
- geração da árvore de destino.

### Downstream — `kryonixos`

Responsável por:

- hosts reais;
- hardware;
- usuários;
- ativação das features adequadas para cada host;
- particularidades do ambiente.

O installer não deve inventar uma feature que não exista no upstream. O downstream não deve depender de uma opção que o core não exporta. O translator não deve emitir um caminho Nix que não exista no módulo carregado.

---

## 13. Matriz de alinhamento atual

| Conceito | UI | Payload V2 | Registry | Translator | Nix | Estado |
|---|---|---|---|---|---|---|
| Desktop Plasma | `desktop.plasma` | `features.desktop.plasma` | `desktop.plasma` | genérico | `kryonix.features.desktop.plasma` | Alinhado |
| Desktop Audio | `desktop.audio` | `features.desktop.audio` | `desktop.audio` | genérico | `kryonix.features.desktop.audio` | Alinhado |
| Desktop Gamer | `desktop.gamer` + `gamer.*` | buckets de domínio | desktop/gamer | genérico | `kryonix.features.*` | Híbrido, revisar taxonomia |
| KVE/Incus | `virtualization.incus` | `features.virtualization.incus` | `virtualization.incus` | genérico | `kryonix.features.virtualization.incus` | Alinhado como ativação |
| KVE orchestration | preset KVE | não há bloco específico | não há modelo completo | não há tradução específica | depende de outras APIs/módulos | Pendente |
| Node Think | `isThinkServer` | `isThinkServer`; `nodeThink` não é montado pela tela | não há capability node | usa `nodeThink` | `node.thinkServer.*` | Desalinhado |
| Ragos | referências antigas/documentais | não deveria aparecer | não existe | não existe | deve ser substituído por Node Think | Migração semântica |
| Perfil Desktop | `profileId` | não enviado como perfil | não conhece perfil | não conhece perfil | só recebe capabilities | Abstração de UI |

---

## 14. O que é validado em cada camada

### Tela React

Valida ou controla:

- seleção visual;
- filtros;
- dependências imediatas;
- confirmação de partial;
- bloqueio de stub/legacy;
- presets;
- estimativas de hardware/storage.

Não deve ser a única autoridade para:

- segurança;
- storage destrutivo;
- existência real de opção Nix;
- compatibilidade de host;
- execução de instalação.

### `installPlan.js`

Valida ou monta:

- estrutura V2;
- normalização dos campos;
- features por domínio;
- storage;
- rede;
- separação de secrets;
- requisitos de quota;
- bloqueios conhecidos do contrato.

### JSON Schema

Valida:

- tipos;
- campos obrigatórios;
- formato;
- propriedades extras;
- enumerações estruturais;
- versão do plano.

### Rust domain

Valida:

- desserialização tipada;
- regras semânticas de rede;
- regras de storage;
- versão do plano;
- campos desconhecidos;
- dependências e conflitos de capabilities.

### Translator

Valida ou gera:

- diretivas declarativas;
- namespaces Nix;
- Node Think especializado;
- storage;
- rede;
- referências seguras para secrets.

### NixOS

Valida:

- se a opção existe;
- se o tipo está correto;
- se os módulos são compatíveis;
- se a composição final avalia;
- se o sistema pode ser construído.

---

## 15. Regras de segurança

### Nunca colocar secrets em features

Não colocar em `InstallPlanV2.features`:

- senha;
- token;
- API key;
- cookie;
- chave SSH privada;
- senha PPPoE.

### Nunca colocar secrets no Nix Store

Não gerar:

```nix
password = "senha-real";
```

Preferir referência runtime:

```nix
passwordFile = "/etc/kryonix/secrets/<nome>";
```

### Nunca confiar apenas na UI

A UI pode ser manipulada, estar desatualizada ou ter um catálogo divergente. O backend deve sempre revalidar o plano.

### Nunca ativar automaticamente mudanças perigosas

Features relacionadas a:

- boot;
- kernel;
- storage;
- rede;
- SSH;
- firewall;
- bridge;
- Incus;
- GPU;

precisam de validação específica e plano de rollback.

---

## 16. Pendências canônicas

### P1 — Fechar Node Think

Definir se Node Think será:

```text
role de instalação
profile
capability
ou combinação de role + capabilities
```

A recomendação atual é:

```text
Node Think = role/plano especializado
KVE = capability/subsistema de virtualização
Desktop = profile composto por capabilities
```

### P2 — Remover a ambiguidade `isThinkServer` versus `nodeThink`

O frontend precisa gerar o contrato usado pelo translator ou o backend precisa fornecer uma migração formal e temporária.

### P3 — Validar `hostId`

Quando `nodeThink.enable` for verdadeiro, o backend deve garantir que `hostId` seja válido e não vazio.

### P4 — Definir o modelo completo do KVE

`virtualization.incus` pode continuar sendo a capability de ativação, mas operações de:

- instância;
- imagem;
- storage;
- rede;
- cluster;

devem possuir contratos próprios, sem sobrecarregar um booleano.

### P5 — Fechar SSoT do catálogo

A decisão arquitetural existente determina que o installer deve consumir o Feature Registry, e não manter catálogo hardcoded divergente.

### P6 — Unificar status

Alinhar os vocabulários:

```text
ready
partial
stub
legacy
unsupported
```

e definir qual camada é responsável por cada transição.

### P7 — Corrigir derivações de profile IDs

Auditar nomes como:

```text
desktop versus desktop-plasma
development versus developer
full versus kryonix-full
gamer versus profile-gamer
```

A divergência pode fazer o catálogo exibir um perfil que não encontra corretamente as features declaradas em `featureCatalog.js`.

---

## 17. Procedimento de auditoria para qualquer nova feature

Antes de adicionar uma feature, seguir esta sequência:

1. Definir o conceito: profile, capability, role ou opção Nix.
2. Confirmar o namespace canônico no upstream.
3. Confirmar o arquivo/módulo Nix que implementa a opção.
4. Adicionar ou revisar a definição no registry.
5. Confirmar `id`, `wireKey`, `domain` e `level`.
6. Definir dependências e conflitos.
7. Definir status e risco.
8. Confirmar presença no catálogo frontend.
9. Confirmar conversão para `features[domain][wireKey]`.
10. Confirmar aceitação pelo `InstallPlanV2`.
11. Confirmar validação backend.
12. Confirmar saída do translator.
13. Confirmar avaliação Nix.
14. Confirmar teste de regressão.
15. Registrar a decisão no Vault.

Uma feature só está realmente pronta quando toda a cadeia estiver alinhada:

```text
UI
→ payload
→ schema
→ registry
→ Rust
→ translator
→ Nix module
→ avaliação
→ runtime validado
```

---

## 18. Comandos de inspeção recomendados

### Frontend

```bash
rg -n "FEATURE_CATALOG|PROFILE_CATALOG|selectedFeatures|buildInstallPlanPayload" \
  repos/kryxd/ui/src
```

### Contrato

```bash
rg -n "InstallPlanV2|features|nodeThink|isThinkServer" \
  repos/kryxd/crates repos/kryxd/schemas repos/kryxd/ui/src
```

### Registry

```bash
rg -n '"id"|"wireKey"|"requires"|"conflicts"|"status"' \
  repos/kryxd/schemas/capabilities.json
```

### Translator

```bash
rg -n "node.thinkServer|kryonix.features|networking\." \
  repos/kryxd/crates/kryx/src/services/translator.rs
```

### Upstream Nix

```bash
rg -n "kryonix\.features|mkOption|mkIf|registry" \
  repos/kryonix/modules repos/kryonix/flake.nix
```

### Validação estrutural

```bash
cd repos/kryxd/ui
npm test
npm run build
```

### Validação Rust

```bash
cd repos/kryxd
cargo test -p kryx
cargo test --lib
```

### Validação Nix

```bash
cd repos/kryonix
nix flake check --keep-going
```

> Os comandos acima são de validação e inspeção. Comandos de ativação, instalação, switch, reboot ou operações de storage possuem gates operacionais adicionais.

---

## 19. Resumo executivo

A tela `SystemFeatures` é uma camada de seleção e composição. Ela não é o NixOS e não é o backend.

O fluxo correto é:

```text
SystemFeatures.jsx
  escolhe IDs

installPlan.js
  converte IDs em features[domain][wireKey]

InstallPlanV2
  transporta o contrato de instalação

capabilities.json
  define o que cada capability significa

capabilities.rs
  valida desconhecidos, dependências e conflitos

translator.rs
  converte o plano em Nix declarativo

modules/nixos/features
  implementa as opções reais

NixOS
  avalia e constrói a geração
```

A taxonomia desejada deve permanecer:

```text
Node Think = role de infraestrutura centralizada/diskless
KVE = virtualização e orquestração baseada em Incus
Desktop = estação de trabalho e otimizações locais
```

Estado atual:

```text
Desktop: alinhado como composição de capabilities
KVE: alinhado para ativação Incus, incompleto para orquestração completa
Node Think: contrato ainda dividido entre isThinkServer e nodeThink
```

## Próxima ação recomendada

Antes da refatoração do JSX, fechar a decisão de contrato de Node Think e transformar esta nota em referência da Etapa 1 do KCR.

#tags
#kryonix #features #systemfeatures #installer #nixos #kve #node-think #architecture
