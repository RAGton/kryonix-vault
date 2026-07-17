# KVE Ceph HA Storage Engine & Datacenter Monitor UI

Data: 2026-07-16
Agente: Aura
Repos afetados:

- kryxd
- kryonix-vault

## Objetivo

Implementar a fundação read-only do Ceph HA Storage Engine no backend Axum e renderizar o painel de monitoramento distribuído nas abas contextuais do KVE.

## Escopo executado

### Backend Rust/Axum

Arquivo:

- `repos/kryxd/src/api/storage.rs`

Endpoints adicionados sob `/api/v2/storage`, ambos protegidos por `RequireCoreRole`:

```txt
GET /api/v2/storage/ceph/status
GET /api/v2/storage/ceph/osds
```

Foram adicionados DTOs fortemente tipados com `serde`:

- `CephClusterStatus`
- `CephQuorumStatus`
- `CephMonitor`
- `CephManagerStatus`
- `CephManagerStandby`
- `CephCapacity`
- `CephPlacementGroups`
- `CephPoolStatus`
- `CephOsd`

O backend simula uma topologia Ceph pronta para futuro adaptador real:

- health global: `HEALTH_WARN` nesta fase simulada;
- quórum MON: `3/3`;
- managers: 1 ativo + 2 standby;
- capacity geral;
- PGs active/degraded/stuck;
- pools `kve-rbd` e `kve-cephfs`;
- OSDs por node/dispositivo físico simulado;
- campos de IOPS e temperatura simulada.

### Frontend API

Arquivo:

- `repos/kryxd/ui/src/lib/api.js`

Funções adicionadas:

```js
getCephStatus()
getCephOsds()
```

### Frontend UI

Arquivo:

- `repos/kryxd/ui/src/App.jsx`

Rotas integradas:

```txt
/kcp/datacenter/storage
/kcp/node/:nodeId/disks
```

Componentes adicionados no roteamento atual:

- `CephDatacenterStorage`
- `NodeDisksPage`
- helpers visuais para badges, métricas e formatação de bytes.

## UX entregue

### Datacenter Storage

A aba `/kcp/datacenter/storage` agora exibe:

- painel executivo `Ceph HA Storage Engine`;
- badge dinâmico de health:
  - verde para `HEALTH_OK`;
  - vermelho pulsante para `HEALTH_ERR`;
  - âmbar para warning;
- métricas de capacity, MON quorum, PGs e exceções de OSD;
- barra de uso de capacidade;
- tabela `MON Quorum Map` com linhas alternadas `bg-slate-900/40`;
- painel de Managers com active/standby.

### Node Disks

A aba `/kcp/node/:nodeId/disks` agora exibe:

- seção `Local ZFS Pools`;
- seção `Cluster Ceph OSDs`;
- filtro de OSDs por `nodeId` da rota;
- colunas: OSD, device, state, usage, IOPS e temperatura;
- fontes monoespaçadas para identificadores e devices;
- linhas alternadas no padrão industrial.

## Segurança e restrições

Esta etapa permaneceu read-only.

Não foram adicionadas:

- rotas de escrita;
- bootstrap de Ceph;
- comandos imperativos de storage;
- execução de binário Ceph;
- formatação ou mutação de disco;
- secrets no frontend.

Fluxo de leitura planejado para fases futuras:

```txt
Frontend -> Axum API -> adaptador Ceph/Incus -> cluster socket/API local
```

## Validações executadas

### Backend

Comando:

```bash
cargo check --workspace
```

Resultado:

```txt
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.23s
```

Observação:

```txt
warning: virtual workspace defaulting to resolver = "1" ...
```

Aviso preexistente de resolver do Cargo; não bloqueou a build.

### Frontend

Comando:

```bash
npm run build --prefix repos/kryxd/ui
```

Resultado:

```txt
✓ 2073 modules transformed.
✓ built in 5.29s
```

Avisos conhecidos do Vite:

```txt
/img/noise.png referenced in /img/noise.png didn't resolve at build time
Some chunks are larger than 500 kB after minification
```

### Git hygiene

Comando:

```bash
git -C repos/kryxd diff --check -- src/api/storage.rs ui/src/lib/api.js ui/src/App.jsx
```

Resultado:

```txt
diff check ok; ui/dist cleanup ok
```

### Verificação ad-hoc

Script temporário criado em:

```txt
/tmp/nix-shell-266339-3526915383/hermes-verify-*.py
```

Resultado:

```txt
AD-HOC VERIFY KVE CEPH STORAGE FOUNDATION: PASS
- backend exposes GET /api/v2/storage/ceph/status
- backend exposes GET /api/v2/storage/ceph/osds
- Ceph endpoints are RBAC-protected
- strong serde DTO present: CephClusterStatus
- strong serde DTO present: CephQuorumStatus
- strong serde DTO present: CephManagerStatus
- strong serde DTO present: CephOsd
- strong serde DTO present: Serialize
- forbidden imperative command absent: ceph-deploy
- forbidden imperative command absent: mkfs.ceph
- forbidden imperative command absent: Command::new("ceph"
- forbidden imperative command absent: Command::new("mkfs"
- forbidden imperative command absent: std::process::Command
- frontend API clients added
- Datacenter Storage route renders Ceph dashboard
- Node Disks route renders node storage view
- industrial UI marker present: MON Quorum Map
- industrial UI marker present: Managers
- industrial UI marker present: Local ZFS Pools
- industrial UI marker present: Cluster Ceph OSDs
- industrial UI marker present: bg-slate-900/40
- industrial UI marker present: font-mono
- generated ui/dist is absent after cleanup
- scoped git diff --check passed
```

Cleanup confirmado:

```txt
cleanup ok
```

## Diff estatístico

Comando:

```bash
git -C repos/kryxd diff --stat -- src/api/storage.rs ui/src/lib/api.js ui/src/App.jsx
```

Resultado:

```txt
src/api/storage.rs | 759 +++++++++++++++++++++++++++++++++++++++++++++++------
ui/src/App.jsx     | 402 +++++++++++++++++++++++++---
ui/src/lib/api.js  |  73 ++++--
3 files changed, 1102 insertions(+), 132 deletions(-)
```

Nota: esse diff estatístico é escopado aos arquivos da missão, mas o repositório já possuía mudanças locais acumuladas anteriores sem commit.

## Estado final

`READY_FOR_REVIEW`

## Riscos restantes

- Os dados Ceph são simulados nesta fase; o acoplamento real ao cluster ainda precisa de adaptador próprio.
- O endpoint real futuro deve preservar RBAC e continuar sem secrets no frontend.
- A UI foi validada por build, mas ainda não foi revisada visualmente pelo Gabriel na prévia.

## Próximo passo recomendado

Rodar prévia visual e avaliar:

```txt
/kcp/datacenter/storage
/kcp/node/pve-alpha/disks
```
