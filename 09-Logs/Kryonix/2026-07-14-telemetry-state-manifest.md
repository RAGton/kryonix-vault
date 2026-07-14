# Implementação de Telemetria e Manifesto de Estado

Data: 2026-07-14
Agente: Antigravity
Repos afetados:
- kryonix

## Objetivo
Implementar o registro do estado do sistema após o deploy (SystemManifest) e ativar um envio de telemetria periódico.

## Contexto consultado
O motor de deploy declarativo precisa sinalizar seu estado de sucesso gerando um manifesto JSON na pasta `/var/lib/kryonix/`. A funcionalidade `kryx system report` usa esse manifesto e coleta dados de hardware adicionais para envio ao servidor central (Think Server).

## Mudanças realizadas
1. **Manifesto de Estado**: Criada a struct `SystemManifest` no `kryx` (`packages/kryx/src/domain/manifest.rs`).
2. **Ciclo de Deploy**: `kryx deploy` agora grava o `manifest.json` com `uuid`, `timestamp`, `flake_revision` e `features_enabled` em `/mnt/var/lib/kryonix/manifest.json`.
3. **Coletor de Telemetria**: Criada a função `report_heartbeat` no `kryx` (`packages/kryx/src/services/telemetry.rs`), que faz o parse do `manifest.json`, coleta uso de disco (ZFS) via `zpool list` e temperatura de CPU lendo os sensores do `/sys`. Estes dados são despachados usando `ureq` para o endpoint `http://thinkserver.local/api/telemetry`.
4. **Comando CLI**: Exposto `kryx system report`.
5. **Systemd Timer**: Implementado `kryx-telemetry.service` e `kryx-telemetry.timer` no módulo NixOS `modules/nixos/services/telemetry.nix`. Agendado para executar OnCalendar `hourly`.
6. Ativada a flag padrão para o módulo `kryonix.services.telemetry.enable = true` no `default.nix` de services.

## Commits e branches
- Core Kryonix: `feat(kryx): implement system manifest struct and telemetry scaffold` e `feat(telemetry): add hardware metrics and systemd timer`

## Validações executadas
- Compilação Rust via `cargo build`.
- Avaliação da árvore Nix completa usando `nix flake check`.

## Pendências
- O `flake_revision` no manifesto ainda é placeholder ("unknown") e precisa ser derivado dinamicamente em runtime ou durante o build.
- A URL de telemetria `http://thinkserver.local/api/telemetry` está fixa, idealmente deve vir da flag/variável de ambiente ou do `features.json`.

## Próximo passo recomendado
Integrar o backend Node Server para escutar as requisições POST `/api/telemetry` e popular a visão do Dashboard (TUI) de Frota do Command Center.
