---
type: installer-note
project: Kryonix
status: stable
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, installer, executor, flake, target-tree]
links:
  - "[[MOC - Installer]]"
  - "[[Backend Routes]]"
  - "[[DECISIONS]]"
---

# Target Flake v2 — Installer Executor

Arquitetura do instalador onde o target produz uma árvore Nix
**autocontida** antes de `nixos-install`.

## Layout no alvo

```txt
/mnt/etc/kryonixos/
├── engine/                       ← cópia segura do motor
├── generated/                    ← target flake gerado pelo installer
│   └── flake.nix  (inputs.kryonix.url = "path:./engine")
└── state/                        ← params + receitas
```

## Por que v2

- Versão antiga (v1) usava `path:../kryonix`, que vazava o store path
  para fora do flake → erro `access to absolute path '/nix/store/...'`
  durante `pure evaluation`.
- v2 com `path:./engine` mantém o flake autocontido. Compatível com
  `pure eval` sem `--impure`.

## Componentes

- `src/executor/target_tree.rs` — **865 LOC**. Cópia segura via
  `walkdir`, filtrando segredos e build artifacts; geração do target
  flake; pre-lock para evitar NAR hash mismatch durante
  `nixos-install`.
- `src/executor/kryonixos.rs` — shim fino delegando ao `target_tree`.
- `src/executor/mod.rs` — chama `run_preflight_install_gate()` antes
  de `nixos-install`.
- `src/executor/nixos.rs` — `--show-trace` + `--verbose`,
  stdout/stderr também em `/tmp/kryonix-nixos-install.log` para
  inspeção via `/debug/target`.

## Endpoint

- `GET /debug/target` — retorna metadata completo (paths, sha do
  engine, lock state) sem rodar instalação.

## Pure eval

- **Não usar** `--impure` sem autorização explícita.
- O target flake foi desenhado especificamente para evitar essa
  necessidade.

## Origem

P0 do trabalho de junho/2026. Resolvido antes do PR #70 (UI polish).

Ver: `docs/AGENTS_REPORT.md` (commits 6445563e/6d5ffca9) ·
[[02 PRs Mergeados]]


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]