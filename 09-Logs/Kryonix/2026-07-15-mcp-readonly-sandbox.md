# MCP read-only com sandbox de kernel

Data: 2026-07-15
Agente: Codex
Repos afetados:

- kryonix
- kryonix-vault

## Objetivo

Confrontar a proposta de MCPs para Hermes com o estado real do projeto e
implementar a menor base declarativa que não conceda escrita ou acesso amplo ao
host.

## Contexto consultado

- `AGENTS.md` do workspace, core e Vault;
- `VAULT_INDEX.md` e notas de Hermes/MCP;
- `docs/CURRENT_STATE.md`, `docs/ROADMAP.md` e `docs/mcp/`;
- módulo real `modules/nixos/features/mcp.nix`;
- documentação e advisories dos servidores MCP oficiais.

## Mudanças realizadas

- mantido Hermes como aposentado;
- implementados wrappers opt-in para filesystem, Git, NixOS Docs e Sequential
  Thinking;
- aplicado `bubblewrap`, ambiente limpo, home efêmero e mounts read-only;
- adicionadas allowlists e assertions Nix;
- removido token fictício e registro direto de servidores mutantes do template;
- corrigida documentação que tratava `server-filesystem` como read-only;
- mantidos GitHub, Fetch/Context7 e Memory fora do default.

## Commits e branches

- branch core preexistente: `fix/installer-iso-e2e`;
- nenhum commit criado nesta execução, para não misturar com o worktree amplo
  já existente sem revisão humana.

## Validações executadas

- `nix-instantiate --parse modules/nixos/features/mcp.nix`: OK;
- `nixfmt --check modules/nixos/features/mcp.nix`: OK;
- build das quatro wrappers com o nixpkgs pinado: OK;
- handshake MCP 2025-06-18 e `tools/list`: OK nos quatro servidores;
- consulta real `mcp-nixos` sobre `bubblewrap`: OK;
- leitura filesystem: OK; `write_file`: bloqueado com `EROFS`;
- `git_status`: OK; `git_add`: bloqueado com `EROFS`; índice inalterado;
- repositório Git fora da allowlist: bloqueado com código 77;
- Sequential Thinking: chamada OK e conteúdo ausente do `stderr`;
- assertions Nix: configuração segura aceita; `/` e allowlist vazia rejeitados;
- `jq empty .mcp.example.json`: OK;
- `git diff --check`: OK;
- `python3 scripts/check_obsidian_links.py`: executou; reportou dívida antiga
  ampla de links ausentes, sem apontar as duas notas alteradas nesta tarefa;
- scan de secrets: nenhum valor real adicionado; ocorrências são termos de
  política e remoção do token fictício anterior;
- `nix flake check --keep-going`: PARTIAL — avaliação do flake e módulo passou,
  mas o check global de formatação falhou em
  `modules/nixos/security/apparmor_industrial.nix`, arquivo preexistente e fora
  deste escopo.

## Evidências

- filesystem: `EROFS: read-only file system` e probe ausente após o teste;
- Git: `index.lock: Read-only file system` e hash do índice inalterado;
- allowlist: retorno 77 para `/tmp`;
- ferramentas descobertas: filesystem 14, Git 12, Sequential Thinking 1,
  NixOS Docs 2;
- versões Nix resolvidas: servidores MCP `2026.1.26` e `mcp-nixos 2.4.3`.

## Pendências

- ativação/build do host Inspiron;
- prova runtime do Brain MCP no Glacier;
- limite obrigatório/paginação de outputs MCP;
- decisão separada de RBAC para conectores remotos.

## Próximo passo recomendado

Revisar o diff isolado, fazer build do host cliente com as opções opt-in e só
então ativar a geração.

## Links relacionados

- [[02-Areas/Kryonix/systems/MCP]]
- [[02-Areas/Kryonix/ai-brain/Hermes]]
- [[01-MOCs/Mapa - Kryonix]]
