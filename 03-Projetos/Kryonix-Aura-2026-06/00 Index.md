---
title: Kryonix · Sessão Aura · 2026-06
date: 2026-06-14
type: project-log
status: ongoing
tags: [kryonix, aura, session-log, index]
project: Kryonix
related:
  - "[[Kryonix System]]"
  - "[[Kryonix Installer]]"
---

# Kryonix · Sessão Aura · 2026-06

Memória operacional consolidada da longa sessão Aura (agente Claude Opus 4.7)
no projeto Kryonix. Conduzida em junho de 2026, transformou o repositório
`RAGton/kryonix` de "trabalho misturado em `/etc/kryonix`" para uma operação
DEV/PROD profissional com identidade KryonixOS.

## Visão geral

```txt
DEV  = /home/rocha/kryonix/kryonix        ← desenvolvimento oficial
PROD = /etc/kryonix                       ← produção controlada
```

Fluxo oficial:

```txt
DEV no HOME
  → validar (fmt + check + test)
  → commit pequeno
  → push GitHub
  → PROD em /etc faz git pull --ff-only
  → validar (check + diff)
  → test / boot / switch conforme risco
```

## Estado de main (HEAD: `30d84ad6`)

| PR  | Título                                                          | Status   |
|-----|------------------------------------------------------------------|----------|
| #62 | ops: define git dev-prod workflow                                | merged   |
| #70 | feat(installer-ui): polish network flow and summary UX           | merged   |
| #71 | fix(branding): default to KryonixOS identity                     | merged   |
| #72 | fix(installer): network apply validation tests + hostname guard  | merged   |
| #78 | chore(installer): clean existing clippy warnings                 | merged   |
| #80 | feat(branding): KryonixOS terminal identity                      | merged   |

Em backlog / aberto:

| Item   | Descrição                                              |
|--------|---------------------------------------------------------|
| #79    | Issue · chore(ci): fix pre-existing failing workflows  |
| P3     | `branding/boot-identity-p3` em curso (não-pushada)     |
| #65–69 | PRs draft de preservação histórica (etc legacy)        |

## Notas da sessão

- [[01 DEV-PROD Layout]] — Layout DEV/PROD oficial, política e detecção
- [[02 PRs Mergeados]] — Cronologia de PRs com escopo e validações
- [[03 Skills git-dev-prod]] — A skill canônica + variante agente
- [[04 Auditoria Boot Identity P3]] — Mapa do que falta para boot KryonixOS
- [[05 Backlog P3 P4 P5]] — Próximos PRs e fatiamento sugerido
- [[06 CI Debt Issue 79]] — Workflows quebrados há tempos
- [[07 Aprendizados e Regras Operacionais]] — Regras úteis para futuras sessões

## Tags principais

`#kryonix` `#aura` `#dev-prod` `#nixos` `#installer` `#branding`
`#session-log` `#governança`

## Links externos

- Repo principal: <https://github.com/RAGton/kryonix>
- Downstream: <https://github.com/RAGton/Kryonixos>
- Issue CI: <https://github.com/RAGton/kryonix/issues/79>
