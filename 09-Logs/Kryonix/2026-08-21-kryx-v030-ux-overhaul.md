# 2026-08-21 — kryx v0.3.0 (UX overhaul: auto-gc 2d + banner + 9 new subcommands)

Data: 2026-08-21
Agente: Aura (sessão Hermes)
Repos afetados:

- `kryx-cli` — 3 commits novos + tag v0.3.0
- `kryonix` — bump do pin `kryx-cli/v0.2.0` → `v0.3.0`
- `kryonixos` — flake.lock update (kryx-cli input v0.3.0)
- `kryonix-dev` — 2 submodule bumps

## Objetivo

Implementar a reformulação do CLI `kryx` (pedido explícito do Gabriel): cobertura total de comandos nix/nh/nixos-rebuild, GC automático com retenção 2d, cleanup de temporários, loading bonito, banner com arte.

## Entregas

### kryx-cli v0.3.0 (3 commits atômicos)

| Commit | Escopo |
|---|---|
| `650524f` | `chore(kryx-cli): bump version 0.2.0 -> 0.3.0 + add indicatif/once_cell` |
| `8dac5ba` | `feat(kryx): ui + cleanup + extra nix coverage` (864 linhas, 3 módulos novos) |
| `6276304` | `feat(kryx): wire new commands + auto-gc integration` (218 linhas, integração CLI) |

### Módulos novos

1. **`src/ui.rs`** (241 linhas)
   - `BANNER` ASCII do KryonixOS
   - `render_banner()` / `print_banner()` com gate `KRYX_NO_BANNER=1`
   - Helpers de diagnóstico com cores: `info/warn/error/pass/step`
   - `KryxSpinner` wrapping `indicatif` com auto-fallback em non-TTY
   - `section_header()` / `divider()` para outputs longos
   - `should_show_visuals()` — TTY detection

2. **`src/cleanup.rs`** (448 linhas)
   - `run_auto_gc(older_than, dry_run)` — nix-collect-garbage com retenção (default 2d)
   - `remove_hm_backups()` — strips `~/.config.hm-bak-*`
   - `remove_result_symlinks()` — strips `result*` GC-root symlinks
   - `remove_kryx_tmpfiles()` — strips `/tmp/kryx-*`
   - `prune_target_cache()` — opt-in `target/` prune (KRYX_PRUNE_TARGET=1)
   - `CleanupReport` struct com `summary()` one-liner
   - `parse_bytes_freed()` best-effort de output do nix-collect-garbage
   - `human_bytes()` binary unit formatter (B/KiB/MiB/GiB/TiB)

3. **`src/nix_extra.rs`** (172 linhas)
   - `prefetch` — `nix-prefetch-url` / `nix-prefetch-git`
   - `registry` — `nix registry` (list/add/remove pin)
   - `edit` — `nix edit` (abre flake no $EDITOR)
   - `sign_paths` — `nix sign-paths`
   - `copy` — `nix copy` (substitui nix-copy-closure)
   - `nix_doctor` — `nix doctor` (upstream)
   - `nh_clean_all` — `nh clean all`
   - `nixos_rebuild` — escape hatch via nixos-rebuild
   - `nh_os_variant` — `nh os <variant>` para boot/test/dry-activate/dry-build/build

### Comandos novos no CLI

- `kryx prefetch <url>` — calcular hash antes de adicionar a flake
- `kryx registry list|add|remove` — gerenciar pins de inputs
- `kryx edit <flake>` — abrir flake no $EDITOR
- `kryx sign-paths` — assinar store paths com trusted key
- `kryx copy --to|--from` — copiar closures entre stores
- `kryx nix-doctor` — diagnosticar config Nix upstream
- `kryx nh-clean-all` — forçar cleanup completa
- `kryx nixos-rebuild ...` — escape hatch (quando cli-lockdown quebra nh)
- `kryx nhos <variant> <args>` — variantes do switch

### Auto-gc integrado

- `kryx switch` → após sucesso, roda `run_full_cleanup(2d, no_gc=false, dry_run=false)`
- `kryx clean` → sem args, roda o mesmo cleanup pass
- `kryx clean <args>` → forwards para `nh clean` (compat preservado)
- Opt-out via `KRYX_NO_AUTO_GC=1`

### Banner auto-print

Topo de: `switch`, `update`, `status`, `doctor`, `gc`, `clean`, `system`
Opt-out via `KRYX_NO_BANNER=1`

## Validação

```text
cargo fmt --check          ✓ clean
cargo clippy -D warnings    ✓ clean
cargo test --lib            22 passed, 0 failed, 1 ignored
cargo build --release       OK, 15s
```

**Produção (inspiron):**
- `kryx switch`: build 3m36s, +302 KiB, **PASS**
- `kryx --version`: `kryx 0.3.0` (em vez de 0.1.0)
- `kryx clean` (sem args): `freed 411.8 MiB`
- `kryx --help`: 9 novos comandos listados (prefetch, registry, edit, sign-paths, copy, nix-doctor, nh-clean-all, nixos-rebuild, nh-os)

## Commits publicados

```text
kryx-cli:    650524f  chore(kryx-cli): bump version 0.2.0 -> 0.3.0 ...
kryx-cli:    8dac5ba  feat(kryx): ui + cleanup + extra nix coverage
kryx-cli:    6276304  feat(kryx): wire new commands + auto-gc integration
kryx-cli:    v0.3.0   tag (refs/tags/v0.3.0 -> 6276304)
kryonix:     1317b3c  fix(flake): pin kryx-cli to v0.3.0
kryonixos:   5889ea1  chore: update flake.lock (kryx-cli v0.3.0)
kryonix-dev: f7318c9  chore(dev): bump kryonix submodule (kryx-cli v0.3.0 pin)
kryonix-dev: 5a2ba8a  chore(dev): bump kryonixos (flake.lock -> kryx-cli v0.3.0)
```

## Pendências

- `kryonix-installer` flake input não foi tocado — verificar se precisa bump similar em outro turno
- Skeleton de `kryx doctor --json` ainda usa o output plain (não mudou nesta release)
- Banner em `kryx shell`/`kryx build` ainda é suprimido (intencional — power user fatigue)
- Considerar adicionar `kryx doctor` integration com a nova `cleanup` (sugerir cleanup se `df /nix` < 10% livre)

## Próximo passo recomendado

1. Adicionar teste de integração que valida `kryx clean` em CI (sandbox sem nh real → `#[ignore]`)
2. Adicionar `kryx version` como alias explícito (hoje só `kryx --version`)
3. Considerar `kryx doctor --fix` que aplica o cleanup automaticamente
4. Avaliar mover o `parse_bytes_freed` para um `crate::bytes` helper reusável
5. Próximo bump de versão: `v0.3.1` para `kryonix-installer` se necessário
