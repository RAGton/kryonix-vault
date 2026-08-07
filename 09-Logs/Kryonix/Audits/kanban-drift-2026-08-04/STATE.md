---
audit_id: kanban-drift-2026-08-04
title: Kanban × Vault drift audit
date: 2026-08-04
status: IN_PROGRESS
---

# Kanban × Vault drift audit

## Resumo
93 cartões no Kanban, drift confirmado em 7 (8% do total). 1 cartão já tratado em 2026-08-05 (resolvido antes do audit virar público).

## Cards em scope

| Card | Status Kanban | Status Real | Ação | Resolvido em |
|---|---|---|---|---|
| t_03e3dfb6 | triage | done | force=true em xdg.mimeApps, PR #15 mergeado, nh home switch validado | 2026-08-05 |
| t_aa0e609b | done | partial (wrapper vazio) | Reabrir como partial, completar wrapper | pendente |
| t_37589718 | done | partial (só análise) | Reabrir como partial + implementar | pendente |
| t_ac17626c | running | broader (3 problemas) | Split em 3 cards | pendente |
| t_d5fc7e89 | blocked | blocked (PXE arch) | Resolver protocol bug do worker, reabrir | pendente |
| t_86b3b38c | blocked | blocked (kryonix-features-node-server) | Resolver protocol bug, reabrir | pendente |
| t_ced1ea2f | blocked | blocked (node-server flag translation) | Resolver protocol bug, reabrir | pendente |

## Resolução aplicada a t_03e3dfb6

### Problema
kryx switch quebrava durante reload do home-manager-rocha.service. xdg.mimeApps regenera ~/.config/mimeapps.list, e o backup .hm-bak-kryonix colidia com checkLinkTargets. Tentativa c7c741d (force=true em xdg.mimeApps) foi revertida em 7a7be84 sem justificativa técnica.

### Fix
Adicionada 1 linha em kryonixos/users/rocha/inspiron/default.nix (~linha 320):
xdg.configFile."mimeapps.list".force = true;

### Validação
- nh home switch exit 0, 1320 paths rebuilt
- Nenhum .hm-bak-* criado (prova que fix funciona)
- /home/rocha/.config/mimeapps.list é symlink pro /nix/store
- Conteúdo novo com 3 associações extras (hermes, obsidian, text/plain expandido)
- kryx status mostra sistema íntegro

### Artifacts
- Commit: 05c7e81 em main
- PR: #15 (mergeado)
- Rescue: /home/rocha/mimeapps.list.rescue (2157 bytes, preservado)

## Próximos passos
- Reabrir 6 cards problemáticos (kryx check wrapper, Node Server removal, etc)
- Investigar bug latente do motor xdg.mimeApps (80+ vs 5 associações) — t_eb10dca9
- Investigar syntax error em glacier hardware-configuration.nix:92 — t_ad219342
## Integração com kryonix-router-loop-002

Este audit alimenta o loop-002 nas seguintes fases:
- KCR-A: cards reabertos viram ready pra priorização
- KCR-D: cards do split (t_6e19cd19, t_fdf7f5df, t_fcd2ec73) viram escopo direto

Ver [[09-Logs/Kryonix/Loops/kryonix-router-loop-002/STATE.md]]
