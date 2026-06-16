---
type: architecture-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, dev-prod, workflow, architecture, governança]
links:
  - "[[MOC - Architecture]]"
  - "[[Safe Git Workflow]]"
  - "[[DECISIONS]]"
---

# DEV / PROD Flow

Referência arquitetural. Conteúdo operacional vive em
[[Safe Git Workflow]] (mais comandos) e em [[DECISIONS]] D-001.

## Mapa

```txt
/home/rocha/kryonix/             DEV
├── kryonix/                     DEV-MOTOR     ↔ origin RAGton/kryonix
└── kryonixos/                   DEV-SITE      ↔ origin RAGton/Kryonixos

/etc/kryonix/                    PROD-MOTOR
/etc/kryonixos/                  PROD-SITE
```

## Ciclo

```mermaid
flowchart LR
    DEV(["DEV-MOTOR
/home/rocha/kryonix/kryonix"]) -->|validar + commit + push| GH[(GitHub
RAGton/kryonix)]
    GH -->|sudo git pull --ff-only| PROD(["PROD-MOTOR
/etc/kryonix"])
    PROD --> KCD[kryonix check]
    KCD --> KDF[kryonix diff]
    KDF --> KT[kryonix test]
    KT --> KB[kryonix boot]
    KB --> KS[kryonix switch]
```

## Matriz de permissões

Ver [[Safe Git Workflow]] ou [[02-Areas/Kryonix/kryonix-meta/CURRENT_STATE]].

## Implementação

- CLI: `kryonix env [status]`, `kryonix update` split DEV/PROD,
  `kryonix pull --ff-only`. Implementado em PR #62.
- Skills: [[02-Areas/Kryonix/operations/Safe Git Workflow]] e
  `docs/operations/GIT_DEV_PROD_WORKFLOW.md`.

Tags: #kryonix #dev-prod #governança


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]