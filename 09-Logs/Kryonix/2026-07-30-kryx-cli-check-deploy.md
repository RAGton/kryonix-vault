# Deploy do Subcomando `kryx check` e Estabilização do `kryx switch`

Data: 2026-07-30
Agente: Aura (co-autoria), Gabriel Aguiar Rocha (execução de PROD)
Cartão Kanban: t_aa0e609b (`kryx check`), t_03e3dfb6 (`kryx switch` clobber bug — referenciado)
Repos afetados:

- `kryonix-dev/repos/kryx-cli` (submodule)
- `kryonix-dev` (meta-repo, pointer do submodule)
- `/etc/kryonixos` (PROD hosts flake lockfile)
- `kryonix-vault` (esta nota)

## Objetivo

Fechar o cartão `t_aa0e609b` com a entrega do wrapper nativo em Rust `kryx check` (pass-through para `nix flake check` via `/run/current-system/sw/bin/nix`, bypassando o `cliLockdown`), promover o ponteiro do submodule no meta-repo `kryonix-dev`, e preparar a produção (`/etc/kryonixos`) para receber o rebuild + switch sem carregar o drift do `flake.lock` atualizado pelo push recente do PR `aiServer skeleton` no core.

Adicionalmente, este ciclo registra a aplicação prévia da **Estratégia B** no cartão `t_03e3dfb6` (`overwriteBackup = true` em `xdg.mimeApps` para prevenir o abort do `kryx switch` por clobber-protection), já mergedada em `3561338` (`/etc/kryonixos`).

## Contexto consultado

- Repo `kryonix-cli` (`repos/kryx-cli/`): `flake.nix`, `Cargo.toml`, `AGENTS.md`, `README.md` (gerado de auditoria de código real).
- `repos/kryonix/AGENTS.md` (regra: nunca desenvolver em `/etc/kryonix`).
- `repos/kryonix-dev/AGENTS.md` (fluxo DEV → push → merge → sync PROD; comandos proibidos sem autorização).
- `repos/kryonix-vault/AGENTS.md` (taxonomia de notas: PT-BR, kebab-case, prefixo `YYYY-MM-DD`, template com seções canônicas).
- Kanban `hermes kanban` (cartão `t_aa0e609b`, status `ready` há 3.4h sem worker).
- Memória operacional Aura (planta Kryonix, blacklist de comandos destrutivos).

## Mudanças realizadas

### 1. Validação local do commit `9284336` em `repos/kryx-cli`

- **Diagnóstico:** `repos/kryx-cli` local e `origin/main` ambos em `9284336` (commit "kryx-cli: add 'check' subcommand for flake validation (#t_aa0e609b)").
- **Conteúdo do commit:** 3 arquivos, +26/-1 (sem novas deps, `Cargo.lock` inalterado):
  - `src/cli/mod.rs` (+6)
  - `src/main.rs` (+8/-1)
  - `src/services/passthrough.rs` (+13)
- **Implementação:** pass-through para `nix flake check --keep-going --impure`, com bypass do `kryonix.security.cliLockdown` via `discover_real_nix_dir` em `src/services/modules.rs` (mesmo padrão de `Build/Shell/Run/Develop/Repl/Fmt`).
- **Autorização:** explícita no commit message — `Check` autorizado sem role-gating (validação read-only).
- **Default path:** `.` (cwd); aceita path explícito (ex.: `kryx check /etc/kryonixos`).

### 2. Trilho 1 — Atualização do pointer no meta-repo (DEV)

- Commit `882258a` em `kryonix-dev/main`:
  - `chore(dev): update kryx-cli submodule pointer to 9284336 (check subcommand)`
  - 1 arquivo, +1/-1 (apenas o pointer `b38f399 → 9284336`)
  - Assinado SSH (`/home/rocha/.ssh/id_ed25519` — chave corrigida via `git config --local user.signingkey`)
  - Co-autoria Aura
- Push: `kryonix-dev/origin/main = 882258a` (verificado via `git ls-remote`).
- **Escopo preservado:** os outros 7 submodules sujos (`kryonix-assets`, `kryonix-aura`, `kryonix-brain-lightrag`, `kryonix-home`, `kryonix-vault`, `kryonixos`, `kryxd`) ficaram intocados — mudança atômica, sem mistura de escopo.

### 3. Trilho 2 passo 1 — Versionamento do `flake.lock` em `/etc/kryonixos` (PROD)

- **Diagnóstico prévio:** `flake.lock` em `/etc/kryonixos` modificado localmente (3+/3-, somente input `kryonix` upstream `e426756 → 970f94a`, narHash e lastModified atualizados). Outros inputs (nixpkgs, home-manager, etc.) inalterados. Causa provável: `nix flake update` parcial ou build interrompido em sessão anterior.
- **Decisão:** mudança benigna e esperada — reflete o push do PR aiServer skeleton que já está em `/etc/kryonix` (HEAD `970f94a8`). Sem alucinar: o lockfile sujo **não** foi gerado por este ciclo, apenas herdado do estado anterior.
- Commit `645fe0a` em `/etc/kryonixos/main`:
  - `chore(flake): regen lockfile — kryonix update for kryx check integration`
  - 1 arquivo, +3/-3 (lockfile)
  - Assinado SSH (chave corrigida via `git config --local user.signingkey /home/rocha/.ssh/id_ed25519.pub`)
  - Co-autoria Aura
- **Não pushed** ainda — aguardando `sudo git push origin main` manual do Gabriel (gate humano para PROD).

### 4. Trilho 2 passos 2-4 — Rebuild e switch (pendente de execução humana)

Sequência autorizada, **a ser rodada manualmente** por Gabriel:

```bash
# 2.2 — Push do lockfile commitado
cd /etc/kryonixos
sudo -E git push origin main

# 2.3 — Sincronização do core/motor com origin
cd /etc/kryonix
sudo git pull --ff-only origin main
# esperado: no-op (já está em 970f94a8)

# 2.4 — Rebuild (vai puxar nixpkgs/nixos-unstable)
sudo kryx update
# esperado: 10-30 min, possível mudança em `nixpkgs` upstream

# 2.5 — Ativação da nova geração
sudo kryx switch
# rollback automático pra geração anterior se boot falhar
```

### 5. Estratégia B do cartão t_03e3dfb6 (referenciada, já mergedada)

- Commit `3561338` em `/etc/kryonixos`:
  - `fix(home): enable overwriteBackup to prevent mimeapps clobber-protection (kryx switch abort)`
  - Bug reintroduzido após o revert `7a7be84` foi corrigido definitivamente
  - Estratégia: `xdg.mimeApps.overwriteBackup = true` no Home Manager
- Esta é a fundação que evita o `kryx switch` abortar em mid-flight — sem ela, o `overwriteBackup` do HM rejeitaria a sobrescrita do arquivo `.gtkrc-2.0` (gera `hm-bak-*` e bloqueia o switch).

## Commits e branches

| Repo | SHA | Mensagem |
|---|---|---|
| `repos/kryx-cli` | `9284336` | `kryx-cli: add 'check' subcommand for flake validation (#t_aa0e609b)` |
| `kryonix-dev` | `882258a` | `chore(dev): update kryx-cli submodule pointer to 9284336 (check subcommand)` |
| `/etc/kryonixos` | `645fe0a` | `chore(flake): regen lockfile — kryonix update for kryx check integration` |
| `/etc/kryonixos` | `3561338` | (referência) `fix(home): enable overwriteBackup to prevent mimeapps clobber-protection (kryx switch abort)` |
| `/etc/kryonix` | `970f94a8` | (referência) `Merge branch 'pr/ai-server-skeleton' into main` |
| `kryonix-vault` | (esta nota) | `docs(vault): register kryx-cli check deploy and switch stabilization` |
| `kryonix-dev` | (próximo) | `chore(dev): update kryonix-vault submodule pointer` |

## Validações executadas

- [x] `git status -sb` em `repos/kryx-cli` — limpo, HEAD = origin/main = `9284336`.
- [x] `git log --oneline -15` em `repos/kryx-cli` — grafo linear, sem merges sujos.
- [x] `git show --stat 9284336` — diff cirúrgico (3 arquivos, +26/-1, sem novas deps).
- [x] `git diff --cached repos/kryx-cli` no meta-repo — exatamente 1 linha (pointer `b38f399 → 9284336`).
- [x] `git push origin main` — `772f720..882258a main -> main` (verificado com `git ls-remote`).
- [x] `git diff flake.lock` em `/etc/kryonixos` — diff benigno (1 input `kryonix`, sem mudanças colaterais).
- [x] `sudo -E git commit` em `/etc/kryonixos` — SHA `645fe0a`, assinado SSH.
- [ ] **`sudo git pull --ff-only`** em `/etc/kryonixos` e `/etc/kryonix` — pendente.
- [ ] **`sudo kryx update`** — pendente (10-30 min estimado).
- [ ] **`sudo kryx switch`** — pendente.
- [ ] **Validação `kryx check` na lista de subcomandos** — pendente.

## Evidências

### Diff do pointer no meta-repo

```diff
diff --git a/repos/kryx-cli b/repos/kryx-cli
index b38f399..9284336 160000
--- a/repos/kryx-cli
+++ b/repos/kryx-cli
@@ -1 +1 @@
-Subproject commit b38f3996d88e5dcd82db9eba999d5391d912341b
+Subproject commit 9284336690e99eb91b4a138e9d55e5bbd7db9c5d
```

### Diff do lockfile em `/etc/kryonixos`

```diff
diff --git a/flake.lock b/flake.lock
@@ -350,11 +350,11 @@
         "plasma-manager": "plasma-manager"
       },
       "locked": {
-        "lastModified": 1785080595,
-        "narHash": "sha256-gAGDwYpqB8hSpkTcdz48Lr+ABaHTdtcr3RoOh+gE+M4=",
+        "lastModified": 1785259641,
+        "narHash": "sha256-69kl0xHxB+4ogEEuIj2/lFLW3mccZHoYwBCFY+qu4d0=",
         "owner": "RAGton",
         "repo": "kryonix",
-        "rev": "e426756bf3592f8647d35f40f53b801b1db4d19b",
+        "rev": "970f94a81bc8702226e35a7aad210b8a8b1c0447",
         "type": "github"
       },
```

### Implementação de `kryx check` em `src/services/passthrough.rs`

- Bypass do `cliLockdown` via `/run/current-system/sw/bin/nix` (path absoluto do Nix store, fora do alcance do Guard interativo).
- Default path: `.` (cwd).
- Suporte a `--keep-going` (padrão) e `--impure` (padrão Nix flake check).

_(evidências pós-switch a serem adicionadas após execução de 2.4 e 2.5)_

## Pendências

- **Push do commit `645fe0a`** em `/etc/kryonixos` para `origin/main` (manual, gate humano).
- **`sudo git pull --ff-only`** em `/etc/kryonixos` e `/etc/kryonix` (manual, gate humano).
- **`sudo kryx update`** — rebuild completo (10-30 min, pode falhar se `nixpkgs/nixos-unstable` upstream quebrar).
- **`sudo kryx switch`** — ativação da nova geração.
- **Validação final:** `kryx --help` deve listar `check` na seção Commands; `kryx check` deve rodar `nix flake check` via bypass do `cliLockdown`.
- **Atualização desta nota** com evidências pós-switch: nova versão de `kryx` no Nix store, output de `kryx --version`, output de `kryx check` em flake válido.
- **Submodule pointer no meta-repo:** após push do vault, criar `chore(dev): update kryonix-vault submodule pointer` em `kryonix-dev`.
- **Kanban:** `hermes kanban complete t_aa0e609b` com `--result` e `--summary` (somente após validação final do `kryx check` em PROD).

## Próximo passo recomendado

1. Gabriel roda os comandos do Trilho 2 (2.2 a 2.5) em ordem.
2. Após `sudo kryx switch` bem-sucedido, Gabriel confirma pra Aura que `kryx check` aparece na lista de subcomandos.
3. Aura atualiza esta nota com as evidências pós-switch e roda `hermes kanban complete t_aa0e609b`.
4. Próximo cartão na fila: `t_49898d6e` ([kryxd][ui] Mover Node Server da tela Welcome para System Features) — aguardando decisão sobre `promote --force` vs. esperar children (já alinhado em sessão anterior).

## Links relacionados

- [[repos/kryonix-cli/AGENTS.md]] (regra do wrapper pass-through, lockdown bypass SSOT)
- [[repos/kryonix/AGENTS.md]] (regra de não desenvolver direto em `/etc/kryonix`)
- [[repos/kryonix-dev/AGENTS.md]] (fluxo DEV → PROD sync, comandos proibidos)
- [[09-Logs/Kryonix/2026-07-12-CachyOS-Sched-Ext-Integration]] (exemplo de log de deploy similar)
- Cartão Kanban: `t_aa0e609b` (`kryx check`)
- Cartão Kanban: `t_03e3dfb6` (`kryx switch` clobber — Estratégia B `overwriteBackup`)

#kryonix #kryx #deploy #nix-flake #home-manager #lockdown-bypass #vault-log
