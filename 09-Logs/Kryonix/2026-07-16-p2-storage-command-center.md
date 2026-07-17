# P2 — Storage Command Center Read-Only

Data: 2026-07-16
Agente: Aura
Repos afetados:

- kryxd
- kryonix-vault

## Objetivo

Evoluir o KCP Storage Command Center para consumir Storage Pools via API local do Incus em modo read-only e renderizar uma UI industrial com abas e cards.

## Contexto consultado

- `repos/kryxd/src/api/storage.rs`
- `repos/kryxd/src/api/mod.rs`
- `repos/kryxd/src/api/v1/rbac.rs`
- `repos/kryxd/ui/src/lib/api.js`
- `repos/kryxd/ui/src/pages/kcp/Storage.jsx`
- Skill `kryxd-development`
- Skill `kryonix-safe-executor`

## Mudanças realizadas

- Criado registro de dívida técnica em `03-Projetos/tech-debt/install-topology-test.md` para a falha do teste `test_install_endpoint_rejects_unsupported_topology`.
- `GET /api/v2/storage/pools` passou a consultar a API local do Incus via socket Unix (`/var/lib/incus/unix.socket`, sobrescrevível por `INCUS_SOCKET`).
- Endpoint protegido com `RequireCoreRole`.
- Implementado mapeamento read-only para `name`, `driver`, `status`, `locations`, `total_size` e `used_size`.
- Busca adicional de recursos por pool em `/1.0/storage-pools/<pool>/resources`, quando disponível.
- UI `Storage.jsx` refeita com abas `Pools`, `Volumes`, `Snapshots`.
- Aba `Pools` renderiza cards com nome do pool, driver colorido, status de saúde, métricas e locations.
- `Volumes` e `Snapshots` ficam como Coming Soon.
- Empty state em PT-BR: `Nenhum Storage Pool encontrado`, inclusive quando a API falha ou retorna vazio.

## Commits e branches

- Nenhum commit realizado.
- Branch observada do installer: `refactor/installer-phase1`.

## Validações executadas

- `cargo check --workspace` — passou, com warning preexistente em `src/api/virt.rs` (`unused import: InstallPlan`).
- `npm run build --prefix repos/kryxd/ui` — passou. Avisos: `/img/noise.png` não resolvido em build time e chunk JS > 500 kB.
- `cargo test api::storage` — passou: 2 testes ok.
- `git diff --check -- src/api/storage.rs ui/src/lib/api.js ui/src/pages/kcp/Storage.jsx` — passou.
- Verificação ad-hoc em `/tmp/nix-shell-266339-3526915383/hermes-verify-*.py` — passou e o script temporário foi removido. Escopo: endpoint storage com RBAC e Incus via Unix socket, contrato `name/driver/status/locations/total_size/used_size`, ausência de comandos shell `zfs/incus` e rotas mutantes no storage backend, UI com tabs/cards/empty state, `cargo test api::storage`, build Vite e limpeza do `ui/dist`.
- O `ui/dist` gerado pelo build foi removido após a validação para não deixar artefato de build no workspace.

## Evidências

- Backend usa somente chamadas GET para Incus (`/1.0/storage-pools`, detalhe do pool e `/resources`).
- Não foi exposta rota de criação, alteração ou deleção de Storage Pool.
- UI não depende de `zfs list` cru.
- `ui/src/lib/api.js` já apontava `getStoragePools()` para `/api/v2/storage/pools`, então não precisou de alteração nesse arquivo.

## Pendências

- Teste completo `cargo test` segue bloqueado pela dívida técnica registrada em `03-Projetos/tech-debt/install-topology-test.md`.
- Validar em host com Incus real para confirmar shape exato de `/resources` e permissões do socket.
- Resolver warning preexistente `unused import: InstallPlan` em `src/api/virt.rs` em uma limpeza separada.

## Próximo passo recomendado

Subir o backend em uma máquina com Incus local e testar `GET /api/v2/storage/pools` com identidade Core/ThinkServer real, depois abrir o painel KCP pelo Vite e conferir os cards visualmente.
