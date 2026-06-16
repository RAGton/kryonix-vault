---
type: entity
entity-type: service
project: Kryonix
status: production
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, service, brain, fastapi]
links:
  - "[[Glacier]]"
  - "[[Ollama]]"
  - "[[Neo4j]]"
---

# Serviço · kryonix-brain-api

FastAPI sobre LightRAG. Vive em [[Glacier]].

## Módulo Nix

`modules/nixos/services/brain.nix` (systemd: ollama, lightrag, brain-api).

## Estado

- `/var/lib/kryonix/brain/` — persistência.
- Credenciais em `/etc/kryonix/brain.env` (`0600`, gitignored).

## Endpoints

- `/health`, `/stats`, `/ask`, `/search`, `/vault-scan`, ...

## CLI

```bash
kryonix brain {start, stop, restart, status, health, doctor, stats,
  search, ask, vault-scan, index, vram-audit, vram-profile, remote,
  autopilot}
```

## Debug

- `journalctl -u kryonix-brain-api.service -f`

Ver: [[MOC - AI Brain]]


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]