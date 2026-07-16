# RAGOS Installer

<p align="center">
  <img alt="NixOS" src="https://img.shields.io/badge/NixOS-5277C3?style=for-the-badge&logo=nixos&logoColor=white" />
  <img alt="Nix" src="https://img.shields.io/badge/Nix-7EBAE4?style=for-the-badge&logo=nixos&logoColor=white" />
  <img alt="Linux" src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" />
  <img alt="iPXE" src="https://img.shields.io/badge/iPXE-Network%20Boot-111111?style=for-the-badge" />
  <img alt="NGINX" src="https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white" />
  <img alt="dnsmasq" src="https://img.shields.io/badge/dnsmasq-DHCP%2FTFTP%2FPXE-444444?style=for-the-badge" />
  <img alt="NFS" src="https://img.shields.io/badge/NFS-Shared%20Storage-0A66C2?style=for-the-badge" />
</p>

<p align="center">
  <img alt="Btrfs" src="https://img.shields.io/badge/Btrfs-Storage%20Snapshots-2E8B57?style=for-the-badge" />
  <img alt="Prometheus" src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white" />
  <img alt="Grafana" src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white" />
  <img alt="KDE Plasma" src="https://img.shields.io/badge/KDE%20Plasma-1D99F3?style=for-the-badge&logo=kde&logoColor=white" />
  <img alt="React" src="https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB" />
  <img alt="Rust" src="https://img.shields.io/badge/Rust-000000?style=for-the-badge&logo=rust&logoColor=white" />
  <img alt="Axum" src="https://img.shields.io/badge/Axum-Rust%20Web-2C2C2C?style=for-the-badge&logo=rust&logoColor=white" />
</p>

Instalador oficial do **RAGOS**, responsável por preparar o servidor base, gerar os parâmetros de implantação e executar o pipeline de instalação do ambiente.

Este repositório concentra:

- a composição da **ISO de instalação**;
- o executor shell que prepara disco, rede e executa o `nixos-install`;
- a interface local em **React**;
- o backend local em **Rust/Axum** usado pela UI;
- `params.nix` e os contratos utilizados pelo pipeline de instalação.

---

## Visão Geral

O objetivo deste projeto é transformar a instalação do servidor RAGOS em um processo:

- reproduzível;
- auditável;
- previsível;
- operacionalmente defensável.

A proposta não é esconder a infraestrutura atrás de “mágica”.  
A proposta é organizar o processo de instalação em camadas claras, com contrato explícito entre UI, backend, shell e configuração NixOS.

---

## Escopo do repositório

Este projeto cobre:

- geração da mídia instalável;
- coleta e validação dos parâmetros de instalação;
- preparação de disco e filesystem;
- geração do plano aplicado ao sistema alvo;
- execução do `nixos-install`;
- integração com o repositório principal do RAGOS.

Não cobre, por si só:

- operação do servidor já instalado;
- publicação de imagens de cliente;
- ciclo operacional do `ragc`;
- administração contínua do ambiente diskless em produção.

---

## Componentes principais

| Caminho | Função |
| --- | --- |
<<<<<<< HEAD
| `iso.nix` | Composicao principal da ISO |
| `iso-image-ragos.nix` | Imagem do instalador |
| `bin/ragos-install` | Entry point do instalador shell |
| `ragos-install-runner` | Runner staged da ISO usado pela UI antes do wipe |
| `steps/` | Etapas do pipeline shell |
| `lib/` | Funcoes de apoio do instalador |
| `params.nix` | Parametros escritos para o sistema instalado |
| `partitioning.nix` | Regras de particionamento integradas ao install |
| `installer-ui/` | UI web/local e backend local |
=======
| `iso.nix` | composição principal da ISO |
| `iso-image-ragos.nix` | definição da imagem do instalador |
| `bin/ragos-install` | entry point principal do instalador shell |
| `steps/` | etapas do pipeline shell |
| `lib/` | funções utilitárias e helpers do instalador |
| `params.nix` | parâmetros escritos para o sistema instalado |
| `partitioning.nix` | regras de particionamento integradas ao fluxo |
| `installer-ui/` | interface web/local e backend local |

---

## Arquitetura do instalador

O instalador organiza a execução em quatro camadas principais:

1. **UI local**
   - coleta entradas do operador;
   - valida combinações suportadas;
   - monta o plano de instalação.

2. **Backend local**
   - recebe o plano;
   - normaliza dados;
   - chama o executor de instalação.

3. **Executor shell**
   - particiona discos;
   - monta filesystems;
   - injeta parâmetros;
   - executa o `nixos-install`.

4. **Configuração NixOS**
   - consome `params.nix`;
   - materializa o sistema final instalado.
>>>>>>> 44d53e29fecc58aec2fa94dabc7cf7e48acaf579

---

## Fluxo real suportado hoje

O pipeline atual trabalha com o seguinte contrato de storage:

- `RAGOS_DISK_MODE = one|two`
- `RAGOS_SYS_DISK`
- `RAGOS_DATA_DISK`
- `RAGOS_ROOT_FS`
- `RAGOS_DATA_FS`

### Layouts implementados

- **single disk**  
  um único disco, com raiz em **BTRFS** com subvolumes e dados no mesmo device;

- **split disks**  
  um disco para o sistema e outro para `/srv/data`;

- **RAID explícito**  
  disponível apenas por caminho operacional explícito do executor, nunca por detecção automática de “dois discos encontrados”.

### Status honesto das funcionalidades

| Recurso | Status |
| --- | --- |
| RAID | suportado por caminho opcional e explícito |
| LUKS | suportado no fluxo atual |
| LVM | não implementado ponta a ponta neste repositório |

---

## Filosofia de instalação

O instalador foi pensado para ambientes reais, não para demo bonita.

Isso significa:

- nada de inferência agressiva em disco;
- nada de assumir que “dois discos = RAID”;
- validação explícita antes da execução;
- separação clara entre entrada do operador e efeito real no sistema;
- prioridade em previsibilidade, não em automação irresponsável.

Em português claro: instalar errado rápido continua sendo instalar errado.

---

## Interface web

A UI moderna fica em `installer-ui/` e organiza o mesmo pipeline operacional do instalador shell.

Ela inclui:

<<<<<<< HEAD
- inventario de discos e interfaces;
- validacao de plano antes da execucao;
- preflight antes do wipe via runner dedicado da ISO;
- geracao do plano de instalacao;
- disparo da instalacao com acompanhamento de logs.
=======
- inventário de discos e interfaces;
- validação do plano antes da execução;
- geração do plano de instalação;
- disparo da instalação com acompanhamento de logs;
- integração com o backend local responsável por acionar o pipeline real.
>>>>>>> 44d53e29fecc58aec2fa94dabc7cf7e48acaf579

README específico da UI:

- [installer-ui/README.md](./installer-ui/README.md)

---

## Fluxo operacional resumido

```text
UI React
  -> Backend local Rust/Axum
    -> Executor shell
      -> Particionamento / montagem
        -> params.nix
          -> nixos-install
            -> sistema RAGOS instalado
```

---

## Desenvolvimento local

### UI e backend local

```bash
cd installer-ui
npm install
npm test
npm run build
cargo check
```

### Fluxo shell

Entry point principal:

```bash
bin/ragos-install --help
```

---

<<<<<<< HEAD
## Branding de boot e live ISO

O branding consumido pela ISO fica em dois pontos reais:

- `iso-branding.nix`: tema de boot do GRUB/EFI, splash do BIOS e paleta do console live;
- `iso.nix`: wallpaper do ambiente live e fallback grafico do kiosk.

Os assets sao gerados a partir de `installer-ui/imgs/ragton.png`, sem depender do tema padrao do NixOS no menu de boot.

---

## Relacao com o repositorio principal
=======
## Contratos e fonte de verdade
>>>>>>> 44d53e29fecc58aec2fa94dabc7cf7e48acaf579

A instalação depende de contrato explícito entre as camadas.

Os pontos centrais são:

- plano de instalação gerado pela UI;
- parâmetros serializados para o pipeline;
- `params.nix` como ponto de integração com o sistema alvo;
- regras de particionamento e montagem executadas pelo shell;
- configuração NixOS consumindo os dados finais da instalação.

Sempre que houver mudança em storage, boot, rede, UX do instalador ou parâmetros do sistema final, o contrato entre essas camadas deve ser revisado.

---

## Relação com o repositório principal

Este repositório é consumido pelo monorepo principal **`ragos`** como submodule em `installer/`.

Quando houver mudança aqui:

1. o commit deve ser feito neste repositório;
2. depois o repositório principal deve atualizar o ponteiro do submodule.

---

## Diretrizes para não quebrar o instalador

- não introduzir detecção automática arriscada de layout de disco;
- não expandir contrato de instalação sem revisar UI, backend, shell e `params.nix`;
- não mascarar limitações reais do pipeline;
- não tratar suporte parcial como se fosse suporte completo;
- manter a documentação alinhada com o comportamento real do código.

---

## Resumo

O **RAGOS Installer** não é apenas uma interface gráfica para `nixos-install`.

Ele é a camada de instalação controlada do ecossistema RAGOS, com foco em:

- previsibilidade operacional;
- instalação reproduzível;
- contrato técnico explícito;
- integração limpa com o sistema final baseado em NixOS.

