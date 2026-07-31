# 2026-07-31 — kryxd storage heuristics + AI Studio cleanup wrap

**Data:** 2026-07-31
**Agente:** Aura (assisted Gabriel)
**Sessão:** kryx-cli/kryxd, branch `main`
**Repos tocados:** `kryxd`, `kryonix-dev` (meta-repo)
**Estado final:** árvore limpa, 4 commits pushed para `origin/main`, daemon restaurado para systemd.

## Objetivo

Recuperar a UI do instalador (tela de Disks) que estava mascarando falhas de API + drifting por sandbox de IA. Encerrar com domínio de storage robusto, tipado e com heurística que blinda o ecossistema (KVE/Incus) contra particionamentos frágeis.

## Resumo em uma frase

De 22 arquivos modificados + 11 untracked de sandbox AI Studio → 4 commits semânticos em `main` + validação E2E em runtime + push pra `origin/main` do `kryxd` e `kryonix-dev`.

## Linha do tempo (4 commits)

| # | SHA | Mensagem | Arquivos |
|---|-----|----------|----------|
| 1 | `1e94064` | `feat(ui): implement capability-driven features and refactor wizard pages` (j√° existia) | 23 |
| 2 | `3be7c0e` | `fix(ui): resolve wifi state rendering and normalize disk api payload` | 2 |
| 3 | `2843d23` | `feat(storage): update storagePlanner domain rules for zfs/btrfs and dynamic FS selection` | 1 |
| 4 | `e500a55` | `refactor(ui): simplify Disks page to Automatic/Manual modes with disk count heuristics` | 4 |
| meta | `2208c4d` | `chore(dev): bump kryxd pointer (storage domain rules + Disks page heuristics refactor)` | 1 |

`kryonix-dev/main` avançou de `5b40f90` → `2208c4d` (1 bump de submodule).

## Diagnóstico fundamentado

### 1. Drift de sandbox AI Studio (P0)

Padrão canônico identificado em `references/ai-studio-drift-cleanup.md`:

- `server.js` injetado mocka `/api/*` e remove proxy pro kryxd real
- `metadata.json` vaza `MAJOR_CAPABILITY_SERVER_SIDE_GEMINI_API`
- `vite.config.js` na raiz substitui `ui/vite.config.js` sem proxy

**Protocolo aplicado (4 passos):**
1. Backup dos artefatos injetados em `/tmp/kryxd-restore-20260730-215712/`
2. `rm -f` dos artefatos na raiz + `ui/.env`
3. `git checkout main -- ui/vite.config.js ui/screenshot.mjs scripts/capture_evidence.sh` (755)
4. Validação: `git status --short` mostra apenas modificações legítimas

Resultado: 22 arquivos modificados **legítimos** (schemas, ui/src, scripts) + 2 screenshots preservados em `~/Proyectos/Rocha-Vault/00-inbox/`.

### 2. Bug estrutural do kryxd (P1)

`/api/disks` retornava **404** porque o handler `get_disks` foi nestado em `legacy_api` no PR de REST v1/v2. O path real é `/api/v1/legacy/api/disks` (com `api/` redundante herdado do prefixo).

**Lado sistema (systemd kryxd):** PATH sem `lsblk` → endpoint retornava 500 `FAILED_TO_LIST_DISKS` mesmo com path correto. Validado em runtime que `target/debug/kryxd` (compilado localmente) + wrapper com PATH completo (`/run/current-system/sw/bin`) conserta.

### 3. WiFi oculto por gates excessivos (P2)

`Network.jsx` tinha `{hasWifi && !wizard.netConnected && !wizard.netOffline && (...)}` no JSX — escondia o painel WiFi mesmo com WiFi dispon√≠vel. Fix:

- Removido `!wizard.netConnected && !wizard.netOffline`
- Adicionado `useEffect` chamando `scanWifi()` automaticamente ao selecionar iface WiFi
- Adicionado `disconnectWifi()` no `installerApi.js` (UX completo)

### 4. KCR-Disks-V2 (reforma estrutural)

**Vocabulário divergente detectado na auditoria (skill §KCR):**
| KCR (solicitado) | Código real |
|------------------|--------------|
| `layoutMode === 'single'` | `wizard.storageMode === 'automatic'` (mapeado internamente) |
| `rootFs`/`dataFs` no dropdown | inexistente — FS era hardcoded via `getDefaultFilesystems()` |
| `['btrfs', 'ext4', 'xfs']` hardcoded | existia só na tabela de particionamento manual |

**Regras estritas aplicadas no `storagePlanner.js`:**
- Single Disk: `rootFs ∈ {btrfs, zfs}` (reject ext4/xfs)
- Split/RAID: `rootFs ∈ {btrfs, zfs, ext4, xfs}` + `dataFs ∈ {btrfs, zfs}` (reject dataFs=ext4/xfs com mensagem de bloqueio)
- `getDefaultFilesystems(layoutMode, overrides={})` aceita overrides

**Heurística UI baseada em contagem:**
| Discos eleg√≠veis | Render |
|------------------|--------|
| 1 | Single Disk + dropdown `rootFs` [btrfs, zfs] |
| 2–3 | Split Disks + `rootFs` [btrfs, zfs, ext4, xfs] + `dataFs` [btrfs, zfs] |
| 4+ | Banner de recomendação RAID/Zpool |

**i18n:** 5 chaves adicionadas (`singleDisk`, `splitDisks`, `rootFs`, `dataFs`, `raidZpoolReco`) em pt-BR/en-US/es-ES com `defaultValue` fallback.

**Correções ad-hoc depois do agente (gaps detectados em build/test):**
- JSX mal-aninhado no bloco `blockedDisks` (1 `</div>` faltando)
- Condição `{blocked.length > 0 && (...)}` que faltava no conditional do map
- 5 strings hardcoded trocadas por `t('...', { defaultValue: '...' })` (test `i18nHardcodedStrings.test.js`)

## Procedimento validado

1. **Limpar drift AI Studio:** backup em `/tmp`, `rm -f` artefatos, `git checkout main --` dos arquivos legados
2. **Validar contrato API:** mapear endpoints reais via `grep` em `src/main.rs`, alinhar `installerApi.js`
3. **Compilar localmente:** `target/debug/kryxd` com bypass do lockdown NixOS (`LIBCLANG_PATH`, `BINDGEN_EXTRA_CLANG_ARGS`, `LIBRARY_PATH`, `RUSTFLAGS`, PATH com clang)
4. **Subir wrapper manual** com PATH completo (`/run/current-system/sw/bin` + dirs do hardware-probe)
5. **E2E visual no Vite** (porta 5173, hot-reload)
6. **Executar KCR via agente executor** background (delegation `deleg_6973c13f`, 144s, 20 chamadas)
7. **Validar pós-agente:** `npm test` (114/114) + `npm run build`, detectar gaps JSX
8. **2 commits atômicos** (domínio + apresentação), separados semanticamente
9. **Push kryxd → bump submodule → push kryonix-dev**

## Resultados quantitativos

| Métrica | Valor |
|---------|------|
| Commits criados | 4 (+ 1 meta-bump) |
| Linhas modificadas | ~410 (Net +220, mas a maioria do commit 1) |
| `npm test` | 114/114 verde em 1.31s |
| `npm run build` | OK em 8.93s |
| `cargo build` (com bypass) | OK em 2m00s |
| E2E disks endpoint | 3 discos (sda 223GiB, zram0 7.7GiB, nvme0n1 476GiB) |
| Working tree final | clean (2 screenshots untracked preservados) |

## Riscos identificados

### Pendente / bloqueador conhecido

**systemd kryxd em produção ainda tem PATH incompleto.** Se o usuário rodar `systemctl start kryxd` (em vez do wrapper manual), o endpoint `/api/v1/legacy/api/disks` retorna 500 com `FAILED_TO_LIST_DISKS`. Fix durável: editar `/etc/systemd/system/kryxd.service` para incluir `/run/current-system/sw/bin` no `Environment="PATH=..."` — **gate humano**, não foi feito hoje.

### Drift pré-existente no meta-repo

`kryonix-dev` tem pointer drift em 6 outros submodules:
- `kryonix-assets`, `kryonix-aura`, `kryonix-brain-lightrag`, `kryonix-home`, `kryonixos`, `kryonix-vault`

Esses são **anteriores** à sessão de hoje e **não foram tocados** (regra §26 anti-scope-creep).

## Quando usar este log como referência

- Padrão para limpar drift de AI Studio/Bolt/IDX (já documentado em `references/ai-studio-drift-cleanup.md`)
- Bypass canônico do lockdown NixOS pra `cargo build --bin kryxd` (5 env vars em `/tmp/kryxd-bypass-env.sh`)
- Padrão KCR com divergência de vocabulário → **sempre auditar antes de patchar** (skill §KCR §4)
- 2 commits atômicos separados (domínio + apresentação) para refactor estrutural
- Vault push protocol (§30): separar `git add` do arquivo do dia de dirty pré-existente

## Arquivos chave da sessão

- `repos/kryxd/ui/src/utils/installerApi.js` — paths consolidados (`/api/v1/legacy/...`)
- `repos/kryxd/ui/src/utils/storagePlanner.js` — `validateFilesystems` privado, regras ZFS/BTRFS estritas
- `repos/kryxd/ui/src/pages/Disks.jsx` — heurística por contagem + i18n
- `repos/kryxd/ui/src/pages/Network.jsx` — gates removidos do painel WiFi
- `repos/kryxd/ui/src/i18n/locales/*.json` — 5 chaves novas

## Pendências e próximos passos

| # | Pendência | Próxima ação | Gate |
|---|-----------|-------------|------|
| 1 | systemd kryxd PATH sem `lsblk` | Adicionar `/run/current-system/sw/bin` ao `Environment="PATH=..."` do unit | humano |
| 2 | Drift em 6 submodules do meta-repo | Triagem em sessão separada | — |
| 3 | Habilitar auto-scan WiFi já está merged (commit 3be7c0e) | Validar E2E com iface WiFi selecionada | nenhum |
| 4 | Atualizar skill `kryonix-installer-development` com o padrão KCR+auditoria | Sessão futura | nenhum |

## Lições duráveis (para Vault MOCs)

- **L1:** AI Studio/Bolt/IDX sempre polui. Detectar via `server.js`/`metadata.json`/`MAJOR_CAPABILITY_SERVER*` antes de tudo.
- **L2:** `lsblk` fora do PATH → 500 silencioso. Wrapper manual com `bash -c "PATH=... kryxd"` resolve sem mexer em systemd.
- **L3:** KCR com vocabulário divergente do código real **sempre auditar antes de patchar**. Diff de `git log -S` + `grep` da função ajuda.
- **L4:** 2 commits atômicos (domínio + apresentação) > 1 patch monolítico. Histórico semântico = auditável.
- **L5:** Subagents paralisam em edge cases de JSX nesting. Validar com `npm run build` antes de devolver.

## Links relacionados

- [[09-Logs/sessions/2026-07-30-kryxd-ai-studio-drift-cleanup]] — log anterior do mesmo dia (fase AI Studio)
- [[08-Referencias/skill-references/kryonix-dev-repo-workflow]] — protocolo §KCR §32
- [[08-Referencias/skill-references/kryx-nix-lockdown-pitfalls]] — Seção 24 do bypass
- [[04-Recursos/playbooks/runbooks/ai-studio-drift-cleanup]] — receituário testado

#kryxd #storage #disks #kcr #ai-studio #drift #cleanup #commit-chain #vault #2026-07