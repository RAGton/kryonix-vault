---
source: repos/kryonix/docs/mcp/README.md
status: partial
canonical: false
last_sync: 2026-07-15
---

# MCP (Model Context Protocol)

> [!IMPORTANT]
> Esta nota é derivada. O código e `repos/kryonix/docs/mcp/` vencem em caso de
> divergência.

## Estado

MCP local usa JSON-RPC sobre `stdio`. Hermes está aposentado; os wrappers não
dependem dele e podem ser consumidos por qualquer cliente compatível.

| Componente | Estado |
|---|---|
| Filesystem sandboxado | PARTIAL — implementação e prova local feitas; host não ativado |
| Git sandboxado | PARTIAL — leitura e bloqueio de staging provados localmente; host não ativado |
| Sequential Thinking | PARTIAL — handshake local provado; host não ativado |
| NixOS Docs | PARTIAL — pacote Nix/sandbox implementado; host não ativado |
| Brain MCP via Glacier | PARTIAL — requer prova runtime remota |
| GitHub MCP | não habilitado |

## Decisão de segurança

`mcp-server-filesystem` e `mcp-server-git` upstream oferecem ferramentas
mutantes. Limitar diretórios no config não os torna read-only.

O contrato Kryonix usa wrappers `kryonix-mcp-*` com `bubblewrap`, ambiente
limpo, mounts `--ro-bind` e home temporário. A garantia vem do kernel, não de
prompt, nome ou `readOnlyHint`.

O wrapper `mcp-nixos` recebe rede, mas nenhum mount do host. Filesystem, Git e
Sequential Thinking ficam sem rede.

## Pendências

- ativar somente após build do host;
- validar handshake e provas negativas na geração do Inspiron;
- implementar limite obrigatório/paginação de output; `rag-slim-wrapper` não
  existe no código atual;
- validar Brain remoto no Glacier;
- manter GitHub/Fetch/Memory fora até contrato explícito de RBAC, custo e
  persistência.

## Fontes

- [Filesystem MCP Server](https://github.com/modelcontextprotocol/servers/blob/main/src/filesystem/README.md)
- [Sequential Thinking MCP Server](https://github.com/modelcontextprotocol/servers/blob/main/src/sequentialthinking/README.md)
- [MCP reference servers](https://github.com/modelcontextprotocol/servers)

## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]
- [[02-Areas/Kryonix/systems/Brain]]
- [[02-Areas/Kryonix/ai-brain/Hermes]]
