# Kryonix Boundaries — Regras Arquiteturais

## Princípios

1. **Core genérico, downstream específico.** O motor não contém configuração de máquina real.
2. **Produtos independentes têm repo próprio.** Brain, Home, Aura, Installer são repositórios separados.
3. **Features são opt-in.** Toda feature no core é desativada por padrão; hosts ativam.
4. **Sem segredos no repositório.** Secrets em `/etc/kryonix/*.env` (gitignored).
5. **Sem estado no repositório.** Runtime em `/var/lib/kryonix/`, cache ignorado.

## Estrutura

```
Kryonix Core (motor)
├── modules/nixos/features/      → Features opt-in (desativadas por padrão)
├── modules/nixos/services/      → Serviços reutilizáveis
├── modules/home-manager/        → Módulos HM
├── lib/                         → Helpers
├── overlays/                    → Overlays
├── packages/                    → CLI, bar, monitors (essenciais)
└── flake/                       → Modularização

KryonixOS (downstream)
├── hosts/<nome>/                → Hardware real, disko, boot
├── users/<nome>/                → Config pessoal
└── profiles/                    → Presets da instância

Kryonix Installer
├── ISO build                    → hosts/iso/
├── TUI/Lib                      → install scripts
├── Web Kiosk                    → Cage + Chromium
├── Disk Planner                 → Rust
├── Hardware Probe               → Rust
└── Backend + UI                 → Axum + React

Kryonix Brain
├── LightRAG                     → RAG engine
├── FastAPI                      → API server
├── CLI `rag`                    → Query CLI
└── Autopilot                    → Self-healing

Kryonix Vault
├── 01-MOCs/                     → Navigation
├── 02-Areas/                    → Knowledge
├── 03-Projetos/                 → Active projects
└── 09-Logs/                     → Sessions & decisions
```

## Links

[[CORE_DOWNSTREAM_INSTALLER]]
[[PACKAGE_CLASSIFICATION]]
[[DEVELOPMENT_FLOW]]
