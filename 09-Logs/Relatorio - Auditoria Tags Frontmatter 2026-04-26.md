---
title: "Relatorio - Auditoria Tags Frontmatter 2026-04-26"
type: audit
status: stable
area: obsidian
project: global
tags:
  - type/audit
  - status/stable
  - area/obsidian
  - ai/context
created: 2026-04-26
updated: 2026-04-26
source: internal
confidence: high
reviewed: false
---

# Relatorio - Auditoria Tags Frontmatter 2026-04-26

## Relatorio inicial de tags

## Total de notas

- 120 notas Markdown auditadas inicialmente.
- Obsidian CLI não estava disponível no PATH (`obsidian`, `obs`, `obsidian-cli` ausentes).
- `rg` falhou com acesso negado neste ambiente; a auditoria complementar usou PowerShell e Python empacotado do Codex.

## Total de tags

- 6 tags únicas antes da padronização.
- Apenas 2 notas tinham frontmatter/tags no início da auditoria.

## Tags mais usadas

- `status/active`: 2
- `area/obsidian`: 2
- `ai/agents`: 2
- `ai/prompts`: 2
- `type/playbook`: 1
- `type/prompt`: 1

## Tags duplicadas/suspeitas

- Nenhuma duplicação por casing detectada.
- Nenhuma tag inválida detectada entre as tags existentes.
- Tags inline encontradas em alguns arquivos antigos como texto/template, não normalizadas nesta rodada.

## Notas sem frontmatter

- 118 notas sem frontmatter.

## Notas sem tags

- 118 notas sem tags.

## Notas órfãs

- Não houve correção automática de órfãs nesta rodada.
- Priorização: frontmatter, tags e links quebrados.

## Links quebrados

- 36 ocorrências detectadas inicialmente.
- A maior parte apontava para notas planejadas nos índices/MOCs.
- Alguns exemplos eram placeholders dentro de prompts.

## Pastas com padrão ruim

- Estrutura principal estava coerente com o padrão do vault.
- Havia links para áreas ainda não criadas: frontend moderno, Proxmox/homelab, debug/testes, NixOS e infra declarativa.

## Recomendações iniciais

- Aplicar frontmatter mínimo por pasta.
- Criar stubs mínimos somente para links intencionais.
- Evitar reescrita técnica.
- Manter placeholders de prompt fora do formato wikilink quando não forem notas reais.

## Plano de padronização aplicado

- Arquivos raiz receberam tipos previsíveis: `index`, `resource`, `prompt` ou `playbook`.
- MOCs receberam `type: moc`, `status: active` e `area` quando inferível.
- Notas de `02-Areas/` receberam `type: area` e tag `area/<area>`.
- Projetos receberam `type: project` e `project/<project>`.
- Templates receberam `type: template`.
- Skills receberam `type: skill`, `ai/skills` e `area/ia`.
- Playbooks receberam `type: playbook`.
- Prompts receberam `type: prompt`, `ai/prompts` e `area/ia`.
- Referências receberam `type: reference`, `source: internal`, `confidence: medium` e `reviewed: false`.
- Logs receberam `type: log`.

## Relatorio final

## Arquivos alterados

- 118 notas existentes receberam frontmatter mínimo.
- 16 notas novas foram criadas como stubs para resolver wikilinks intencionais.
- 1 prompt foi ajustado para não criar wikilink falso com placeholder.
- 1 relatório de auditoria foi criado.

## Tags criadas

- 50 tags únicas após a padronização.
- Principais famílias: `type/*`, `status/*`, `area/*`, `project/*`, `ai/*`, `eng/*`, `linux/*`, `nixos/*`, `infra/*`, `source/*`.

## Tags removidas

- Nenhuma tag existente foi removida.

## Tags normalizadas

- Todas as notas Markdown passaram a ter tags em frontmatter.
- Nenhuma tag com espaço, uppercase, acento ou `#` foi detectada na auditoria final.
- Nenhuma duplicação por casing foi detectada.

## Links corrigidos

- `scripts/check_obsidian_links.py` passou com sucesso após a correção.
- Resultado: `OK: checked 136 markdown files` antes da criação deste relatório.

## Notas ainda pendentes

- Completar o conteúdo técnico dos stubs criados conforme necessidade prática.
- Revisar tags inline antigas usadas como exemplo/template.
- Instalar ou documentar um wrapper real do Obsidian CLI se o fluxo depender dele.
- Decidir se `.obsidian/` deve ser versionado neste vault.

## Recomendações futuras

- Rodar este playbook antes de importações grandes: [[06-Playbooks/Organizar Tags e Frontmatter do Vault]].
- Usar o prompt operacional quando delegar a manutenção a outro agente: [[07-Prompts/PROMPT_ORGANIZAR_TAGS_OBSIDIAN]].
- Evitar criar wikilinks para páginas conceituais sem criar a nota-alvo.
- Manter cada nota com poucas tags, usando frontmatter para estrutura e MOCs para navegação.

## Links relacionados

- [[VAULT_INDEX]]
- [[01-MOCs/Mapa - IA e Agentes]]
- [[06-Playbooks/Organizar Tags e Frontmatter do Vault]]
- [[07-Prompts/PROMPT_ORGANIZAR_TAGS_OBSIDIAN]]
