# P3 — ZFS Replication Planner

Data: 2026-07-16
Agente: Aura
Repos afetados:

- kryxd
- kryonix-vault

## Objetivo

Implementar uma interface e API para planejamento declarativo de replicação ZFS/Disaster Recovery no KCP Storage Command Center, sem executar alterações físicas no filesystem.

## Contexto consultado

- `repos/kryxd/src/api/storage.rs`
- `repos/kryxd/ui/src/lib/api.js`
- `repos/kryxd/ui/src/pages/kcp/Storage.jsx`
- Skill `kryxd-development`
- Skill `kryonix-safe-executor`
- Skill `obsidian`

## Mudanças realizadas

### Backend

- Adicionado `GET /api/v2/storage/replication/status`.
- Adicionado `POST /api/v2/storage/replication/plan`.
- Ambos protegidos por `RequireCoreRole`.
- `replication/status` retorna estado estruturado em modo `planned-only`, sem inspecionar snapshots fisicamente.
- `replication/plan` recebe `source_pool`, `target_host`, `frequency` e retorna um plano NixOS simulado com `services.sanoid` e `services.syncoid`.
- O plano referencia a chave SSH apenas como path abstrato: `/run/secrets/syncoid_key`.
- Adicionadas validações de entrada para dataset, target host e frequência.
- Adicionados testes focados para geração do plano e rejeição de targets com usuário/path.

### Frontend

- Adicionados `getReplicationStatus()` e `generateReplicationPlan(data)` em `ui/src/lib/api.js`.
- Ativada aba `Replication` no `Storage.jsx`.
- Criado formulário com:
  - Source Dataset
  - Target Node IP
  - Frequency
- O botão `Generate Plan` chama o endpoint POST e renderiza o Nix gerado em `<pre><code>`.
- Adicionado botão `Audited / Close` para fechar o plano renderizado.
- UI mantém o visual dark/blue e informa explicitamente que nada é aplicado no filesystem.

## Restrições de segurança verificadas

- Não foram adicionadas chamadas a `zfs send`, `zfs recv` ou `syncoid`.
- O backend não executa comandos ZFS/syncoid via subprocesso para o planner.
- Nenhuma chave SSH é solicitada no frontend.
- O path `/run/secrets/syncoid_key` é usado apenas como referência abstrata no plano Nix.

## Commits e branches

- Nenhum commit realizado.
- Branch observada do installer: `refactor/installer-phase1`.

## Validações executadas

- `cargo check --workspace` — passou, com warning preexistente em `src/api/virt.rs` (`unused import: InstallPlan`).
- `npm run build --prefix repos/kryxd/ui` — passou. Avisos: `/img/noise.png` não resolvido em build time e chunk JS > 500 kB.
- `cargo test api::storage` — passou: 4 testes ok.
- `git diff --check -- src/api/storage.rs ui/src/lib/api.js ui/src/pages/kcp/Storage.jsx` — passou.
- Verificação ad-hoc em `/tmp/nix-shell-266339-3526915383/hermes-verify-*.py` — passou e o script temporário foi removido. Escopo: endpoints `replication/status` e `replication/plan` com RBAC, Nix declarativo sanoid/syncoid com `/run/secrets/syncoid_key`, ausência de `zfs send`/`zfs recv`/subprocesso `syncoid`, UI com aba Replication/form/code block/botão `Audited / Close`, `cargo test api::storage`, `cargo check --workspace`, build Vite, limpeza de `ui/dist` e ausência de logs/docs temporários na raiz.
- `ui/dist` gerado pelo build foi removido após a validação.

## Evidências

- `storage.rs` contém rotas `replication/status` e `replication/plan` somente sob `/api/v2/storage`.
- O planner renderiza Nix com `services.sanoid` e `services.syncoid`.
- A UI usa a aba `Replication` e exibe a string Nix retornada dentro de bloco de código.
- A limpeza da raiz foi mantida: nenhum `implementation_plan.md`, `task.md` ou `*.log` solto nas raízes de `kryxd` ou `kryonix`.

## Pendências

- Teste completo `cargo test` segue bloqueado pela dívida técnica registrada em `03-Projetos/tech-debt/install-topology-test.md`.
- Validar em ambiente real com identidade Core/ThinkServer e Incus/ZFS reais.
- Futuramente conectar o plano gerado ao motor declarativo Nix do Kryonix em vez de apenas exibir a string.

## Próximo passo recomendado

Revisar visualmente a aba Replication pelo Vite e, se aprovado, preparar commits separados: installer e Vault.
