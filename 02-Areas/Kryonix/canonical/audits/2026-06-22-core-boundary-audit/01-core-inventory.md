# Inventário do Kryonix Core

## Flake

- `flake.nix` — 330+ linhas, centraliza inputs, overlays, outputs
- `flake/` — modularizado: `checks.nix`, `data/hosts.nix`, `formatter.nix`, `lib.nix`, `modules.nix`, `packages.nix`, `shells.nix`

## Hosts encontrados no core

| Host | Caminho | Categoria | Deve ficar? | Destino |
|---|---|---|---|---|
| `common` | `hosts/common/default.nix` | `CORE_SHARED` | ✅ Sim | Core |
| `inspiron` | `hosts/inspiron/default.nix` | `DOWNSTREAM_ONLY` | ❌ Não | kryonixos |
| `inspiron` (disks) | `hosts/inspiron/disks.nix` | `DOWNSTREAM_ONLY` | ❌ Não | kryonixos |
| `inspiron` (hardware) | `hosts/inspiron/hardware-configuration.nix` | `DOWNSTREAM_ONLY` | ❌ Não | kryonixos |
| `iso` | `hosts/iso/default.nix` | `ISO_ONLY` | ❌ Não | kryonix-installer |

**Obs**: O `inspiron` no core NÃO é usado pelo flake (o `flake/data/hosts.nix` só contém `iso`). Ele existe como resíduo histórico. O verdadeiro `inspiron` vive em `/etc/kryonixos/hosts/inspiron/`.

## Modules

### NixOS Modules (`modules/nixos/`)

| Módulo | Categoria | Descrição |
|---|---|---|
| `audio/` | `CORE_MODULE` | Configuração de áudio (PipeWire) |
| `base/` | `CORE_MODULE` | Base do sistema (locale, time, Nix settings) |
| `branding/kryonix/` | `CORE_SHARED` | Branding Kryonix (grub, issue, iso) |
| `branding/ragos/` | `LEGACY` | Branding RagOS legado |
| `common/` | `CORE_MODULE` | Common compartilhado entre hosts |
| `desktop/` | `CORE_MODULE` | Orquestrador de desktop (KDE, Caelestia) |
| `features/` | `CORE_MODULE` | Features toggle (ai, browser-automation, desktop, gamer, etc.) |
| `hardware/` | `CORE_MODULE` | Hardware genérico |
| `hyprland/` | `CORE_MODULE` | Módulo Hyprland |
| `input/` | `CORE_MODULE` | Input (teclado, mouse, touchpad) |
| `installer/` | `INSTALLER_PRODUCT` | Installer TUI/TUI lib/web-kiosk |
| `meta/` | `CORE_MODULE` | Metadados do sistema |
| `network/` | `CORE_MODULE` | Rede |
| `programs/` | `CORE_MODULE` | Programas (jupyter, kryonix CLI, ragos, winbox) |
| `services/` | `CORE_MODULE` | Serviços (aura, brain, state, neo4j, tailscale, etc.) |
| `theming/` | `CORE_SHARED` | Theming base |

### Home Manager Modules (`modules/home-manager/`)

| Módulo | Categoria | Descrição |
|---|---|---|
| `common/` | `CORE_MODULE` | HM comum a todos |
| `desktop/` | `CORE_MODULE` | Monitores HM |
| `features/` | `CORE_MODULE` | Features HM (ai, browser, desktop, dev, etc.) |
| `misc/` | `CORE_MODULE` | GTK, Qt, wallpaper, XDG |
| `programs/` | `CORE_MODULE` | 30+ programas (vscode, neovim, zsh, git, etc.) |
| `scripts/` | `CORE_SHARED` | Scripts shell do usuário |
| `services/` | `CORE_MODULE` | Serviços HM (kryonix-bar, home, optimizer, etc.) |

## Packages

| Package | Categoria | Descrição |
|---|---|---|
| `kryonix-cli` | `CORE_CLI` | CLI principal do Kryonix |
| `kryonix-brain-lightrag` | `BRAIN_PRODUCT` | Submódulo Python/Rust do Brain (repo externo) |
| `kryonix-home` | `HOME_PRODUCT` | CLI Rust para organização de home |
| `kryonix-disk-planner` | `INSTALLER_PRODUCT` | Planejador de disco em Rust |
| `kryonix-hardware-probe` | `INSTALLER_PRODUCT` | Probe de hardware |
| `kryonix-bar` | `CORE_PACKAGE` | Backend D-Bus da barra (Rust) |
| `kryonix-caelestia-watcher` | `CORE_PACKAGE` | Watcher Caelestia (Rust) |
| `kryonix-monitors` | `CORE_PACKAGE` | Gerenciador de monitores |
| `kryonix-optimizer` | `CORE_PACKAGE` | Otimizador Python |
| `kryonix-wallpapers` | `DESKTOP_ASSET` | Wallpapers Kryonix Aurora |
| `kryonix-sddm-theme` | `DESKTOP_ASSET` | Tema SDDM Kryonix Aurora |
| `bonafides-theme` | `DESKTOP_ASSET` | Tema Plasma BonaFides |
| `kryonix-llama-cpp-cuda` | `CORE_PACKAGE` | Llama.cpp CUDA |
| `aura/aura.sh` | `AURA_PRODUCT` | Script do agente Aura |

## Overlays

| Overlay | Descrição |
|---|---|
| `default.nix` | 10 overlays (stable-packages, openrgb, drkonqi, etc.) |
| `patches/` | Patches (atlauncher, drkonqi) |

## Lib

| Arquivo | Descrição |
|---|---|
| `lib/default.nix` | Funções helpers do flake |
| `lib/options.nix` | Opções globais do Kryonix (`kryonix.*`) |

## Docs (apenas os ativos)

| Área | Descrição |
|---|---|
| `docs/ARCHITECTURE.md` | Arquitetura geral |
| `docs/brain/` | Documentação do Brain |
| `docs/installer/` | Documentação do Installer |
| `docs/operations/` | Procedimentos operacionais |
| `docs/ai/` | Documentação para agentes IA |
| `docs/desktop/` | Documentação do desktop |
| `docs/hosts/` | Documentação de hosts |

## Scripts

| Script | Descrição |
|---|---|
| `scripts/` | ~20 scripts (testes, validação, deploy, secret scan) |

## Referências suspeitas

- `hosts/iso/default.nix` importa `modules/nixos/installer/` — amarração correta mas deveria estar no repo installer
- `packages/kryonix-brain-lightrag` é submódulo Git → conflito com consumo via flake input
- `profiles/` contém `glacier-*.nix` que são específicos de servidor, não de core
- `features/f5-tts-server/` contém `setup.sh` com caminho hardcoded `/etc/kryonix/`

## Observações

- Total de arquivos .nix: ~200
- Total de diretórios top-level: ~30
- Contexto IA fragmentado em 4 diretórios ocultos (`.ai/`, `.agents/`, `.claude/`, `.codex/`)
- Submódulos Git: `packages/kryonix-brain-lightrag`, `packages/kryonix-home`
