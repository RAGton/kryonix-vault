---
type: entity
entity-type: command
project: Kryonix
status: stable
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, command, cli, dev-prod]
links:
  - "[[Commands]]"
  - "[[Safe Git Workflow]]"
---

# Comando · `kryonix env [status]`

Imprime ambiente detectado e matriz de políticas.

## Saída

```
Kryonix env status
  Environment    : DEV-MOTOR | DEV-SITE | PROD-MOTOR | PROD-SITE | UNKNOWN
  Repo           : /caminho/atual
  Branch         : <branch>
  Upstream       : origin/main
  Dirty          : yes/no
  Remote ahead   : 0
  Remote behind  : 0
  Policy:
    edits_allowed        : yes/no
    flake_update_allowed : yes/no/n/a
    push_allowed         : yes/no
    switch_allowed       : yes (com check+diff+test) / no / n/a
  Lembrete       : ...
```

## Implementação

- `packages/kryonix-cli/git.sh` — `kryonix_detect_env`,
  `kryonix_env_is_prod/dev`, `kryonix_env_policy`,
  `print_kryonix_env_status`.
- `packages/kryonix-cli/main.sh` — case `env`.
- `packages/kryonix-cli/registry.sh` — entradas em `home|env|*`.

## Origem

PR #62 (`ops: define git dev-prod workflow`).


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]