---
title: Playbook - Usar Obsidian Skills kepano
tags:
  - playbook
  - obsidian
  - ia-agentes
  - kepano
aliases:
  - Usar kepano skills
---

# Playbook - Usar Obsidian Skills kepano

## Objetivo

Padronizar o uso das 5 skills oficiais do [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) instaladas no Hermes para trabalhar com o kryonix-vault, evitando retrabalho e mantendo consistência.

## Quando usar

Sempre que o Gabriel pedir qualquer uma das ações abaixo:

- Criar, editar ou auditar uma nota `.md` com sintaxe Obsidian (wikilink, callout, embed, property, tag, frontmatter).
- Criar, editar ou auditar uma base `.base` (filtros, views, formulas, summaries).
- Criar, editar ou auditar um canvas `.canvas` (nodes, edges, groups).
- Interagir com o Obsidian via CLI (`obsidian create`, `obsidian read`, `obsidian daily:append`, `obsidian property:set`, etc.).
- Extrair conteúdo limpo de uma página web para virar nota (economiza tokens).

## Quando NÃO usar

- Para leitura simples de nota única já existente → use `read_file` direto (mais barato).
- Para busca de texto dentro de nota → use `search_files` (mais barato).
- Para URL que já termina em `.md` → use `curl` direto, não precisa do defuddle.

## Inputs esperados

- Caminho ou nome da nota/base/canvas alvo (ou `obsidian` CLI command pronto).
- Conteúdo a ser inserido (ou pedido do Gabriel em linguagem natural).
- Contexto do vault (pasta, MOC relacionado, tags).

## Outputs esperados

- Arquivo criado/editado no kryonix-vault com sintaxe Obsidian válida.
- Wikilinks para MOCs relacionados.
- Resposta curta da Aura citando qual skill foi carregada.

## Procedimento

### Despacho gatilho → skill (TOON)

```toon
gatilho,                                          skill,                       alternativa_mais_barata
wikilink, callout, frontmatter, property, tag,    kepano-obsidian-markdown,    read_file + patch (nota unica)
.base, base, views, filters, formulas, summaries, kepano-obsidian-bases,       -
.canvas, canvas, nodes, edges, groups,            kepano-json-canvas,          -
obsidian CLI, daily, dev:errors, property:set,    kepano-obsidian-cli,         read_file direto
URL, webpage, extrair pagina, defuddle,           kepano-defuddle,             curl direto se URL termina em .md/.txt/.json
```

1. **Detectar gatilho**: palavras-chave acima. Use a tabela TOON para decidir skill em milissegundos.
2. **Carregar a skill certa** via `skill_view(name='kepano-<nome>')` ANTES de qualquer escrita.
3. **Verificar caminho**: `OBSIDIAN_VAULT_PATH=/home/rocha/kryonix/kryonix-vault`. Se for editar nota existente, ler primeiro com `read_file` (ou `obsidian read file="..."`).
4. **Seguir sintaxe da skill**: copy/paste dos exemplos do `SKILL.md` da skill carregada. Respeitar regras de YAML quoting (`.base`) e ID hex 16 chars (`.canvas`).
5. **Respeitar AGENTS.md do vault**:
   - PT-BR nos nomes de nota (salvo termos técnicos).
   - Pelo menos 1 wikilink para um MOC existente.
   - Template padrão: Objetivo / Resumo / Quando usar / Procedimento / Checklist / Riscos / Links / Próxima ação.
   - Sem duplicar nota já existente.
6. **Validar**:
   - `.md`: conferir render no Obsidian ou rodar `python3 scripts/check_obsidian_links.py`.
   - `.base`: validar YAML (sem colon não-quoted, quotes balanceadas em formulas).
   - `.canvas`: `python3 -c "import json; json.load(open('nota.canvas')); print('ok')"` e checar IDs únicos + referências de edge.
7. **Reportar**: responder em 2-3 linhas o que foi feito + qual skill usou.

## Checklist

- [ ] Skill correta carregada via `skill_view`
- [ ] `OBSIDIAN_VAULT_PATH` apontando para `/home/rocha/kryonix/kryonix-vault`
- [ ] Nota lida antes de editar (se já existe)
- [ ] Wikilink para MOC adicionado
- [ ] Tags em PT-BR
- [ ] Validação executada (link check / YAML / JSON)
- [ ] Resposta cita a skill usada

## Riscos

- **Path errado**: se `OBSIDIAN_VAULT_PATH` estiver vazio, a skill `obsidian` (filesystem-first) cai em `~/Documents/Obsidian Vault` — sempre confirmar com `echo $OBSIDIAN_VAULT_PATH` no início.
- **YAML mal quoted em `.base`**: formulas com aspas duplas dentro de string com aspas duplas quebram — usar single quote por fora.
- **IDs colidindo em `.canvas`**: sempre gerar hex 16-char novo e conferir contra nodes+edges existentes.
- **Criar nota em vez de atualizar**: a skill `obsidian-markdown` assume "creating", mas o AGENTS.md do vault prefere "update". Antes de `write_file`, fazer `read_file` e checar duplicata via `search_files pattern="<mesmo-nome>"`.
- **Token blow-up**: `kepano-defuddle` em página de 50MB ainda é grande — preferir `curl` direto se for só 1 parágrafo.

## Links relacionados

- [[01-MOCs/Mapa - Obsidian Skills (kepano)]]
- [[01-MOCs/Mapa - IA e Agentes]]
- [[02-Areas/IA e Agentes/Skills Reutilizaveis]]
- https://github.com/kepano/obsidian-skills

## Próxima ação

Quando Gabriel pedir a próxima vez "anota isso no vault" / "cria uma base" / "monta um canvas" / "extrai esse site", executar este playbook sem perguntar.
