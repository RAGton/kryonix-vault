---
title: Build baseline kryxd-daemon (Gate A.1)
date: 2026-08-04
tags: [kryonix, kryxd, audit, baseline, blocked, environment]
status: blocked
branch: fix/kcr-ui4-wizard-allowlists
commit: 771c086
working_tree: sujo (src/api/virt.rs)
environment: inspiron (NixOS)
---

# Build baseline kryxd-daemon (Gate A.1)

> Tentativa de baseline de compilação em 2026-08-04.
> **Status final: BLOCKED por ambiente.**
> Bloqueia KCR-TARGETTREE-1 e KCR-REFACTOR-1 (ver `_roadmap_kryxd-daemon-debt.md`).

## Contexto

- Branch: `fix/kcr-ui4-wizard-allowlists` (não main — baseline foi feita em branch de feature por conveniência)
- Commit: `771c086`
- Working tree: 1 arquivo sujo (`src/api/virt.rs`)
- KRYXD_INCUS_SOCKET: unset (correto)
- KRYONIX_AUTH_PASSWORD: unset (modo dev sem auth)

## Comandos executados

### 1. `cargo fmt --check`

**Status: ❌ FALHOU**

```diff
Diff in /home/rocha/Proyectos/kryonix-dev/repos/kryxd/src/api/virt.rs
Diff in /home/rocha/Proyectos/kryonix-dev/repos/kryxd/src/storage.rs
```

**Causa:** código não formatado. Arquivos sujos identificados:
- `src/api/virt.rs`
- `src/storage.rs`

**Ação recomendada:** rodar `cargo fmt` para corrigir, depois validar com `cargo fmt --check`. Não foi aplicado nesta baseline para preservar working tree do usuário.

### 2. `cargo build --workspace`

**Status: ❌ FALHOU (erro de ambiente, não de código)**

```
warning: clang-sys@1.8.1: could not execute `llvm-config` one or more times
error: failed to run custom build command for `clang-sys v1.8.1`

Caused by:
  process didn't exit successfully: `clang-sys-27e3fb2be44ea8ea/build-script-build`
  (exit status: 101)

  called `Result::unwrap()` on an `Err` value: "couldn't find any valid shared
  libraries matching: ['libclang.so', 'libclang-*.so'], set the
  `LIBCLANG_PATH` environment variable to a path where one of these files
  can be found (invalid: [])"
```

**Cadeia de dependências culpada:**

```
kryxd v0.2.1
└── pam v0.8.0
    └── pam-sys v1.0.0-alpha5 [build-dependencies]
        └── bindgen v0.69.5 [build-dependencies]
            └── clang-sys v1.8.1
                └── precisa de libclang + llvm-config
```

**Diagnóstico:** o daemon kryxd depende de `pam` (autenticação Linux PAM) que usa `bindgen` em build-time, que por sua vez exige toolchain C pesado (clang + libclang + llvm-config). Em NixOS puro sem `nix develop` aplicado, essas tools não estão no PATH.

**Tentativas de contorno:**

1. ❌ `which llvm-config` → não encontrado
2. ❌ `find /nix/store -name libclang.so*` → nada no escopo razoável
3. ❌ `nix develop --no-write-lock-file` → falhou por causa do `kryxd-ui` (npmDepsHash drift)

### 3. `nix develop`

**Status: ❌ FALHOU**

```
error: Cannot build '/nix/store/...kryxd-0.2.1-env.drv'.
Reason: 1 dependency failed.

Output paths:
  /nix/store/...kryxd-0.2.1-env

For full logs, run:
  nix log /nix/store/...kryxd-ui-0.1.0.drv
> 1. Use `lib.fakeHash` as the npmDepsHash value
> 2. Build the derivation and wait for it to fail with a hash mismatch
> 3. Copy the 'got: sha256-' value back into the npmDepsHash field
```

**Diagnóstico:** o devShell do flake depende de buildar `kryxd-ui`, que precisa de hash npmDeps válido. O hash está stale (UI lockfile mudou desde a última atualização do `nix/ui.nix`).

### 4. `cargo test --workspace`

**Status: ⏸️ NÃO EXECUTADO**

Depende de build verde. Não foi tentado.

## Veredito

| Comando | Status | Motivo |
|---|---|---|
| `cargo fmt --check` | ❌ FAIL | código sujo em virt.rs e storage.rs |
| `cargo build --workspace` | ❌ FAIL | ambiente sem libclang/llvm-config |
| `nix develop` | ❌ FAIL | kryxd-ui npmDepsHash stale |
| `cargo test --workspace` | ⏸️ NOT_RUN | bloqueado por build |

**Bloqueios estruturais identificados:**

1. **Dependência pesada de PAM** (`pam-sys` → `bindgen` → `clang-sys`) força toolchain C completa para build. Em ambiente NixOS puro isso exige devShell ativo, que por sua vez depende de buildar a UI primeiro.

2. **UI bloqueia devShell** via `npmDepsHash` stale. Para destravar:
   - regenerar hash: `nix-prefetch-url --type sha256 https://registry.npmjs.org/...` ou usar `lib.fakeHash` + 2 builds (workflow canônico Nix)
   - atualizar `nix/ui.nix:11` com hash correto

3. **Working tree sujo** impede baseline limpa. `src/api/virt.rs` e `src/storage.rs` precisam de `cargo fmt` antes de qualquer validação.

## Próximos passos para desbloquear

### Opção A — Ambiente devShell funcional (recomendado)

```bash
# 1. Regenerar npmDepsHash do kryxd-ui
cd ~/Proyectos/kryonix-dev/repos/kryxd
nix-prefetch-url --type sha256 "https://registry.npmjs.org/kryxd-ui/-/kryxd-ui-0.1.0.tgz"
# (ajustar URL/versão conforme package.json)

# 2. Atualizar nix/ui.nix com novo hash
$EDITOR nix/ui.nix

# 3. Entrar no devShell
nix develop

# 4. Rodar baseline
cargo fmt --check
cargo build --workspace
cargo test --workspace
```

### Opção B — Workaround sem devShell (não recomendado)

Instalar libclang manualmente via perfil Nix:

```bash
nix-env -iA nixpkgs.llvmPackages.libclang
export LIBCLANG_PATH=$(nix-env -q --out-path -A nixpkgs.llvmPackages.libclang | tail -1)/lib
export LLVM_CONFIG_PATH=$(nix-env -q --out-path -A nixpkgs.llvm | tail -1)/bin/llvm-config
cargo build --workspace
```

Risco: polui perfil global, pode conflitar com pacotes do sistema.

### Opção C — Limpar working tree primeiro

```bash
cd ~/Proyectos/kryonix-dev/repos/kryxd
cargo fmt
git diff src/api/virt.rs src/storage.rs  # revisar mudanças
git add src/api/virt.rs src/storage.rs
git commit -m "style(kryxd): aplicar cargo fmt"
```

Depois disso, voltar para Opção A.

## Achados correlatos (cross-reference com audit estrutural)

- **Achado #2 do audit (router mount v2 duplicado):** não foi validado em runtime. Baseline bloqueada impede confirmar se o mount duplo causa bug ou funciona "por acidente" como sugerido.
- **Achado #4 do audit (translator.rs morto):** não foi validado. Sem baseline, "dead code" continua sendo hipótese.
- **Achado #6 do audit (partition.rs legado):** não foi validado. Pipeline pode quebrar se for removido.

**Conclusão:** a baseline não respondeu nenhuma das hipóteses do audit estrutural. O próximo Gate (B) não pode começar até que pelo menos uma das Opções A/B/C seja executada.

## Honestidade intelectual

- Esta baseline foi executada em ~10 minutos (3 comandos tentados, 1 background cancelado).
- Não foi tentado `cargo build --no-default-features` nem features específicas — pode haver rota alternativa.
- Não foi consultada documentação oficial de NixOS sobre clang-sys — workaround pode existir documentado.
- Não foi verificado se há CI rodando em outro lugar que tenha passado nessas condições — pode ser que o build só passe em CI e não local.
- O finding sobre `pam` ser dependência pesada é observação, não recomendação. Avaliar se faz sentido pro kryxd depender de PAM é trabalho de design.
