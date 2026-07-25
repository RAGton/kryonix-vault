# Kryonix Release Process & Semver

> Diretriz canônica de versionamento e release para o ecossistema Kryonix.
> Single Source of Truth (SSOT). Todo repo deve referenciar este arquivo.

**Status:** 🟢 Validated
**Data:** 2026-07-24
**Versão da diretriz:** 1.0
**Owner:** Gabriel Aguiar Rocha
**Aprovação:** V22b + V25a (loops autônomos)

---

## Objetivo

Padronizar versionamento, tagging e release em **todos** os repos do ecossistema Kryonix, garantindo rastreabilidade imutável e rollback seguro. Cada commit relevante deve ter um **identificador rastreável** que permita saber "qual commit, em qual repo, em que momento" sem abrir o `git log`.

---

## Resumo

Política unificada baseada em:

1. **Semver** (`MAJOR.MINOR.PATCH`) no manifesto de cada repo (`Cargo.toml`, `package.json`, `flake.nix`).
2. **Git tags anotadas** em cada marco de release (`v1.2.3`) + tags descritivas para pre-releases e snapshots.
3. **Vergen** (build-time) injeta SHA do commit no binário para que `--version` reporte a verdade operacional.
4. **Lockfile canônico** em `/etc/kryonixos/flake.lock` aponta para tags semver quando existem, e revs hex quando não.

---

## Escopo

**Aplica-se a** (repos principais):

- `kryxd` — daemon Rust (backend + UI React/Vite)
- `kryx-cli` — CLI Rust (orquestrador)
- `kryonix` — core NixOS (módulos, features, CLI base)
- `kryonix-vault` — Obsidian Vault (documentação, ADRs, skills)

**Aplica-se a** (subrepos):

- `kryonix-installer` — ISO, TUI, web-kiosk
- `kryonix-brain-lightrag` — RAG engine
- `kryonix-home` — organizador de home directory
- `kryonix-aura` — agente Aura
- `kryonix-assets` — wallpapers, temas, branding

**Não aplica-se a** (read-only):

- `kryonix-dev` (meta-repo) — versionado pelo GitHub, segue próprio ciclo

---

## Política unificada

### Princípios

1. **Semver canônico** no manifesto (single source of truth do versionamento "declarado").
2. **Tag anotada** em cada release de produção (single source of truth do "realmente publicado").
3. **Vergen** em Rust para `--version` reportar SHA real do build.
4. **Lockfile Nix** prefere tag → rev (se tag existe, `nix flake update` resolve via tag).
5. **Semver bumps** são **eventos raros** (releases), não a cada commit.
6. **Commits atômicos** continuam a regra do `disciplined-project-agent` (1 commit por escopo, sem "feat: bump version" na história).

### Mapeamento repo → versionamento

| Repo | Tipo | Manifesto | Build-time SHA | Tag prefix |
|---|---|---|---|---|
| `kryx-cli` | Rust CLI | `Cargo.toml` `[package].version` | `vergen` em `build.rs` | `v` |
| `kryxd` (backend) | Rust daemon | `Cargo.toml` `[package].version` | `vergen` em `build.rs` | `v` |
| `kryxd-ui` | React/Vite | `package.json` `"version"` | `git rev-parse --short HEAD` em `vite.config.ts` | (segue o backend) |
| `kryonix` | Nix flake | `version = "x.y.z"` em `flake.nix` | NixOS computa via `flake.lock` | `v` |
| `kryonix-vault` | Docs | (sem manifesto, versionado pelo Git) | (sem build) | (sem tag, só SHA) |
| Subrepos Rust | Rust | `Cargo.toml` | `vergen` | `v` |
| Subrepos Nix | Nix flake | `flake.nix` | NixOS | `v` |

---

## Procedimento

### Cenário A: bump de patch (1.0.0 → 1.0.1)

Quando: bugfix, regressão, correção de segurança.

```bash
# 1. Garantir working tree limpo
git checkout main && git pull --ff-only

# 2. Editar o manifesto (UMA linha)
# Cargo.toml: version = "1.0.1"
# package.json: "version": "1.0.1"
# flake.nix: version = "1.0.1"

# 3. Commit
git add Cargo.toml
git commit -m "chore(release): v1.0.1

- <bullet list do que mudou no release>
- See CHANGELOG.md for full diff"

# 4. Tag anotada
git tag -a v1.0.1 -m "Release v1.0.1 - <resumo de 1 linha>"

# 5. Push
git push origin main --follow-tags
```

### Cenário B: bump de minor (1.0.x → 1.1.0)

Quando: feature nova (PR mergeado, capability nova, API expandida).

```bash
# Igual ao A, mas major é preservado:
# version = "1.1.0"
```

### Cenário C: bump de major (1.x.x → 2.0.0)

Quando: breaking change, API incompatível, schema V1→V2.

```bash
# Igual ao A, mas com aviso de breaking:
git commit -m "chore(release): v2.0.0

BREAKING CHANGES:
- <bullet list>

Migration guide: <link ou seção>"
```

### Cenário D: tag de snapshot pré-release (sem bump de manifesto)

Quando: marco de PR mergeado que precisa de tag sem alterar o semver declarado.

```bash
# Útil para `nix flake update` preferir tag sobre rev
git tag -a v1.0.1-snapshot-5da3734 5da3734 -m "Snapshot pós-PR #12"
git push origin --tags
```

### Cenário E: adicionar `vergen` ao `kryx-cli` (PR atômico)

Quando: setup inicial de rastreabilidade de build.

```toml
# Cargo.toml
[build-dependencies]
vergen = "8"

[package]
metadata.build-info = true  # opcional
```

```rust
// build.rs
fn main() {
    vergen::EmitBuilder::builder()
        .git_sha(true)
        .git_describe(true, true, Some("v0.0.0"))
        .build_date()
        .emit()
        .expect("Failed to emit vergen");
}
```

```rust
// src/cli/version.rs (ou equivalente)
pub const GIT_SHA: &str = env!("VERGEN_GIT_SHA");
pub const GIT_DESCRIBE: &str = env!("VERGEN_GIT_DESCRIBE");
pub const BUILD_DATE: &str = env!("VERGEN_BUILD_DATE");

pub fn print_verbose() {
    println!("kryx {}", env!("CARGO_PKG_VERSION"));
    println!("  git: {}", GIT_SHA);
    println!("  describe: {}", GIT_DESCRIBE");
    println!("  build: {}", BUILD_DATE);
}
```

---

## Checklist (template para o release agent)

Antes de fazer push de tag de release:

- [ ] Working tree clean (`git status -sb` mostra apenas M/A esperados)
- [ ] Branch = `main` (`git branch --show-current`)
- [ ] HEAD está em sincronia com `origin/main` (`git rev-parse HEAD == origin/main`)
- [ ] Versão bump no manifesto, em UMA linha
- [ ] `cargo build --release` (Rust) ou `nix flake check` (Nix) passou
- [ ] `cargo test` (Rust) ou bateria de teste do CI passou
- [ ] `cargo clippy -- -D warnings` (Rust) sem regressões
- [ ] CHANGELOG.md atualizado (se existir)
- [ ] Commit segue convenção: `chore(release): vX.Y.Z`
- [ ] Tag anotada com `-a -m "..."` (não lightweight)
- [ ] Push com `--follow-tags` (atomicamente commit + tag)
- [ ] PR aberto se for release multi-repo (release coordination)

---

## Riscos

1. **Race condition na tag**: se duas pessoas bumpam ao mesmo tempo, a segunda `git push --follow-tags` falha (fast-forward impossível). Solução: serializar releases via PR/branch feature.
2. **Force push destrói tags**: `git push --force --tags` reescreve histórico de tags. Proibido pela política do agente.
3. **Verge drift entre Nix e Rust**: `vergen` lê do `git` em build-time. Se o build rodar fora do repo (Cachix substituter), o SHA vai ser do source pinado no lockfile, não do source local. Isso é **correto e desejável**.
4. **Vergem no Nix store**: `vergen` roda em build-time, e o SHA do source vai pra dentro do binário. **Sem problema de privacidade** porque o SHA é público.
5. **Lockfile do Nix e tag drift**: se o lock do `/etc/kryonixos/flake.lock` aponta para um rev que **não tem tag**, e depois o upstream cria uma tag, o `nix flake update` **pode reverter** para o rev sem tag. Solução: usar `--override-input` para forçar a tag.
6. **Tag corrompida**: se uma tag for renomeada ou reescrita, o lockfile pode quebrar. Tags são imutáveis por convenção do Git — respeite.

---

## Nix integration (detalhe técnico)

O `nix flake update` resolve inputs nesta ordem de preferência:

1. **Tag exata** (`v1.0.1`) → usa o rev da tag
2. **Tag prefix** (`v1.0`) → usa o rev da tag mais recente com esse prefix
3. **Rev hex** (`5da3734...`) → usa esse rev exato

**Implicação operacional**: se você quer que `nix flake update` siga uma **tag** (e não um rev), crie a tag no upstream e o lockfile vai automaticamente resolver para ela.

Exemplo:

```nix
# kryx-cli/flake.nix (input declaration)
inputs.kryx-cli = {
  url = "github:RAGton/kryx-cli";  # sem rev/branch
  flake = true;
};
```

→ Nix resolve para a tag mais recente (e.g., `v1.0.1`) e popula o `flake.lock` com o `rev` correspondente.

Se você fizer:

```nix
inputs.kryx-cli = {
  url = "github:RAGton/kryx-cli/5da3734f...";  # rev hex explícito
  flake = true;
};
```

→ Nix usa o rev exato, e `nix flake update` **só atualiza se você mudar manualmente** (ou se o rev sumir da origin).

**Recomendação**: prefira `url = "github:RAGton/kryx-cli"` sem rev, deixando o tag `v*` ser a fonte de verdade.

---

## Relação com o lockfile do `/etc/kryonixos`

O lockfile (`flake.lock`) tem 4 secções por input:

```json
{
  "original": { "owner": "RAGton", "repo": "kryx-cli", "type": "github" },  // spec do flake.nix
  "locked": {
    "narHash": "sha256-...",
    "lastModified": 1784838493,  // epoch unix do commit
    "owner": "RAGton",
    "repo": "kryx-cli",
    "rev": "5ab75997e24d7207278e996fd2fdcc344da076a7",  // SHA do commit
    "type": "github"
  }
}
```

**Não tem campo "tag" no lock** — Nix só registra o rev exato. A "preferência por tag" é apenas no `inputs.<name>.url` do `flake.nix` upstream. **Por isso é importante que a tag exista na origin antes do `nix flake update` rodar**, senão o Nix vai resolver para o rev mais recente e a tag não será usada.

---

## Workflow operacional para o agente de release

### 1. Detectar que um release é necessário

Triggers:

- PR mergeado com label `release:minor` ou `release:major`
- Push direto em `main` com mensagem começando com `chore(release):`
- Comando manual de Gabriel: "faça o release do `kryx-cli`"

### 2. Validar pré-condições

```bash
git -C $REPO status -sb  # deve estar clean
git -C $REPO rev-parse --abbrev-ref HEAD  # deve ser main
git -C $REPO fetch origin  # atualizar refs
git -C $REPO rev-parse origin/main
LOCAL=$(git -C $REPO rev-parse HEAD)
REMOTE=$(git -C $REPO rev-parse origin/main)
[ "$LOCAL" = "$REMOTE" ] || { echo "out of sync"; exit 1; }
```

### 3. Determinar novo version

```bash
# Pega o manifesto
if [ -f "$REPO/Cargo.toml" ]; then
  CURRENT=$(grep -E '^version' $REPO/Cargo.toml | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
elif [ -f "$REPO/package.json" ]; then
  CURRENT=$(grep -E '"version"' $REPO/package.json | head -1 | sed -E 's/.*"version":\s*"([^"]+)".*/\1/')
fi

# Incrementa patch (default) ou minor/major conforme contexto
NEXT="1.0.1"  # Gabriel decide
```

### 4. Editar manifesto (1 linha, atômico)

```bash
# Cargo.toml
sed -i "s/^version = \"$CURRENT\"/version = \"$NEXT\"/" $REPO/Cargo.toml
# ou:
# flake.nix
# version = "$NEXT";
```

### 5. Commit + tag + push

```bash
cd $REPO
git add <arquivo-do-manifesto>  # SEMPRE path explícito
git commit -m "chore(release): v$NEXT"
git tag -a "v$NEXT" -m "Release v$NEXT"
git push origin main --follow-tags
```

### 6. Validar propagação

```bash
# Validar que `nix flake update` (em /etc/kryonixos) resolve para a tag
cd /etc/kryonixos
sudo kryx update --force-sync
git diff flake.lock  # se mudou, a tag foi reconhecida
```

---

## Pendências conhecidas

1. **`kryxd-ui` (React/Vite) ainda não tem build-time SHA.** Vercel/Vite pode injetar via `process.env.GIT_SHA` se o build rodar no CI. Pendência: configurar CI/CD com variável de ambiente.
2. **`kryonix-vault` é só SHA, sem semver.** Por ser documentação (não código compilável), fica sem manifesto. Versão = número de PRs mergeados + data. Aceitável.
3. **4 subrepos com detached HEAD**: `kryonix-brain-lightrag`, `kryonix-assets`, `kryonix-home`, `kryonix-aura`. Precisam de `git checkout main` antes de receber atualização. **Não é bloqueador da skill** — a skill é no meta-repo e vale para todos.

---

## Próxima ação

1. Aplicar `kryx-cli` e `kryxd` primeiro (Rust, com `vergen`).
2. Validar que `kryx --version` mostra o SHA real após rebuild.
3. Estender para `kryonix` (Nix flake) com tag `v1.0.0` e version bump.
4. Para cada subrepo com detached HEAD, fazer checkout de main antes de aplicar.

---

#tags: kryonix release semver tagging vergen git-versioning kryx-cli kryxd kryonix
#moc: [[01-MOCs/Mapa - Engenharia de Software]]
#related: [[02-Areas/Kryonix/canonical/kryx-nix-lockdown-pitfalls]]