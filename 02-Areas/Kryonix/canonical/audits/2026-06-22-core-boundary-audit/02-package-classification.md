# Classificação de packages e áreas — CORRIGIDO

## Legenda

| Categoria | Significado |
|---|---|
| `CORE_KEEP` | Deve permanecer no core |
| `CORE_SHARED` | Compartilhado entre core e outros produtos |
| `CORE_MODULE` | Módulo NixOS/HM reutilizável |
| `CORE_PACKAGE` | Package essencial do motor |
| `CORE_CLI` | CLI base do motor |
| `DOWNSTREAM_ONLY` | Deve ir para kryonixos |
| `HOST_REAL_CONFIG` | Configuração de máquina real |
| `ISO_ONLY` | Apenas ISO |
| `INSTALLER_PRODUCT` | Produto installer |
| `BRAIN_PRODUCT` | Produto Brain |
| `HOME_PRODUCT` | Produto Kryonix Home |
| `AURA_PRODUCT` | Produto Aura |
| `DESKTOP_ASSET` | Asset de desktop (pesado/não-funcional) |
| `CANONICAL_AGENT_CONTEXT` | Contexto de agente ativo e canônico |
| `LEGACY` | Código legado |
| `UNKNOWN_NEEDS_REVIEW` | Precisa revisão |

## Tabela de classificação (corrigido)

| Item | Caminho | Categoria | Fica no core? | Destino | Motivo | Risco | Evidência |
|---|---|---|---|---|---|---|---|
| hosts/inspiron/ | `hosts/inspiron/*` | `DOWNSTREAM_ONLY` | ❌ | kryonixos | Resíduo — flake não exporta (só `iso`) | Alto | `flake/data/hosts.nix` só tem `iso` |
| hosts/iso/ | `hosts/iso/*` | `ISO_ONLY` | ❌ | kryxd | ISO build | Médio | Usa installer modules |
| profiles/glacier-ai.nix | `profiles/glacier-ai.nix` | `CORE_MODULE` | ✅ **SIM** (por enquanto) | Pendente decisão | ATIVO — importado por `profiles/default.nix` e usado pelo downstream | Alto | Downstream `hosts/glacier/default.nix` ativa |
| profiles/glacier-base.nix | `profiles/glacier-base.nix` | `CORE_MODULE` | ✅ **SIM** (por enquanto) | Pendente decisão | ATIVO — mesmo motivo | Alto | Idem |
| profiles/glacier-gamer.nix | `profiles/glacier-gamer.nix` | `CORE_MODULE` | ✅ **SIM** (por enquanto) | Pendente decisão | ATIVO — mesmo motivo | Alto | Idem |
| profiles/server-ai.nix | `profiles/server-ai.nix` | `CORE_MODULE` | ✅ **SIM** (por enquanto) | Pendente decisão | ATIVO — importado por `profiles/default.nix` | Alto | `profiles/default.nix:21` |
| packages/kryonix-brain-lightrag | `packages/kryonix-brain-lightrag/` | `BRAIN_PRODUCT` | ❌ | repo próprio | Submódulo obsoleto (`58d905d`) vs input (`95dfc2e`) | Baixo | Build usa `inputs.kryonix-brain-lightrag` |
| packages/kryonix-home | `packages/kryonix-home/` | `HOME_PRODUCT` | ❌ | repo próprio | Já consumido via `inputs.kryonix-home` | Baixo | `flake.nix:96`, overlay usa input |
| packages/kryonix-disk-planner | `packages/kryonix-disk-planner*` | `INSTALLER_PRODUCT` | ❌ | kryxd | Exclusivo do installer | Médio | Só referenciado em installer/ISO |
| packages/kryonix-hardware-probe | `packages/kryonix-hardware-probe*` | `CORE_SHARED` | ✅ **SIM** | Core | Usado por CLI, ISO, installer | Alto | CLI `installer.sh`, `kryonix-cli.nix`, ISO, installer |
| packages/aura/ | `packages/aura/aura.sh` | `AURA_PRODUCT` | ❌ | repo próprio | Agente/automação | Baixo | |
| assets/ | `assets/*` | `DESKTOP_ASSET` | ❌ | repo assets | Avatars, wallpapers PNG, grub-theme | Baixo | |
| desktop/sddm/, desktop/wallpapers/ | `desktop/sddm/*`, `desktop/wallpapers/*` | `DESKTOP_ASSET` | ❌ | repo assets | Temas SDDM, wallpapers | Baixo | |
| desktop/hyprland/core/ | `desktop/hyprland/core/*` | `CORE_MODULE` | ✅ **SIM** | Core | Config funcional (monitores, keybinds, cursor) | Nenhum | |
| desktop/kde/*.nix | `desktop/kde/*.nix` | `CORE_MODULE` | ✅ **SIM** | Core | Config funcional KDE | Nenhum | |
| .agents/ | `.agents/*` | `CANONICAL_AGENT_CONTEXT` | ✅ **SIM** | Core | Ativo e canônico — AGENTS.md referencia | Nenhum | AGENTS.md:40, `.agents/INDEX.md` |
| .ai/ | `.ai/*` | `LEGACY` | ❌ | Archive | Fragmentado, sobreposto com `.agents/` e `docs/ai/` | Baixo | |
| .codex/ | `.codex/*` | `LEGACY` | ❌ | Archive | Config antiga | Baixo | |
| modules/nixos/installer/ | `modules/nixos/installer/*` | `INSTALLER_PRODUCT` | ❌ | kryxd | TUI, kiosk, backend | Alto | ISO depende |
