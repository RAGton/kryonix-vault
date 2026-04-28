---
title: "Organizar Tags e Frontmatter do Vault"
type: playbook
status: active
area: obsidian
project: global
tags:
  - type/playbook
  - status/active
  - area/obsidian
  - ai/agents
  - ai/prompts
created: 2026-04-26
updated: 2026-04-26
source: internal
confidence: high
reviewed: false
---

# Organizar Tags e Frontmatter do Vault

## Objetivo

Executar uma manutenção segura de tags, frontmatter, links internos e estrutura do Kryonix Vault.

## Quando usar

- Antes de uma revisão ampla de organização do vault.
- Depois de importar muitas notas novas.
- Quando tags começam a aparecer duplicadas, genéricas ou sem padrão.
- Quando agentes de IA precisam consumir o vault com menor custo de contexto.

## Entrada esperada

- Caminho do vault.
- Escopo da manutenção: auditoria, correção segura ou reorganização proposta.
- Prompt operacional em [[07-Prompts/PROMPT_ORGANIZAR_TAGS_OBSIDIAN]].

## Saída esperada

- Relatório inicial.
- Plano de padronização.
- Alterações pequenas e rastreáveis.
- Relatório final.
- Pendências que exigem decisão humana.

## Procedimento

1. Ler [[VAULT_INDEX]], [[AGENTS]] e [[01-MOCs/Mapa - IA e Agentes]].
2. Detectar CLI disponível: `obsidian`, `obs`, `obsidian-cli` ou wrapper local documentado.
3. Se o Obsidian CLI estiver disponível, listar tags, contagens e tags por arquivo.
4. Complementar a inspeção com busca local por arquivos Markdown, frontmatter, tags inline e wikilinks.
5. Gerar relatório inicial antes de editar.
6. Propor mudanças de taxonomia, frontmatter e links.
7. Aplicar somente correções seguras em lotes pequenos.
8. Validar links com `scripts/check_obsidian_links.py`.
9. Gerar relatório final.
10. Registrar pendências em [[09-Logs/Backlog de Estudos]] quando a correção exigir interpretação humana.

## Checklist

- [ ] Obsidian CLI detectado ou ausência registrada.
- [ ] Tags existentes revisadas.
- [ ] Notas sem frontmatter identificadas.
- [ ] Notas sem tags identificadas.
- [ ] Tags genéricas ou inconsistentes listadas.
- [ ] Links quebrados verificados.
- [ ] MOCs principais preservados.
- [ ] Conteúdo técnico não foi reescrito sem necessidade.
- [ ] Wikilinks preservados.
- [ ] Nenhum segredo foi adicionado.
- [ ] Relatório final produzido.

## Riscos

- Renomear arquivos sem atualizar wikilinks quebra navegação.
- Padronização agressiva pode apagar intenção semântica de uma nota.
- Tags demais aumentam ruído e custo de contexto.
- Inferir área/projeto sem evidência cria falsa organização.
- CLI ausente exige registrar limitação e usar validação complementar.

## Validação

```bash
python scripts/check_obsidian_links.py
```

Se o Obsidian CLI estiver disponível:

```bash
<obsidian-cli> tags counts format=json
<obsidian-cli> tags total
```

## Links relacionados

- [[07-Prompts/PROMPT_ORGANIZAR_TAGS_OBSIDIAN]]
- [[07-Prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]]
- [[01-MOCs/Mapa - IA e Agentes]]
- [[08-Referencias/Fontes Oficiais]]

## Próxima ação

Rodar uma auditoria pequena em uma pasta antes de aplicar normalização no vault inteiro.
