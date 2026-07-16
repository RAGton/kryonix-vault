# Arquivo Histórico: RAGOS (Legacy)

## O que era o ecossistema RAGOS?
O RAGOS nasceu como um projeto autônomo focado em infraestrutura de clientes diskless (boot via PXE, iPXE e SquashFS stateless) com um servidor central controlando o parque através de mounts NFS e configurações provisionadas dinamicamente. Ele operava paralelamente à distribuição principal e mantinha sua própria marca, instalador e CLI (`ragc`).

## Por que foi unificado sob a arquitetura Kryonix Node?
Para reduzir o atrito arquitetural, diminuir as duplicações de código e centralizar todo o *lifecycle* do ecossistema sob um único padrão e binário. 
- O instalador paralelo (`ragos-installer`) e a base modular foram incorporados ao mono-repositório `kryonix` sob o namespace `kryonix/modules/node`.
- A interface de linha de comando (`ragc`) foi absorvida, tornando-se uma coleção de subcomandos do utilitário padrão: `kryx node`.
- A marca e *branding* visual ("Ragos") foram trocados por "Kryonix" / "Kryonix Node", reforçando que agora trata-se apenas de um *perfil de operação* (Node/Think) nativo da distro, e não um sistema operacional separado.

## Metadados da Migração
- **Data da Consolidação e Rebranding:** 2026-07-14
- **Repositórios Obsoletos (Purgados):** `RAGton/ragos`, `RAGton/ragos-installer`
- **Novos Caminhos Canônicos:**
  - Código Core e Perfis (PXE, Servidor, Cliente): `kryonix-dev/repos/kryonix/modules/node/`
  - Motor de Orquestração (Rust): `kryonix-dev/repos/kryonix/packages/kryx/` (comando `kryx node`)
  - Instalador Gráfico: Integrado aos assets e features habilitáveis da iso `kryonix`.

> Este diretório (`04-Archive/Ragos-Legacy/`) preserva os documentos de design, ROADMAPS e manuais originais do projeto por motivos puramente históricos e de auditoria de decisões arquiteturais antigas.
