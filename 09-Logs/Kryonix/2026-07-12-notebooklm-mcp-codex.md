# Instalação isolada do NotebookLM MCP no Codex

Data: 2026-07-12
Agente: Codex
Repos afetados:

- `kryonix-vault` (somente este registro)
- Nenhum repositório de código do Kryonix foi alterado

## Objetivo

Instalar o MCP comunitário `antigravity-notebooklm-mcp` fora do workspace,
adaptá-lo ao NixOS e registrá-lo no Codex com exposição inicial restrita.

## Contexto consultado

- [[VAULT_INDEX]]
- [[01-MOCs/Mapa - IA e Agentes]]
- [[02-Areas/Kryonix/systems/MCP]]
- [[02-Areas/Kryonix/ai-brain/MCP]]
- documentação oficial do Codex para MCP e `config.toml`
- código upstream no commit `2c122a72163ee94f98f4b9da2fb1dfd5e905da6f`

## Mudanças realizadas

- Backup de `~/.codex/config.toml` criado antes da edição.
- Node.js 22 fixado por GC root em `~/.local/share/kryonix/nodejs`.
- Upstream clonado em `~/.local/share/kryonix/notebooklm-mcp`.
- Chromium/Chrome configurável por `NOTEBOOKLM_CHROME_PATH` ou
  `PUPPETEER_EXECUTABLE_PATH`.
- Remote debugging limitado a `127.0.0.1`.
- Diretório e arquivo de autenticação endurecidos para `0700` e `0600`.
- Extração de cookies atualizada de `Network.getAllCookies` para
  `Storage.getCookies`, compatível com o Chrome atual.
- Superfície lateral de `resources` removida; o servidor principal declara
  somente tools para evitar contorno da allowlist.
- Dependências transitivas corrigidas com `npm audit fix`, sem `--force`.
- Launcher `~/.local/bin/notebooklm-mcp` criado com modo `0700` e `umask 077`.
- Launcher define `AUTH_PATH`, modo read-only, allowlists de tool/action e o
  único notebook autorizado, sem armazenar cookies na configuração do Codex.
- O servidor aplica as mesmas políticas no handler, antes de ler autenticação
  ou acessar a rede.
- A ferramenta `authenticate` e o import de `browserLogin` foram removidos do
  processo MCP principal; autenticação permanece uma CLI separada.
- Servidor registrado em `~/.codex/config.toml` com aprovação `prompt` e
  allowlist inicial `manage_notebook` + `query_notebook`.
- Confianças globais, amplas e temporárias removidas de `config.toml`; a
  confiança do workspace exato foi preservada.
- Geração de memória passou a excluir threads com contexto externo.

## Commits e branches

- Nenhum commit criado durante a instalação.
- O clone comunitário mantém alterações locais de hardening sobre `main`.

## Validações executadas

- `npm run build`: SUCCESS.
- `npm audit --omit=dev --audit-level=high`: SUCCESS, zero vulnerabilidades.
- Handshake STDIO e `tools/list` via SDK MCP: SUCCESS.
- Superfície final do launcher: SUCCESS, somente `query_notebook`.
- Matriz read-only: SUCCESS, 11 de 11 operações mutáveis recusadas antes de
  autenticação/rede.
- Allowlist de notebook: SUCCESS, ID incorreto recusado antes da rede.
- Scan de stdout do runtime: SUCCESS, nenhum `console.log/info/debug/warn`.
- `codex mcp list` e `codex mcp get notebooklm`: SUCCESS.
- Login Google/NotebookLM: SUCCESS após verificação manual da conta.
- Permissões de `~/.notebooklm-mcp` e `auth.json`: SUCCESS (`0700`/`0600`).
- Listagem somente leitura: BROKEN; o parser RPC retorna zero mesmo com o
  notebook `KRYONIX OS` aberto e confirmado na interface.
- Consulta real: BROKEN; o endpoint devolveu somente envelope `batchexecute`
  com erro 16, sem resposta textual nem citações.
- MCP de testes `kryonix-test`: UNKNOWN; não está disponível na sessão atual.

## Evidências

- O baseline upstream compilava, mas inicialmente tinha 16 vulnerabilidades
  auditadas, incluindo uma crítica, e falhava no handshake com o SDK corrigido.
- Após atualização do lockfile e correção da capability, o handshake concluiu.
- O hardening final removeu `resources` e `authenticate`, filtra tools na
  descoberta e repete a autorização no handler de cada chamada.
- O Codex expôs `manage_notebook` somente para a listagem inicial e depois teve
  a allowlist reduzida para apenas `query_notebook`.
- Nenhum conteúdo de `auth.json` foi lido, impresso ou registrado.

## Pendências

- Corrigir os RPCs `listNotebooks()`/`getNotebook()`: a interface confirma o
  notebook `KRYONIX OS`, mas ambos os parsers retornam vazio/nulo.
- Reimplementar `query()`: o código atual ignora `notebookId`, usa lista de
  fontes vazia e retorna o stream bruto sem parser de resposta.
- Revalidar consulta e citações com fontes reais antes de classificar o MCP
  como funcional.
- Reiniciar o cliente Codex para recarregar a configuração global.

## Próximo passo recomendado

Manter o MCP limitado a `query_notebook`, mas classificar a consulta como
BROKEN até substituir ou portar uma implementação de query que obtenha source
IDs, trate o stream e retorne resposta com citações. Tratar futuras atualizações
upstream como reaplicação auditada dos patches locais, não como `git pull` cego.

#kryonix #codex #mcp #notebooklm #security

## Migração para `jacob-bd/notebooklm-mcp-cli`

### Decisão

O runtime TypeScript `jackc1111` foi preservado como experimento auditado e
desabilitado no Codex. A execução ativa passou para o reference Python
`jacob-bd/notebooklm-mcp-cli`, commit upstream
`e98cab174f8452c130da28898844f823d002b0a9`.

### Isolamento e segurança

- Novo clone em `~/.local/share/kryonix/notebooklm-mcp-ref`.
- Novo launcher em `~/.local/bin/notebooklm-mcp-ref`, modo `0700`.
- Profile `kryonix` criado em `~/.notebooklm-mcp-cli`, sem ler ou imprimir
  arquivos de credenciais.
- Diretórios do storage/profile endurecidos para `0700`; `cookies.json` em
  `0600`.
- O upstream tenta migrar automaticamente `~/.notebooklm-mcp`. Foi adicionado
  o gate local `NOTEBOOKLM_DISABLE_AUTO_MIGRATION=1` em ambos os entrypoints de
  migração e no launcher.
- Uma cópia automática criada antes da descoberta do segundo entrypoint foi
  interrompida e movida reversivelmente para
  `~/.notebooklm-mcp-cli.migrated-quarantine.20260712-162044`.
- O lockfile upstream tinha 25 vulnerabilidades conhecidas em sete pacotes. O
  `uv.lock` local foi atualizado somente para as versões corrigidas; a auditoria
  posterior retornou zero vulnerabilidades.

### Configuração final do Codex

- `notebooklm`: desabilitado e preservado para rollback.
- `notebooklm_ref`: habilitado, `required = false`, aprovação `prompt` e
  `enabled_tools = ["notebook_query"]`.
- Transporte ativo: HTTP normal dentro do cliente de referência.
- Fallback CDP: não habilitado, pois a consulta HTTP funcionou.

### Validações

- `uv sync --frozen`: SUCCESS.
- `uv run ruff check src tests`: SUCCESS.
- `uv run pytest -q -m 'not e2e'`: 1091 passed, 37 skipped, 1 deselected.
- `uvx pip-audit --path .venv/lib/python3.11/site-packages`: zero
  vulnerabilidades após atualização do lockfile.
- `uv run mypy src`: BROKEN no baseline upstream, 235 erros em 46 arquivos.
- Suite sem filtro: PARTIAL; os mesmos 1091 testes passaram, mas um E2E tentou
  migrar o profile legado e falhou em sockets Chrome `Singleton*`.
- `nlm login --check --profile kryonix`: SUCCESS, autenticação válida e um
  notebook encontrado.
- `nlm notebook list --profile kryonix --title`: SUCCESS, `KRYONIX OS` listado.
- Consulta CLI HTTP: SUCCESS, answer textual, quatro fontes, 21 citações e
  referências.
- Handshake MCP STDIO: SUCCESS. O upstream anunciava 39 tools; o launcher agora
  desabilita 38 com `NOTEBOOKLM_DISABLED_TOOLS`, e tanto o processo MCP bruto
  quanto o Codex expõem somente `notebook_query`.
- Consulta MCP: SUCCESS, answer textual, duas fontes, oito citações, oito
  referências e `conversation_id`.

### Pendências após migração

- Reiniciar Codex Desktop/CLI/extensão para carregar `notebooklm_ref` na sessão.
- Manter o gate de auto-migração em futuras atualizações ou propor a opção ao
  upstream.
- Reaplicar/revalidar o lockfile local ao atualizar o commit upstream.
- Revisar e remover a quarentena somente após confirmação humana; ela contém a
  cópia interrompida do profile legado e não deve ser versionada.
- Tratar os 235 erros de tipagem como dívida upstream; eles não foram corrigidos
  nesta migração.

### Rollback da migração

Desabilitar `notebooklm_ref`, reabilitar temporariamente `notebooklm` somente
para diagnóstico e restaurar o backup
`~/.codex/backups/config.toml.notebooklm-ref.20260712-161524`. Não apagar os
storages de autenticação durante o rollback.
