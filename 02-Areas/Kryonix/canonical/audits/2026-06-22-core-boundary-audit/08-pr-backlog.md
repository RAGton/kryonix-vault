# Backlog de PRs — CORRIGIDO

**Nota:** Numeração harmonizada com `07-migration-plan.md`. PRs #90 a #97.

| PR | Título | Fase | Arquivos afetados | Risco | Evidência |
|---|---|---|---|---|---|
| #90 | docs: auditoria de boundaries core (ESTE DOC) | F0 | Vault apenas | Nenhum | — |
| #91 | fix: remover submódulo obsoleto kryonix-brain-lightrag | F1 | `packages/kryonix-brain-lightrag/` | Baixo | Submódulo `58d905d` ≠ input `95dfc2e` |
| #92 | fix: remover submódulo obsoleto kryonix-home | F1 | `packages/kryonix-home/` | Baixo | Já consumido via `inputs.kryonix-home` |
| #93 | refactor: remover hosts/inspiron do core | F2 | `hosts/inspiron/*` | Médio | Flake só exporta `iso` |
| #94 | chore: consolidar contextos IA (.ai/, .codex/) | F3 | `.ai/*`, `.codex/*` | Baixo | `.agents/` é canônico, não tocar |
| #95 | refactor: separar Aura como produto | F4 | `packages/aura/`, `modules/nixos/services/aura.nix` | Baixo | Decisão pendente |
| #96 | refactor: decidir destino profiles glacier-* | F4 | `profiles/glacier-*.nix` | Alto | ATIVOS — downstream usa |
| #97 | refactor: mover desktop assets para repo separado | F5 | `assets/`, `desktop/sddm/`, `desktop/wallpapers/` | Médio | Manter config funcional no core |

## Fora do escopo (não são PRs)

- **`kryonix-hardware-probe`** → fica no core (`CORE_SHARED`)
- **`.agents/`** → fica no core (`CANONICAL_AGENT_CONTEXT`)
- **ISO/Installer** → mover para `kryonix-installer` (PR futuro, pós-decadências)
- **`profiles/glacier-*`** → decisão arquitetural pendente com Gabriel

## Ordem recomendada

```
PR #90 (docs) → PR #91 + PR #92 (submódulos) [paralelo]
→ PR #93 (hosts resíduo) → PR #94 (contextos)
→ PR #95 + PR #96 (Aura + glacier profiles) [dependem de decisão]
→ PR #97 (assets)
```
