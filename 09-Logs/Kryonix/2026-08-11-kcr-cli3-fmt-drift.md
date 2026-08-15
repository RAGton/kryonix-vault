# KCR-CLI-3-FMT — execução

**Data:** 2026-08-11
**Agente:** Aura
**Branch:** `chore/kcr-cli3-fmt-drift-cleanup`
**Commit:** `cca45c1 kryx-cli: KCR-CLI-3-FMT — drift pré-existente cleanup`
**Base:** `1830525` (KCR-CLI-3-HELP)

## O que foi feito

Aplica `cargo fmt` em 13 arquivos com drift acumulado + corrige warnings
de clippy (`-D warnings`) que bloqueavam o build canon do repo.

### Escopo inicial (6 arquivos, conforme KCR original)

| Arquivo | Mudança |
|---|---|
| `src/cli/kve.rs` | cargo fmt |
| `src/cli/think.rs` | cargo fmt |
| `src/main.rs` | cargo fmt + `match` → `matches!` macro (linha 59) |
| `src/services/diagnostics.rs` | cargo fmt + 5× `collapsible_if` → let-chains + 1× `map_or` → `is_none_or` |
| `src/services/status.rs` | cargo fmt + 10× `collapsible_if` → let-chains |
| `src/services/theme.rs` | cargo fmt + 2× `collapsible_if` → let-chains (KCR mencionava explicitamente) |

### Expansão do escopo (7 arquivos adicionais, autorizada por Gabriel)

Após `cargo fmt` resolver os 6 iniciais, `cargo clippy -D warnings` ainda
falhava em 7 arquivos com drift adicional. Gabriel autorizou via
out-of-band durante a sessão: "pode converta de todos arquivos n tem
problema".

| Arquivo | Mudança |
|---|---|
| `src/client.rs` | cargo fmt + 1× `redundant_field_names` |
| `src/services/env.rs` | 1× `needless_borrows_for_generic_args` |
| `src/services/telemetry.rs` | 1× `needless_borrows_for_generic_args` |
| `src/services/modules.rs` | 1× `unnecessary_map_or` → `is_none_or` |
| `src/services/node.rs` | cargo fmt + 2× `collapsible_if` → let-chains |
| `src/services/translator.rs` | 1× `unused_imports` (`BtrfsStoragePlan` removido) |
| `src/services/deployment.rs` | cargo fmt + fix `items_after_test_module` (`run_factory_reset` movido de linhas 256-339 pra antes do `#[cfg(test)] mod tests` na linha 173) |

**Total: 13 arquivos, +379/-271 linhas, puramente de forma.** Zero mudança
comportamental. Zero novos deps. Zero tests novos.

## Validação

- [x] `cargo fmt --check` global → exit 0
- [x] `cargo clippy --all-targets -- -D warnings` global → exit 0
- [x] `cargo build --release` → OK (~9s)
- [x] Smoke first-class (`kryx --help`) → OK
- [x] Smoke HELP (`kryx gc --help` mostra híbrido, `kryx gc -- --help` mostra só native) → OK, zero regressão
- [x] Help híbrido (Phase HELP, commit `1830525`) preservado

## Edge case resolvido: `items_after_test_module` em `deployment.rs`

Clippy `-D warnings` exige que `#[cfg(test)] mod tests` seja o **último**
item do arquivo. No `deployment.rs`, o `pub fn run_factory_reset` (80 linhas)
estava posicionado DEPOIS do test module (linha 256, test module fechava
em 254). Fix: mover `run_factory_reset` pra antes do test module. Mudança
puramente posicional, zero alteração de lógica. Estratégia aplicada:

1. Deletar corpo da função (deixou assinatura vazia)
2. Inserir função completa antes do `#[cfg(test)] mod tests`
3. Deletar assinatura órfã que sobrou na posição original

## Decisões / observações

- **Fora do escopo original da KCR:** os 7 arquivos extras foram tocados
  após autorização explícita do Gabriel. Mensagem do commit documenta a
  expansão pra rastreabilidade.
- **Let-chains edition 2024:** todas as 19 ocorrências de `collapsible_if`
  (2 theme.rs + 5 diagnostics.rs + 10 status.rs + 2 node.rs) foram
  colapsadas via `&& let Padrão = expr` ou `&& cond_booleana`, consistente
  com a edição 2024 já em uso no projeto (Cargo.toml `edition = "2024"`).
- **Nenhum arquivo fora dos 13 listados foi tocado.** O constraint da KCR
  ("NÃO modifique código fora dos 6 arquivos") foi respeitado na fase
  inicial; a expansão foi decisão humana explícita.
- **`run_factory_reset`:** função inteira (~80 linhas) preservada
  verbatim, só reposicionada. Logs (`println!`), flags (`preserve_home`),
  side effects (`fs::write`) e branches de erro — tudo intacto.

## Push

🟡 **NÃO feito** — Gabriel valida e decide.

## Próximo passo recomendado

1. Gabriel revisar commit `cca45c1` no branch `chore/kcr-cli3-fmt-drift-cleanup`
2. Se aprovado, push + abrir PR contra `feat/kcr-cli3-help-c` (ou `main`
   se HELP já merged)
3. Após merge, seguir pra **Phase B** catch-alls (KCR-CLI-3-B)

## Links relacionados

- [[kryonix-dev/AGENTS.md]]
- [[kryonix-dev/repos/kryx-cli/AGENTS.md]]
- Phase A: `ffb4642`
- KCR-CLI-3-HELP: `1830525`
- KCR-CLI-3-FMT: `cca45c1` (este commit)
