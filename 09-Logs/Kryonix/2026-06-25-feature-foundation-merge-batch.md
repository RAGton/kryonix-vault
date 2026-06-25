---
title: Feature foundation merge batch
date: 2026-06-25
project: Kryonix
type: log
status: completed
---

# Feature foundation merge batch

## Summary

Merged and validated the first canonical feature foundation batch in `RAGton/kryonix`.

## Merged PRs

| PR | Scope | Result |
|---:|---|---|
| #92 | feature schema | merged + validated |
| #93 | feature registry | merged + validated |
| #103 | development canonical migration | merged + validated |
| #104 | virtualization canonical migration | merged + validated |
| #105 | gaming canonical migration | merged + validated |
| #106 | AI namespace alignment | merged + validated |

## Resulting canonical tree

```txt
modules/nixos/features/
├── schema.nix
├── registry.nix
├── development.nix
├── virtualization.nix
├── gaming.nix
└── ai.nix
```

## Runtime impact

No runtime services were changed.

No hosts, installer, downstream config, secrets, GPU/CUDA, storage paths, or service units were changed.

## Decisions reinforced

* `modules/nixos/features/` is canonical.
* `features/` remains legacy/compat temporarily.
* `schema.nix` owns common/core namespace declarations.
* `registry.nix` is the base for future feature metadata/export.
* AI runtime migration remains pending and must be split.

## Next recommended work

1. Registry audit.
2. Feature catalog export design for installer.
3. Remote-desktop/openrgb/workstation/f5-tts migration planning.
4. AI runtime migration plan split into Brain, Ollama/OpenWebUI, Neo4j/LightRAG.
