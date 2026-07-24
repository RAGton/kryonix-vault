# Sessão Concluída: KVE Activation + Lockdown Bypass SSOT

## Resumo

Data: 2026-07-24
Agente: Aura (MiniMax-M3)
Repositórios afetados:
- `kryxd` (https://github.com/RAGton/kryxd.git)
- `kryx-cli` (https://github.com/RAGton/kryx-cli.git)
- `kryonix` (https://github.com/RAGton/kryonix.git)
- `kryonix-vault` (https://github.com/RAGton/kryonix-vault.git)
- meta-repo `kryonix-dev` (`/home/rocha/Proyectos/kryonix-dev/`)
Host Alvo: `inspiron` (Geração 47 ativa em runtime, com KVE Incus + nftables)

## Contexto consultado

- `/home/rocha/Proyectos/kryonix-dev/repos/kryxd/` (PR #12 capability-driven UI já merged)
- `/home/rocha/Proyectos/kryonix-dev/repos/kryx-cli/` (3 commits atômicos criados nesta sessão)
- `/home/rocha/Proyectos/kryonix-dev/repos/kryonix/` (PR #118 URL canônica merged)
- `/home/rocha/Proyectos/kryonix-dev/repos/kryonix-vault/` (skill canônica atualizada)
- `/etc/kryonixos/flake.lock` (lockfile de produção, saneado nesta sessão)
- Skill `devops:kryx-nix-lockdown-pitfalls` (bússola conceitual, já sincronizada)
- `modules/nixos/features/virtualization.nix` no `kryonix` (feature declarativa do KVE)
- `hosts/glacier/default.nix` no `/etc/kryonixos` (referência para a configuração de Incus)

## Mudanças realizadas

### 1. Repositório `kryxd` — Capability-Driven UI (PR #12)
- **3 commits mergeados via PR #12 em `kryxd/origin/main` = `5da3734`**:
  - `5d0bae6` — `feat(ui): fetch and store capability registry on authenticated session`
  - `6df1458` — `refactor(ui): make sidebar navigation dynamic based on host capabilities`
  - `8501606` — `feat(ui): bind KCP datacenter route for server profiles`
- Adiciona `getCapabilities()` e `resolveHostCapabilities()` em `ui/src/lib/api.js` (fail-closed, fallback por role).
- Refatora `Sidebar.tsx` para ocultar seções KCP/KVE quando capabilities são `false`/`unsupported`.
- Conecta `App.jsx` para redirecionar pós-login: `Core/ThinkServer/Node` → `/kcp/datacenter/summary`; `Desktop` → `/desktop/summary`.

### 2. Repositório `kryx-cli` — Lockdown Bypass + Hygiene (3 commits)
- **3 commits em `kryx-cli/origin/main` = `9197436`**:
  - `7bdd5c7` — `chore(kryx-cli): ignore vendor/ build cache` (higiene do repo)
  - `6fb58a4` — `fix(kryx): bypass cli-lockdown in update and node publish` (SSOT canônica)
  - `9197436` — `docs(kryx-cli): add initial README grounded in source` (332 linhas, 22 subcomandos)
- **Patch central do `6fb58a4`**: promove `modules::discover_real_nix_dir()` para `pub` + `#[inline(never)]`. Reaproveitada em:
  - `update.rs::run_update` (linha 89, `Command::new("nix")` direto → bypass com `discover_real_nix_dir`)
  - `node.rs::NodeAction::Publish` (mesmo padrão)
- **Validação empírica**: `nm target/release/kryx | grep discover_real_nix_dir` retorna símbolo `T` na text section, comprovando que o `#[inline(never)]` evitou que LTO descartasse a função.

### 3. Repositório `kryonix` — URL Canônica (PR #118)
- **1 commit merged via PR #118 em `kryonix/origin/main` = `8aa637d4`**:
  - `db1cd607` — `fix(flake): point kryxd + kryonix-assets to canonical https URLs`
- Migra `inputs.kryxd` e `inputs.kryonix-assets` de `git+file:///home/rocha/kryonix-dev/repos/...` (path local quebrado) para `git+https://github.com/RAGton/<repo>.git` (canônico).
- Preserva a justificativa original do comentário: usar `git+` em vez de `github:` para evitar dependência da API REST do GitHub (que apresentou 504 intermitente).
- **`/etc/kryonixos/flake.lock` reescrito** para usar URLs HTTPS — `kryxd = 5da3734` (canônico), `kryxd` via `git+https://github.com/RAGton/kryxd.git`.

### 4. Repositório `kryx-cli` — Resolução direta no Vault (canônica)
- **1 commit em `feat/vault-lockdown-pitfalls-sync-2026-07-24` = `cf5d784`**:
  - `cf5d784` — `docs(vault): sync lockdown pitfalls with kryx-cli 6fb58a4 (SSOT + 3 new call-sites)`
- Atualiza `02-Areas/Kryonix/canonical/kryx-nix-lockdown-pitfalls.md`:
  - Frontmatter → 2026-07-24 com sessão adicional
  - Tabela TL;DR corrigida: `discover_real_nix_dir()` em `modules.rs` (canônica pós-`6fb58a4`)
  - Seção Bug #1 expandida com SSOT explícita
  - Tabela de commits +3 linhas (`7bdd5c7`, `6fb58a4`, `9197436`)
  - Seção de referências +3 entradas (`update.rs`, `node.rs`, `kryx-cli/README.md`)
- Skill `devops:kryx-nix-lockdown-pitfalls` revalidada e já estava sincronizada (frontmatter + seção "Bug #6" + transcript `bug6-update-lockdown-2026-07-24.md`).

### 5. KVE (Incus) Ativado no Inspiron — runtime
- **2 commits em `/etc/kryonixos/main` (= `Kryonixos.git/origin/main`)**:
  - `8d2a5c7` — `feat(inspiron): enable KVE incus feature` (+24 linhas)
  - `b0fcb9d` — `fix(inspiron): enable nftables for incus support` (+5 linhas, fix do assertion)
- Adiciona `kryonix.features.virtualization.incus.enable = true` com config:
  - `storage.backend = "zfs"`, `poolName = "kryonix-incus"`, `source = null` (reusa dataset ZFS `/var/lib/incus` pré-existente)
  - `network.mode = "managed-nat"`, `bridgeName = "incusbr-kryonix"`
  - `ui.enable = false` (leve, sem Web UI por enquanto)
- Adiciona `networking.nftables.enable = true` (Incus não suporta iptables no NixOS).

## Validações executadas

### Backend Rust (`kryx-cli`)
- `cargo build --release`: exit 0 em 8.18s (com `6fb58a4`).
- `cargo clippy -- -D warnings`: 27 errors antes, 27 depois (zero regressão; baseline preexistente).
- `rustfmt --check` nos 3 arquivos do escopo: exit 0.
- `nm target/release/kryx | grep discover_real_nix_dir`: símbolo `T` presente (LTO não descartou).

### Frontend UI (`kryxd`)
- `npm run build`: exit 0, bundle gerado em `dist/`.
- `node --test src/tests/capabilities.test.js`: 3/3 passam.
- 1 falha preexistente: sweep i18n (117 strings hardcoded, fora de escopo desta sessão).

### Runtime NixOS
- `nix flake update --impure` em `/etc/kryonixos`: re-resolveu `kryxd` para `git+https://github.com/RAGton/kryxd.git?rev=5da3734` e `kryonix` para `8aa637d4`.
- `sudo kryx switch`: geração 47 construída e persistida (3379 → 3412 paths, +766 MiB).
- `systemctl is-active incus`: `active`.
- `systemctl is-active nftables`: `active`.
- `systemctl --failed`: 0 unidades.
- Web UI `http://127.0.0.1:8080/api/v1/system/identity`: responde `200 OK` com identidade preservada.

### Compliance (sem secrets)
- Grep regex `(api_key|secret|password|token|passwd)[[:space:]]*=` em todos os diffs staged: clean.
- `git diff --check`: whitespace OK em todos os commits.
- `git add .` proibido — todos os commits usaram paths explícitos.

## Pendências explícitas

1. **PR #1 do `kryonix-vault`** (`feat/vault-lockdown-pitfalls-sync-2026-07-24` → `main`) está aberto e `MERGEABLE`. Decisão de merge fica para o usuário na UI.
2. **Pointer do submodule `kryonix-vault`** no meta-repo `kryonix-dev` ainda não foi atualizado (depende de merge do PR #1).
3. **Sweep i18n** no `kryxd/ui` (117 strings hardcoded) — bug preexistente, fora de escopo.
4. **`Node::Reboot`** stub com log "Mock: não implementado" no `kryx-cli` — substituir por wake-on-lan ou RPC real.
5. **`Setup`** stub literal no `kryx-cli` (imprime "Setup não implementado ainda.") — definir caminho manual ou implementar.
6. **27 erros de clippy preexistentes** em `theme.rs`, `diagnostics.rs`, `status.rs` do `kryx-cli` — sweep independente.

## Próximo passo recomendado

1. Mergear **PR #1** do `kryonix-vault` na UI do GitHub.
2. Atualizar **pointer do submodule `kryonix-vault`** no meta-repo `kryonix-dev` (commit separado, scope único).
3. Quando quiser usar o Incus:
   ```bash
   incus launch images:debian/12 my-debian
   incus list
   incus exec my-debian -- bash
   ```
4. Validar visualmente a Sidebar capability-driven em `http://inspiron.local:8080` (Role=Desktop, deve esconder seções KCP/KVE até o host ser promovido a ThinkServer/Node).

#tags: ai-agent session-log kve-incus lockdown-bypass capability-driven kryxd kryx-cli kryonix kryonix-vault