---
type: branding-note
project: Kryonix
status: shipped
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, branding, terminal, fastfetch, zsh]
links:
  - "[[MOC - Branding]]"
  - "[[KryonixOS Identity]]"
---

# Terminal Identity — KryonixOS

PR #80 mergeado. Cobre shell interativo.

## fastfetch (Home Manager)

Logo ASCII Kryonix injetado via `pkgs.writeText` (sem arquivo externo):

```txt
██╗  ██╗
██║ ██╔╝
█████╔╝       ← $1 = cyan
██╔═██╗       ← $2 = magenta
██║  ██╗
╚═╝  ╚═╝
```

- Tamanho: 10 col × 6 linhas.
- Opção: `kryonix.programs.fastfetch.logo.enable = true` (default).
- Desativar → `logo.type = "none"`.
- Módulos system-info preservados (OS, Machine, Kernel, Packages, Uptime,
  Resolution, WM, DE, Shell, Terminal, CPU, GPU, Memory, IPs, paleta).

## zsh (Home Manager)

Welcome banner curto no startup interativo:

```
KryonixOS · <hostname>
```

- Cores: cyan · magenta.
- Idempotente por sessão (`KRYONIX_WELCOME_DONE`).
- Opt-out declarativo: `kryonix.programs.zsh.welcomeBanner.enable = false`.
- Opt-out runtime: `export KRYONIX_NO_WELCOME=1`.
- Banner fastfetch completo continua opt-in via `RAG_ZSH_STARTUP_BANNER=1`.

## Limites

- HM Home Manager não tem `homeConfigurations.*` no upstream.
  Validação real ocorre no downstream `kryonixos rebuild`.

Ver: [[Branding KryonixOS]] · [[KryonixOS Identity]]
