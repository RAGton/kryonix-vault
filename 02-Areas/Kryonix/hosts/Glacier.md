---
type: host-spec
project: Kryonix
status: production
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, host, glacier, server, ai, amd, nvidia]
links:
  - "[[MOC - Hosts]]"
  - "[[Ollama]]"
  - "[[Neo4j]]"
---

# Glacier

Server / IA do Kryonix.

## Identidade

- Hostname: `glacier` (alias hostname Linux pode ser `rve-glacier`)
- Role: Server / Brain Node
- CPU: AMD
- GPU: Nvidia (CUDA)

## Branding

- `kryonix.branding.prettyName = "Kryonix Glacier"`
- `kryonix.branding.edition = "Server/Workstation"`
- `KRYONIX_PRETTY_NAME` em `/etc/kryonix-version` reflete a edição.

## Serviços

- [[Ollama]] — LLM local (keepAlive=0)
- [[Neo4j]] — grafo restrito a Tailscale
- `kryonix-brain-api` — FastAPI sobre LightRAG
- Túneis Tailscale para acesso remoto

## Build

```bash
nix build .#nixosConfigurations.glacier.config.system.build.toplevel \
  --no-link -L --show-trace
```

Compilação pesada (Rust/CUDA/PyTorch) acontece aqui ou vem do Cachix
(`kryonix.cachix.org`).

## Política operacional

- `kryonix switch --host glacier` permitido de remoto (com `--host`).
- Antes de switch: `kryonix check --host glacier`.
- Recuperação Brain: `kryonix brain doctor --remote`.

## Build pesado

- `kryonix-llama-cpp-cuda` (LightRAG)
- `kryonix-brain-lightrag-src`
- Optimizer Rust (`kryonix-optimizer`)

Ver: [[Inspiron]] · [[MCP]]
