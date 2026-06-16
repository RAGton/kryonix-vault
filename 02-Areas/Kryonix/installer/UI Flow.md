---
type: installer-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, installer, ui, react, vite]
links:
  - "[[MOC - Installer]]"
---

# Installer UI Flow

## Steps do wizard (após PR #70)

```txt
1. Welcome
2. Network                  (handleNetworkNext aplica /network/apply antes do next)
3. Disks
4. Machine Profile
5. Profile
6. Source                   (offline-defaults / offline-cache / remote-github)
7. Host Selection
8. Remote Access            (auto-detect IP no mount, sem toggle)
9. System Features
10. User Features
11. Summary                 (slugs internos → labels amigáveis)
12. Install                 (irreversível)
```

## Utilities centrais

- `src/utils/installerApi.js` — chamadas axum (`/network/*`,
  `/dry-run`, `/install`, etc.).
- `src/utils/installPlan.js` — serializa draft → payload backend.
- `src/utils/network.js` — funções puras (`isValidIpv4`,
  `netmaskToPrefix`).
- `src/state/wizardState.js` — estado persistente + transient.
- `src/install-plan.schema.json` — JSON Schema (validação Ajv).

## Testes (47/47 após PR #70)

- `src/tests/installPlan.test.js`
- `src/tests/installExecution.test.js`
- `src/tests/localizationCatalog.test.js`
- `src/tests/storagePlanner.test.js`
- `src/tests/wizardState.test.js`

## Build

```bash
cd packages/kryonix-installer/ui
npm install
npm test
npm run build              # vite build → dist/
```

Ver: [[Backend Routes]] · [[Network Flow]]
