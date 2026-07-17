# KVE Architecture Reference — Engenharia Reversa Conceitual Proxmox VE → Kryonix Virtual Environment

Data: 2026-07-16
Agente: Aura
Status: Referência arquitetural / análise conceitual

## Objetivo

Mapear os conceitos arquiteturais centrais do Proxmox VE para uma arquitetura moderna do **Kryonix Virtual Environment (KVE)**, sem clonar nem estudar massivamente o código-fonte legado em Perl/C.

O foco desta nota é traduzir o que o Proxmox faz bem em termos de operação — cluster, resource tree, storage, SDN e API — para uma fundação KVE baseada em:

- Incus como hypervisor e API operacional;
- Incus cluster com banco distribuído Cowsql/dqlite-like replicado por Raft;
- backend Rust/Axum como plano de controle Kryonix;
- NixOS como baseline declarativo e mecanismo de convergência;
- React/Vite como UI KCP/KVE com resource tree dinâmica.

## Fontes consultadas

- Proxmox VE Cluster Manager: <https://pve.proxmox.com/wiki/Cluster_Manager>
- Proxmox Cluster File System — pmxcfs: <https://pve.proxmox.com/pve-docs/chapter-pmxcfs.html>
- Proxmox VE API Viewer: <https://pve.proxmox.com/pve-docs/api-viewer/>
- Proxmox VE Storage: <https://pve.proxmox.com/pve-docs/chapter-pvesm.html>
- Proxmox VE SDN: <https://pve.proxmox.com/pve-docs/chapter-pvesdn.html>
- Incus clustering: <https://linuxcontainers.org/incus/docs/main/explanation/clustering/>
- Incus REST API: <https://linuxcontainers.org/incus/docs/main/rest-api/>
- Incus storage pools: <https://linuxcontainers.org/incus/docs/main/howto/storage_pools/>
- Incus networks: <https://linuxcontainers.org/incus/docs/main/howto/network_create/>

## 1. Resumo executivo

O Proxmox VE combina uma UI operacional madura com uma arquitetura de cluster baseada em `pmxcfs` + Corosync. Essa combinação entrega uma experiência forte: resource tree global, configuração distribuída, storage compartilhado, HA e API REST consistente. O ponto que o KVE deve copiar não é o código, mas o **modelo mental operacional**.

A equivalência moderna para o KVE é:

| Pilar | Proxmox VE | KVE / Kryonix Virtual Environment |
|---|---|---|
| Hypervisor | QEMU/KVM + LXC | Incus containers + VMs |
| Estado de cluster | `pmxcfs` replicado via Corosync | Incus cluster com Cowsql/Raft + plano declarativo NixOS |
| UI | ExtJS/PVE Manager resource tree | React/Vite KCP com TreeView dinâmica |
| API | `/api2/json/...` | `/api/v2/virt/...`, `/api/v2/storage/...`, `/api/v2/network/...` |
| Storage | plugins `libpve-storage-perl`, `storage.cfg` | Incus storage pools/volumes + futuro planner Ceph/NixOS |
| SDN | bridges Linux, VNets, zones, subnets | Incus managed networks: `bridge`, `ovn`, `physical`, `macvlan`, `sriov` |
| HA | HA manager + fencing + shared storage | Incus placement/evacuation + Ceph RBD foundation + NixOS convergence |
| Locking | pmxcfs locks + owner path by node | Incus API consistency + operation IDs + KVE policy layer |

Conclusão: o KVE deve ser **Proxmox-like na ergonomia**, mas **Incus/NixOS-native na execução**.

## 2. Cluster & Quórum

### 2.1 Como o Proxmox sincroniza estado

O Proxmox VE usa o **Proxmox Cluster File System (`pmxcfs`)** como camada central de configuração distribuída. O `pmxcfs` monta `/etc/pve` como um filesystem FUSE e armazena configurações em uma base SQLite replicada em tempo real via Corosync.

Características relevantes:

| Aspecto | Proxmox VE |
|---|---|
| Caminho lógico | `/etc/pve` |
| Tecnologia | FUSE + SQLite + Corosync |
| Replicação | tempo real entre nós do cluster |
| Quórum | quando um nó perde quórum, `/etc/pve` fica read-only |
| Consistência | evita IDs duplicados de VMs/CTs |
| Locks | arquivos/locks distribuídos sob `/etc/pve/priv/lock` |
| Limite relevante | cópia em RAM, documentação cita limite de 128 MiB |
| Configurações globais | `storage.cfg`, `datacenter.cfg`, `user.cfg`, `sdn/*`, `ha/*` |

O Proxmox também usa Corosync para comunicação de grupo e votação de quórum. A própria documentação recomenda rede de cluster de baixa latência, idealmente dedicada, porque Corosync é sensível a latência e perda de pacotes.

### 2.2 Como o KVE deve sincronizar estado

O KVE não deve recriar um `pmxcfs` próprio. O Incus já fornece uma arquitetura moderna de cluster: todos os servidores compartilham um banco distribuído do cluster, replicado por Raft. A documentação atual do Incus descreve esse backend como **Cowsql**, sucessor/derivado operacional do padrão dqlite: SQLite + consenso Raft.

Características relevantes do Incus cluster:

| Aspecto | Incus / KVE |
|---|---|
| Estado de cluster | banco distribuído interno do Incus |
| Consenso | Raft |
| Tolerância | maioria dos voters precisa estar online |
| Topologia recomendada | no mínimo 3 membros para sobreviver à perda de 1 voter |
| Papéis | `database`, `database-leader`, `database-standby`, `database-client`, `event-hub`, `ovn-chassis` |
| API de gestão | REST API local via Unix socket ou remota via TLS |
| KVE Control Plane | Axum consome API Incus, normaliza DTOs e aplica policy/RBAC |

### 2.3 Tradução arquitetural

| Conceito Proxmox | Papel no Proxmox | Equivalente KVE | Observação de design |
|---|---|---|---|
| `pmxcfs` | FS distribuído de configuração | Incus distributed DB + NixOS declarations | Não criar FS próprio; consumir fonte real do Incus e gerar baseline Nix quando aplicável. |
| Corosync | group communication/quorum | Raft voters no Incus | Evita stack paralela de quórum para recursos Incus. |
| `/etc/pve/storage.cfg` | storage global | `/1.0/storage-pools` + KVE storage policy | Incus é fonte operacional; NixOS é fonte declarativa revisável. |
| `/etc/pve/sdn/*` | SDN global | `/1.0/networks` + KVE network policy | Usar pending/apply semantics para mudanças críticas. |
| `/etc/pve/nodes/<node>/qemu-server` | ownership local da VM | `location`/target member da instância Incus | KVE deve expor o owner/location na TreeView. |
| `.members` | estado dos membros | `/1.0/cluster` e members API | KVE Cluster Grid deve consumir isto. |
| `.vmlist` | inventário global de VMs | `/1.0/instances?recursion=1` | Base da TreeView dinâmica. |

## 3. Storage Abstraction

### 3.1 Modelo Proxmox

O Proxmox usa um plugin system de storage (`libpve-storage-perl`) e centraliza a configuração em `/etc/pve/storage.cfg`. Cada storage pool possui um tipo e um ID único. Exemplos oficiais incluem:

| Tipo Proxmox | Classe | Compartilhado | Snapshots | Função típica |
|---|---|---:|---:|---|
| `dir` | file-level | não | limitado/qcow2 | ISO, backup, templates |
| `zfspool` | local ZFS | não | sim | root disks locais em zvol/datasets |
| `lvm` | block-level | não/depende | limitado | discos raw |
| `lvmthin` | block-level thin | não | sim | discos de VM locais |
| `nfs` | file-level | sim | limitado | shared ISO/backup/images |
| `iscsi` | block-level | sim | depende | SAN |
| `rbd` | Ceph block | sim | sim | HA/shared VM disks |
| `cephfs` | Ceph file | sim | sim | arquivos compartilhados |
| `pbs` | backup | sim | n/a | Proxmox Backup Server |

Ponto essencial: Proxmox diferencia **storage local replicado apenas por configuração** de **storage realmente compartilhado**. Marcar `shared` não transforma storage local em compartilhado; apenas declara que o backend já é compartilhado.

### 3.2 Modelo Incus/KVE

O Incus trabalha com **storage pools** e **storage volumes**. Pools podem usar drivers como `dir`, `btrfs`, `lvm`, `zfs`, `ceph`, `cephfs` e `cephobject`, dependendo da instalação e suporte local.

Chamadas Incus relevantes para o KVE:

| Operação | Incus REST API | Uso no KVE |
|---|---|---|
| Listar pools | `GET /1.0/storage-pools` | `GET /api/v2/storage/pools` |
| Detalhar pool | `GET /1.0/storage-pools/{name}` | card/detail view de pool |
| Recursos/uso | `GET /1.0/storage-pools/{name}/resources` | capacidade, uso, alertas |
| Criar pool | `POST /1.0/storage-pools` | futura operação segura, não P2/P3 atual |
| Volumes do pool | `GET /1.0/storage-pools/{pool}/volumes` | aba Volumes |
| Detalhar volume | `GET /1.0/storage-pools/{pool}/volumes/{type}/{name}` | detail de root disk/snapshot |

Em clusters Incus, a criação de pool pode exigir fase `pending` por membro com `--target=<member>` e finalização global sem `target`. Essa semântica é importante para o KVE porque permite modelar um workflow industrial:

1. coletar parâmetros por nó;
2. validar simetria e divergências legítimas;
3. gerar plano declarativo;
4. só então aplicar/confirmar.

### 3.3 Tradução Storage Proxmox → KVE

| Proxmox | KVE/Incus | API KVE proposta | Observações |
|---|---|---|---|
| `/etc/pve/storage.cfg` | Incus storage pools + NixOS storage policy | `GET /api/v2/storage/pools` | Fonte operacional vem do Incus; política desejada pode ser Nix. |
| `pvesm status` | pool/resources | `GET /api/v2/storage/pools` | Já implementado em leitura no KCP. |
| `zfspool` local | Incus `zfs` pool | `/api/v2/storage/pools/{pool}` | Bom para single-node/dev; não vender como HA síncrono. |
| `lvmthin` local | Incus `lvm` pool | `/api/v2/storage/pools/{pool}` | Útil para desempenho local, sem mobilidade HA por si só. |
| `rbd` | Incus `ceph` pool | futuro `/api/v2/storage/ceph/*` | Fundação correta para root disks compartilhados/HA. |
| `cephfs` | Incus `cephfs` pool | futuro `/api/v2/storage/cephfs/*` | Arquivos compartilhados, não substitui RBD para disco de VM. |
| shared storage | Ceph-backed pool | policy `ha_capable=true` | KVE deve mostrar explicitamente se o pool suporta HA. |
| content types | volume types/content | pool capabilities | Traduzir em UI para `instances`, `images`, `custom`, `backup` etc. |

### 3.4 Decisão crítica: Sanoid/Syncoid vs HA

Sanoid/Syncoid é excelente para backup/replicação assíncrona/DR. Não deve ser posicionado como HA síncrono de datacenter. Para KVE HA real, o caminho industrial é:

- Ceph RBD para blocos compartilhados;
- Incus cluster para ownership/placement/operations;
- KVE policy layer para health, constraints, evacuation e UX;
- NixOS para baseline declarativo e convergência de serviços.

## 4. Redes e SDN

### 4.1 Modelo Proxmox

O modelo tradicional Proxmox usa bridges Linux, normalmente `vmbr0`, ligadas a interfaces físicas. O Proxmox SDN moderno expande isso com:

| Camada | Proxmox SDN |
|---|---|
| Zone | área virtualmente separada |
| VNet | rede virtual dentro de uma zone |
| Subnet | range IP dentro da VNet |
| Simple zone | bridge isolada/NAT/routed local |
| VLAN zone | VLAN sobre bridge local/OVS |
| QinQ | VLAN stacking |
| VXLAN | overlay L2 via UDP 4789 |
| EVPN | VXLAN + BGP/FRRouting |
| IPAM/DHCP/DNS | integração opcional/tech preview em partes |

O Proxmox grava a configuração SDN sob `/etc/pve/sdn`, replicada via pmxcfs. Alterações podem ficar pendentes e serem aplicadas como conjunto, o que é um padrão bom para o KVE copiar.

### 4.2 Modelo Incus/KVE

O Incus possui managed networks com tipos:

| Tipo Incus | Uso |
|---|---|
| `bridge` | bridge gerenciada local, NAT/routed/isolada |
| `ovn` | overlay/SDN com OVN |
| `physical` | interface/uplink físico gerenciado |
| `macvlan` | L2 direto em interface física |
| `sriov` | passthrough/virtual functions SR-IOV |

Chamadas relevantes:

| Operação | Incus REST/API conceitual | API KVE proposta |
|---|---|---|
| Listar redes | `GET /1.0/networks` | `GET /api/v2/network/networks` |
| Detalhar rede | `GET /1.0/networks/{name}` | `GET /api/v2/network/networks/{name}` |
| Criar rede | `POST /1.0/networks` | futura operação com plano/approval |
| Anexar a instância | device NIC em instance config | `POST /api/v2/virt/instances/{id}/nics/plan` |
| Eventos | Incus events websocket | KVE live resource tree |

Em cluster, assim como storage, redes podem exigir configuração `pending` por membro usando `--target=<cluster_member>`, por exemplo quando o parent/uplink físico muda por nó.

### 4.3 Tradução SDN Proxmox → KVE

| Proxmox | KVE/Incus | Observação |
|---|---|---|
| `vmbr0` | Incus `bridge` ou `physical` parent | Para modo simples/local. |
| VNet | Incus managed network | O nome da VNet vira recurso de TreeView. |
| Zone Simple | `bridge` NAT/routed | Boa equivalência. |
| Zone VLAN | `physical`/bridge + VLAN-aware config | Exige cuidado por nó. |
| Zone VXLAN | `ovn` ou overlay dedicado | Preferir OVN para modelo cluster-native. |
| EVPN/BGP | OVN/OVN chassis + rede underlay | KVE deve tratar como fase avançada. |
| SDN pending/apply | KVE network plan + apply gate | Padrão seguro: planejar, revisar, aplicar. |

## 5. Estrutura de API

### 5.1 Padrão Proxmox

A API Proxmox se organiza como uma resource tree. O API viewer mostra raízes como:

- `access`
- `cluster`
- `nodes`
- `pools`
- `storage`
- `version`

O padrão mais conhecido é:

```txt
/api2/json/nodes/{node}/qemu/{vmid}/...
/api2/json/nodes/{node}/lxc/{vmid}/...
/api2/json/nodes/{node}/storage/{storage}/...
/api2/json/cluster/...
/api2/json/access/...
```

Esse padrão é excelente para UI porque a rota carrega o contexto: datacenter → node → recurso → ação.

### 5.2 Padrão KVE/Axum

O KVE deve manter a semântica de resource tree, mas com rotas modernas e orientadas por domínio:

| Domínio | API KVE atual/proposta | Fonte operacional |
|---|---|---|
| Identidade | `/api/v1/system/identity` | Kryonix identity |
| Auth | `/api/v1/auth/login`, `/api/v1/auth/session` | KVE auth gateway |
| Virt | `/api/v2/virt/nodes`, `/api/v2/virt/instances` | Incus instances/cluster |
| Storage | `/api/v2/storage/pools` | Incus storage pools/resources |
| Replication/DR | `/api/v2/storage/replication/*` | planner declarativo, não HA |
| Network | futuro `/api/v2/network/*` | Incus networks |
| Cluster | futuro `/api/v2/cluster/*` | Incus cluster/members/resources |
| Operations | futuro `/api/v2/operations/*` | Incus operation IDs/events |

### 5.3 Mapeamento de endpoints

| Proxmox API | Significado | KVE API | Observação |
|---|---|---|---|
| `/api2/json/version` | versão do PVE | `/api/v1/system/identity` + `/api/v2/version` futuro | Separar identidade host/produto. |
| `/api2/json/cluster/status` | estado do cluster | `/api/v2/cluster/status` | Consumir `/1.0/cluster`/members Incus. |
| `/api2/json/nodes` | nós | `/api/v2/virt/nodes` | Já existe como rota de nodes. |
| `/api2/json/nodes/{node}/qemu` | VMs QEMU | `/api/v2/virt/instances?type=virtual-machine&node={node}` | Incus usa instances com type. |
| `/api2/json/nodes/{node}/lxc` | containers | `/api/v2/virt/instances?type=container&node={node}` | Mesmo inventário, filtro diferente. |
| `/api2/json/nodes/{node}/storage` | storage visível no nó | `/api/v2/storage/pools?node={node}` | Pool location/capabilities. |
| `/api2/json/storage` | storage global | `/api/v2/storage/pools` | KVE normaliza storage global. |
| `/api2/json/access/ticket` | login/ticket | `/api/v1/auth/login` | JWT/cookie efêmero. |
| `/api2/json/cluster/resources` | recursos globais | `/api/v2/cluster/resources` | Ideal para TreeView unificada. |
| `/api2/json/nodes/{node}/network` | redes do nó | `/api/v2/network/networks?node={node}` | Futuro network module. |

## 6. Resource Tree KVE

A TreeView do KVE deve copiar a ergonomia do Proxmox, mas modelar recursos Incus:

```txt
Datacenter
└── Cluster: kryonix
    ├── Nodes
    │   ├── inspiron
    │   │   ├── Instances
    │   │   │   ├── vm-web-01
    │   │   │   └── ct-rag-01
    │   │   ├── Storage
    │   │   │   ├── local-zfs
    │   │   │   └── ceph-rbd
    │   │   └── Networks
    │   │       ├── LAN
    │   │       └── KVE-MGMT
    │   └── thinkserver
    ├── Storage
    │   ├── local pools
    │   └── ceph pools
    ├── Networks
    ├── HA
    └── Operations
```

Regras UX:

- TreeView deve ser derivada de API, não hardcoded.
- Cada item deve carregar `kind`, `id`, `node/location`, `status`, `capabilities`.
- Recursos com risco devem abrir páginas com plano, diff e aprovação — nunca mutação cega.
- Eventos Incus/WebSocket devem alimentar refresh live no futuro.

## 7. HA e failover

### 7.1 Proxmox

Proxmox combina:

- shared storage;
- HA manager;
- locks/fencing/watchdog;
- ownership de guest por nó;
- recuperação manual/automática dependendo se o guest é HA-managed.

Sem shared storage ou sem fencing confiável, failover seguro fica limitado.

### 7.2 KVE

O KVE deve separar claramente três camadas:

| Camada | Responsabilidade |
|---|---|
| Incus cluster | ownership, placement, operations, evacuation, estado de instances |
| Ceph RBD/CephFS | storage compartilhado/síncrono para discos e arquivos |
| KVE policy/NixOS | declara constraints, baseline, health, approvals, UX e convergência |

Princípio importante: replicação ZFS assíncrona não é HA. Ela é backup/DR. A UI pode continuar oferecendo planner de Sanoid/Syncoid, mas deve rotular como **DR/replication**, não como HA.

## 8. Implicações para roadmap KVE

| Fase | Entrega | Risco | Observação |
|---|---|---:|---|
| Fase 1 | TreeView dinâmica baseada em Incus | baixo | Já iniciada no KCP. |
| Fase 2 | Cluster Grid `/api/v2/cluster/status` | médio | Read-only primeiro. |
| Fase 3 | Network inventory `/api/v2/network/networks` | médio | Read-only primeiro. |
| Fase 4 | Ceph Foundation planner | alto | Planner declarativo, sem executar mutações destrutivas. |
| Fase 5 | Operations/events live | médio | WebSocket/SSE para status de operações. |
| Fase 6 | HA policy | alto | Depende de Ceph/fencing/health model. |

## 9. Guardrails de implementação

1. Não clonar monorepos do Proxmox por padrão.
2. Usar Proxmox apenas como referência de comportamento/API/UX.
3. Não copiar Perl/ExtJS legado para o KVE.
4. Não chamar Sanoid/Syncoid de HA.
5. Não executar comandos destrutivos de storage na fase de planner.
6. Toda mutação futura de rede/storage/cluster deve ter:
   - plano declarativo;
   - diff/preview;
   - validação;
   - aprovação humana;
   - rollback documentado.
7. Segredos de Ceph, tokens, cookies e chaves nunca entram em Vault/log/UI.
8. API Rust deve encapsular Incus e expor DTOs KVE estáveis, não vazar detalhes instáveis da CLI.

## 10. Recomendação final

A próxima evolução técnica correta é criar endpoints read-only de cluster e network antes de qualquer mutação:

```txt
GET /api/v2/cluster/status
GET /api/v2/cluster/members
GET /api/v2/cluster/resources
GET /api/v2/network/networks
GET /api/v2/network/networks/{name}
```

Depois disso, o KVE pode iniciar o **Ceph Foundation Planner** como artefato declarativo, sem aplicar alterações físicas:

```txt
POST /api/v2/storage/ceph/plan
```

Esse caminho preserva o que o Proxmox tem de melhor — resource tree, visão de datacenter e operações centralizadas — mas troca a fundação antiga por Incus/Raft/NixOS/Ceph, que é mais coerente com o Kryonix.
