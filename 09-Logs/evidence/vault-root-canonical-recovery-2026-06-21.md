---
status: ativo
validade: revisao_humana_pendente
tipo: incidente
projeto: kryonix
componente: vault-root
fonte_verdade: observacao
confianca: media
rag: baixo_peso
graph: true
validado_em: 2026-06-21
author: aura
tags: [kryonix, incidente, vault, recovery]
---

# Incidente — arquivos canônicos da raiz enviados para lixeira

## Arquivos afetados

- `AGENTS.md`
- `CLAUDE.md`
- `PROMPT_MASTER.md`
- `README.md`
- `VAULT_INDEX.md`

## Cronologia

- 2026-06-20 (final da sessão): vault com raiz limpa (Fase A), 22 T-templates movidos, commits C0 e C1 aplicados.
- 2026-06-21 13:42 (início desta sessão): os 5 arquivos canônicos da raiz foram encontrados ausentes do vault e presentes na lixeira do sistema (`~/.local/share/Trash/files/`).
- Arquivos como `_duplicatas_2026-06-15/`, `_planos_abandonados_2026-06-18/`, `_meta/`, `_lixo_raiz_2026-06-15/` também foram encontrados na lixeira (decisão do usuário: não restaurar, são lixo operacional validado por SHA256).

## Diagnóstico

Os arquivos canônicos foram enviados para a lixeira (`~/.local/share/Trash/files/`) por algum processo externo ao Hermes. `mv` via shell não manda para a lixeira do sistema operacional — portanto algum outro mecanismo moveu os arquivos:

- Hipótese 1: Obsidian (reorganização automática, plugin de limpeza, ou ação manual via Obsidian).
- Hipótese 2: Outro agente IA (`.gemini/antigravity/` encontrado em worktrees de Kryonix).
- Hipótese 3: Script do sistema (manutenção periódica).

**Causa raiz não identificada.** Não há evidência conclusiva de qual processo fez o move.

## Análise das versões (lixeira vs Git HEAD)

| Arquivo | Lixeira (bytes) | Git HEAD (bytes) | mtime lixeira | Versão escolhida |
|---|---|---|---|---|
| AGENTS.md | 7.612 | 9.655 | 2026-05-07 | Git HEAD |
| CLAUDE.md | (não existe) | 4.135 | — | Git HEAD |
| PROMPT_MASTER.md | 6.323 | 4.315 | 2026-05-07 | Git HEAD |
| README.md | 1.069 | 2.040 | 2026-05-07 | Git HEAD |
| VAULT_INDEX.md | 2.316 | 4.322 | 2026-05-07 | Git HEAD |

### Por que Git HEAD (e não a lixeira)

As versões da lixeira são **cópia antiga** do vault (todas com mtime `2026-05-07 07:24`), anterior à migração canônica de 2026-06-14. Evidências:

- `AGENTS.md` da lixeira não tem a seção `## Kryonix multi-repository documentation policy` (adicionada em 2026-06).
- `PROMPT_MASTER.md` da lixeira não tem frontmatter YAML, não tem estrutura de XML tags TOON moderna.
- `README.md` da lixeira é um placeholder, sem seção "Entrada" nem links para `AGENTS`.
- `VAULT_INDEX.md` da lixeira contém links quebrados para `07-Prompts/PROMPT_IA_CONSUMIR_OBSIDIAN` e `07-Prompts/PROMPT_SUPREMO_DEEP_RESEARCH` (caminhos antigos, pasta `07-Prompts` não existe mais).
- `CLAUDE.md` não existe na lixeira — apenas no Git HEAD.

Restaurar da lixeira seria **regredir** o vault para versão de 45 dias atrás com links quebrados.

## Ação executada

1. Criado diretório de trabalho em `/tmp/vault-root-canonical-recovery-2026-06-21-134227/` com subdirs `trash/` e `git-head/`.
2. Copiadas versões da lixeira para `trash/` (4 arquivos; CLAUDE.md não estava lá).
3. Extraídas versões do Git HEAD para `git-head/` (todos os 5 via `git show HEAD:<file>`).
4. Comparados checksums SHA256 e diffs por arquivo.
5. Restaurados os 5 arquivos **do Git HEAD** via `cp -a` (não `mv` — preserva backup na lixeira).

## Resultado

Todos os 5 arquivos canônicos restaurados no vault, a partir do Git HEAD (versão moderna e consistente com o layout atual do vault).

## Riscos

- **Causa raiz desconhecida**: o processo que moveu os arquivos para a lixeira pode atuar novamente. Recomendado:
  - Monitorar se `AGENTS.md` / `CLAUDE.md` / `PROMPT_MASTER.md` / `README.md` / `VAULT_INDEX.md` voltam a sumir.
  - Verificar se há automatismos do Obsidian ou de outros agentes mexendo na raiz do vault.
  - Considerar adicionar `.obsidian/trash/` ou configuração para desabilitar auto-limpeza.
- **Backup na lixeira pode expirar**: arquivos em `~/.local/share/Trash/files/` podem ser removidos pela política do sistema operacional após N dias. Se precisar consultar a versão antiga, copiar para outro local antes que expire.

## Próximas ações

1. ✅ Validar `git status` está coerente com a restauração (os 5 devem aparecer como "novos adicionados" em staged, ou "modified" dependendo de como ficam após cp).
2. ⏸️ **Pausar commits** até essa situação estar 100% estável.
3. 🔍 Investigar causa raiz (Obsidian? Outros agentes? Cron do sistema?).
4. 📝 Continuar commits C2/C3/C4/C5 somente depois.

## Confirmações

- ✅ Nenhuma ação destrutiva executada.
- ✅ Nenhum `rm` usado.
- ✅ Nenhum arquivo removido.
- ✅ Restauração via `cp -a` (não `mv`) — preserva backup na lixeira.
- ✅ Nenhum push feito.
- ✅ Nenhum commit feito nesta sessão ainda (após descobrir o incidente).
