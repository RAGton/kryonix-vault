# MOC — Kryonix Core Boundaries

## Objetivo

Navegação para toda documentação sobre boundaries arquiteturais do Kryonix: o que pertence ao core, o que vai para downstream, o que é produto independente.

## Documentos canônicos

- [[02-Areas/Kryonix/canonical/CORE_DOWNSTREAM_INSTALLER]]
- [[02-Areas/Kryonix/canonical/PACKAGE_CLASSIFICATION]]
- [[02-Areas/Kryonix/canonical/BOUNDARIES]]
- [[02-Areas/Kryonix/canonical/DEVELOPMENT_FLOW]]

## Auditorias

- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/README]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/01-core-inventory]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/02-package-classification]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/03-hosts-and-downstream-boundaries]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/04-installer-boundary]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/05-brain-aura-home-assets-boundary]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/06-runtime-state-and-secrets]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/07-migration-plan]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/08-pr-backlog]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/09-validation-checklist]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/10-open-questions]]
- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/11-evidence-pack]]

## Erratas (correções da auditoria)

1. `.agents/` foi reclassificado de LEGACY para `CANONICAL_AGENT_CONTEXT` — é ativo e referenciado pelo AGENTS.md canônico.
2. `profiles/glacier-*` foram reclassificados de `DOWNSTREAM_ONLY` para `CORE_MODULE` — são ativos e usados pelo downstream.
3. `kryonix-hardware-probe` foi reclassificado de `INSTALLER_PRODUCT` para `CORE_SHARED` — usado pela CLI também.
4. `desktop/` foi separado em assets (SDDM/wallpapers) vs config funcional (Hyprland/KDE core).

## PRs relacionados

- PR #87 — browser-automation (gatilho desta auditoria)
- PR #90 — docs: boundary audit (este documento)
- PR #91 a #98 — migrações (backlog)

## Perguntas abertas

Ver [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/10-open-questions]]
