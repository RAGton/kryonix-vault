# KCR-CLI-3-HELP — implementação do help híbrido (Opção C)

**Data:** 2026-08-11 08:04
**Agente:** Aura
**Repos afetados:**
- `repos/kryx-cli` (1 commit atômico em `feat/kcr-cli3-help-c`, base `ffb4642`)

## Objetivo

Implementar **Opção C** do help híbrido pra os 5 catch-alls da Phase A
(`gc`, `home-manager`, `copy-closure`, `nix-env`, `nix-channel`):
renderizar **seção kryx estática + output nativo do `binary --help` inline**,
com `kryx <cmd> -- --help` continuando a funcionar como atalho só-nativo
(convenção Unix).

## Contexto consultado

- `kryonix-dev/AGENTS.md` — política de worktree, paths DEV vs PROD, Vault obrigatório
- `kryonix-dev/repos/kryx-cli/AGENTS.md` — regras específicas do repo
- `kryonix-dev/repos/kryx-cli/src/services/passthrough.rs` (Phase A intacto)
- `kryonix-dev/repos/kryx-cli/src/cli/mod.rs` (5 clap variants Phase A)

## Mudanças realizadas

**4 arquivos modificados, +412/-70:**

1. **`src/services/passthrough.rs`** (núcleo):
   - `KryxHelp` struct com builder ergonômico (`new`, `option`, `example`, `note`) + `Display` impl
   - 5 help constants (`help_gc`, `help_home_manager`, `help_copy_closure`, `help_nix_env`, `help_nix_channel`) cacheadas via `std::sync::OnceLock` (Rust 1.70+, zero deps)
   - `help_for_binary(binary_name) -> Option<&'static KryxHelp>` dispatcher
   - `help_text(binary, kryx_help) -> String` renderiza seção kryx + invoca `binary --help` via `discover_real_bin` + `Command::new`
   - `run_passthrough_with_help(binary_name, fallback, args, label)` wrapper que detecta `--help`/`-h` (com workaround clap `--`) e despacha
   - 5 handlers Phase A migrados pra nova função (lógica Phase A 100% preservada — só adiciona camada de help detection)

2. **`src/cli/mod.rs`**: `disable_help_flag = true` em cada um dos 5 variants Phase A (faz clap NÃO interceptar `--help`, deixa nosso handler tratar)

3. **`README.md`**: nota curta sobre help behavior logo após a tabela Phase A

4. **`AGENTS.md`**: nova seção `§HELP` documentando o workaround do `--` consumido pelo clap

## Commits e branches

- Branch: `feat/kcr-cli3-help-c` (forked de `feat/kcr-cli3-phase-a-catch-alls` em `ffb4642`)
- Commit: `1830525 kryx-cli: KCR-CLI-3-HELP — hybrid help (kryx + native inline)`
- Push: **NÃO FEITO** (Gabriel decide conforme constraint da KCR)

## Validações executadas

| Check | Resultado |
|---|---|
| `cargo build --release` | OK (~35s, exit 0) |
| `cargo clippy` no escopo (`passthrough.rs`, `cli/mod.rs`) | ZERO warnings |
| `cargo fmt` no escopo | CLEAN (sem mudanças adicionais) |
| Smoke `kryx <cmd> --help` × 5 | Todos mostram kryx + native (2 matches cada) |
| EDGE 1: `kryx gc -- --help` | SÓ native help (0 matches `kryx-gc`, 542 linhas = man page nativo) |
| EDGE 2: `kryx gc` sem args | Passthrough normal (`finding garbage collector roots... deleting garbage...`) |
| EDGE 3: `kryx gc --delete-older-than 30d --help` | Passthrough pro native (mostra man page, 0 matches `kryx-gc`) |

**Observação sobre fmt/clippy:** O repo `kryx-cli` tem ~26 warnings pré-existentes
em arquivos fora do escopo (`diagnostics.rs`, `kve.rs`, `think.rs`, `main.rs`,
`node.rs`, `status.rs`, `telemetry.rs`, `theme.rs`, `env.rs`, `modules.rs`, `client.rs`).
Esses warnings são de edições recentes em Rust 2024 com let-chains e clippy rules
mais novas — **NÃO foram tocados por esta KCR** (constraint: não modificar código
Phase A além do necessário). Vale uma KCR de hygiene separada depois.

## Edge case crítico — workaround clap + `--`

**Sintoma descoberto durante smoke test:**
`kryx gc -- --help` deveria mostrar SÓ o help nativo, mas estava renderizando help híbrido.

**Causa-raiz:** Com `trailing_var_arg = true` + `allow_hyphen_values = true`,
o clap **consome o token `--` internamente** e não o entrega pro handler.
Resultado: `args.first()` chega como `"--help"` (sem o `--` separador).

**Tentativa inicial (rejeitada):** detectar `--` em `args` — inútil porque
o `--` nunca chega lá. **Correção aplicada:** detector lê `std::env::args()`
raw (`std::env::args().any(|a| a == "--")`) ANTES de qualquer lógica de help.
Se o usuário usou `--` explicitamente, passthrough direto sem help híbrido.

**Matriz de decisão final:**

| Input | `std::env::args()` contém `--`? | Comportamento |
|---|---|---|
| `kryx gc --help` | ❌ | Help híbrido ✓ |
| `kryx gc -h` | ❌ | Help híbrido ✓ |
| `kryx gc -- --help` | ✅ | Passthrough puro (só native) ✓ |
| `kryx gc --delete-older-than 30d --help` | ❌ | Passthrough pro native ✓ |
| `kryx gc` (sem args) | ❌ | Passthrough pro native ✓ |

## Decisões / observações

- **`OnceLock` ao invés de `lazy_static`/`once_cell`:** Rust 1.70+ estável,
  zero deps novas. Constantes são cacheadas na primeira call e reusadas.
- **Help constants no mesmo arquivo (`passthrough.rs`):** coesão com os
  handlers que as consomem. Se Phase B/C adicionar muitos helps, refatorar
  pra `help.rs` separado.
- **`run_passthrough_with_help` ao invés de modificar `run_passthrough`:** a
  Phase A original não tem gate (a KCR-CLI-3 menciona `run_with_gate` que
  ainda não existe). A nova função centraliza help + futuro gate sem reescrever
  lógica existente. Phase A passthrough 100% preservado.
- **`disable_help_flag = true` é essencial:** sem ele, clap intercepta
  `--help` em `args[0]` antes de chegar no nosso handler. Documentado em
  clap 4.x docs.
- **Borrow corrigido:** `Command::new(&bin)` ao invés de `Command::new(bin)`
  pra não mover `PathBuf` antes do `bin.display()` no branch `Err`.

## Pendências

1. **Push pendente** — Gabriel valida e decide.
2. **Phase B HELP** (`kryx eval`, `kryx flake`, etc.) e **Phase C HELP**
   (`kryx nix-shell`, etc.) seguem o mesmo template — não foram tocados
   conforme escopo dessa KCR.
3. **Hygiene fmt/clippy** nos arquivos fora do escopo (`diagnostics.rs`,
   etc.) — vale KCR separada.
4. **Tests automatizados** — AGENTS.md prefere atualizar existentes, não há
   tests de help hoje. Vale considerar na Phase B.

## Próximo passo recomendado

1. Gabriel revisar o commit `1830525` no branch `feat/kcr-cli3-help-c`
2. Se aprovado, push + abrir PR contra `feat/kcr-cli3-phase-a-catch-alls`
   (ou `main` se Phase A já merged)
3. Após merge, registrar o template `KryxHelp` + `run_passthrough_with_help`
   como skill reutilizável pra Phase B/C HELP

## Links relacionados

- [[kryonix-dev/AGENTS.md]]
- [[kryonix-dev/repos/kryx-cli/AGENTS.md]]
- Phase A: `feat/kcr-cli3-phase-a-catch-alls` @ `ffb4642`
- KCR-CLI-3 §10 (gate table — exercitado em Phase B, não aqui)
