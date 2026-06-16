---
title: PRs Mergeados na Sessão
date: 2026-06-14
type: changelog
status: ongoing
tags: [kryonix, prs, changelog, session-log]
related:
  - "[[00 Index]]"
  - "[[01 DEV-PROD Layout]]"
---

# PRs Mergeados na Sessão Aura 2026-06

Cronologia dos PRs (mais antigo no fundo, mais recente no topo).

## PR #80 — terminal identity KryonixOS

- **Merge commit**: `30d84ad6`
- **Branch (deletada)**: `branding/terminal-identity-p2`
- **3 commits**: meta motd · fastfetch logo · zsh banner
- **Diff**: 3 arquivos, +221 / −114

### Mudanças
- `modules/nixos/branding/kryonix/default.nix`
  - opção `kryonix.branding.motd` (nullable lines)
  - `/etc/motd` auto: "Welcome to <displayName>. Run `kryonix --help`..."
  - `/etc/issue` prefixa "Welcome to "
- `modules/home-manager/programs/fastfetch/default.nix`
  - logo ASCII KryonixOS 10×6 via `pkgs.writeText`
  - cores `$1=cyan` / `$2=magenta`
  - opção `kryonix.programs.fastfetch.logo.enable` (default true)
- `modules/home-manager/programs/zsh/default.nix`
  - welcome curto cyan·magenta no startup interativo
  - opção `kryonix.programs.zsh.welcomeBanner.enable` (default true)
  - opt-out runtime: `export KRYONIX_NO_WELCOME=1`
  - mantém `RAG_ZSH_STARTUP_BANNER=1` para fastfetch completo

### Validações
- `nix flake show`, `nix build .#nixosConfigurations.iso.config.system.build.toplevel`
- `nix build .#kryonix-installer`
- Verificado `cat $TOP/etc/{motd,issue,os-release}` no toplevel da ISO.

---

## PR #78 — clippy sweep no installer

- **Merge commit**: `a83590e2`
- **Branch (deletada)**: `installer/clippy-sweep-p1`
- **1 commit único**: `chore(installer): clean existing clippy warnings`
- **Diff**: 8 arquivos, +91 / −97

### Lints corrigidos (~19 errors)
- `unused_imports` (re-export `run_preflight_install_gate`)
- `collapsible_if` ×7 (let-chains edition 2024)
- `double_ended_iterator_last` (`.last()` → `.next_back()`)
- `manual_contains` (`iter().any()` → `.contains(&name)`)
- `unnecessary_sort_by` (`sort_by` → `sort_by_key + Reverse`)
- `bool_assert_comparison` ×2 (`assert_eq!(x, false)` → `assert!(!x)`)
- `manual_is_multiple_of`
- `absurd_extreme_comparisons` + `unused_comparisons`
- `items_after_test_module` (reordena `verify.rs`)

### Resultado
- `cargo clippy --all-targets --all-features -- -D warnings`: **PASS** (gate real agora).
- `cargo test --locked`: 42/42.
- Resolve issue #77 (criada no fim do PR #72 como pendência).

---

## PR #72 — backend hardening

- **Merge commit**: `395adaec`
- **Branch (deletada)**: `installer/backend-hardening-p1`
- **2 commits**: rescan + validation tests · hostname guard
- **Diff**: 2 arquivos, +194 / −82

### Mudanças
- `network.rs`
  - `rescan_res.unwrap()` → `match` explícito (sem mudança de comportamento)
  - extrai `pub(crate) fn validate_apply_network_request(...)`
  - 7 testes novos para ApplyNetworkRequest (DHCP/static/IP/gateway/prefix/DNS)
- `main.rs`
  - `fn is_valid_hostname(s: &str) -> bool` (RFC-1123 light)
  - `validate_plan` rejeita hostname com shell metas, path traversal
  - 2 testes novos (5 payloads injection + 4 path traversal)

### Validações
- `cargo test --locked`: 42/42 (+9 novos).
- `cargo clippy -D warnings`: FAIL por débito antigo, **encaminhado em #77**.

---

## PR #71 — branding base KryonixOS

- **Merge commit**: `aa70d669`
- **Branch (deletada)**: `branding/kryonixos-identity-p1`
- **3 commits**: os-release · meta/version · UI strings
- **Diff**: 4 arquivos, +17 / −7

### Mudanças
- `kryonix.branding.prettyName` default: `"Kryonix"` → `"KryonixOS"`
- `/etc/os-release` `NAME="KryonixOS"`, `PRETTY_NAME=KryonixOS`
- `ID=nixos` mantido (compat tooling Nix)
- `KRYONIX_PRETTY_NAME = "KryonixOS <prettyName> (v<sha>)"` — bug
  detectado em P3: gerou duplicação após default mudar.
- UI: `Finalizar Instalação do NixOS` → `KryonixOS`
- `wizardState.githubRepo`: `Kryonix/kryonixos` → `RAGton/Kryonixos`

---

## PR #70 — installer UI/network polish

- **Merge commit**: `e84ec73b`
- **Branch (deletada)**: `installer/polish-p1-clean`
- **3 commits**: utilities · network apply · polish display
- **Diff**: 9 arquivos, +285 / −22

### Mudanças
- `utils/network.js` (NOVO, +100): funções puras `isValidIpv4`,
  `netmaskToPrefix`, etc.
- `install-plan.schema.json`: `mgmt.mode = enum["dhcp","static"]`
- `installerApi.applyNetwork()` → POST `/network/apply`
- `App.jsx`: `onNext={handleNetworkNext}` no passo Network (corrige bug
  do `goNext` que não aplicava configuração)
- `Network.jsx`, `RemoteAccess.jsx`, `Summary.jsx`, `Welcome.jsx`: polish
- `Welcome.jsx`: PNG troca por SVG inline com gradiente Kryonix

### Origem dos arquivos
- 8 arquivos da UI vieram do archive `#68` (variante mais madura: tinha
  `handleNetworkNext` + `netmaskToPrefix` refactor)
- `network.js` veio do archive `#67`
- `#65`, `#66`, `#69` **não** entraram aqui — ficam como referência ou
  PRs próprios futuros.

---

## PR #62 — política Git DEV/PROD

- **Merge commit**: `2b322b24`
- **Branch (deletada)**: `worktree-aura-git-dev-prod-skill`
- **2 commits**: docs(ops) · feat(cli)
- **Diff**: 10 arquivos, +1572 / −5

### Mudanças
- Skills entregues:
  - `skills/git-dev-prod/SKILL.md` (canônica, para humanos / agentes)
  - `.claude/skills/git-dev-prod/SKILL.md` (variante para Claude Code)
- Docs em `docs/operations/`:
  - `GIT_DEV_PROD_WORKFLOW.md`
  - `KRYONIX_UPDATE_POLICY.md`
  - `RELEASE_ISO.md`
  - `ROLLBACK_TAGS.md`
- CLI (`packages/kryonix-cli/`):
  - `kryonix_detect_env()` + `kryonix_env_is_prod/dev` + `kryonix_env_policy`
  - `kryonix env [status]` (novo subcomando)
  - `kryonix update` em PROD: bloqueia `nix flake update`; faz apenas
    `git pull --ff-only` + `check` + `diff`
  - `kryonix pull` agora `--ff-only` (era `--rebase`)
  - `update_flake_lock` aborta em PROD

Esse foi **o PR fundacional**. Sem ele, o resto não teria gating
seguro.

---

## PRs draft (preservação histórica, NÃO mergear)

| #  | Branch                                              | Conteúdo                                    |
|----|------------------------------------------------------|---------------------------------------------|
| 65 | `archive/etc-installer-polish-p1-20260613`           | dirty da branch `ui/installer-polish-p1`    |
| 66 | `archive/etc-wt-installer-target-flake-v2-20260613`  | worktree target-flake-v2 (redundante)       |
| 67 | `archive/etc-wt-polish-p1.1-network-20260613`        | worktree polish + `network.js` novo         |
| 68 | `archive/etc-wt-ui-installer-polish-p1-20260613`     | worktree variante UX (mais madura)          |
| 69 | `archive/etc-wt-qdbus-nocore-20260613`               | overlay `qdbus-nocore.nix` isolado          |

Todos ficam abertos como **referência histórica** após o PR #70 cobrir
o trabalho útil de UI. Fechar quando confortável (nada destrutivo, só
limpeza de inbox de PRs).

---

## Issue aberta

- **#77** — clippy sweep (RESOLVIDA pelo PR #78)
- **#79** — chore(ci): fix pre-existing failing workflows (em aberto)

## Cadeia de commits em `main` ao final

```
30d84ad6 Merge pull request #80 from RAGton/branding/terminal-identity-p2
762e7c87 feat(hm/zsh): KryonixOS welcome banner on startup
77b7cc34 feat(hm/fastfetch): KryonixOS ASCII logo with color accents
79db20ed feat(branding): KryonixOS motd and welcome /etc/issue
a83590e2 Merge pull request #78 (clippy sweep)
bf136bde   chore(installer): clean existing clippy warnings
395adaec Merge pull request #72 (backend hardening)
fccd019c   fix(installer): reject hostname with shell metas or path traversal
7e079131   chore(installer/network): explicit rescan handling and pure validation
aa70d669 Merge pull request #71 (branding base)
c6fb80e8   fix(installer-ui): KryonixOS branding strings
3cdc67fe   fix(meta/version): consume kryonix.branding.prettyName
e2dd90ea   fix(branding): default to KryonixOS identity in os-release
e84ec73b Merge pull request #70 (installer UI polish)
5386dc7e   fix(installer-ui): polish remote access and summary display
1fcc0bbf   fix(installer-ui): apply network config before advancing
adabde40   feat(installer-ui): add network plan utilities
2b322b24 Merge pull request #62 (Git DEV/PROD política)
```

Ver: [[01 DEV-PROD Layout]] · [[04 Auditoria Boot Identity P3]]
