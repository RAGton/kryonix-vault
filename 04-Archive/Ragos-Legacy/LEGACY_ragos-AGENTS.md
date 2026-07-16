# RAGOS Codex Operating Guide

Este arquivo governa o uso de Codex no repositorio RAGOS.

## Missao

O RAGOS opera infraestrutura on-premises para clientes diskless reais em NixOS.

Regras nao negociaveis:

- servidor e o centro operacional;
- cliente e endpoint descartavel;
- boot oficial atual: UEFI + PXE + iPXE + HTTP;
- root oficial atual do cliente: `/nix/store` remoto via NFS (ro) + overlay tmpfs (rw);
- persistencia oficial do usuario: `/home` via NFSv4;
- split-storage obrigatorio no servidor;
- tier de dados em BTRFS;
- inventario externo em `/etc/ragos-inventory/clients.nix`;
- `ragos` opera o servidor;
- `ragc` opera a imagem do cliente.

Nao venda netboot/SquashFS como estado atual enquanto o codigo, os testes e o runbook nao fecharem esse contrato.

## Fontes de verdade por dominio

- `server/`: host `srv-rag`, rede, storage, runtime e servicos
- `client/`: cliente diskless e perfis publicados
- `installer/`: instalacao do host, runtime persistente e contrato da live ISO
- `ragc/`: build, publish, rollback, GC e manifests da imagem do cliente
- `docs/`: documentacao canonica, runbook e material de apoio
- `scripts/tests/`: validacao reproduzivel
- `scripts/ops/`: automacao operacional suportada
- `scripts/lab/`: laboratorio e prova controlada
- `/etc/ragos-inventory/clients.nix`: inventario operacional do parque
- `/var/lib/ragos/runtime/*`: runtime persistente real do host
- `/etc/ragos`: checkout operacional para aplicacao e comparacao, nunca fonte primaria de verdade do repo

## Estrutura local do Codex

- `AGENTS.md`: instrucoes persistentes do projeto
- `.codex/config.toml`: defaults locais do Codex no repo
- `.codex/agents/*.toml`: agentes especializados do projeto
- `.agents/skills/*/SKILL.md`: workflows reutilizaveis do projeto

A estrutura canonica do repo e exatamente esta.

Nao reintroduza:

- `.codex/skills/` como arvore ativa de skills;
- agentes genericos legados quando o repo ja possui agentes canonicos por dominio;
- documentacao que trate qualquer estrutura paralela como fonte equivalente.

## Sequencia obrigatoria para qualquer tarefa

1. Classifique a tarefa: `server`, `client`, `installer`, `ragc`, `docs`, `scripts`, `inventario`, `branding` ou `validacao`.
2. Leia primeiro os documentos canonicos e os pontos de entrada reais da area.
3. Confirme o contrato atual no codigo antes de editar.
4. Mapeie impacto entre camadas antes de tocar naming, fluxo de boot, storage, publish ou inventario.
5. Faca a menor mudanca correta.
6. Rode a validacao minima adequada ao escopo.
7. Atualize docs no mesmo ciclo se o contrato, a operacao ou a arquitetura mudarem.

## Leitura minima por area

- arquitetura geral: `README.md`, `docs/architecture.md`, `docs/boot-process.md`, `docs/storage.md`, `docs/network.md`
- servidor: `docs/server.md`, `docs/runbook.md`, `server/default.nix`, `server/roles/services.nix`, `server/services/*`
- cliente: `docs/client.md`, `client/default.nix`, `client/profiles/*`, `client/modules/boot/*`
- installer: `installer/README.md`, `docs/installer-contract-matrix.md`, `docs/install-plan-schema.md`, `installer/lib/*`, `installer/steps/*`
- publish: `docs/ragc-channels-explained.md`, `ragc/**`, `scripts/tests/test-ragc-phaseA.sh`, `scripts/tests/test-ragc-channels.sh`
- inventario: `docs/network.md`, `server/network/clients-inventory-lib.nix`, `server/roles/services.nix`, `scripts/tests/test-clients-inventory-validation.sh`, `scripts/tests/test-client-inventory-routing.sh`

## Guardrails de documentacao

- Separe explicitamente `estado atual implementado`, `direcao oficial` e `roadmap`.
- Nao descreva `/etc/ragos` ou `/etc/ragos-inventory` como se fossem o repositorio Git de desenvolvimento.
- Nao promova feature planejada a contrato so porque aparece em roadmap ou arquivo historico.
- Quando o codigo contradizer a doc, corrija a doc ou classifique o drift no mesmo ciclo.

## Guardrails de engenharia

- Prefira mudanca pequena, reversivel e reproduzivel.
- Nao misture incidente operacional com refatoracao ampla.
- Nao duplique fonte de verdade entre docs, scripts e modulos.
- Nao esconda comportamento operacional em wrappers mortos ou aliases sem uso real.
- Nao trate screenshot, overlay temporario ou ajuste manual em runtime como prova de entrega.
- Nao use `~/Documents/...` como workspace; esse path e `backup somente leitura`.

## Uso de agentes

Use os agentes em `.codex/agents/` quando o escopo pedir especializacao real:

- `arquitetura`: fronteiras entre `server`, `client`, `installer`, `ragc`, inventario e storage
- `documentacao`: README, docs canonicas, runbook e roadmap
- `installer`: contrato UI/backend/shell/runtime da instalacao do host
- `branding`: Plymouth, SDDM, Plasma, GTK e BrandLab
- `validacao`: testes, lint, checks e smoke checks

Agente nao substitui leitura de codigo. Ele concentra o raciocinio e reduz erro de fronteira.

## Uso de skills

Antes de reinventar workflow, verifique `.agents/skills/`.

`.codex/skills/` foi aposentada neste repo e nao deve voltar como fonte ativa.

Skills devem ser usadas para tarefas repetiveis ou frageis, especialmente:

- auditoria de contrato
- drift documental
- publish e rollback
- inventario, `dnsmasq` renderizado e `by-mac`
- sincronizacao de runbook com comportamento real

## Validacao minima

Escolha a validacao mais barata que prova o contrato tocado.

Prioridades comuns:

- `bash ./scripts/tests/test-clients-inventory-validation.sh`
- `bash ./scripts/tests/test-client-inventory-routing.sh`
- `bash ./scripts/tests/test-runtime-guardrails.sh`
- `bash ./scripts/tests/test-ragc-phaseA.sh`
- `bash ./scripts/tests/test-ragc-channels.sh`
- `bash ./scripts/tests/test-installer-live-media-contract.sh`
- `bash ./scripts/tests/test-day0-contract.sh`

Se algo nao foi executado, declare sem rodeio.

## Entrega esperada

Toda resposta de implementacao deve deixar claro:

- classificacao da tarefa
- contexto confirmado no codigo
- arquivos lidos
- arquivos criados ou atualizados
- validacoes executadas
- riscos remanescentes
- decisao final
