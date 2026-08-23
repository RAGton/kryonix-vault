# Configuração das ferramentas web/MCP do Hermes (Inspiron)

Data: 2026-08-23
Agente: Aura
Repos afetados: nenhum (config local `~/.hermes/config.yaml`)

## Objetivo

Ficar mais inteligente no projeto, ativando ferramentas de busca, extração web e
MCP de NixOS que estavam quebradas ou desconfiguradas.

## Contexto consultado

- `hermes status`, `hermes tools list`, `hermes plugins list`, `hermes mcp list`
- Código-fonte do provider Firecrawl (`plugins/web/firecrawl/provider.py`) — heroi do
  mecanismo direct-vs-gateway.
- Busca web (agora funcional) para o comando de instalação do `utensils/mcp-nixos`.

## Problemas encontrados e correções

### 1. Busca web quebrada (web.backend = searxng)
- **Sintoma:** `web_search` falhava com `SEARXNG_URL is not set`.
- **Causa:** `web.backend: searxng` apontando pra um SearXNG sem URL configurada.
- **Correção:** `hermes config set web.backend firecrawl` + `web.use_gateway true`.
  O provider firecrawl usa o **Nous Tool Gateway** (`firecrawl-gateway.nousresearch.com`)
  autenticado pelo token do Nous Portal — sem API key extra (assinatura Nous).

### 2. Extração web quebrada (sem extract_backend)
- **Sintoma:** `web_extract` falhava com "SearXNG is a search-only backend...".
- **Correção:** mesmo que acima — o firecrawl fornece `search` + `extract`.

### 3. MCP nixos-mcp quebrado (url inválida)
- **Sintoma:** `hermes mcp test nixos-mcp` → "Invalid MCP URL... scheme must be http or
  https, got 'github'".
- **Causa:** config `url: github:utensils/mcp-nixos` num transport HTTP — inválido; o
  mcp-nixos roda via stdio.
- **Correção:** `hermes mcp remove nixos-mcp` + `hermes mcp add nixos-mcp --command uvx
  --args mcp-nixos` → conecta via `uvx`, descobre 2 tools (`nix`, `nix_versions`).

### 4. context_engine desabilitado
- **Correção:** `hermes tools enable context_engine`.

## Validações executadas

| Item | Resultado |
|---|---|
| `web_search` real | ✅ Retornou resultados (Proxmox 9.2) |
| `web_extract` real | ✅ Extraiu página completa do Roadmap Proxmox |
| `hermes mcp test nixos-mcp` | ✅ Connected (1599ms), 2 tools |
| MCP tools | `nix` + `nix_versions` |
| `context_engine` | ✅ Enabled |

## Pendências

- `web.backend`/`use_gateway` + MCP: mudanças de toolset exigem `/reset` (nova sessão)
  para entrarem na sessão. Já afetaram a sessão atual para search/extract (lido por chamada).
- Há toolset `video`, `video_gen`, `x_search`, `homeassistant`, `spotify` desabilitados —
  não relevantes ao projeto (ou exigem credencial externa).

## Próximo passo recomendado

- Rodar `/reset` (ou `/reload-mcp`) para garantir o MCP nixos-mcp disponível na sessão atual.
- Se quiser mais poderes: adicionar FERACRAWL_API_KEY direta (opcional), ou configurar
  um backend de browser local se o browser-use via gateway não bastar.

#tags #hermes #configuração #web-tools #mcp #nixos #firecrawl