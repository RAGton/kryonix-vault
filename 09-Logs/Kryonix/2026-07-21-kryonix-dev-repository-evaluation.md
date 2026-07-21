# Avaliação completa do workspace Kryonix Dev

Data: 2026-07-21
Agente: Aura
Escopo: `/home/rocha/kryonix-dev`

## Objetivo

Avaliar o estado atual do meta-repositório Kryonix Dev e dos repositórios oficiais em `repos/` e `raw/`, sem executar operações destrutivas, switch NixOS, build de ISO ou limpeza de mudanças preexistentes.

## Contexto consultado

- `AGENTS.md` do workspace.
- `repos/kryonix-vault/AGENTS.md`.
- `repos/kryonix-vault/VAULT_INDEX.md`.
- `.gitmodules`.
- `README.md`.
- `scripts/status-all.sh`.
- `scripts/validate-all.sh`.
- Manifests principais: `Cargo.toml`, `flake.nix`, `pyproject.toml`, `package.json`.

## Baseline Git

### Meta-repo

- Repo: `kryonix-dev`
- Branch: `main`
- HEAD: `8e3cb3d487c9be2f98b09b8d9379f1dd05ce0936`
- Status: limpo e sincronizado com `origin/main`.

### Repositórios principais sincronizados

| Repo | Branch | HEAD curto | Status |
|---|---:|---:|---|
| `repos/kryonix` | `main` | `d5681dc` | limpo, sync |
| `repos/kryonix-assets` | `main` | `f6b87b3` | limpo, sync |
| `repos/kryonix-vault` | `main` | `bfa4a20` | limpo, sync antes deste log |
| `repos/kryonixos` | `main` | `ae7ad54` | limpo, sync |
| `repos/kryx-cli` | `main` | `8ed4705` | limpo, sync |
| `repos/kryxd` | `main` | `6ea5cb8` | limpo, sync |
| `raw/kryonix` | `main` | `d5681dc` | limpo, sync |
| `raw/kryonix-installer` | `main` | `6ea5cb8` | limpo, sync |

### Repositórios limpos mas atrás do remoto

| Repo | Situação |
|---|---|
| `repos/kryonix-aura` | limpo, `main...origin/main [detrás 1]` |
| `repos/kryonix-brain-lightrag` | limpo, `main...origin/main [detrás 1]` |
| `repos/kryonix-home` | limpo, `main...origin/main [detrás 1]` |
| `raw/kryonix-aura` | limpo, `main...origin/main [detrás 1]` |
| `raw/kryonix-brain-lightrag` | limpo, `main...origin/main [detrás 1]` |
| `raw/kryonix-home` | limpo, `main...origin/main [detrás 1]` |

## Estrutura e composição

Contagem leve por extensão, ignorando `.git`, `target`, `node_modules`, `dist`, `.venv`, caches e builds:

| Área | Arquivos | Top extensões |
|---|---:|---|
| workspace inteiro | 6217 | `.json`, `.md`, `.nix`, `.png`, `.rs`, `.py` |
| `repos/kryonix` | 929 | `.md`, `.nix`, scripts, JSON, Lua, Python |
| `repos/kryxd` | 322 | imagens, Rust, TSX, JSX, JS |
| `repos/kryonix-vault` | 635 | Markdown, PDFs, JSON, CSS |
| `repos/kryonixos` | 44 | Nix, Markdown, JSON |
| `repos/kryonix-brain-lightrag` | 74 | Python, Rust, TOML |
| `repos/kryonix-home` | 33 | Rust, Markdown |
| `repos/kryx-cli` | 28 | Rust, Nix, lockfiles |
| `repos/kryonix-assets` | 71 | PNG, SVG, QML, JPG, Nix |
| `repos/kryonix-aura` | 1 | Markdown |

## Outputs Nix confirmados

### `repos/kryonix`

- `nixosConfigurations`: `iso`, `iso-e2e`.
- Pacotes x86_64-linux: 18.
- Pacotes principais incluem: `kryx`, `kryxd`, `kryonix-home`, `kryonix-brain-lightrag`, `kryonix-branding`, `kryonix-sddm-theme`, `kryonix-wallpapers`, `kryonix-disk-planner`, `kryonix-hardware-probe`.

### `repos/kryonixos`

- `nixosConfigurations`: `glacier`, `inspiron`, `inspiron-nina`.
- `homeConfigurations`: `nina@inspiron-nina`, `rocha@glacier`, `rocha@inspiron`.

### `repos/kryxd`

- Pacotes: `default`, `kryxd`, `kryxdUi`.
- Não expõe `apps.x86_64-linux` no flake.

## Validações executadas

### `./scripts/status-all.sh`

Resultado: todos os repos em `repos/` sem alterações de working tree.

### `./scripts/validate-all.sh`

Resultado geral: PASS para os repositórios com `flake.nix` cobertos pelo script.

- `kryonix`: PASS.
- `kryonix-assets`: PASS.
- `kryonixos`: PASS.
- `kryx-cli`: PASS.
- `kryxd`: PASS.
- `kryonix-aura`: pulado por ausência de `flake.nix`.
- `kryonix-brain-lightrag`: pulado por ausência de `flake.nix`.
- `kryonix-home`: pulado por ausência de `flake.nix`.
- `kryonix-vault`: pulado por ausência de `flake.nix`.

## Achados principais

### ✅ A1 — Estado Git principal está saudável

Os repositórios centrais que acabaram de ser consolidados estão limpos, sincronizados e com validações Nix passando.

Impacto: baixo risco imediato para continuar com validação downstream planejada.

### 🟡 A2 — Documentação do workspace está desatualizada sobre repositórios

`README.md` e `AGENTS.md` ainda citam caminhos que não existem em `repos/`:

- `repos/kryonix-installer`
- `repos/ragos`
- `repos/ragos-installer`

Evidência direta:

- `.gitmodules` possui `repos/kryxd`, mas não possui `repos/kryonix-installer`, `repos/ragos` ou `repos/ragos-installer`.
- No filesystem:
  - `repos/kryonix-installer`: não existe.
  - `repos/ragos`: não existe.
  - `repos/ragos-installer`: não existe.
  - `raw/kryonix-installer`: existe e aponta para o repo `kryxd`.
  - `repos/kryxd`: existe e é o daemon/installer atual.

Risco: agentes podem seguir documentação antiga e tentar editar caminho inexistente.

Recomendação: fazer um commit docs pequeno corrigindo `README.md`, `AGENTS.md`, scripts e referências operacionais para refletir a topologia real: `repos/kryxd` + `raw/kryonix-installer` como compatibilidade/clone bruto, se ainda desejado.

### 🟡 A3 — `scripts/kryonix-test-profile.sh` referencia `repos/kryonix-installer`

O script ainda tenta acessar:

- `$KDEV/repos/kryonix-installer/ui`

Mas esse caminho não existe no workspace atual.

Risco: perfil de teste `installer-critical` ou similar pode falhar por path antigo.

Recomendação: atualizar para `repos/kryxd/ui` ou criar compatibilidade explícita, dependendo da decisão canônica.

### 🟡 A4 — Alguns repos estão limpos, mas um commit atrás

Repos atrás do remoto:

- `kryonix-aura`
- `kryonix-brain-lightrag`
- `kryonix-home`
- equivalentes em `raw/`

Risco: baixo imediato, mas pode gerar divergência silenciosa em auditorias futuras.

Recomendação: executar `pull --ff-only` seletivo nesses repos e atualizar ponteiros no meta-repo, se forem submódulos oficiais ativos.

### 🟡 A5 — `validate-all.sh` cobre apenas flakes e pula projetos importantes

O script pula:

- `kryonix-brain-lightrag`, embora tenha `pyproject.toml`.
- `kryonix-home`, embora tenha `Cargo.toml`.
- `kryonix-aura`, embora seja repo oficial.
- `kryonix-vault`, que deveria ter validação de links/estrutura quando possível.

Risco: falsa sensação de validação completa.

Recomendação: evoluir `validate-all.sh` para detectar por manifest:

- `flake.nix` → `nix flake check`.
- `Cargo.toml` → `cargo check`/`cargo test` via Nix/uv shell quando aplicável.
- `pyproject.toml` → `uv run pytest`/lint configurado quando aplicável.
- Vault → validação própria de estrutura e links.

### 🟡 A6 — TODOs reais em código/profiles

Achados relevantes fora de docs arquivadas:

- `repos/kryonixos/hosts/inspiron/default.nix`: TODO para remover bloco após validar feature.
- `repos/kryonix/profiles/glacier-base.nix`: TODO para migrar para feature `gpu.prime` quando existir.
- `repos/kryonix/packages/kryonix-caelestia-watcher/src/main.rs`: TODO estrutural sobre implementação de edição declarativa.

Risco: médio baixo; não bloqueia estado atual, mas indica dívida técnica real.

### ✅ A7 — Varredura leve de secrets não encontrou arquivos óbvios de credenciais

Busca por nomes sensíveis retornou zero para:

- `.env`
- `*.pem`
- `*.key`
- `id_rsa`
- `id_ed25519`
- `auth.json`
- `credentials.json`

Busca textual encontrou principalmente exemplos, variáveis de ambiente e testes com placeholders/redações. Não houve leitura de segredo real.

## Recomendações priorizadas

### P0 — Antes de switch/runtime

1. Não executar `nixos-rebuild switch` automaticamente.
2. Validar build do host `inspiron` em modo seguro antes da ativação.
3. Depois da ativação, verificar portas `8080`, `3000`, `5173` com `ss`/curl.

### P1 — Corrigir topologia documental

1. Atualizar `README.md` e `AGENTS.md` para remover caminhos inexistentes ou marcá-los como históricos.
2. Corrigir `scripts/kryonix-test-profile.sh` para usar `repos/kryxd` no lugar de `repos/kryonix-installer`, se essa for a decisão canônica.
3. Alinhar `docs/DEVELOPMENT_WORKSPACE.md` e `docs/MULTI_REPO_ARCHITECTURE.md` com `.gitmodules` real.

### P2 — Sincronizar repos um commit atrás

Rodar `git pull --ff-only` apenas em:

- `repos/kryonix-aura`
- `repos/kryonix-brain-lightrag`
- `repos/kryonix-home`
- equivalentes em `raw/`, se ainda forem mantidos.

Depois, atualizar ponteiros no `kryonix-dev` com commit explícito.

### P3 — Melhorar validação global

Evoluir `scripts/validate-all.sh` para não limitar validação a flakes.

## Estado final da avaliação

Status: `VALIDATED`

Nada foi limpo, resetado, removido, aplicado em runtime ou reconstruído em produção. A avaliação ficou limitada a inspeção, validações leves e registro no Vault.
