# Core, Downstream e Installer — Boundaries

## Definição

| Camada | Repositório | Conteúdo | Regra |
|---|---|---|---|
| **Core/Motor** | `github:RAGton/kryonix` | Módulos NixOS/HM reutilizáveis, lib, overlays, features opt-in, CLI base | Genérico, sem config real de máquina |
| **Downstream** | `github:RAGton/kryonixos` | Hosts reais (inspiron, glacier, inspiron-nina), usuários, hardware, disko | Config real, segredos, identidade |
| **Installer** | `github:RAGton/kryonix-installer` | ISO build, TUI, web-kiosk, disk planner, hardware probe, backend/UI React | Fluxo de instalação apenas |
| **Brain** | `github:RAGEnterprise/kryonix-brain-lightrag` | LightRAG, FastAPI, CLI `rag`, autopilot, Neo4j integration | IA e conhecimento |
| **Vault** | `github:RAGton/kryonix-vault` | Notas, MOCs, ADRs, documentação operacional | Memória do projeto |

## O que NUNCA deve estar no core

- `hosts/<nome_real>/` (inspiron, glacier, etc.)
- `users/<nome_real>/` (rocha, nina, etc.)
- Config de hardware real (UUIDs, disk IDs, MACs)
- Secrets ou referência a paths de secrets reais
- Produtos independentes completos (Brain, Home, Aura)
- Assets pesados (wallpapers, temas SDDM, etc.)
- Estado runtime, cache, logs

## O que DEVE estar no core

- `modules/` — módulos NixOS e Home Manager desativados por padrão
- `lib/` — funções helpers
- `overlays/` — overlays de pacote
- `flake/` — modularização do flake
- `packages/` essenciais ao motor (CLI, bar, monitors, optimizer)
- `features/` — features opt-in desativadas por padrão

## Fluxo de desenvolvimento

```
DEV (home/rocha/kryonix/) → Commit → PR → Merge main → Sync PROD (/etc/)
```

## Links relacionados

[[PACKAGE_CLASSIFICATION]]
[[BOUNDARIES]]
[[DEVELOPMENT_FLOW]]
[[MOC - Kryonix Core Boundaries]]
