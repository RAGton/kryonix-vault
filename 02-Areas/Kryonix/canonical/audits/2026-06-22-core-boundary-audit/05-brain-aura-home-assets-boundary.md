# Brain, Aura, Home e Desktop Assets

## Brain

**Status:** `BRAIN_PRODUCT` — repositório próprio `github:RAGEnterprise/kryonix-brain-lightrag`

**No core:**
- `packages/kryonix-brain-lightrag/` — submódulo Git com código Python+Rust completo
- `packages/kryonix-brain-lightrag.nix` — package Nix
- `modules/nixos/services/brain.nix` — módulo NixOS para o serviço Brain
- `modules/nixos/features/ai.nix` — feature toggle para IA
- `docs/brain/` — documentação do Brain

**O que deve mudar:**
- ✅ Já é consumido como flake input: `inputs.kryonix-brain-lightrag`
- ✅ Já tem package Nix que aponta para o input externo
- ❌ Submódulo Git em `packages/kryonix-brain-lightrag/` é duplicata local
- ❌ `.venv/`, `target/`, `__pycache__/` dentro do submódulo ocupam espaço e poluem o repositório

**Recomendação:** Remover o submódulo e consumir exclusivamente via flake input.

## Aura

**Status:** `AURA_PRODUCT` — script de agente/automação

**No core:**
- `packages/aura/aura.sh` — script shell principal
- `modules/nixos/services/aura.nix` — módulo NixOS do serviço Aura
- `docs/aura/` — documentação da Aura

**O que deve mudar:**
- Separar para repo próprio `kryonix-aura` ou manter no core como feature opt-in?
- Atualmente é serviço opcional desativado por padrão → pode ficar no core como `CORE_MODULE`
- Decisão: depende se Aura crescerá como produto independente

## Kryonix Home

**Status:** `HOME_PRODUCT` — CLI Rust para organização de home directory

**No core:**
- `packages/kryonix-home/` — submódulo Git com código Rust completo
- `packages/kryonix-home.nix` — package Nix
- `modules/home-manager/services/kryonix-home.nix` — serviço HM

**O que deve mudar:**
- Separar para repo próprio `kryonix-home`
- ✅ Já é consumido via inputs indiretamente
- ❌ Submódulo em `packages/kryonix-home/` deve ser removido

## Desktop Assets

**Status:** `DESKTOP_ASSET` — temas, wallpapers, SDDM, identidade visual

**No core:**
- `assets/avatar/`, `assets/grub-theme/`, `assets/sddm/`, `assets/wallpaper/`
- `desktop/hyprland/` (temas, caelestia, rice, user-vars)
- `desktop/kde/` (temas, wallpapers, scheme)
- `desktop/sddm/kryonix-aurora/`
- `desktop/wallpapers/kryonix-aurora/`
- `packages/kryonix-wallpapers.nix`
- `packages/kryonix-sddm-theme.nix`
- `packages/bonafides-theme.nix`

**O que deve mudar:**
- Assets pesados não devem poluir o core
- Separar para repo `kryonix-assets` ou `kryonix-branding`
- `desktop/` configurações funcionais (monitores, keybinds) podem ficar no core como módulos

## O que é legado

- `.ai/` — contexto IA antigo, duplicado em `.agents/` e `docs/ai/`
- `.agents/` — contexto IA antigo
- `.codex/` — config Codex
- `.claude/` — config Claude (pode manter, é ativo)
- `docs/archive/` — documentação arquivada (manter como referência)
