---
source: docs/brain/vault.md
status: derived
canonical: false
last_sync: 2026-06-19
operation_mode: inspiron-local-hermes-openrouter
---

# Vault (Obsidian)

> [!IMPORTANT]
> Esta nota é derivada de `docs/`. Em caso de divergência, `docs/` vence.

O cérebro técnico e central do projeto opera num diretório formatado como Vault do Obsidian.

- **Status:** **PRODUCTION** (Base de conhecimento ativa)
- **Local real:** `/home/rocha/kryonix/kryonix-vault`
- **Path antigo (desalinhado/vazio):** `/home/rocha/.local/share/kryonix/kryonix-vault`
  > Esse path está vazio ou não é o Vault operacional atual. Era o destino planejado do LightRAG/Brain quando Glacier
  > era runtime ativo. Será reativado apenas após reinstalação limpa do Glacier via ISO oficial.

O Vault pode ser modificado com a variável ambiental `LIGHTRAG_VAULT_DIR`.

> [!IMPORTANT]
> ## Modo Operacional Atual (2026-06-19)
>
> Decisão humana: **Glacier está congelado para runtime/serviços por enquanto.**
>
> **Runtime ativo agora:**
> - Inspiron como máquina operacional
> - Hermes local como agente principal
> - OpenRouter como provider/modelos externos
> - Vault local real: `/home/rocha/kryonix/kryonix-vault`
> - Código fonte operacional:
>   - `/home/rocha/kryonix/kryonix` para desenvolvimento ativo
>   - `/etc/kryonix` como checkout operacional em sistema instalado
>
> **Fora de escopo temporário (NÃO validar/corrigir/depender):**
> - `glacier` (host) e qualquer serviço rodando lá
> - `ollama.service`, `neo4j.service`, `kryonix-lightrag`, `kryonix-brain-api.service` no Glacier
> - LightRAG remoto, MCP remoto via Glacier
> - `/var/lib/kryonix` no Glacier
> - Storage compartilhado Inspiron↔Glacier
>
> > Qualquer validação envolvendo Glacier deve ser registrada como `SKIPPED_BY_OPERATION_MODE`, não como PASS nem FAIL.
>
> **Roadmap:**
> ```
> P0 - Finalizar installer
> P1 - Gerar ISO oficial Kryonix
> P2 - Preparar perfil first-install do Glacier
> P3 - Reinstalar Glacier com ISO Kryonix
> P4 - Só então ativar Brain/Ollama/LightRAG/Neo4j no Glacier
> ```
>
> **Política RAG**: aplica-se apenas ao Vault local real. LightRAG/Brain remoto não é prioridade enquanto Glacier estiver congelado.
>
> Ver nota canônica: [[02-Areas/Kryonix/canonical/CURRENT_OPERATION_MODE]]
>
## Regras de Acesso e Operação (Obsidian CLI Brain Enforcement)

O sistema conta com regras estritas para agentes não modificarem de forma caótica as anotações centrais do usuário:

1. **Acesso com CLI**: Todo agente interagindo com o Vault deve utilizar a `kryonix vault ...` ou `kryonix brain ...` como porta de acesso e operação principal.
2. **Saúde Inicial**: Executar `kryonix brain health` e `kryonix vault scan` é o pré-requisito antes de depender do retorno do Vault.
3. **Escrita Bloqueada**: Não modificar arquivos Markdown no Vault diretamente (`sed`, `echo` ou edição file-system padrão) a não ser que o usuário autorize ativamente.
4. Caso necessite atualizar de forma profunda o Vault ou se os mecanismos de update seguros estiverem offline, crie uma proposta de update em `docs/archive/VAULT_UPDATE_PROPOSAL.md`.

## Interação Segura com o Grafo

Ao interagir com o Brain, a ordem de prioridade de fontes é:
1. Código atual do projeto
2. Documentação atual do projeto
3. Diretório `docs/agents/`
4. O Obsidian Vault acessado de modo restrito via CLI
5. A documentação oficial do produto upstream (NixOS, Hyprland, etc)


## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]