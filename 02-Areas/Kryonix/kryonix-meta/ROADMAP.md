---
type: project-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-15
tags: [kryonix, roadmap]
links:
  - "[[MOC - Kryonix]]"
  - "[[ACTIVE_WORK]]"
  - "[[Externalize-Roadmap]]"
---

# Roadmap — Kryonix

> Direção atual: **fechar a distro até RC1**. Detalhes operacionais por
> sprint em [[Externalize-Roadmap]].

## Sprint atual — Externalização do installer (P0)

1. Mergear [PR #1 RAGton/kryonix-installer](https://github.com/RAGton/kryonix-installer/pull/1)
   (`initial-flake-and-ci`) — ✅ aberto, MERGEABLE, validações verde.
2. PR no Kryonix: `installer/externalize-input-p1` (consumir installer
   como flake input; manter pacote interno como fallback).
3. PR no Kryonix: `installer/exclude-installer-from-target-p2`
   (denylist + teste assertando target instalado limpo).
4. PR no Kryonix: `installer/remove-internal-source-p3`
   (remover `packages/kryonix-installer/`).

Critério: sistema instalado não carrega `packages/kryonix-installer/`
source; ISO e CLI seguem funcionando com binário via overlay.

## Curto prazo (semanas)

1. Sprint externalização (acima).
2. Build ISO completo + smoke test em VM libvirt
   (boot → kiosk → `/dry-run` → install qcow2 → reboot).
3. CI #79 — triagem por workflow (tabela em [[Externalize-Roadmap]]).
4. Validar HM downstream após `kryonixos rebuild`.

## Médio prazo (1-2 meses)

- Backend hardening P2 (`installer/backend-hardening-p2`):
  - `deny_unknown_fields`
  - Payload guards (gigante / null bytes / path traversal)
  - HTTP harness para E2E
  - VM libvirt pentest
- UI final do installer (erro, sucesso, export `install-plan.json`).
- Segurança da UI remota (token + opt-in remote).
- P4 — Plymouth logo dedicado (`branding/plymouth-logo-p4`).
- P5 — `kryonix.branding.systemLabel` opt-in (hosts não-ISO).

## Longo prazo

- Refactor desktop em camadas (skill `phase4-desktop`)
- Kryonix Shell WM-first (skill `phase7-kryonix-shell`)
- Aurora Shell sobre KDE (skill `phase8-kryonix-aurora`)
- Channel/release track real

## Backlog persistente

- versionId vs stateVersion (cosmético vs técnico) — docs
- GRUB extraEntries / menuentry custom
- audio/portaudio (preservado em #65)
- qdbus-nocore overlay (preservado em #69)
- ISO firewall/listenAddress (preservado em #65)
- Aura agent migration (resumo do Hermes purge em [[Hermes]])

Ver: [[CURRENT_STATE]] · [[ACTIVE_WORK]]
