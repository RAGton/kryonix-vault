# Arquitetura do NODE

Status: canonical
Scope: fronteiras entre codigo, runtime, inventario e operacao do NODE
Last reviewed: 2026-04-09

## Objetivo

O NODE separa claramente:

- codigo declarativo no repositorio;
- runtime persistente fora do checkout Git;
- inventario de clientes em repositorio proprio;
- publicacao do cliente por geracoes imutaveis;
- operacao do parque a partir do servidor.

## Estado atual versus direcao oficial

### Estado atual implementado

Hoje o projeto ja entrega:

- servidor declarativo em `server/`;
- cliente publicado por `knyc`;
- canais oficiais `generic`, `lab` e `rescue` para o cliente;
- boot UEFI com PXE + iPXE + HTTP;
- inventario externo em `/etc/node-inventory/clients.nix`;
- instalador do host em `installer/`.

### Direcao oficial

A arquitetura oficial implementada neste ciclo e:

- root por `/nix/store` via NFS (ro);
- overlay em RAM;
- persistencia restrita a `/home` via NFSv4.

Roadmap declarado:

- migrar o root para netboot/SquashFS quando o pipeline de publicacao e boot estiver completo.
- a semantica nova de `bootMethod`, `releaseTrack` e `clientProfile` fica descrita em `docs/boot-semantics.md` como proposta compativel, nao como substituicao do contrato atual.

## Fronteiras de dominio

```text
server/               configuracao NixOS do srv-rag
client/               configuracao NixOS do cliente diskless
installer/            instalador e bootstrap inicial do host
knyc/                 publicacao, rollback e GC da imagem do cliente
server/runtime/       ponte para params/hardware persistentes do host
/etc/node-inventory  inventario externo de clientes
```

## Componentes principais

| Camada | Responsabilidade |
| --- | --- |
| PXE/UEFI | descobrir o servidor de boot |
| `dnsmasq` | DHCP, TFTP e allowlist por inventario |
| iPXE | entrypoint neutro, roteamento por MAC e fallback interativo |
| `nginx` | servir `boot.ipxe`, `by-mac/<mac>.ipxe`, `generic.ipxe`, `lab.ipxe`, manifests, kernel e initrd |
| `/nix/store` via NFS | root compartilhado consumido pelos clientes |
| overlay em RAM | absorver estado local descartavel do root |
| `nfs-server` | exportar `/home` e dados operacionais do parque |
| `knyc` | gerar, validar, publicar, promover e limpar geracoes |
| inventario externo | autorizar clientes por MAC/hostname/IP |
| `node` | operar o servidor, diagnosticar e evoluir a infraestrutura |

## Caminhos operacionais

| Caminho | Papel |
| --- | --- |
| `/etc/node` | checkout operacional do servidor |
| `/var/lib/node/runtime` | runtime persistente do host instalado |
| `server/runtime/` | links/compatibilidade para o runtime persistente |
| `/etc/node-inventory/clients.nix` | inventario externo de clientes |
| `/srv/http` | raiz HTTP de boot |
| `/srv/http/by-mac` | roteamento HTTP por MAC derivado do inventario |
| `/srv/tftp` | raiz TFTP |
| `/srv/data/images` | geracoes do cliente |
| `/srv/data/home` | persistencia dos usuarios |
| `/srv/data/snapshots` | snapshots de seguranca e GC |

## Fronteiras obrigatorias

- o servidor nao deve manter cadastro estatico de clientes dentro do modulo `dnsmasq`; ele renderiza o inventario externo;
- o cliente padrao deve continuar sendo `desktop-generic`;
- o endpoint nao deve carregar estado local persistente como premissa de operacao;
- inventario deve sustentar hostname, IP reservado, canal de boot, allowlist e futuro WOL;
- Wake-on-LAN pertence ao dominio do servidor e ao comando `node`, nao ao `knyc`.
