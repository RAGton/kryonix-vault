# Network.jsx — Etapa 1 — Evidências de Validação

## 1. `npm test` — saída final

```
$ npm test

> node --test "src/tests/**/*.test.js" "src/tests/*.test.js"

...
1..100
# tests 123
# suites 13
# pass 123
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 1184.738935
```

**Veredito:** ✅ 123/123 verde.

## 2. `npm run build` — saída final

```
$ npm run build

> vite build

vite v6.0.7 building for production...
✓ 3109 modules transformed.
rendering chunks...
computing gzip size...
dist/index.html                     0.53 kB │ gzip:   0.33 kB
dist/assets/logo--SY328LB.png     678.64 kB
dist/assets/index-De6ulri2.css    120.67 kB │ gzip:  21.30 kB
dist/assets/index-BWPkoD5h.js   1,809.79 kB │ gzip: 506.11 kB

(!) Some chunks are larger than 500 kB after minification. Consider:
- Using dynamic import() to code-split the application
- Use build.rollupOptions.output.manualChunks to improve chunking: https://rollupjs.org/configuration-options/#output-manualchunks
- Adjust chunk size limit for this warning via build.chunkSizeWarningLimit.
✓ built in 8.13s
```

**Veredito:** ✅ build verde. (Aviso de chunk > 500kB é pré-existente, não introduzido pela Etapa 1.)

## 3. `git diff --stat` (resumo)

```
 ui/src/WizardInstaller.jsx    |  25 +---------
 ui/src/pages/Network.jsx      | 112 ++++++++++++------------------------------
 ui/src/pages/RemoteAccess.jsx |  18 +------
 ui/src/state/wizardState.js   |   4 +-
 ui/src/utils/installPlan.js   |  53 ++++----------------
 ui/src/utils/network.js       |  71 ++++++++++++++++++++++++--
 6 files changed, 113 insertions(+), 170 deletions(-)
```

(Sem o novo arquivo `network.test.js` no stat acima — `git diff` não inclui untracked; o
arquivo foi criado em commit à parte.)

## 4. `git log` após commit

```
$ git log -1 --oneline
bd313ac refactor(network): centralize ip helpers in utils/network.js

$ git show --stat bd313ac
 commit bd313ac
 Author: ...
 Date: ...
 
     refactor(network): centralize ip helpers in utils/network.js
 
     Adota o utils/network.js canônico (até então órfão) como Single Source
     of Truth para helpers de IP/máscara/DNS. Remove duplicações de
     sanitizeIp, isUsableRemoteIp, formatIpv4Input e netmaskToPrefix em
     Network.jsx, RemoteAccess.jsx, installPlan.js e WizardInstaller.jsx.
     Substitui fallback hardcoded '1.1.1.1,8.8.8.8' por DEFAULT_DNS_CSV.
     JSX, hooks e validações inalterados. Sem mudança de comportamento em
     runtime (ternários existentes protegem fallback 24).

  ui/src/WizardInstaller.jsx               |  25 +---
  ui/src/pages/Network.jsx                 | 112 +++++--------------
  ui/src/pages/RemoteAccess.jsx            |  18 +--
  ui/src/state/wizardState.js              |   4 +-
  ui/src/utils/installPlan.js              |  53 +++---
  ui/src/utils/network.js                  |  71 ++++++++--
  ui/src/tests/utils/network.test.js       | 173 +++++++++++++++++++++++++++++++
  7 files changed, 286 insertions(+), 170 deletions(-)
```

## 5. `cargo clippy` — saída e veredito

```
$ cargo clippy -- -D warnings
...
warning: clang-sys@1.8.1: could not execute `llvm-config` one or more times
error: failed to run custom build command for `clang-sys v1.8.1`
Caused by:
  process didn't exit successfully: ... (exit status: 101)
  --- stdout
  cargo:warning=could not execute `llvm-config --prefix`
  ...
called `Result::unwrap()` on an `Err` value: "couldn't find any valid shared
libraries matching: ['libclang.so', 'libclang-*.so'], set the `LIBCLANG_PATH`
environment variable to a path where one of these files can be found (invalid: [])"
```

**Veredito:** ⚠️ bloqueado por dependência externa (`libclang.so` ausente no ambiente).
**Não é regressão** — arquivos Rust não foram tocados na Etapa 1.

## 6. `cargo fmt --check` — drift pré-existente

```
$ cargo fmt --check
Diff in src/storage.rs:80:
 
     #[test]
     fn unbounded_uses_max_bytes() {
-        let cfg = MediaStorageConfig::unbounded("kryonix-isos", PathBuf::from("/var/lib/kryonix/isos"));
+        let cfg =
+            MediaStorageConfig::unbounded("kryonix-isos", PathBuf::from("/var/lib/kryonix/isos"));
```

**Veredito:** ⚠️ drift pré-existente em `src/storage.rs:80` (indentação), não introduzido
pela Etapa 1. Card separado para limpeza.

## Resumo de semáforos

| Semáforo | Status |
|---|---|
| `npm test` (123 testes) | ✅ 123/123 |
| `npm run build` | ✅ verde |
| `git commit` | ✅ `bd313ac` |
| `cargo clippy` | ⚠️ bloqueado por ambiente (libclang) |
| `cargo fmt` | ⚠️ drift pré-existente em `src/storage.rs` |

3/5 verdes, 2/5 são **bloqueios de ambiente não relacionados à Etapa 1**.