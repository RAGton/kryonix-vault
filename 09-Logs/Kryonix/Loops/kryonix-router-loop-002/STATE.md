---
loop_id: kryonix-router-loop-002
title: Router / caps / desktop-zfs / kryx — Phase 2 do iso-loop
status: PLANNED
date: 2026-08-07
parent_loop: kryonix-iso-loop-001 (superseded)
estimated_duration: 4-8 weeks
---

# Loop 002 — Router, caps, desktop-zfs, kryx

> **Substitui:** `kryonix-iso-loop-001` (superseded 2026-08-07)
> **Herdado do:** 5 patches W1, W3, W5, W6, W7 + Audit-A1 do iso-loop-001
> **Objetivo:** resolver os 4 KCRs identificados na Fase 1 + 6 cards reabertos + 3 cards novos do split.

---

## Inputs (de onde viemos)

### Pendências do iso-loop-001

| ID | Descrição | Esforço | Bloqueia |
|---|---|---|---|
| Patch-W1 | Corrigir sintaxe `iso.nix` | 20-40min | build ISO |
| Patch-W3 | sops-nix bootstrap TOK-001 | 30-60min | leak de secrets parar |
| Patch-W4 | Investigar auth failure `rocha` | 10min | segurança |
| Patch-W5 | Remover/ativar passos do wizard | 15min | UX wizard |
| Patch-W6 | openapi.yaml no repo kryxd + dump script | 30min | drift CI |
| Patch-W7 | Bridge sem-sops (LogLevelMax=err) | 25min build | leak parcial |
| Audit-A1 | ISO build + VM walkthrough E2E | 90-150min | aceite 1ª install |

### Cards reabertos (Passo 4 da sessão anterior)

| Card | Status atual | Escopo |
|---|---|---|
| `t_aa0e609b` | partial | kryx check wrapper é stub, completar |
| `t_37589718` | partial | Node Server removal — só análise, falta implementar |
| `t_d5fc7e89` | ready | PXE boot architecture + KCC server config |
| `t_86b3b38c` | ready | kryonix.features.node-server module skeleton |
| `t_ced1ea2f` | ready | node-server flag translation in KCC executor |

### Cards novos (split de t_ac17626c)

| Card | Status | Escopo |
|---|---|---|
| `t_6e19cd19` | ready | kryx check: stub/incomplete wrapper (dup de t_aa0e609b) |
| `t_fdf7f5df` | ready | Guard quebrando nix flake check em background |
| `t_fcd2ec73` | ready | UI Kanban desincronizada (estado vs display) |

### KCRs identificados

| KCR | Card | Escopo |
|---|---|---|
| KCR-ROUTER-1 | `t_0fa4e069` (ready) | Corrigir mount v2 + remover duplo nest (PITFALL L18) |
| KCR-TRANSLATOR-1 | ? | (verificar onde está) |
| KCR-CAPS-HARDCODE | ? | (verificar onde está) |
| KCR-DESKTOP-ZFS-TEST | ? | (verificar onde está) |

---

## Sequência proposta: A → B → C → D

### KCR-A: Quick wins (resolvendo bugs latentes)

**Escopo:**
- `t_ad219342` (priority 2): glacier hardware-configuration.nix:92 syntax error — bloqueia CI/eval completo
- `t_fcd2ec73` (ready): UI Kanban desincronizada (estado vs display)
- `t_eb10dca9` (priority 3): investigar bug latente motor xdg.mimeApps (read-only investigation)
- Patch-W4: Investigar auth failure `rocha` (10min)

**Fora do escopo (deferred):**
- Patch-W1, W3, W5, W6, W7 do iso-loop-001 (vão pro KCR-C ou ficam pra sprint separada)
- Audit-A1 (precisa do KCR-C pronto pra rodar ISO build completo)

**Critério de aceite (binário):**
- [ ] `nix flake check --keep-going --impure` passa SEM erro em glacier
- [ ] UI Kanban mostra status correto após sync
- [ ] Relatório de investigação do motor xdg.mimeApps (decide se é bug ou não)
- [ ] Auth failure do `rocha` documentado ou resolvido

**Gate humano:** antes de mover pro KCR-B, mostrar relatório com os 4 itens resolvidos/investigados.

**Esforço:** 4-8h (1 dia de trabalho focado).

---

### KCR-B: KCR-ROUTER-1 (foco no router)

**Escopo:**
- `t_0fa4e069` (ready): Corrigir mount v2 + remover duplo nest (PITFALL L18)

**Dependência:** KCR-A (precisa do flake check passando pra testar o router).

**Critério de aceite:**
- [ ] `t_0fa4e069` movido pra `done` com `FEATURE_DELIVERED`
- [ ] VM walkthrough com router funciona end-to-end
- [ ] `kryx status` mostra router limpo
- [ ] PITFALL L18 documentado no Vault (em `02-Areas/Kryonix/canonical/pitfalls/` ou similar)

**Gate humano:** VM walkthrough validado por você antes de fechar.

**Esforço:** 1-2 dias (8-16h).

---

### KCR-C: Node Server module + 5 patches do iso-loop-001

**Escopo:**
- `t_37589718` (partial): Node Server removal — implementar
- `t_86b3b38c` (ready): kryonix.features.node-server module skeleton
- `t_ced1ea2f` (ready): node-server flag translation in KCC executor
- `t_d5fc7e89` (ready): PXE boot architecture + KCC server config
- Patch-W1: Corrigir sintaxe `iso.nix`
- Patch-W5: Remover/ativar passos do wizard

**Dependência:** KCR-A (precisa do flake check passando). KCR-B pode estar em paralelo.

**Critério de aceite:**
- [ ] 4 cards do Node Server fechados (done, FEATURE_DELIVERED)
- [ ] ISO build completo sem erro (Patch-W1)
- [ ] Wizard tem passos claros (Patch-W5)
- [ ] PXE boot funciona em VM

**Gate humano:** ISO build + VM walkthrough Audit-A1.

**Esforço:** 2-3 dias (16-24h).

---

### KCR-D: kryx check wrapper + Guard + ISO completion

**Escopo:**
- `t_aa0e609b` (partial) + `t_6e19cd19` (ready) — **consolidados** num único card: completar kryx check wrapper
- `t_fdf7f5df` (ready): Guard quebrando nix flake check em background
- Patch-W3: sops-nix bootstrap TOK-001
- Patch-W6: openapi.yaml no repo kryxd + dump script
- Patch-W7: Bridge sem-sops
- Audit-A1: ISO build + VM walkthrough E2E (consolidação)

**Dependência:** KCR-C (precisa do ISO build funcionando pra testar).

**Critério de aceite:**
- [ ] `kryx check` retorna exit 0 em código válido, exit != 0 em código quebrado
- [ ] `nix flake check` roda em background sem travar Guard
- [ ] Secrets não vazam em logs (sops-nix ativo)
- [ ] OpenAPI spec do kryxd versionado
- [ ] ISO E2E walkthrough documentado (Audit-A1)

**Gate humano:** ISO E2E instalado em hardware real + aceito por você.

**Esforço:** 3-5 dias (24-40h).

---

## Total estimado

| KCR | Esforço | Dependência |
|---|---|---|
| A — Quick wins | 4-8h | nenhuma |
| B — Router | 8-16h | A |
| C — Node Server + ISO | 16-24h | A |
| D — kryx + Guard + ISO complete | 24-40h | C |
| **Total** | **52-88h** | — |

**Estimativa de sprint:** 4-8 semanas (1 pessoa, 8-12h/semana, com revisão).

---

## Como executar

### Estrutura de arquivos do loop

```
09-Logs/Kryonix/Loops/kryonix-router-loop-002/
├── STATE.md          # este arquivo
├── EVENTS.jsonl      # append-only, 1 evento por linha
├── EVIDENCE.md       # artefatos, links, screenshots
└── FINAL_REPORT.md   # criado no fechamento
```

### Formato de evento (EVENTS.jsonl)

```json
{"ts": "2026-08-07T12:00:00Z", "actor": "aura", "kind": "kcr_started", "kcr": "A", "notes": "Iniciando quick wins"}
{"ts": "2026-08-07T14:30:00Z", "actor": "aura", "kind": "card_closed", "card_id": "t_ad219342", "result": "FEATURE_DELIVERED"}
{"ts": "2026-08-07T15:00:00Z", "actor": "gabriel", "kind": "gate_human", "kcr": "A", "decision": "approved", "notes": "Aprovado, segue pro B"}
```

Kinds válidos: `kcr_started`, `kcr_completed`, `card_closed`, `card_reopened`, `gate_human`, `blocker_found`, `evidence_collected`, `commit_made`.

### Como fechar o loop

1. Todos os 4 KCRs com critério de aceite atingido
2. Você aprova o `FINAL_REPORT.md`
3. Cria `kryonix-router-loop-003/` (próximo sprint) ou marca o sistema como `idle`

---

## Riscos e mitigações

| Risco | Mitigação |
|---|---|
| KCR-A descobre bug grave no glacier | Bloquear, abrir cartão de bug, escalar antes de seguir |
| KCR-B (router) tem mais pitfalls escondidos | Adicionar PITFALL L19, L20, etc ao Vault incrementalmente |
| KCR-C (ISO build) falha por deps não-pinadas | Rodar `nix flake update` numa branch separada, testar em VM |
| KCR-D (kryx check) revela que wrapper precisa rewrite | Reabrir como `broken`, replanejar |
| Trabalhador bloqueia sem chamar `kanban_complete` | Investigar worker protocol bug antes de KCR-D (risco de refazer tudo) |

---

## Métricas de sucesso

- 4 KCRs com critério de aceite atingido
- 0 regressões no kryx status / nh home switch
- 100% dos cards do loop commited com `FEATURE_DELIVERED` real
- ISO E2E build + walkthrough documentado
- `kanban-sync` continua sem drift após cada KCR

---

## Status

- **2026-08-07:** STATE.md criado, plano A→B→C→D definido
- **Próximo:** criar `EVENTS.jsonl` (vazio) e `EVIDENCE.md` (template) quando KCR-A iniciar
- **Bloqueios atuais:** nenhum (KCR-A pode começar quando você quiser)

---

_Versão 0.1 — 2026-08-07. Atualizar a cada KCR concluído._
