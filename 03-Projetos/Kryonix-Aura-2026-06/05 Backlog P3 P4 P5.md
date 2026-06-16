---
title: Backlog P3 / P4 / P5
date: 2026-06-14
type: backlog
status: ongoing
tags: [kryonix, backlog, branding, boot, plymouth, ci]
related:
  - "[[00 Index]]"
  - "[[04 Auditoria Boot Identity P3]]"
  - "[[06 CI Debt Issue 79]]"
---

# Backlog P3 / P4 / P5

Fatiamento sugerido das próximas frentes. Cada item vira PR isolado e
pequeno — herança da política do PR #62.

## Em curso

### P3 · `branding/boot-identity-p3`

- [x] Auditoria read-only ([[04 Auditoria Boot Identity P3]])
- [x] Branch criada a partir de `30d84ad6`
- [x] `assets/grub-theme/theme.txt` — label `KryonixOS`
- [x] `modules/nixos/meta/version.nix` — fix duplicação
- [x] `hosts/iso/default.nix` — `KryonixOS-Installer`
- [ ] `nix fmt` / `git diff --check`
- [ ] `nix flake show`
- [ ] `nix build` ISO toplevel + installer
- [ ] verificações `cat $TOP/...`
- [ ] commits (3, separados por tema)
- [ ] push + PR

## Próximo

### P4 · `branding/plymouth-logo-p4`

**Risco médio** — assets Plymouth.

- [ ] Substituir `assets/avatar/ragton.jpeg` por logo KryonixOS dedicado
- [ ] Considerar formatos: PNG 120×120 (compatível com script atual) ou
      SVG → PNG via ImageMagick
- [ ] Manter `kryonix-plymouth-theme` derivation com nova fonte
- [ ] Testar em VM antes de mergear

### P5 · `branding/system-label-p5`

**Risco médio** — toca hosts reais.

- [ ] Nova opção `kryonix.branding.systemLabel = { enable, distroName }`
- [ ] Aplicar em `hosts/inspiron`, `hosts/glacier` (via downstream)
- [ ] `system.nixos.distroName = "KryonixOS"` opt-in
- [ ] Não substituir `ID=nixos` (técnico, compat tooling)
- [ ] Validar em ambos os hosts antes de merge

### CI · Issue #79 ([[06 CI Debt Issue 79]])

- [ ] PR `chore(ci/iso-build)` — investigar Build & Test ISO
- [ ] PR `chore(ci/nix-validation)` — identificar check específico
- [ ] PR `chore(ci/rust-audit-home)` — reproduzir o que checa
- [ ] PR `chore(ci/security-scan)` — falha em ~8s, possível secret
- [ ] PR `chore(ci/claude-action)` — avaliar propósito ou remover

## Fora dos próximos PRs (fila longa)

### Branding ainda pendente
- channel/release track (`kryonix.branding.releaseTrack`)
- alinhar `versionId` (25.11) com `stateVersion` (26.05) ou doc separada
- GRUB extraEntries / menuentry custom
- GRUB hint em PT-BR vs EN — decisão de localização
- Plymouth refactor pesado (animação real)

### Backend installer
- `deny_unknown_fields` em todos os structs
- Payload gigante / null bytes / path traversal causando panic (E2E HTTP)
- Auditoria completa do executor `/install`
- Pentest E2E em VM libvirt
- Install real em disco

### Outras frentes
- audio/portaudio (preservado em #65)
- qdbus-nocore overlay (preservado em #69)
- ISO firewall/listenAddress (preservado em #65)
- Refactor desktop em camadas (fase 4 via skill `phase4-desktop`)
- Kryonix Shell WM-first (fase 7)
- Aurora Shell sobre KDE (fase 8)

## Pendências de validação

- [ ] Validar Home Manager fastfetch + zsh nos hosts downstream após
      próximo `kryonixos rebuild` (PR #80 introduziu o welcome banner)
- [ ] Smoke-test visual real do GRUB/Plymouth em VM libvirt (após P3+P4)
- [ ] Fechar PRs draft #65–#69 quando confortável (preservação histórica)
- [ ] Limpar minha worktree em `/etc/kryonix/.claude/worktrees/aura-git-dev-prod-skill`
      quando sessão do agente terminar

Ver: [[02 PRs Mergeados]] · [[07 Aprendizados e Regras Operacionais]]
