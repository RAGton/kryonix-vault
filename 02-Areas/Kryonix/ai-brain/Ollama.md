---
type: ai-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, brain, ollama, llm]
links:
  - "[[MOC - AI Brain]]"
  - "[[Glacier]]"
---

# Ollama — Kryonix

LLM local rodando no host [[Glacier]] (server com Nvidia/AMD).

## Política

- Não fica ativo perpetuamente — economia de VRAM.
- `keepAlive=0` → desliga quando ocioso.
- Subir sob demanda quando uma sessão Brain começa.

## Comandos

```bash
kryonix ollama status
kryonix ollama list
kryonix ollama pull <model>
kryonix ollama run               # chat interativo
```

## Debug

- `journalctl -u kryonix-brain-api.service -f`
- `systemctl stop kryonix-brain-api.service` (para o motor)

## Restrição

- VRAM tuning por perfil: `kryonix brain vram-profile {ai|balanced|gaming}`.
- Audit: `kryonix brain vram-audit`.

Ver: [[Glacier]] · [[RAG CAG GraphRAG]]
