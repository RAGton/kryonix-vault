# KCR-Network-Features-V2 — Frente 1

## Node Think + WAN/Uplink Obrigatória

Data: 2026-08-01
Status: **PROPOSTA — AGUARDANDO APROVAÇÃO HUMANA**
Autonomia: L1 — documentação e planejamento
Tipo: Kryonix Change Request
Repos previstos:

- `repos/kryxd`
- `repos/kryonix`
- `repos/kryonix-vault`

Evidência principal:

- [[AUDIT]]
- [[../../02-Areas/Kryonix/canonical/SystemFeatures-Fluxo-Completo-UI-Backend-NixOS]]

---

## 1. Objetivo

Fechar o contrato industrial do modo **Node Think** no installer Kryonix, garantindo que:

```text
Node Think ativo
→ uplink/WAN obrigatória
→ DHCP ou PPPoE autenticado
→ contrato validado antes da persistência
→ translator recebe plano consistente
→ NixOS recebe somente diretivas compatíveis
```

Também tornar a obrigatoriedade de `hostId` uma regra explícita e coerente com o storage real, sem manter acoplamento artificial entre identidade do node e qualquer filesystem local.

---

## 2. Contexto arquitetural

A taxonomia oficial desta frente é:

```text
Node Think = node de infraestrutura centralizada/diskless, dependente do Control Plane
KVE = Kryonix Virtualization Engine, baseado em Incus e orquestração
Desktop = perfil de estação de trabalho e otimizações locais
```

A Frente 1 trata somente de Node Think e WAN. KVE e Desktop entram apenas como escopo de não regressão.

---

## 3. Estado atual confirmado

### 3.1 Frontend

O frontend usa principalmente:

```text
isThinkServer
```

O `SystemFeatures.jsx` não gera `nodeThink.enable` nem `nodeThink.hostId`.

`buildNetworkPlan()` considera WAN opcional e emite:

```json
"wan": null
```

quando não há interface WAN configurada.

### 3.2 Rust

`InstallPlanV2` já possui:

```rust
is_think_server: bool,
node_think: Option<NodeThinkPlan>,
network: Option<NetworkPlan>,
```

`NodeThinkPlan` atual:

```rust
pub struct NodeThinkPlan {
    pub enable: bool,
    pub host_id: String,
}
```

O validador atual valida rede somente quando `network` existe. Não valida as relações:

```text
nodeThink.enable → hostId
nodeThink.enable → network
nodeThink.enable → network.wan
```

### 3.3 Schema

O JSON Schema atual:

- exige `isThinkServer`;
- não declara `nodeThink`;
- permite `network = null`;
- permite `network.wan = null`.

### 3.4 NixOS

O módulo real está em:

```text
repos/kryonix/modules/node/think/think-server.nix
```

Ele atualmente:

- exige `hostId` como string sem default;
- aplica `networking.hostId` sempre que habilitado;
- habilita ZFS;
- assume datasets `zroot/srv-data/*`;
- não possui variante local ext4/btrfs;
- não valida WAN nesse módulo específico.

### 3.5 Translator

O translator:

- ignora a ativação por `isThinkServer`;
- usa `nodeThink`;
- sempre emite `node.thinkServer.hostId` quando `nodeThink.enable` é verdadeiro;
- emite WAN somente se `plan.network.wan` existir;
- protege a senha PPPoE usando `passwordFile`.

---

## 4. Invariantes propostas

As seguintes regras são o alvo da Frente 1, sujeitas ao gate humano abaixo.

### I1 — Node Think exige uplink

Se:

```text
nodeThink.enable == true
```

então:

```text
network != null
network.wan != null
```

A WAN deve usar um modo suportado:

```text
dhcp
pppoe
```

A modalidade `static` permanece fora do requisito mínimo desta frente, salvo decisão contrária.

### I2 — WAN deve ser distinta da LAN de management

```text
network.wan.interface != network.management.interface
```

### I3 — PPPoE nunca carrega senha no plano

O `InstallPlanV2` deve conter apenas:

```text
pppoeUser
```

A senha deve continuar exclusivamente no fluxo de secrets:

```text
InstallSecretsV2
→ endpoint de secrets
→ arquivo runtime protegido
→ passwordFile no Nix
```

### I4 — `hostId` depende do modelo final de Node Think/storage

A regra desejada é:

```text
Node Think + ZFS distribuído/clusterizado → hostId obrigatório
Node Think + filesystem local simples → hostId opcional ou omitido
```

Entretanto, essa regra não pode ser implementada apenas no Rust enquanto o módulo Nix atual continuar exigindo `hostId` e montando datasets ZFS fixos.

Portanto, o KCR deve primeiro decidir se haverá:

```text
modo Node Think ZFS
modo Node Think local
```

ou se Node Think continuará exclusivamente ZFS nesta primeira versão.

### I5 — `nodeThink` é o contrato canônico

A direção recomendada é:

```text
nodeThink = contrato canônico
isThinkServer = compatibilidade temporária, se necessário
```

O translator e o domínio devem convergir para um único caminho.

### I6 — Validação deve ocorrer antes do digest

Um plano inválido não deve ser persistido nem receber `planDigest` válido.

As invariantes Node Think/WAN devem ser verificadas antes de:

```text
persistência do plano
preparação do target tree
tradução Nix
qualquer ação destrutiva
```

---

## 5. Escopo de arquivos previsto

### Backend Rust — `kryxd`

Previstos para análise/alteração após aprovação:

```text
crates/kryx/src/domain/config.rs
crates/kryx/src/domain/mod.rs, se necessário
src/api/install.rs, se necessário
crates/kryx/src/services/translator.rs
```

Possíveis mudanças:

- modelagem de `NodeThinkPlan`;
- `host_id: Option<String>` ou campo equivalente;
- validação cruzada com storage;
- validação cruzada com rede;
- erros de domínio claros;
- testes unitários para combinações válidas e inválidas.

### JSON Schema

Previstos:

```text
schemas/install-plan.schema.json
ui/src/generated/installPlanSchema.js
```

A geração do arquivo JS deve seguir o procedimento real do repositório. Não editar generated file manualmente sem confirmar o gerador.

Possíveis mudanças:

- declarar `nodeThink`;
- declarar `hostId` opcional/condicional;
- expressar `if/then` para WAN obrigatória, quando compatível com o modelo final;
- manter `isThinkServer` somente se a compatibilidade for aprovada.

### Frontend

Previstos:

```text
ui/src/state/wizardState.js
ui/src/pages/SystemFeatures.jsx
ui/src/utils/installPlan.js
ui/src/tests/installPlan.test.js
ui/src/tests/utils/installPlan.test.js
```

Possíveis mudanças:

- adicionar estado explícito de Node Think;
- identificar o role sem depender de heurística de perfil genérico;
- bloquear avanço quando Node Think estiver ativo e WAN faltar;
- exigir usuário PPPoE quando o modo for PPPoE;
- não colocar senha no plano;
- manter Desktop, KVE e profiles existentes sem regressão.

### Core NixOS — `kryonix`

Previsto somente se a decisão aprovar Node Think local sem ZFS:

```text
modules/node/think/think-server.nix
```

Possíveis mudanças:

- tornar `hostId` opcional em um modo explicitamente definido;
- separar configuração ZFS da ativação geral do Node Think;
- evitar `networking.hostId` quando não houver necessidade;
- não montar datasets ZFS fixos em um modo local;
- adicionar assertions coerentes para cada modo.

Se Node Think continuar exclusivamente ZFS nesta frente, o módulo Nix não deve ser alterado por especulação.

---

## 6. Casos de teste obrigatórios

### Caso A — Desktop sem WAN

```text
profile = desktop
nodeThink.enable = false
network.wan = null
```

Esperado:

```text
válido, desde que as demais regras do plano sejam satisfeitas
```

### Caso B — KVE sem WAN

```text
KVE/Incus ativo
nodeThink.enable = false
network.wan = null
```

Esperado:

```text
não aplicar a obrigatoriedade Node Think
```

A dependência de storage do KVE continua sendo validada separadamente.

### Caso C — Node Think sem bloco de rede

```text
nodeThink.enable = true
network = null
```

Esperado:

```text
rejeitado antes da persistência
```

### Caso D — Node Think com LAN, sem WAN

```text
nodeThink.enable = true
network.management presente
network.wan = null
```

Esperado:

```text
rejeitado: Node Think exige uplink/WAN
```

### Caso E — Node Think com WAN DHCP

```text
nodeThink.enable = true
network.management presente
network.wan.mode = dhcp
```

Esperado:

```text
válido, desde que hostId/storage estejam coerentes com o modo aprovado
```

### Caso F — Node Think com PPPoE

```text
nodeThink.enable = true
network.wan.mode = pppoe
network.wan.pppoeUser preenchido
InstallSecretsV2.pppoePassword presente no canal de secrets
```

Esperado:

```text
válido
senha ausente do InstallPlanV2
senha ausente do Nix gerado
passwordFile presente na tradução
```

### Caso G — Node Think com PPPoE sem usuário

Esperado:

```text
rejeitado
```

### Caso H — WAN igual à management

Esperado:

```text
rejeitado
```

### Caso I — Node Think + ZFS distribuído sem hostId

Esperado:

```text
rejeitado
```

### Caso J — Node Think + filesystem local sem hostId

Esperado:

```text
resultado depende da decisão final do módulo Nix
```

Este caso não pode ser marcado como válido antes de existir suporte real no módulo `think-server.nix`.

---

## 7. Testes de tradução Nix

O translator deverá provar:

### Node Think habilitado

```nix
node.thinkServer.enable = true;
```

### Host ID quando requerido

```nix
node.thinkServer.hostId = "<valor-validado>";
```

### WAN DHCP

A saída deve conter a diretiva correspondente à interface WAN, sem credenciais PPPoE.

### WAN PPPoE

A saída deve conter:

```nix
networking.pppoe.<iface>.enable = true;
networking.pppoe.<iface>.username = "<user>";
networking.pppoe.<iface>.passwordFile = "/etc/kryonix/secrets/pppoe-<iface>";
```

E não deve conter:

```text
senha real
password = "..."
secret literal
```

### Plano inválido

O translator não deve ser usado como mecanismo primário para aceitar planos inválidos. A validação deve falhar antes dele.

---

## 8. Não objetivos da Frente 1

Não fazem parte deste KCR:

- Multi-LAN;
- Dual LAN;
- múltiplas interfaces de management;
- Link Aggregation;
- LACP/802.3ad;
- bonding;
- VLAN;
- trunking;
- bridge avançada;
- NetworkManager completo;
- migração geral de `Network.jsx`;
- Disko destrutivo;
- `mkfs`;
- `wipefs`;
- mudança em `/etc/kryonix`;
- mudança em `/etc/kryonixos`;
- `nixos-rebuild switch`;
- reboot;
- deploy de produção;
- alteração de secrets reais;
- criação de cluster Incus.

---

## 9. Riscos

### R1 — Módulo Nix contradiz a nova regra

O módulo atual é ZFS-cêntrico e exige `hostId`. Tornar o campo opcional no Rust sem alterar o Nix produziria configuração inválida.

### R2 — Schema e Rust divergentes

Adicionar `nodeThink` no Rust sem schema e frontend deixa o contrato inconsistente.

### R3 — WAN exigida globalmente por engano

A regra deve afetar Node Think, não Desktop ou KVE puro.

### R4 — Segredo PPPoE exposto

Qualquer mudança no builder ou translator deve preservar o canal separado de secrets.

### R5 — Compatibilidade legada

Remover `isThinkServer` sem migração pode quebrar drafts, testes e fluxos existentes.

### R6 — Falsa conclusão por build parcial

`npm test`, `cargo test` e `nix flake check` são gates diferentes. Nenhum deles sozinho prova integração completa.

---

## 10. Rollback

Como esta fase é apenas contrato e implementação em DEV:

- um commit por camada;
- nenhum commit misto entre `kryxd` e `kryonix`;
- nenhum arquivo em `/etc`;
- nenhum switch;
- reversão por commit específico;
- manter compatibilidade temporária somente se ela for testada.

Ordem recomendada de commits após aprovação:

```text
1. fix(kryxd-domain): validate Node Think uplink invariants
2. fix(kryxd-schema): declare nodeThink and conditional WAN contract
3. fix(kryxd-ui): enforce WAN for Node Think
4. fix(kryxd-translator): render validated Node Think contract
5. fix(kryonix-node): support approved local/ZFS modes, if required
```

A ordem exata depende da decisão sobre o módulo Nix.

---

## 11. Gate humano obrigatório

Antes de qualquer patch, aprovar explicitamente:

### Decisão D1 — Modelo Node Think

Escolher:

```text
A. Node Think continua exclusivamente ZFS nesta frente
B. Node Think terá modo ZFS e modo local ext4/btrfs
```

### Decisão D2 — `hostId`

Escolher:

```text
A. hostId continua obrigatório para todo Node Think
B. hostId é obrigatório apenas no modo ZFS/distribuído
C. hostId é fornecido por outro mecanismo fora do InstallPlanV2
```

### Decisão D3 — Campo canônico

Escolher:

```text
A. nodeThink canônico + isThinkServer compatibilidade temporária
B. isThinkServer continua canônico
C. outro modelo explicitamente documentado
```

### Decisão D4 — WAN

Confirmar:

```text
Node Think ativo exige network e network.wan
WAN mínima: DHCP ou PPPoE
WAN static fica fora ou entra na Frente 1?
```

### Decisão D5 — Integração Nix

Confirmar se a Frente 1 pode alterar:

```text
modules/node/think/think-server.nix
```

ou se o módulo deve ficar congelado e Node Think permanecer ZFS-only.

---

## 12. Critério de conclusão da Frente 1

A Frente 1 somente poderá ser declarada concluída quando:

- [ ] decisões D1–D5 aprovadas;
- [ ] contrato `nodeThink` único definido;
- [ ] schema e Rust concordarem;
- [ ] Node Think sem WAN for rejeitado;
- [ ] Desktop sem WAN continuar válido;
- [ ] KVE puro sem WAN continuar sujeito somente às próprias regras;
- [ ] PPPoE não vazar senha;
- [ ] `hostId` seguir exatamente a regra do módulo Nix aprovado;
- [ ] translator produzir Nix válido;
- [ ] testes de domínio passarem;
- [ ] testes de schema passarem;
- [ ] testes de frontend passarem;
- [ ] testes do translator passarem;
- [ ] avaliação Nix passar, se o módulo Nix mudar;
- [ ] commits forem atômicos e revisáveis;
- [ ] relatório e evidências forem registrados no Vault;
- [ ] nenhum deploy/ativação ocorrer sem autorização separada.

---

## 13. Estado atual

```text
AUDIT: concluída
KCR: redigido
CÓDIGO: não alterado
SCHEMA: não alterado
NIX: não alterado
TESTES: não executados — esta fase foi read-only
COMMITS: nenhum
PUSH: nenhum
PRODUÇÃO: intocada
```

## Próximo passo

Gabriel deve aprovar as decisões D1–D5. Após isso, a implementação poderá começar pelo contrato de domínio, mantendo o gate humano ativo entre cada camada.

#kcr #kryonix #node-think #network #wan #installplanv2 #nixos
