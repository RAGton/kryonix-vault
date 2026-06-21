---
tipo: pr-log
projeto: kryonix
componente: browser-automation
created: 2026-06-21
updated: 2026-06-21
author: aura
tags: [pr, nixos, browser-automation, playwright, nix-ld]
---

# PR-087 — browser automation runtime support

## Estado

- PR: https://github.com/RAGton/kryonix/pull/87
- Status: OPEN / Draft
- Branch: `feat/browser-automation`
- Commit: `0b40dcb7b286c51cdea5cf4f4defefa26169cecf`

## Objetivo

Adicionar suporte declarativo para browser automation no NixOS usando `nix-ld`, permitindo que Chromium/Playwright/Puppeteer usados por Hermes/Aura encontrem bibliotecas nativas no sistema.

## Arquivos alterados

- `modules/nixos/features/browser-automation.nix` (novо)
  - Módulo declarativo com option `kryonix.features.browserAutomation`.
  - Popula `programs.nix-ld.libraries` com 22 libs do Chromium:
    `glib, gtk3, atk, at-spi2-atk, cups, libdrm, dbus, expat, cairo, pango, alsa-lib, nspr, nss, libxkbcommon, xorg.libX{11,composite,damage,ext,fixes,randr,xcb}, libgbm`.
  - Instala `playwright-driver` quando `installPlaywright = true` (default).
  - Seta `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1` e (quando aplicável) `PLAYWRIGHT_BROWSERS_PATH` apontando para o store path.
- `modules/nixos/features/default.nix`
  - Apenas adiciona import do novo módulo.
- `hosts/inspiron/default.nix`
  - Ativa `kryonix.features.browserAutomation.enable = true` no host atual.

## Validações

- `nix fmt` nos arquivos alterados: OK
- `git diff --check`: OK (sem whitespace errors)
- `nix flake check --keep-going`: FALHOU em `checks.x86_64-linux.formatting`
  - Motivo: formatação suja pré-existente fora do escopo (`desktop/kde/wallpaper.nix`, múltiplos `modules/{nixos,home-manager}/features/*.nix`, `packages/kryonix-wallpapers.nix`).
  - **Nenhum dos 3 arquivos deste PR aparece na lista de erro.**

## Pendências

- Validar downstream em `kryonixos` (`/etc/kryonixos`) com `--override-input kryonix git+file:///home/rocha/kryonix/kryonix`.
- Decidir se formatação pré-existente vira PR separado ou fica como dívida técnica.
- Após aprovação explícita e merge:
  - `sudo git pull --ff-only origin main` em `/etc/kryonix`.
  - `sudo git pull --ff-only origin main` em `/etc/kryonixos` (ou equivalente com `--override-input`).
  - `sudo nixos-rebuild switch --flake /etc/kryonixos#inspiron` (só com autorização).
- Retestar Hermes/browser-automation; screenshots devem funcionar depois do switch.

## Segurança

### O que NÃO foi executado nesta sessão

Comandos de ativação / rebuild (nenhum deles rodado, em nenhum momento):

- [x] `kryonix switch` (qualquer subcomando: `all`, `client`, `server`, etc.)
- [x] `kryonix boot`
- [x] `kryonix rebuild`
- [x] `kryonix test` (em runtime do sistema)
- [x] `nixos-rebuild switch` (com ou sem sudo, com ou sem `--flake`)
- [x] `nixos-rebuild boot`
- [x] `nixos-rebuild test`
- [x] `nixos-rebuild build-vm` / `boot-vm`
- [x] qualquer comando que altere `/run/current-system` ou `/nix/var`

Comandos destrutivos (todos bloqueados):

- [x] `disko` / `disko-format` / `disko-mount`
- [x] `mkfs.*` em qualquer partição real
- [x] `nixos-install`
- [x] `reboot` / `poweroff` / `shutdown`
- [x] `git reset --hard`
- [x] `git clean -fdx`
- [x] `git push --force`

Fluxo upstream/downstream (nenhum executado):

- [x] `git pull` em `/etc/kryonix`
- [x] `git pull` em `/etc/kryonixos`
- [x] qualquer `--override-input` executando build contra host real

Git operacional:

- [x] Não usado `git add .`
- [x] Não misturado com `feat/remote-web-boot-mode`

Arquivos canônicos / sensíveis:

- [x] Não tocado em `/etc/kryonix`
- [x] Não tocado em `/etc/kryonixos`
- [x] Não alterados `flake.lock`, `flake.nix`, `hosts/*/hardware-configuration.nix`, `hosts/*/disks.nix`
- [x] Não alterados `packages/kryonix-brain-lightrag` (submodule) nem nenhum módulo de `modules/nixos/installer/*`

PR:

- [x] Nenhum merge feito
- [x] Não retirado de Draft

## Observação lateral

Dependabot reportou 13 vulnerabilidades na default branch (2 high, 6 moderate, 5 low) quando o push chegou no GitHub. Não relacionado a este PR — tratar em momento separado. Ver `https://github.com/RAGton/kryonix/security/dependabot`.

## Links relacionados

- [[04-Recursos/skills/vibe-coding/briefing-to-spec]]
- [[03-Projetos/kryonix-installer]] (quando for retomar UI)
- [[09-Logs/evidence/vibe-coding-agent-training-2026-06-21]]
