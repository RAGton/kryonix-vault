---
title: Mapa - Obsidian Skills (kepano)
type: moc
status: active
tags: [obsidian, skills, kepano, hermes, mapa]
source: https://github.com/kepano/obsidian-skills
---

# Mapa - Obsidian Skills (kepano)

## Objetivo

Centralizar o uso das 5 skills oficiais do [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) instaladas no Hermes para o kryonix-vault. Toda vez que o Gabriel pedir trabalho com vault, base, canvas, CLI do Obsidian ou extração de página web, a Aura deve carregar a skill correspondente antes de agir.

## Resumo

Mapa de despacho entre intenção do usuário e skill kepano. Reduz custo de token carregando skill certa sob demanda e padroniza uso de `.md`, `.base`, `.canvas`, CLI e extração web.

## Skills instaladas (namespace kepano-*)

```toon
skill,                       quando_carregar,                                                                  fonte
kepano-obsidian-markdown,    criar/editar .md com wikilinks, callouts, embeds, properties, frontmatter, tags,  github.com/kepano/obsidian-skills
kepano-obsidian-bases,       criar/editar .base (Bases do Obsidian) com views, filters, formulas, summaries,     github.com/kepano/obsidian-skills
kepano-json-canvas,          criar/editar .canvas (JSON Canvas 1.0) com nodes, edges, groups,                     github.com/kepano/obsidian-skills
kepano-obsidian-cli,         interagir com vault via obsidian CLI (criar nota, daily, property, tasks, dev:errors), github.com/kepano/obsidian-skills
kepano-defuddle,             extrair markdown limpo de URL (economiza tokens vs WebFetch),                       github.com/kepano/obsidian-skills
```

## Onde elas vivem

- Path local: `~/.hermes/skills/note-taking/kepano-*/SKILL.md`
- Vault alvo: `/home/rocha/kryonix/kryonix-vault` (env `OBSIDIAN_VAULT_PATH`)
- Skill antiga `obsidian` (filesystem-first) continua instalada — use essa quando o Obsidian CLI não estiver rodando ou para leituras simples via file tools.

## Regra de uso (sempre)

1. **Detectar** palavras-chave: `wikilink`, `callout`, `frontmatter`, `embed`, `tag`, `properties`, `obsidian`, `vault`, `nota`, `.base`, `bases`, `canvas`, `.canvas`, `defuddle`, `obsidian CLI`, `daily`.
2. **Carregar** a skill via `skill_view(name='kepano-...')` antes de criar ou editar o arquivo.
3. **Seguir** as regras do `kryonix-vault/AGENTS.md`:
   - PT-BR nos nomes das notas (exceto termos técnicos consagrados em inglês).
   - Sempre linkar para pelo menos um MOC.
   - Preferir atualizar nota existente em vez de criar duplicata.
   - Usar os templates do AGENTS.md (Objetivo / Resumo / Procedimento / Checklist / Riscos / Links).
4. **Validar** depois de criar/editar: rodar `python3 scripts/check_obsidian_links.py` ou o linter de YAML para `.base`, e o `validate-json` para `.canvas`.
5. **Citar a skill** na resposta: "usei `kepano-obsidian-markdown` para...".

## Alvos comuns no vault

- Wikilinks + callouts → `02-Areas/*/*.md`, `03-Projetos/*.md`, `09-Logs/*.md`
- Bases (.base) → `03-Projetos/<projeto>/_bases/`, `09-Logs/_bases/`
- Canvas → `02-Areas/<area>/_canvases/`, `03-Projetos/<projeto>/_canvases/`
- Daily notes → raiz do vault ou `09-Logs/daily/`
- Tags principais → `#kryonix`, `#ia-agentes`, `#nixos`, `#backend`, `#devops`, `#seguranca`

## Playbooks relacionados

- [[04-Recursos/playbooks/Playbook - Usar Obsidian Skills kepano]]

## Links relacionados

- [[01-MOCs/Mapa - IA e Agentes]]
- [[01-MOCs/Mapa - Engenharia de Software]]
- [[AGENTS]]
- [[VAULT_INDEX]]

## Próxima ação

Adicionar este MOC ao [[VAULT_INDEX]] quando der update no índice.
