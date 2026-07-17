# kryxd Wiring Fase 2 — Árvore Dinâmica e Criação de Instâncias

Data: 2026-07-17
Agente: Aura
Status: READY_FOR_REVIEW

## Objetivo

Eliminar os dados hardcoded da TreeView KVE e conectar a UI premium ao backend `kryxd` para:

1. descobrir a topologia real do cluster Incus;
2. montar uma árvore hierárquica estilo Proxmox;
3. criar novas VMs/CTs via API nativa do Incus;
4. conectar o botão `Create VM/CT` a um modal operacional.

## Escopo alterado

Repo funcional:

```txt
repos/kryxd
```

Arquivos alterados/criados nesta missão:

```txt
src/api/incus.rs
src/api/cluster.rs
src/api/mod.rs
src/api/virt.rs
ui/src/lib/api.js
ui/src/components/kcp/TreeView.jsx
ui/src/layouts/DashboardLayoutWithTree.jsx
```

Log canônico:

```txt
repos/kryonix-vault/09-Logs/Kryonix/2026-07-17-kryxd-wiring-fase2.md
```

## Passo a passo

### 1. Auditoria inicial

Foram lidos/inspecionados os arquivos ativos da missão:

```txt
repos/kryxd/src/api/virt.rs
repos/kryxd/src/api/mod.rs
repos/kryxd/ui/src/lib/api.js
repos/kryxd/ui/src/components/kcp/TreeView.jsx
repos/kryxd/ui/src/layouts/DashboardLayoutWithTree.jsx
repos/kryxd/ui/src/components/Topbar.tsx
repos/kryxd/ui/src/components/Modal.tsx
repos/kryxd/ui/src/layouts/ContextLayout.jsx
repos/kryxd/src/api/storage.rs
```

Constatações:

- a TreeView ativa no shell `/kcp/*` era `ui/src/components/kcp/TreeView.jsx`;
- o botão ativo `Create VM/CT` ficava em `DashboardLayoutWithTree.jsx`;
- `Topbar.tsx` tinha botões AI Studio com `alert(...)`, mas não é o shell ativo de `/kcp/*` nesta fase;
- `src/api/virt.rs` já tinha `PUT /instances/:id/state` da Fase 1, mas `POST /instances` ainda usava `incus launch` via subprocesso;
- `storage.rs` já continha um padrão prévio de leitura Incus via Unix socket, mas isolado no próprio módulo.

### 2. Helper Incus compartilhado

Criado:

```txt
repos/kryxd/src/api/incus.rs
```

Responsabilidades:

- conectar no socket local do Incus;
- usar `INCUS_SOCKET` quando definido;
- fallback para `/var/lib/incus/unix.socket`;
- emitir requisições HTTP manuais sobre Unix socket;
- suportar `GET`, `POST` e `PUT` JSON;
- parsear resposta JSON Incus;
- extrair `operation_id` quando Incus retorna task assíncrona;
- codificar segmentos de path com `byte_serialize`.

Segurança:

```txt
O socket root do Incus fica somente no backend Rust.
Nada disso é importado ou renderizado no frontend.
```

### 3. Backend — Tree Discovery

Criado:

```txt
repos/kryxd/src/api/cluster.rs
```

Rota criada:

```txt
GET /api/v2/cluster/topology
```

Montagem feita em:

```txt
repos/kryxd/src/api/mod.rs
```

```rust
pub mod cluster;
pub mod incus;

.nest("/cluster", cluster::router())
```

Proteção:

```rust
RequireCoreRole
```

Leituras Incus executadas pelo backend:

```txt
GET /1.0/cluster/members
GET /1.0/instances?recursion=1
GET /1.0/storage-pools?recursion=1
```

Fallback de cluster:

```txt
Se /1.0/cluster/members falhar ou retornar vazio, a árvore usa local-node.
```

DTO hierárquico criado:

```txt
ClusterTopology
└── DatacenterTree
    └── NodeTree[]
        ├── StorageTree[]
        ├── InstanceTree[] vms
        └── InstanceTree[] cts
```

Shape conceitual:

```json
{
  "datacenter": {
    "id": "datacenter",
    "name": "Datacenter",
    "kind": "datacenter",
    "route": "/kcp/datacenter/summary",
    "nodes": [
      {
        "node_name": "node-a",
        "route": "/kcp/node/node-a/summary",
        "storages": [],
        "vms": [],
        "cts": []
      }
    ]
  },
  "source": "incus-socket"
}
```

### 4. Backend — Create VM/CT

Alterado:

```txt
repos/kryxd/src/api/virt.rs
```

Endpoint:

```txt
POST /api/v2/virt/instances
```

Payload novo:

```json
{
  "name": "vm-app-01",
  "kind": "vm",
  "image": "images:ubuntu/24.04",
  "cpu": 2,
  "ram_mb": 2048,
  "disk_gb": 20,
  "network_bridge": "incusbr0"
}
```

Também aceita:

```json
{
  "kind": "ct"
}
```

Proteção:

```rust
RequireCoreRole
```

Mudança técnica importante:

```txt
ANTES: subprocesso `incus launch`
AGORA: POST JSON nativo em /1.0/instances via Unix socket
```

Payload nativo enviado ao Incus:

```json
{
  "name": "vm-app-01",
  "type": "virtual-machine",
  "source": {
    "type": "image",
    "alias": "images:ubuntu/24.04"
  },
  "config": {
    "limits.cpu": "2",
    "limits.memory": "2048MiB"
  },
  "devices": {
    "root": {
      "type": "disk",
      "path": "/",
      "pool": "default",
      "size": "20GiB"
    },
    "eth0": {
      "type": "nic",
      "name": "eth0",
      "network": "incusbr0"
    }
  },
  "start": true
}
```

Operação síncrona:

- após `POST /1.0/instances`, o backend extrai `task_id`/operation id;
- quando disponível, chama:

```txt
GET /1.0/operations/<task_id>/wait?timeout=30
```

Resposta do `kryxd`:

```json
{
  "status": "completed",
  "task_id": "<uuid>",
  "instance": "vm-app-01",
  "kind": "vm",
  "incus": {},
  "wait": {}
}
```

Se não houver operação para aguardar:

```json
{
  "status": "accepted"
}
```

Validações de payload no backend:

- `name` obrigatório;
- `image` obrigatório;
- `network_bridge` obrigatório;
- `cpu > 0`;
- `ram_mb > 0`;
- `disk_gb > 0`.

### 5. Frontend API

Alterado:

```txt
repos/kryxd/ui/src/lib/api.js
```

Funções novas:

```js
getClusterTopology()
createInstance(data)
```

Compatibilidade preservada:

```js
createVirtInstance(config) -> createInstance(config)
```

Rotas usadas:

```txt
GET  /api/v2/cluster/topology
POST /api/v2/virt/instances
```

### 6. Frontend — TreeView dinâmica

Alterado:

```txt
repos/kryxd/ui/src/components/kcp/TreeView.jsx
```

Mudanças:

- adiciona `useEffect` na montagem;
- chama `getClusterTopology()`;
- adiciona botão de refresh da topologia;
- escuta evento global `kve:topology-refresh` para recarregar após deploy;
- remove hardcoded demo:
  - `pve-alpha`;
  - `local-zfs`;
  - `100 (web-server)`;
  - `/vm/100`;
  - `101 (db-postgres)`;
- renderiza dinamicamente:
  - datacenter;
  - nodes;
  - storages;
  - VMs;
  - CTs.

Links formados dinamicamente:

```txt
/kcp/node/${nodeName}/summary
/kcp/node/${nodeName}/storage/${poolName}/summary
/kcp/node/${nodeName}/vm/${instanceName}/summary
/kcp/node/${nodeName}/ct/${instanceName}/summary
```

Os segmentos são codificados com `encodeURIComponent(...)` no frontend e com `encode_path_segment(...)` no backend.

### 7. Frontend — Wizard de criação

Alterado:

```txt
repos/kryxd/ui/src/layouts/DashboardLayoutWithTree.jsx
```

O botão ativo:

```txt
Create VM/CT
```

Agora abre um modal operacional com campos:

```txt
name
kind: vm | ct
image
cpu
ram_mb
disk_gb
network_bridge
```

Ao enviar:

1. converte campos numéricos para `Number`;
2. chama `createInstance(payload)`;
3. mostra spinner `Loader2` durante deploy;
4. bloqueia fechamento/cancelamento enquanto envia;
5. mostra toast de sucesso ou erro;
6. fecha modal em caso de sucesso;
7. emite `kve:topology-refresh` para recarregar a árvore.

Nota de segurança exibida na UI:

```txt
O frontend envia apenas o payload declarativo para o kryxd. Socket root do Incus e credenciais ficam só no backend.
```

## Validações executadas

### Rust check

Comando:

```bash
cargo check --workspace
```

Resultado:

```txt
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.23s
```

### Frontend build

Comando:

```bash
npm run build --prefix repos/kryxd/ui
```

Resultado:

```txt
✓ 2476 modules transformed.
✓ built in 6.05s
```

Warnings conhecidos:

```txt
/img/noise.png referenced in /img/noise.png didn't resolve at build time
Some chunks are larger than 500 kB after minification
```

### Diff check escopado

Comando:

```bash
git -C repos/kryxd diff --check -- \
  src/api/mod.rs \
  src/api/incus.rs \
  src/api/cluster.rs \
  src/api/virt.rs \
  ui/src/lib/api.js \
  ui/src/components/kcp/TreeView.jsx \
  ui/src/layouts/DashboardLayoutWithTree.jsx
```

Resultado:

```txt
exit 0
```

### Cleanup

Após build Vite:

```bash
rm -rf repos/kryxd/ui/dist
```

Resultado:

```txt
ui/dist absent
```

### Verificação ad-hoc

Script temporário:

```txt
/tmp/nix-shell-266339-3526915383/hermes-verify-*.py
```

Resultado:

```txt
AD-HOC VERIFY KVE WIRING FASE 2: PASS
cleanup ok
```

Cobertura da verificação:

- `cluster` e `incus` montados no backend;
- `GET /api/v2/cluster/topology` existe;
- topology protegida por `RequireCoreRole`;
- topology lê members, instances e storage pools via Incus socket;
- fallback `local-node` existe;
- DTO hierárquico existe;
- rotas dinâmicas usam encoding;
- helper Incus usa Unix socket backend-only;
- `POST /api/v2/virt/instances` existe;
- criação protegida por `RequireCoreRole`;
- payload contém `name`, `kind`, `image`, `cpu`, `ram_mb`, `disk_gb`, `network_bridge`;
- `vm`/`ct` mapeiam para `virtual-machine`/`container`;
- criação usa `POST /1.0/instances`;
- backend aguarda operation wait quando há task id;
- frontend expõe `getClusterTopology` e `createInstance`;
- TreeView carrega dinamicamente por `useEffect`;
- TreeView não contém mais hardcoded demo da fase anterior;
- modal `Create VM/CT` envia via `createInstance`;
- modal tem spinner/loading;
- toast de sucesso antes do fechamento;
- frontend não expõe `INCUS_SOCKET`, `/var/lib/incus/unix.socket` ou `UnixStream`;
- `ui/dist` removido.

## Diff stat escopado

Arquivos rastreados já existentes:

```txt
src/api/mod.rs                             |   4 +
src/api/virt.rs                            | 275 +++++++++++++++++++++++------
ui/src/components/kcp/TreeView.jsx         | 170 +++++++++++++++---
ui/src/layouts/DashboardLayoutWithTree.jsx | 153 +++++++++++++++-
ui/src/lib/api.js                          |  94 ++++++++--
5 files changed, 594 insertions(+), 102 deletions(-)
```

Arquivos novos não rastreados no submódulo:

```txt
src/api/cluster.rs
src/api/incus.rs
```

## Status escopado

```txt
 M src/api/mod.rs
 M src/api/virt.rs
AM ui/src/components/kcp/TreeView.jsx
AM ui/src/layouts/DashboardLayoutWithTree.jsx
 M ui/src/lib/api.js
?? src/api/cluster.rs
?? src/api/incus.rs
```

Observação: alguns arquivos aparecem como `AM` porque já eram novos/modificados de fases anteriores na mesma working tree.

## Riscos restantes

1. `POST /api/v2/virt/instances` faz mutação real no Incus, então deve permanecer atrás de `RequireCoreRole`.
2. O payload usa storage pool `default`, porque o payload solicitado não inclui campo de pool. Em hosts sem pool `default`, o Incus deve retornar erro e a UI exibirá toast de falha.
3. `network_bridge` usa o campo nativo `network`; em ambientes com bridge não gerenciada, pode ser necessário evoluir para `nictype=bridged` + `parent`.
4. O endpoint aguarda operation por até 30s; operações longas podem retornar como aceitas/pendentes dependendo do comportamento real do Incus.
5. A validação não executou deploy real contra Incus para evitar mutação operacional sem autorização explícita.
6. `Topbar.tsx` ainda contém botões AI Studio com `alert(...)`, mas o shell `/kcp/*` ativo usa `DashboardLayoutWithTree.jsx`, que foi conectado ao modal real.

## Estado final

```txt
READY_FOR_REVIEW
```

Nenhum commit ou push foi executado.
