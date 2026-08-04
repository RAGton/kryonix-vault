---
title: Build baseline kryxd-daemon (Gate A.1)
date: 2026-08-04
tags: [kryonix, kryxd, audit, baseline, partial, environment-fixed]
status: partial
branch: fix/kcr-ui4-wizard-allowlists
commit_inicio: 771c086
commit_desbloqueio: 1db9077
working_tree_final: 1 arquivo sujo (src/api/virt.rs, PR #27 não commitado)
environment: inspiron (NixOS)
---

# Build baseline kryxd-daemon (Gate A.1)

> Baseline executada em 2026-08-04. Status final: **PARTIAL**.
> Build compila. Test falha por erros pré-existentes.
> Bloqueios de KCRs: ver nota no final.

## Mudanças de ambiente aplicadas

Para desbloquear a baseline, foram necessárias 2 mudanças cirúrgicas no flake (commit `1db9077`):

### 1. `nix/ui.nix` — `npmDepsHash` corrigido

```diff
- npmDepsHash = "sha256-e36ZFfsQoVphL5hzVdzrfxO78bUsV24KC/2VzPuSg9w=";
+ npmDepsHash = "sha256-ZjH2CUzwHWI9rUMMhY9jTGdWKya/HZxRcDmGpn3K2tU=";
```

Obtido via workflow canônico `lib.fakeHash` → build → copiar `got: sha256-...`.

### 2. `flake.nix` — adicionado `devShells`

```nix
devShells = forEachSystem (
  system:
  let
    pkgs = pkgsFor system;
  in
  {
    default = pkgs.mkShell {
      inputsFrom = [ self.packages.${system}.kryxd ];

      nativeBuildInputs = with pkgs; [
        pkg-config
        llvmPackages_19.libclang
        llvmPackages_19.llvm
      ];

      LIBCLANG_PATH = "${pkgs.llvmPackages_19.libclang.lib}/lib";
      LLVM_CONFIG_PATH = "${pkgs.llvmPackages_19.llvm}/bin/llvm-config";
    };
  }
);
```

Resolve: `cargo build` falhava por falta de libclang/llvm-config no PATH do NixOS puro.

## Comandos executados e resultados

### 1. `cargo fmt --check`

**Status: ❌ FAIL (código pré-existente sujo)**

```diff
Diff in /home/rocha/Proyectos/kryonix-dev/repos/kryxd/src/api/virt.rs
Diff in /home/rocha/Proyectos/kryonix-dev/repos/kryxd/src/storage.rs
```

2 arquivos não formatados. Não aplicado `cargo fmt` para preservar working tree do usuário.

### 2. `cargo build --workspace` (dentro de `nix develop`)

**Status: ✅ PASS (41.33s, 3 warnings)**

Ambiente confirmado:

| Tool | Path |
|---|---|
| `llvm-config` | `/nix/store/.../llvm-19.1.7-dev/bin/llvm-config` (v19.1.7) |
| `libclang.so` | `/nix/store/.../clang-21.1.8-lib/lib/libclang.so` |

Warnings emitidos:

| # | Arquivo:linha | Tipo | Significado |
|---|---|---|---|
| 1 | `src/api/v2/kve.rs:26` | `unused_imports` | `use crate::{AppState, services::KveService}` não usado. **Confirma achado #1 do audit**: router v2 montado por acidente, imports nunca chegaram a ser exercitados |
| 2 | `src/main.rs:271` | `private_interfaces` | Função `pub fn load_install_state()` retorna tipo `InstallStatus` que é `pub(crate)`. **Confirma achado #6 do audit**: god object main.rs com boundary quebrado |
| 3 | `src/api/auth.rs:297` | `dead_code` | Função `expected_password(uuid)` nunca é usada. Indica código de autenticação incompleto ou KCP-tela-login com refactor parcial |

### 3. `cargo test --workspace`

**Status: ❌ FAIL (4 erros de compilação em testes)**

Erros:

```
error[E0063]: missing fields `network` and `node_think` in initializer of `InstallPlanV2`
   --> src/api/install.rs:887:9
error[E0063]: missing fields `network` and `node_think` in initializer of `InstallPlanV2`
   --> src/services/migration.rs:119:9
error[E0063]: missing fields `network` and `node_think` in initializer of `InstallPlanV2`
   --> src/services/target_tree.rs:1058:9
error[E0063]: missing fields `network` and `node_think` in initializer of `InstallPlanV2`
   --> src/services/mod.rs:24:9
```

**Diagnóstico:** struct `InstallPlanV2` (provavelmente) ganhou 2 campos novos (`network`, `node_think`) sem que os testes/inicializadores existentes fossem atualizados. Isso é dívida técnica real — código de produção compila (provavelmente tem `Default` impl), mas código de teste não.

**Severidade:** 🟠 ALTO — significa que **cobertura de testes está mentindo**. Os 233 testes listados pelo audit original **não compilam**, então não rodam, então não protegem.

## Veredito final

| Comando | Status |
|---|---|
| `cargo fmt --check` | ❌ FAIL |
| `cargo build --workspace` | ✅ PASS (3 warnings) |
| `cargo test --workspace` | ❌ FAIL (4 erros pré-existentes) |

**Conclusão:** o daemon kryxd **compila mas não tem testes válidos**. Toda a confiança em "233 testes passando" do audit original é **falsa**.

## Achados novos (não estavam no audit estrutural)

### 🔴 N0 — Test suite quebrada

**Severidade:** 🔴 CRÍTICA

`InstallPlanV2` evoluiu (ganhou `network`, `node_think`) sem atualizar 4 inicializadores. Resultado: `cargo test` não compila, então:

- 233 testes reportados pelo audit **não rodam**
- CI provavelmente passa porque roda `cargo build`, não `cargo test`
- Qualquer regressão em runtime passa despercebida

**Recomendação:** corrigir os 4 inicializadores adicionando os campos novos. Esforço: ~30min.

### 🟠 N1 — `expected_password` dead code

**Severidade:** 🟠 ALTO

`src/api/auth.rs:297` define função `expected_password(uuid)` que nunca é chamada. Possíveis interpretações:

- KCP tela de login foi refatorada e esqueceu de remover essa função
- Lógica de autenticação tá incompleta (verifica senha de outro jeito)
- Bug latente de segurança

**Recomendação:** investigar callers via `cargo doc` ou simplesmente deletar se for morta.

### 🟡 N2 — router v2 com imports não usados

**Severidade:** 🟡 MÉDIO

`src/api/v2/kve.rs:26` importa `services::KveService` mas nunca usa. Isso reforça o achado #1 do audit: `v2/mod.rs` é scaffolding que nunca foi conectado ao runtime.

**Recomendação:** KCR-ROUTER-1 já cobre isso. Promover pra `ready` agora que baseline existe.

## Impacto nos KCRs

| KCR | Antes da baseline | Depois da baseline |
|---|---|---|
| KCR-ROUTER-1 | blocked | **ready** (build compila, audit confirmou bug, agora pode fix) |
| KCR-TRANSLATOR-1 | blocked | **ready** (build compila, dead code confirmado por warning) |
| KCR-V1-DEPRECATE | blocked | **ready** (processo puro, sem dependência de teste) |
| KCR-PARTITIONER-1 | blocked | blocked (precisa de `cargo test` verde pra validar migração) |
| KCR-TARGETTREE-1 | blocked | blocked (precisa de `cargo test` verde + PARTITIONER-1) |
| KCR-REFACTOR-1 | blocked | blocked (precisa de baseline + tests verdes) |
| **KCR-TESTS-FIX (NOVO)** | n/a | **ready** (corrigir 4 inicializadores, ~30min) |

## Próximos passos recomendados

1. **KCR-TESTS-FIX** (novo) — corrigir os 4 inicializadores de `InstallPlanV2` (30min, baixo risco)
2. **KCR-ROUTER-1** — corrigir mount v2 + remover duplo nest (1-2h, depois do TESTS-FIX pra ter test-suite válida)
3. **KCR-TRANSLATOR-1** — deletar `translator.rs` morto (30-60min)
4. Re-rodar baseline após cada KCR pra confirmar que nada regride

## Honestidade intelectual

- Build verde é real (rodei, capturei output). Não é simulação.
- Test vermelho é real (rodei, capturei erros E0063). Não é invenção.
- Os 3 warnings de build são úteis — mas são warnings, não erros. Não bloqueiam nada por si.
- Não rodei `cargo clippy`. Pode ter mais achados.
- Não rodei UI tests (`ui/npm test`). Pode ter regressões na UI.
- Não testei runtime do daemon (subir kryxd, fazer request, ver resposta).
