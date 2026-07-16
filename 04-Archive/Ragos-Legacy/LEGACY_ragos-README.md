# RAGOS

[![CI](https://github.com/RAGEnterprise/ragos/actions/workflows/ci.yml/badge.svg)](https://github.com/RAGEnterprise/ragos/actions/workflows/ci.yml)

RAGOS e uma plataforma on-premises para clientes diskless reais em NixOS, com boot 100% via rede, imagem centralizada e operacao orientada a previsibilidade.

## Visao executiva

No RAGOS, o endpoint nao e o centro do sistema.

O centro do sistema e o servidor.

Isso implica um modelo operacional claro:

- o cliente fisico deve ser tratavel como hardware descartavel;
- o sistema do cliente deve ser centralizado e controlado por geracoes;
- o estado persistente relevante deve ficar no servidor;
- a substituicao de hardware nao deve exigir reinstalacao artesanal;
- a operacao deve ser explicavel, auditavel e reproduzivel.

## Estado atual e direcao oficial

Para evitar documentacao enganosa, o projeto diferencia tres coisas:

### Estado atual implementado

Hoje o repositorio ja entrega:

- boot UEFI com PXE + iPXE + HTTP;
- publicacao geracional do cliente por `ragc`;
- canais oficiais de cliente `generic`, `lab` e `rescue`;
- perfis oficiais `desktop-generic`, `desktop-lab`, `rescue-minimal` e `hyperv-debug` (lab/CI);
- inventario externo em `/etc/ragos-inventory/clients.nix`;
- servidor NixOS declarativo em `server/`;
- instalador do host em `installer/`.

### Midia oficial do installer

O installer do host tem um contrato proprio de live ISO e precisa ser tratado separadamente do boot diskless do cliente.

Posicao operacional oficial do projeto:

- **suportado oficialmente:** ISO gravada diretamente em pendrive com `dd` ou gravador raw equivalente;
- **experimental:** boot da ISO via Ventoy;
- **nao tratado como contrato forte:** qualquer fluxo que dependa de comportamento especifico de device-mapper, loopback ou remount custom do carregador da midia.

Motivo:

- a live ISO depende do stage 1 conseguir descobrir e montar a propria midia;
- caminhos como `/dev/mapper/ventoy`, `findiso=` e loops alternativos sao trataveis ate certo ponto, mas nao sao razoaveis como garantia universal;
- por isso a validacao oficial do projeto continua sendo UEFI puro, Secure Boot desabilitado e pendrive gravado diretamente.

### Direcao oficial atual

A direcao correta do RAGOS e:

- root do cliente por **`/nix/store` remoto via NFS (ro) + overlay tmpfs (rw)** neste ciclo;
- overlay temporario em RAM;
- persistencia do usuario via **NFSv4 em `/home`**;
- split-storage obrigatorio no servidor;
- BTRFS como padrao do tier de dados;
- inventario como base da operacao;
- Wake-on-LAN como capacidade do **`ragos`**.

### Roadmap declarado

Migracao para root por **netboot/SquashFS** continua no roadmap, mas ainda nao e o contrato oficial de producao.

### O que esta torto hoje

Qualquer documento que venda SquashFS como estado atual esta adiantado em relacao ao codigo.
O contrato real implementado hoje e NFS do `/nix/store` + overlay em RAM.

## Decisoes arquiteturais nao negociaveis

### 1. Cliente diskless de verdade

O cliente nao deve depender de disco local funcional como pre-condicao normal de operacao.

Fluxo alvo:

1. UEFI PXE;
2. chainload para iPXE;
3. `boot.ipxe` via HTTP, com roteamento por inventario em `by-mac/<mac>.ipxe`;
4. kernel + initrd via HTTP;
5. root entregue por `/nix/store` remoto via NFS + overlay tmpfs;
6. overlay volatil em RAM;
7. `/home` montado via NFSv4.

### 2. Persistencia so onde importa

A persistencia do endpoint deve ficar em `/home`.

Estado local do root deve ser minimo, temporario e descartavel.

### 3. Split-storage obrigatorio no servidor

O servidor deve separar:

- Tier 0: sistema do host, servicos e runtime local;
- Tier 1: `/srv/data/home`, `/srv/data/images` e `/srv/data/snapshots`.

### 4. BTRFS no tier de dados

Subvolumes esperados:

- `@ragos_homes`
- `@ragos_images`
- `@ragos_snapshots`

### 5. Hostname unico por cliente

Cada cliente deve ser identificavel por:

- MAC;
- hostname;
- IP reservado;
- inventario.

### 6. Wake-on-LAN pertence ao servidor

WOL e capacidade de infraestrutura.

Portanto:

- pertence ao `ragos`;
- deve operar por hostname ou MAC inventariado;
- deve ser emitido pelo servidor;
- deve ser documentado em runbook e roadmap;
- ainda nao deve ser tratado como implementado enquanto o comando nao existir no codigo.

## Componentes principais

| Componente | Papel |
| --- | --- |
| `server/` | composicao NixOS do servidor RAGOS |
| `client/` | imagem do cliente diskless |
| `installer/` | instalacao do host e bootstrap inicial |
| `ragc/` | build, publish, rollback e GC da imagem do cliente |
| `docs/` | documentacao canonica de dominio e operacao |
| `scripts/` | apoio de laboratorio, testes e migracoes auxiliares |

## Estrutura conceitual do repositorio

```text
.
├── flake.nix
├── flake/
├── server/
├── client/
├── installer/
├── ragc/
├── scripts/
├── docs/
├── README.md
├── INSTRUCT.md
└── INSTRUCOES.md
```

## Fonte de verdade por dominio

- `flake.nix` e `flake/` -> composicao, validacao e parametros globais
- `server/` -> servidor RAGOS
- `client/` -> imagem do cliente diskless
- `installer/` -> instalacao do servidor
- `ragc/` -> publicacao da imagem do cliente
- `docs/` -> documentacao tecnica e operacional

## Interfaces operacionais

### `ragos`

CLI do servidor.

Escopo esperado:

- switch, test, rollback e status do host;
- operacao da infraestrutura;
- diagnostico operacional;
- integracao com inventario;
- WOL quando implementado.

### `ragc`

CLI da imagem do cliente.

Escopo esperado:

- build;
- publish / switch;
- rollback;
- listagem de geracoes;
- GC / retencao;
- diagnostico de consistencia.

Regra pratica:

- `ragos` opera infraestrutura;
- `ragc` opera imagem de cliente.

## Mapa de leitura recomendado

### Para entender o projeto

1. [INSTRUCOES.md](INSTRUCOES.md)
2. [INSTRUCT.md](INSTRUCT.md)
3. [docs/architecture.md](docs/architecture.md)
4. [docs/boot-process.md](docs/boot-process.md)
5. [docs/storage.md](docs/storage.md)
6. [docs/network.md](docs/network.md)

### Para operar

1. [docs/runbook.md](docs/runbook.md)
2. [docs/server.md](docs/server.md)
3. [docs/client.md](docs/client.md)
4. [docs/roadmap.md](docs/roadmap.md)
5. [installer/README.md](installer/README.md)

### Para desenvolver

1. [docs/dev.md](docs/dev.md)
2. [scripts/README.md](scripts/README.md)

## O que o RAGOS nao e

O RAGOS nao quer ser:

- VDI pesado fantasiado de simplicidade;
- desktop stateful por maquina;
- plataforma dependente de ajuste manual escondido;
- colecao de scripts sem fronteira clara;
- distribuicao generica para qualquer topologia.

Se uma decisao aumenta glamour e reduz previsibilidade, a decisao esta errada.
