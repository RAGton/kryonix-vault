---
type: MOC
id: MOC_Kanban_Kryonix
title: Map of Content — Kanban × Vault governance
date: 2026-08-07
status: active
tags: [moc, governance, kanban, vault, kryonix]
---

# MOC — Kanban × Vault (kryonix-dev)

> **Propósito:** índice de governança do sistema Kanban × Vault. Onde está o quê, regras de drift, status válidos, e link pros artefatos vivos (audits, loops, KCRs).

---

## Princípio fundamental

> **Kanban = execução. Vault = decisão/evidência. MOC = navegação.**

- **Kanban** rastreia o estado das tarefas em movimento.
- **Vault** guarda decisões, evidências, e histórico imutável.
- **MOC** aponta pra tudo isso sem virar ele próprio mais um arquivo que fica stale.

**Regra de ouro:** se Kanban e Vault discordam, **Vault wins** (Vault é derivado de Kanban via `kanban-sync`, então divergência = bug do sync, corrigir e seguir).

---

## Onde está o quê

### Kanban (estado de execução)

- **DB:** `~/.hermes/kanban/boards/kryonix/kanban.db` (SQLite, ~636KB)
- **Schema da tabela `tasks`:** `id, status, title, type, priority, body, created_at, updated_at, kind, severity, tags, result, last_failure_error, started_at, completed_at`
- **Card ID pattern:** `t_[a-z0-9]{6,}`
- **Tool de leitura/escrita:** `kanban_*` (Aura tem)
- **98 cards totais** (atualizado em 2026-08-07)

### Vault (decisão/evidência)

- **Path principal:** `~/Proyectos/kryonix-dev/repos/kryonix-vault/` (submodule git)
- **Estrutura:**
  - `00-Inbox/` — entrada de ideias
  - `01-MOCs/` — **Map of Content (este arquivo e futuros)**
  - `02-Areas/Kryonix/{canonical,active,archive}/` — áreas de trabalho
  - `03-Projetos/` — projetos
  - `04-Recursos/` — recursos, playbooks
  - `08-Referencias/` — referências externas
  - `09-Logs/Kryonix/{Loops,KCRs,Audits}/` — histórico operacional
  - `99-Logs/` — logs diversos

### Sincronização (Kanban → Vault)

- **Path:** `~/Proyectos/kryonix-dev/scripts/kanban-sync/`
- **Comando:** `kanban-sync` (symlink em `~/.local/bin/kanban-sync`)
- **Output:** `09-Logs/Kryonix/Cards/` (1 `.md` por card + `_INDEX.md` + `kanban-state.json`)
- **Trigger atual:** Aura chama `kanban-sync --card t_xxxxx` após cada tool call `kanban_*`
- **Trigger alternativo:** cron a cada 5min (`kanban-sync --quiet`) — não configurado ainda
- **Hook automático:** `kanban-hook.sh` em `~/.hermes/hooks/post-tool-call.sh` (instalado mas **NÃO ATIVADO**)

---

## Status válidos (não usar `DONE`)

| Status | Significado | Quem age |
|---|---|---|
| `running` | Em execução agora | Worker ativo |
| `triage` | Precisa decisão (urgente?) | Você |
| `ready` | Pode começar | Próximo worker livre |
| `blocked` | Parado, esperando algo | Você destrava |
| `todo` | Vai fazer nas próximas semanas | Sequenciado |
| `scheduled` | Wishlist — futuro incerto | Você reprioriza |
| `done` | Finalizado (validado de verdade) | — |
| `superseded` | Substituído por outro card | — |
| `partial` | Incompleto, mas avançou | — |
| `broken` | Tentou, quebrou, precisa refazer | — |

**Atenção:** o Hermes Kanban tem `done` como status técnico (significa "fechado no sistema"). Mas pra gente, **done só conta se tiver `result=FEATURE_DELIVERED` E evidência no Vault**. Done sem evidência = partial, não done.

---

## Drift principle (regra anti-stale)

**Se Kanban e Vault discordam:**

1. Verificar `kanban-sync.log` (`.kanban-sync.log` no vault, append-only).
2. Rodar `kanban-sync --check` (exit 0 = sem drift, 1 = drift detectado).
3. Se drift real: provavelmente alguém editou o card no Kanban sem rodar sync. Re-rodar `kanban-sync --card t_xxxxx` (ou full sync).
4. **Nunca** editar o `.md` no vault pra "combinar" com o Kanban. Vault é derivado, não source of truth.

**Anti-pattern:** `kanban.md` único no root do vault. Vira stale, mistura governança com data, sem audit trail. **Não criar.**

---

## Loops registrados

### `kryonix-iso-loop-001/` (2026-08-03, **superseded**)

- **Path:** `/home/rocha/Proyectos/Rocha/09-Logs/Kryonix/Loops/kryonix-iso-loop-001/`
- **Autor:** Aura, sessão L2 com gate humano
- **Produziu:** 11 achados (4 P0 build-blockers + 3 P1 UX + 4 P2 debt), 1 patch aplicado (W7, não commitado), 7 patches pendentes (W1..W6 + Audit-A1), 8 artefatos de evidência
- **Status:** `superseded` — substituído por `kryonix-router-loop-002`
- **Pendências herdadas pelo loop-002:**
  - Patch-W1: Corrigir sintaxe `iso.nix` (20-40min)
  - Patch-W3: sops-nix bootstrap TOK-001 (30-60min)
  - Patch-W4: Investigar auth failure `rocha` (10min)
  - Patch-W5: Remover/ativar passos do wizard (15min)
  - Patch-W6: openapi.yaml no repo kryxd + dump script (30min)
  - Patch-W7: Bridge sem-sops (25min build)
  - Audit-A1: ISO build + VM walkthrough E2E (90-150min)

### `kryonix-router-loop-002/` (2026-08-07, **planejado**)

- **Path planejado:** `09-Logs/Kryonix/Loops/kryonix-router-loop-002/`
- **Plano:** KCR-A → B → C → D (4 fases com gate humano)
- **KCR-A (Quick wins):** Glacier syntax + UI Kanban + investigar motor
- **KCR-B (KCR-ROUTER-1):** corrigir mount v2 + remover duplo nest (PITFALL L18)
- **KCR-C (Node Server module):** 3 cards relacionados (37589718, 86b3b38c, ced1ea2f) + t_d5fc7e89 PXE
- **KCR-D (kryx check + Guard):** t_aa0e609b + t_6e19cd19 (consolidados) + t_fdf7f5df
- **Status:** Skeleton não criado ainda (próxima sessão)

---

## Audits registradas

### `kanban-drift-2026-08-04/` (IN_PROGRESS)

- **Path:** `09-Logs/Kryonix/Audits/kanban-drift-2026-08-04/STATE.md`
- **Trigger:** auditoria inicial do Kanban, 93 cartões, drift confirmado em 7
- **Status atual:** 1 de 7 resolvido (`t_03e3dfb6` — mimeapps fix)
- **Cards restantes:** 6 (t_aa0e609b, t_37589718, t_ac17626c, t_d5fc7e89, t_86b3b38c, t_ced1ea2f)
- **Cards novos do split:** t_6e19cd19, t_fdf7f5df, t_fcd2ec73 (precisam ser integrados ao audit)

---

## KCRs (Key Change Requests) ativos

- `t_0fa4e069` (ready): **KCR-ROUTER-1** — corrigir mount v2 + remover duplo nest (PITFALL L18)
- KCR-TRANSLATOR-1 — em algum card (verificar)
- KCR-CAPS-HARDCODE — em algum card (verificar)
- KCR-DESKTOP-ZFS-TEST — em algum card (verificar)
- KCR-Node Think Backend — planejado

---

## Operacional

### Como rodar o sync

```bash
# Full sync (93 cards → 96 files)
kanban-sync --quiet

# Sync de 1 card
kanban-sync --card t_aa0e609b

# Drift check (não escreve)
kanban-sync --check

# Validar audit config
kanban-sync --validate-config

# Dry-run
kanban-sync --dry-run
```

### Como abrir um novo loop

1. Criar pasta: `09-Logs/Kryonix/Loops/<loop-id>/`
2. Criar `STATE.md` com plano (KCRs, fases, gates humanos)
3. Criar `EVENTS.jsonl` (vazio, append-only durante o loop)
4. Criar `EVIDENCE.md` (artefatos, links, screenshots)
5. Quando fechar: `FINAL_REPORT.md` com TL;DR + aprendizados

### Como fechar um card

1. Trabalho feito + validado (testado em produção ou VM)
2. `kanban_complete --card t_xxxxx --result FEATURE_DELIVERED --notes "..."`
3. Re-sync: `kanban-sync --card t_xxxxx`
4. Commit: `git add 09-Logs/Kryonix/Cards/ && git commit -m "..."` (sem push)

---

## Regras duras (não quebrar)

1. **Não** modificar `/etc/kryonix` ou `/etc/kryonixos` sem comando explícito.
2. **Não** `git add .` (sempre paths explícitos).
3. **Não** `git push` sem comando explícito (PR sempre, merge manual).
4. **Não** amend, squash, rebase após push.
5. **Não** criar `kanban.md` único (drift garantido).
6. **Não** usar `DONE` fora do Kanban (status `done` é terminologia do Hermes; internamente a gente usa `validated`).
7. **Não** rodar `nixos-rebuild` direto — usar `kryx switch` ou `nh os switch`.
8. **Não** commitar `.obsidian/workspace.json` ou `.obsidian/graph.json` (estado local, regenera).
9. **Vault é derivado de Kanban**, não source of truth. Editar Vault = bug.
10. **Cada commit = 1 problema.** Não misturar fix de emergência com refactor.

---

## Onde achar ajuda

- **Bug do kanban-sync:** `kanban-sync --help` (wrapper) ou `kanban-sync.py --help` (Python)
- **Schema do Kanban:** `kanban-schema` ou `sqlite3 ~/.hermes/kanban/kanban.db ".schema tasks"`
- **Status do host:** `kryx status`
- **Diagnóstico geral:** `kryx doctor --json`
- **Logs do home-manager:** `journalctl --user -u home-manager-rocha.service -n 50`

---

## Versão

- **v1.0** — 2026-08-07, criado na sessão de fechamento
- **Próxima revisão:** quando o `kryonix-router-loop-002` for iniciado (sugestão: ao final do KCR-A)

---

_MOC é vivo. Atualizar quando governance muda, não a cada sync. Se você tá editando esse arquivo mais de 1x por mês, tá updateando demais._
