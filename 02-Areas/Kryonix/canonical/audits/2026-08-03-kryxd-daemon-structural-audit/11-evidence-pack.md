---
title: Evidence Pack — audit kryxd-daemon
date: 2026-08-03
tags: [kryonix, kryxd, audit, evidence]
status: archived
metodologia: Evidence Pack (read-only)
repo: ~/Proyectos/kryonix-dev/repos/kryxd @ 771c086
---

# Evidence Pack — audit kryxd-daemon

> Evidências brutas (comandos + outputs) capturadas durante o Gate A.
> Audit completo: [[10-structural-audit]]
> Sumário executivo: [[00-summary]]

## Nota

As evidências brutas completas deste audit (comandos rodados, outputs capturados, métricas extraídas) ficaram preservadas na versão original em:

```
~/Proyectos/Rocha-Vault/02-Areas/Kryonix/canonical/audits/2026-08-03-kryxd-arquitetura/11-evidence-pack.md
```

Esta pasta versionada (em `kryonix-vault`) preserva apenas os arquivos canônicos resultantes (00/10/11/20/90).

Para reprodutibilidade completa, consultar o histórico git deste commit.

## Baseline de compilação

Evidências detalhadas da tentativa de baseline em 2026-08-04 estão em [[20-build-baseline]].

## Comandos canônicos reproduzíveis

```bash
# Inventário
cd ~/Proyectos/kryonix-dev/repos/kryxd
find src crates/kryx/src nixos/modules/kryonix -name "*.rs" -o -name "*.nix" | xargs wc -l
grep -c "#\[test\]\|#\[tokio::test\]" $(find src crates/kryx/src -name "*.rs")

# Validação
cargo fmt --check
cargo build --workspace
cargo test --workspace
unset KRYXD_INCUS_SOCKET
nix flake check --keep-going --impure
```
