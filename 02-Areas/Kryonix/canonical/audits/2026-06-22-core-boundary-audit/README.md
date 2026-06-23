# Kryonix Core Boundary Audit — 2026-06-22

## Objetivo

Auditar profundamente o repositório core do Kryonix (`/home/rocha/kryonix/kryonix`) para:
1. Descobrir o que realmente pertence ao core/motor reutilizável
2. Identificar o que deve sair do core para `kryonixos` (downstream)
3. Identificar o que deve virar repo/produto próprio (Brain, Home, Aura, Installer)
4. Classificar todo item encontrado com a taxonomia definida
5. Documentar as regras oficiais no Vault
6. Gerar plano de PRs pequenos para migração segura

**Nota:** Esta auditoria foi revisada com Evidence Pack (ver `11-evidence-pack.md`). Afirmações foram corrigidas com base em comandos reais executados.

## Repositórios auditados

| Repo | Caminho DEV | Caminho PROD | Status |
|---|---|---|---|
| **kryonix** (motor) | `/home/rocha/kryonix/kryonix` | `/etc/kryonix` | ✅ Auditado |
| **kryonixos** (downstream) | `/home/rocha/kryonix/kryonixos` | `/etc/kryonixos` | ✅ Auditado |
| **kryonix-installer** | `/home/rocha/kryonix/kryonix-installer` | flake input externo | ✅ Confirmado existente |
| **kryonix-vault** | `/home/rocha/kryonix/kryonix-vault` | — | ✅ Vault oficial confirmado |

## Resumo executivo

O core do Kryonix está **funcional mas com mistura arquitetural significativa**. Existem 4 camadas principais que precisam de separação mais clara. A auditoria foi refinada com evidências concretas (ver `11-evidence-pack.md`).

## Principais achados (corrigido)

1. **`hosts/inspiron/` no core** → `DOWNSTREAM_ONLY`. O flake do core expõe APENAS `iso` como nixosConfiguration. `inspiron` não é exportado — é resíduo de documentação/referência. Evidência: `flake/data/hosts.nix` só contém `iso`. O verdadeiro inspiron vive em `kryonixos`.
2. **`profiles/glacier-*.nix` no core** → **ATIVOS, NÃO REMOVER.** São importados por `profiles/default.nix` no core e ATIVADOS pelo downstream (`hosts/glacier/default.nix`). Decisão arquitetural pendente: devem ficar no core como CORE_MODULE ou ser movidos para o downstream?
3. **`packages/kryonix-brain-lightrag`** → submódulo `58d905d` desatualizado vs flake input `95dfc2e`. O package Nix usa o input externo, NÃO o submódulo. Submódulo é cópia obsoleta.
4. **`packages/kryonix-home`** → já consumido como flake input (`inputs.kryonix-home`). Submódulo segue mesmo padrão: não usado pelo build.
5. **`.agents/`** → **NÃO é LEGACY.** É ativo e canônico. AGENTS.md referencia `.agents/skills/`. `.agents/INDEX.md` lista agentes ativos. Mantido como `CANONICAL_AGENT_CONTEXT`.
6. **`desktop/`** → Separar: `desktop/sddm/` + `desktop/wallpapers/` + `assets/` são `DESKTOP_ASSET`. `desktop/hyprland/core/`, `desktop/kde/*.nix` (funcional) são `CORE_MODULE`.
7. **`kryonix-hardware-probe`** → `CORE_SHARED`. Usado por CLI, ISO, installer, web-kiosk. Não é exclusivo do installer.
8. **Contexto IA fragmentado**: `.ai/`, `.agents/`, `.claude/`, `.codex/`, `docs/ai/` — `.agents/` é canônico; os demais podem ter sobreposição.

## Decisões recomendadas

| Decisão | Prioridade | Impacto |
|---|---|---|
| Remover submódulo obsoleto `packages/kryonix-brain-lightrag` | P0 | Baixo — build já usa input |
| Remover submódulo obsoleto `packages/kryonix-home` | P0 | Baixo — build já usa input |
| Decidir destino dos `profiles/glacier-*` | P1 | Impacto no downstream |
| Mover `hosts/inspiron/` do core | P1 | Resíduo apenas |
| Consolidar contextos IA | P2 | Reduz duplicação |
| Separar desktop assets | P3 | Bloat do core |

## Riscos atuais (evidenciados)

- `profiles/glacier-*` NÃO podem ser removidos sem quebrar o downstream
- `kryonix-hardware-probe` NÃO pode ir para installer sem quebrar a CLI
- `.agents/` NÃO deve ser arquivado — é canônico ativo

## Arquivos gerados

| Arquivo | Status |
|---|---|
| `01-core-inventory.md` | ✅ Mantido |
| `02-package-classification.md` | ✅ **Corrigido** |
| `03-hosts-and-downstream-boundaries.md` | ✅ Mantido |
| `04-installer-boundary.md` | ✅ Mantido |
| `05-brain-aura-home-assets-boundary.md` | ✅ Mantido |
| `06-runtime-state-and-secrets.md` | ✅ Mantido |
| `07-migration-plan.md` | ✅ **Corrigido** |
| `08-pr-backlog.md` | ✅ **Corrigido** |
| `09-validation-checklist.md` | ✅ Mantido |
| `10-open-questions.md` | ✅ **Corrigido** |
| `11-evidence-pack.md` | ✅ **Novo** |
