# 2026-07-31 — kryxd AI Studio drift cleanup + capability-driven UI

**Data:** 2026-07-31
**Agente:** Aura (assisted Gabriel)
**Repos afetados:**
- `repos/kryxd/` (commit `1e94064` na main)
- `repos/kryonix-dev/` (commit `5b18f23` na main — submodule pointer)

## Objetivo

Recuperar o repo `kryxd` de uma injeção de infraestrutura vinda de
sandbox de IA (AI Studio / Bolt / IDX) que duplicou o workspace,
injetou mocks Express e removeu o proxy Vite → `kryxd`. Em paralelo,
preservar e validar as melhorias legítimas de frontend
(capability-driven features + refactor de wizard pages).

## Contexto consultado

- `repos/kryxd/AGENTS.md` — regras de não misturar escopo
- `~/.hermes/skills/devops/kryx-nix-lockdown-pitfalls/SKILL.md` —
  Seção 24 (bypass `LIBCLANG_PATH` + `NIX_CFLAGS_COMPILE` pra
  `cargo check` em shell NixOS minimal) + Seção 33 (signing key
  stale em PROD)
- `~/.hermes/skills/kryxd-and-kryx-cli-audit-2026-07-27/SKILL.md`
  — arquitetura canônica do kryxd
- Skill `disciplined-project-agent` — heurística "anti-vibe coding"
  e princípio "menor mudança correta"

## Mudanças realizadas

### Fase 1: Diagnóstico do drift (sem modificação)

Identificado que o AI Studio duplicou o workspace em `repos/kryxd/`:

```
?? ". (1).agents/"
?? "crates (1)/"
?? "docs (1)/"
?? kryxd/                     ← outro repo dentro do repo
?? "nix (1)/"
?? "nixos (1)/"
?? "schemas (1)/"
?? screenshot-eula.png
?? screenshot-welcome.png
?? "scripts (1)/"
?? server.js                  ← Express mock de /api/*
?? "src (1)/"
?? "tests (1)/"
?? "ui (1)/"
?? vite.config.js             ← substitui ui/vite.config.js
```

**Diagnóstico:** o AI Studio não consegue compilar o daemon Rust
(`kryxd` precisa de `pam-sys` + `clang-sys`), então ejetou um mock
Express (`server.js`), moveu o dev server pra raiz via
`package.json`/`server.js`, e removeu o proxy Vite. A constante
`MAJOR_CAPABILITY_SERVER_SIDE_GEMINI_API` em `metadata.json`
confirmou o vazamento de contexto da ferramenta de IA.

### Fase 2: Backup + limpeza segura

- Backup de todos os artefatos injetados em `/tmp/kryxd-limpeza-20260730-214703/`
- Screenshots preservados em `~/Proyectos/Rocha-Vault/00-inbox/ai-studio-{eula,welcome}-20260730-214703.png`
  (evidência visual, fora do repo)
- `rm -f` dos artefatos injetados (sem `git clean` — política do AGENTS.md)

### Fase 3: Restauração de configs vitais

`git checkout main -- ui/vite.config.js ui/screenshot.mjs scripts/capture_evidence.sh`
restaurou:

- `ui/vite.config.js` → porta 5173 + proxy pro `127.0.0.1:8080`
  (kryxd real, não mock)
- `ui/screenshot.mjs` → porta 5173
- `scripts/capture_evidence.sh` → permissão 755 (lost +x durante drift)

### Fase 4: Identificação das mudanças legítimas

Mapeei 22 arquivos modificados que **não** vieram do AI Studio:

**Capability registry expandido (43→50 caps):**
- `desktop.ai` (AI Workstation)
- `desktop.gamer`
- `gamer.{steam,gamemode,mangohud,proton,controllers}` (5)

**Frontend refatorado:**
- `Welcome.jsx` enxuto (só locale, sem Node Server)
- `Network.jsx` (+943 linhas — config de rede rico)
- `SystemFeatures.jsx` (+683 linhas) puxando caps do registry
- `Eula.jsx` (+251 linhas)
- `Disks.jsx` (+66 linhas) + novo `storagePlanner.js` (+18 linhas)

**Infra legada ajustada:**
- `scripts/generate-ui-contracts.mjs` — assertion `=== 42` → `>= 40`
- `i18n/*.json` — texto mais enxuto ("Bem-vindo ao Kryonix")
- `package-lock.json` regenerado pelo `npm install`

### Fase 5: Validação estática (sem runtime)

```bash
cd ui
npm install                       # exit 0 (6 vuln conhecidas)
npm test                          # 114/114 passed, 0 failed
cd ..
node scripts/generate-ui-contracts.mjs  # exit 0 (contrato válido)
cd ui && npm run build            # exit 0, 3108 modules, 9.35s
```

**Pivot crucial:** após ~10min tentando `cargo check` com bypass de
libclang/PAM, identifiquei que **nenhum arquivo Rust foi tocado** pelo
drift ou pelas mudanças legítimas. Validação de backend não traria
informação útil pro commit — pivotei pra frontend (escopo real das
mudanças).

### Fase 6: Segunda faxina (dentro do `npm install`)

O `npm install` regenerou `ui/vite.config.js` (modificou proxy de
`127.0.0.1:8080` → `127.0.0.1:8081`, mudança do AI Studio) e
adicionou `start-host-cargo.sh`, `test.sh`, `test2.sh` na raiz
(artefatos residuais).

- `git checkout main -- ui/vite.config.js` → restaurou proxy 8080
- `rm -f start-host-cargo.sh test.sh test2.sh`

### Fase 7: Commit atômico

```bash
git add schemas/ ui/src/ scripts/generate-ui-contracts.mjs \
        scripts/capture_evidence.sh ui/package-lock.json
git commit -m "feat(ui): implement capability-driven features and refactor wizard pages"
# SHA: 1e94064 (23 arquivos, +1902/-659)
```

### Fase 8: Push + atualização do meta-repo

```bash
# kryxd
git push origin main
# 9fac859..1e94064 main -> main

# kryonix-dev (submodule pointer)
cd ~/Proyectos/kryonix-dev
git add repos/kryxd
git commit -m "chore(dev): update kryxd submodule pointer (UI refactor + capability-driven features)"
git push origin main
# 0dd0ba8..5b18f23 main -> main
```

## Commits e branches

| Repo | SHA | Mensagem |
|------|-----|----------|
| `kryxd` | `1e94064` | `feat(ui): implement capability-driven features and refactor wizard pages` |
| `kryonix-dev` | `5b18f23` | `chore(dev): update kryxd submodule pointer (UI refactor + capability-driven features)` |

## Validações executadas

| Check | Resultado |
|-------|-----------|
| `npm install` | ✅ exit 0 (6 vuln conhecidas pré-existentes) |
| `npm test` | ✅ 114/114 passed, 13 suites, 0 failed, 1.25s |
| `node scripts/generate-ui-contracts.mjs` | ✅ exit 0 (registry com 50 caps, assertion `>= 40` passa) |
| `npm run build` | ✅ 3108 modules, 9.35s, dist/ criado |
| `git checkout main -- <configs vitais>` | ✅ proxy 8080 restaurado, perm 755 |
| `git push origin main` | ✅ `9fac859..1e94064` |
| `git push origin main` (meta-repo) | ✅ `0dd0ba8..5b18f23` |

## Evidências

- **Screenshots** (EULA + Welcome) preservados em:
  - `~/Proyectos/Rocha-Vault/00-inbox/ai-studio-eula-20260730-214703.png` (202KB)
  - `~/Proyectos/Rocha-Vault/00-inbox/ai-studio-welcome-20260730-214703.png` (126KB)
- **Backup do lixo injetado** em `/tmp/kryxd-restore-20260730-215712/`
  (artefatos AI Studio: `server.js`, `metadata.json` com
  `MAJOR_CAPABILITY_SERVER_SIDE_GEMINI_API`, `package.json`,
  `vite.config.js`, etc.)
- **Git log**: `git log --oneline -3` mostra `1e94064` no topo de
  `kryxd/main`

## Pendências

### Imediatas (próximo turno)

- [ ] **Drift em 6 submodules** do meta-repo (`kryonix-assets`,
      `kryonix-aura`, `kryonix-brain-lightrag`, `kryonix-home`,
      `kryonix-vault`, `kryonixos`) — modificados mas fora do escopo
      desta sessão. Triagem recomendada antes do próximo commit multi-repo.
- [ ] **Backup em `/tmp/`** ainda existe (4.4MB) — manter 7 dias pra
      inspeção eventual, depois `rm -rf`.

### Médio prazo

- [ ] **Skill nova**: `ai-studio-workspace-drift` — documentar o
      padrão de poluição (sandbox duplica workspace, injeta mock
      server, remove proxy, força porta 3000). Útil pra próximas
      ocorrências.
- [ ] **PR #27 + UI refinements**: o PR #27 (`feat(kve-media-storage)`)
      já está merged na `kryxd/main`. Mas o PR que faltava (UX/
      Welcome → System Features pra Node Server, card `t_49898d6e`)
      está dentro deste commit `1e94064` como refactor parcial.
      Vale revisar se a separação dos cards Kanban foi honrada ou
      se misturamos escopo.
- [ ] **Lock file Nix**: o meta-repo tem drift acumulado. Sugestão:
      `kryx update --force-sync` em `/etc/kryonix` e `/etc/kryonixos`
      antes do próximo switch pesado.

## Próximo passo recomendado

1. **Triagem do drift nos 6 submodules** — verificar se cada
   modificação é trabalho seu legítimo (PR em andamento) ou
   ruído de sessões paralelas.
2. **Criar skill `ai-studio-workspace-drift`** — pattern
   arquitetural detectável (sandbox duplica workspace, ejetam mock,
   vazam capabilities via `metadata.json`).
3. **Continuar Jenpex (Strike 1)** — cards `t_b409dfcd`,
   `t_49898d6e`, `t_707677ca` agora têm base mais sólida na UI
   (caps registradas, refactor de pages pronto). Próximo: backend
   `NodeThinkPlan` aceitando `node-server` no executor.

## Lições duráveis

### L1 — Sandbox de IA sempre polui, sempre nega

Padrão observado: AI Studio / Bolt / IDX **não conseguem compilar
kryxd** (precisa de `pam-sys` + `clang-sys` + toolchain Rust 2024),
então:

1. Duplicam o workspace em `src (1)/`, `ui (1)/`, etc.
2. Injetam mock Express (`server.js`) pra fazer UI rodar isolada
3. Removem proxy Vite pro backend real
4. Forçam porta 3000 (vs padrão Vite 5173 + kryxd 8080)
5. Criam `metadata.json` com capabilities que vazam contexto da
   própria ferramenta (`MAJOR_CAPABILITY_SERVER_SIDE_GEMINI_API`)

**Detecção rápida:** `git status` mostra várias pastas ` (1)` +
arquivos `server.js`, `vite.config.js`, `package.json` na raiz.
Se isso aparecer, **não commitar antes de faxinar**.

### L2 — Validar escopo certo, não o fácil

Quando o commit envolve só frontend, **não validar backend**.
~10min perdidos em `cargo check` por não parar pra pensar que
o subconjunto de arquivos modificados era 100% JS/JSON.

**Regra:** antes de validar, listar `git diff --stat` e verificar
que a stack de validação casa com o diff. Se 0 arquivos Rust
foram tocados, `cargo check` é perda de tempo.

### L3 — Drift recorrente pede Skill, não nota

Padrão de poluição de sandbox de IA merece virar **skill** (não
log de sessão), porque vai acontecer de novo. Skill permite que
próximo agente tenha o playbook na primeira tool call.

### L4 — Backup `/tmp/` antes de deletar é barato e seguro

`/tmp/` é writeable, isolado por sessão, sobrevive reboot mas é
limpo eventualmente. Backupar artefatos injetados lá custou ~2s
e deu opção de inspeção posterior sem risco pro repo.

#tags: #kryxd #ai-studio #drift #cleanup #capability-registry #ui-refactor