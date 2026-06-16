---
title: Skill git-dev-prod
date: 2026-06-13
type: skill-doc
status: published
tags: [kryonix, skill, dev-prod, governança, claude-code]
related:
  - "[[00 Index]]"
  - "[[01 DEV-PROD Layout]]"
---

# Skill `git-dev-prod`

Skill operacional canônica do Kryonix, criada no PR #62. Define o fluxo
DEV/PROD para qualquer agente (Aura, Claude Code, Codex, Cursor) ou
humano operando o repositório.

## Duas cópias, papéis distintos

| Caminho                                          | Papel                                              |
|--------------------------------------------------|----------------------------------------------------|
| `skills/git-dev-prod/SKILL.md`                   | Skill **canônica** do projeto (humanos + qualquer agente) |
| `.claude/skills/git-dev-prod/SKILL.md`           | Skill para Claude Code / Aura (com `allowed-tools`)|

Regra: ao atualizar uma, propagar para a outra **no mesmo commit**.

## Frontmatter (.claude variant)

```yaml
---
name: git-dev-prod
description: Kryonix Git Dev/Prod Workflow — separa desenvolvimento no
  HOME (/home/rocha/kryonix/*) de produção em /etc/kryonix e
  /etc/kryonixos, padroniza sync, release ISO, rollback e o contrato
  de `kryonix update` (DEV vs PROD).
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
---
```

## Conteúdo curado (resumo)

A skill aborda 13 seções:

1. Mapa de ambientes
2. Antes de qualquer ação (ler contexto canônico)
3. Detecção de ambiente
4. Bootstrap (uma vez por máquina)
5. Fluxo Git diário (DEV)
6. Fluxo Git produção (PROD)
7. Contrato de `kryonix update`
8. Release ISO no GitHub
9. Rollback (geração NixOS + tag git)
10. Contrato de segurança (10 regras invioláveis)
11. Comandos esperados na CLI (`kryonix env`, `git sync-dev/prod`,
    `release iso`, `rollback`)
12. Validações obrigatórias antes de concluir
13. Formato do relatório final

## Documentos vinculados (vivos no repo)

- `docs/operations/GIT_DEV_PROD_WORKFLOW.md`
- `docs/operations/KRYONIX_UPDATE_POLICY.md`
- `docs/operations/RELEASE_ISO.md`
- `docs/operations/ROLLBACK_TAGS.md`

## Implementação na CLI

Concretizado em `packages/kryonix-cli/git.sh` + `nixos.sh` + `main.sh`
+ `registry.sh`:

- `kryonix_detect_env(target)` — retorna DEV-MOTOR / DEV-SITE /
  PROD-MOTOR / PROD-SITE / UNKNOWN
- `kryonix_env_is_prod(env)` / `kryonix_env_is_dev(env)`
- `kryonix_env_policy(env, key)` — yes/no/n/a por (env, edits|push|
  flake_update|switch)
- `print_kryonix_env_status` — render colorido com tags ANSI
- `update_flake_lock()` aborta em PROD com erro claro

Subcomando: `kryonix env [status]`.

## Skills relacionadas no projeto

| Skill                  | Descrição                                        |
|------------------------|---------------------------------------------------|
| git-dev-prod           | Esta. Governança Git.                            |
| kryonix-audit          | Auditoria de estrutura do repo                    |
| phase1-flake-modular   | Refactor fase 1 — flake modular                  |
| phase2-packages        | Refactor fase 2 — packages com callPackage       |
| phase3-cachix          | Refactor fase 3 — CI/Cachix                      |
| phase4-desktop         | Refactor fase 4 — desktop em camadas             |
| phase7-kryonix-shell   | Fase 7 — Kryonix Shell (Hyprland)                |
| phase8-kryonix-aurora  | Fase 8 — Aurora Shell (KDE Plasma)               |

## Regra geral de execução pelo agente

- Todo comando começa com preflight:

```bash
cd /home/rocha/kryonix/kryonix || exit 1
test "$(pwd -P)" = "/home/rocha/kryonix/kryonix" || exit 1
```

- Nunca tocar em `/etc/kryonix` ou `/etc/kryonixos` em sessão de
  desenvolvimento.
- Nunca usar `git add .`, `git reset --hard`, `git push --force`,
  `git clean -fdx` sem aprovação explícita.

Ver: [[01 DEV-PROD Layout]] · [[07 Aprendizados e Regras Operacionais]]
