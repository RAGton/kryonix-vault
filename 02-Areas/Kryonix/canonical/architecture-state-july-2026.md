# Kryonix: Estado da Arte e Arquitetura Consolidada (Julho 2026)

Este documento centraliza todas as conquistas, refatorações e adições arquiteturais recentes que transformaram o ecosistema Kryonix em um motor puramente declarativo, ciente de contexto (context-aware) e com observabilidade nativa, suportado por um orquestrador em Rust (`kryx`) e base NixOS.

## 1. O Fim do Imperativo: Auditoria e Remoção de Fix-it Scripts
**Objetivo:** Eliminar "vibe coding" e a dependência de scripts avulsos no backend de instalação.
- **Ação Executada:** Foram removidos antigos scripts em Python e JS (`apply_semantic_theme.py`, `fix_app.js`, `fix_network_theme.py`, `fix_theme.py`, `fix_ui.js`) dentro do `kryonix-installer`.
- **Resultado:** O instalador baseia-se 100% no `InstallPlanV2` em Rust, que gera configurações `.nix` nativas. Todas as decisões de UI, rede e disco fluem de forma puramente declarativa sem mutações posteriores ("gambiarra").

## 2. Identity Guard (A Bússola do Sistema)
**Objetivo:** Todo nó do ecossistema deve saber exatamente quem é, qual seu papel, e quais seus privilégios antes de operar.
- **Ação Executada:** Implementação do módulo `domain::identity` e `services::identity` no binário `kryx`.
- **Como funciona:** O `kryx` exige a presença de um `/etc/kryonix/identity.json` contendo `uuid`, `role` (Core, Node, ThinkServer, Desktop), e `edition`.
- **Resultado:** **Fail-Fast garantido.** Se o host for um zumbi (sem identidade) ou tiver um JSON corrompido, o motor aborta operações de deploy e modificação de sistema, protegendo a frota contra inconsistências.

## 3. CLI Contextual (Context-Aware CLI)
**Objetivo:** Esconder comandos destrutivos ou irrelevantes de usuários finais, e expô-los apenas para os nodos da frota gerencial.
- **Ação Executada:** O parser do `clap` no `kryx` foi amarrado ao `Identity Guard`.
- **Como funciona:** 
  - Hosts `Core` ou `ThinkServer` possuem a árvore completa de comandos (ex: `deploy`, `node`).
  - Hosts `Desktop` veem apenas ferramentas utilitárias ou `system report`.
  - Hosts não-identificados possuem apenas comandos de resgate como `setup`.
- **Resultado:** Um único binário Rust entregue pela ISO que se molda automaticamente à topologia onde está rodando.

## 4. Estabilidade Industrial: Host Glacier, ZFS e Kernel LTS
**Objetivo:** Refinar os profiles de produção para servidores (como o host `glacier`) para não quebrarem e lidarem perfeitamente com pools de armazenamento crítico.
- **Ação Executada:** Atualização das configurações em `hosts/glacier` e no módulo global de kernel.
- **Como funciona:** 
  - Forçado uso do pacote `linuxPackages_latest_lts` de kernel para o Glacier.
  - Sincronização explícita do boot do ZFS para evitar erros de importação na inicialização (`boot.supportedFilesystems = [ "zfs" ]` e dependências atadas ao `zfs-import-cache.service`).
  - Automação de segurança do pool ativada com `services.zfs.autoScrub.enable = true`.
- **Resultado:** Host `glacier` tolerante a falhas, com risco de bit-rot zerado e previsibilidade máxima de updates no Kernel.

## 5. Inspeção Rápida de Features (`kryx feature list`)
**Objetivo:** Permitir aos agentes (Aura) e ao administrador ver exatamente o que está ativo no sistema em tempo de execução.
- **Ação Executada:** Criado um subcomando em Rust que converte o arquivo `/etc/kryonix/features.json` em uma tabela humana de fácil leitura.

## 6. Observabilidade Nativa: Manifesto de Estado e Telemetria
**Objetivo:** Ter um "Coração Pulsante" no sistema para monitorar a frota sem precisar entrar via SSH e ter rastreabilidade de sucessos de deploy.
- **Ação Executada (Manifesto):** Implementado o `domain::manifest::SystemManifest`. Após todo `kryx deploy` bem sucedido, o `nixos-install` injeta um manifesto JSON em `/var/lib/kryonix/manifest.json` com Timestamp, UUID e Status.
- **Ação Executada (Telemetria):** Desenvolvido o serviço de Telemetria (`report_heartbeat`) que:
  1. Parseia o Manifesto do SO atual.
  2. Executa coleta de hardware nativa: Consulta ao `zpool list` (disco), e `sysfs` térmico (temperatura CPU).
  3. Prepara um JSON e dispara um POST não-bloqueante (usando `ureq` com feature `json`) para `http://thinkserver.local/api/telemetry`.
- **Ação Executada (Systemd):** Módulo NixOS de Telemetria (`telemetry.nix`) configurado para injetar um timer que roda o comando `kryx system report` via `OnCalendar = "hourly"`, garantindo heartbeats previsíveis por toda a frota.

## 7. Próximos Passos Identificados
As seguintes frentes arquiteturais ficaram prontas para desenvolvimento assim que a fundação foi completada:
1. **Kryonix Node Command Center (TUI):** Utilizando o `ratatui` (Rust), para visualizar o mapa do ecosistema, escutando a rede e reagindo ao Identity Guard para se transformar num "Fleet Dashboard" (se Core) ou "Local Dashboard" (se Node).
2. **Think Server Backend:** Receber os POSTs `/api/telemetry` dos nós, atuar na base de dados (SQLite/Postgres), atualizando o tempo de uptime e degradação em tempo real.

---
**Vault Commit Status:** Totalmente auditado. Nenhuma modificação baseada em intuição; todas as decisões deixaram rastro em `.md` no `kryonix-vault` para preservar a memória persistente dos agentes IA.
