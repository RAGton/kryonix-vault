---
type: ai-note
project: Kryonix
status: active
created: 2026-06-14
updated: 2026-06-14
tags: [kryonix, brain, mcp, security]
links:
  - "[[MOC - AI Brain]]"
  - "[[Security Model]]"
---

# MCP — Model Context Protocol

Interface JSON-RPC entre LLMs e ferramentas/sistemas.

## Configuração

- Versionado: `.mcp.example.json` (template, sem secrets).
- Real: `.mcp.json` (gitignored, com tokens).
- Codex: `.codex/config.toml`.

## Servidores típicos no Kryonix

| Servidor | Acesso inicial | Notas |
|----------|----------------|-------|
| Filesystem | read-only | acesso a `/` proibido |
| GitHub | token | wrapper `kryonix-github-mcp` |
| Brain MCP | read-only | runtime Python |
| Neo4j | read-only | local-only |
| Ollama | local | restrito |

## Validação

```bash
kryonix mcp check        # Inspiron — validação leve
kryonix mcp doctor       # Glacier — runtime completo
kryonix mcp print-config
./scripts/check-mcp.sh
codex mcp list           # cliente Codex
```

## Regras de segurança

- JSON-RPC limpo no stdout; logs em stderr.
- Bancos: read-only por padrão; destrutivos bloqueados.
- Nunca tokens em `.mcp.json` versionado.

Detalhes: `docs/mcp/SECURITY.md` no repo. Ver [[Security Model]].
