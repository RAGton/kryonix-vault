---
title: Plano - Segundo Cérebro IA do Kryonix
type: plano
status: active
project: Kryonix
area: ai-brain
tags: [plano, vault, segundo-cerebro, multiagente, rag, moc]
created: 2026-06-16
updated: 2026-06-16
links:
  - "[[AGENTS]]"
  - "[[VAULT_INDEX]]"
  - "[[PROMPT_MASTER]]"
  - "[[CLAUDE.md]]"
  - "[[02-Areas/Kryonix/ai-brain/MOC - AI Brain]]"
  - "[[01-MOCs/Mapa - Kryonix]]"
---

# Plano — Segundo Cérebro IA do Kryonix

## Fato

### Layout real do vault (verificado 2026-06-16)

```txt
kryonix-vault/                branch: main
├── 00-Inbox/
├── 01-MOCs/                  15 MOCs ativos
├── 02-Areas/                 8 áreas (Backend, Dados, DevOps, Eng, IA, Kryonix, Linux, Segurança)
├── 03-Projetos/              projetos ativos (Kryonix System, Installer, VE, RAGOS…)
├── 04-Archive/               legados e lixo de inbox
├── 04-Recursos/              assets reutilizáveis
│   ├── templates/            9 templates (kebab-case)
│   ├── skills/               21 Skills
│   ├── playbooks/            13 playbooks + runbooks/
│   └── prompts/              13 prompts
├── 08-Referencias/
└── 09-Logs/
    ├── sessions/             logs por sessão
    └── evidence/             artefatos de validação
```

### Agentes-alvo

| Agente       | Tipo           | Entry point no vault            |
|-------------|---------------|----------------------------------|
| Claude Code  | CLI assistant  | `CLAUDE.md`                      |
| Antigravity  | Orquestrador   | `PROMPT_MASTER.md`, `AGENTS.md`  |
| Codex        | Executor tasks | `AGENTS.md`, playbooks Codex     |
| Aura         | agente operacional principal atual | `02-Areas/Kryonix/ai-brain/Aura.md` |
| Hermes       | referência histórica / compatibilidade quando aplicável | `02-Areas/Kryonix/ai-brain/Hermes.md` |

### Docs-âncora existentes

- `AGENTS.md` — contrato operacional (regras, folder ownership, padrões)
- `CLAUDE.md` — entry point Claude Code (criado 2026-06-16)
- `VAULT_INDEX.md` — home do cérebro, navegação
- `PROMPT_MASTER.md` — system prompt canônico
- `04-Recursos/templates/README.md` — convenções YAML + XML Claude + TOON
- `04-Recursos/prompts/PROMPT_AGENT_KRYONIX_VAULT.md` — prompt de edição

---

## Boa prática

- **Session logs**: cada sessão de agente registra em `09-Logs/sessions/YYYY-MM-DD/`
  com frontmatter `type: session`, `agent:`, `status: open/closed`
- **PROJECT_SUMMARY curto**: sumário ≤ 20 linhas por projeto ativo; reduz custo de contexto
- **ADR para decisões**: toda decisão técnica relevante vira ADR em `03-Projetos/<proj>/`
  ou `02-Areas/<área>/`; modelo: `template-adr.md`
- **Playbooks para operações**: procedimento repetível → playbook em `04-Recursos/playbooks/`
- **Skills para workflows repetidos**: workflow de IA repetido → SKILL.md em
  `04-Recursos/skills/<nome>/SKILL.md`
- **TOON para listas grandes**: arrays JSON no prompt → TOON para reduzir tokens
- **Menor mudança correta**: commit atômico, nunca `git add .`, nunca push sem revisão

---

## Opinião

- Manter poucos arquivos canônicos na raiz (AGENTS, CLAUDE, VAULT_INDEX, PROMPT_MASTER, README)
- Evitar templates duplicados — um template por tipo de nota
- Usar PROMPT_MASTER como única fonte de system prompt; prompts derivados herdam dele
- Sessions em `09-Logs/sessions/` são mais valiosas que notas ad-hoc no inbox
- MOCs em `01-MOCs/` devem ser sempre ponto de entrada, nunca destino final

---

## Hipótese

- Logs de sessão estruturados + MOCs atualizados melhoram a continuidade dos agentes
  entre sessões desconexas (reduz tempo de orientação de ~5 min para ~30s)
- Specs curtas (PROJECT_SUMMARY ≤ 20 linhas) reduzem custo de contexto em 30-60%
  comparado a carregar notas extensas no prompt
- Um vault bem conectado com wikilinks reais permite RAG por grafo (LightRAG/Neo4j)
  mais preciso que busca puramente vetorial

---

## Risco

| Risco                          | Impacto | Mitigação                                      |
|-------------------------------|---------|------------------------------------------------|
| Caminhos quebrados             | Alto    | `just check-links` antes de commit             |
| Duplicação de notas            | Médio   | buscar antes de criar; regra "2 vezes → nota"  |
| Secrets em logs/repo           | Crítico | revisão humana obrigatória antes de push        |
| Agente alterando repo errado   | Alto    | verificar `pwd` + `git remote -v` no início    |
| Logs gigantes sem curadoria    | Médio   | arquivar sessões > 30 dias em `04-Archive/`    |
| Layout antigo em novos arquivos| Médio   | AGENTS.md e CLAUDE.md têm lista negra explícita|

---

## O que armazenar no vault

| Tipo              | Onde                                          |
|------------------|-----------------------------------------------|
| Specs técnicas   | `02-Areas/<área>/` ou `03-Projetos/<proj>/`   |
| ADRs             | `03-Projetos/<proj>/ADR-*.md` ou junto à área |
| Runbooks         | `04-Recursos/playbooks/runbooks/`             |
| Skills           | `04-Recursos/skills/<nome>/SKILL.md`          |
| Prompts          | `04-Recursos/prompts/`                        |
| Session logs     | `09-Logs/sessions/YYYY-MM-DD/`               |
| PR summaries     | `09-Logs/evidence/` ou `03-Projetos/<proj>/`  |
| Troubleshooting  | `02-Areas/<área>/` ou `03-Projetos/<proj>/`   |
| Decisões         | ADR ou `02-Areas/Kryonix/kryonix-meta/DECISIONS.md` |
| Mapas MOC        | `01-MOCs/Mapa - <Área>.md`                   |

---

## Validação

Comandos a rodar antes de qualquer commit:

```bash
# Verificar layout antigo ainda referenciado
grep -RIn \
  -e '01-Projects' -e '03-Resources' -e '10-MOCs' -e '99-Logs' \
  -e '05-Skills' -e '06-Playbooks' -e '07-Prompts' \
  -- AGENTS.md CLAUDE.md VAULT_INDEX.md PROMPT_MASTER.md README.md || true

# Verificar whitespace issues
git diff --check

# Status limpo
git status --short

# Links quebrados (quando justfile disponível)
# just check-links
```

---

## Próximos passos

- [x] Corrigir docs-âncora (folder ownership em AGENTS.md)
- [x] Criar `CLAUDE.md` para Claude Code
- [ ] Criar `PROJECT_SUMMARY.md` para o projeto Kryonix System (≤ 20 linhas)
- [ ] Criar sessão diária em `09-Logs/sessions/YYYY-MM-DD/` antes de cada work session
- [ ] Verificar se `01-MOCs/Mapa - Kryonix.md` precisa de atualização
- [ ] Adicionar link deste plano no `MOC - AI Brain.md`
- [ ] Avaliar criação de `PROMPT_SUPREMO_DEEP_RESEARCH.md` para pesquisa autônoma
- [ ] Revisão humana + push

---

## Links relacionados

- [[AGENTS]]
- [[CLAUDE.md]]
- [[VAULT_INDEX]]
- [[PROMPT_MASTER]]
- [[02-Areas/Kryonix/ai-brain/MOC - AI Brain]]
- [[02-Areas/Kryonix/ai-brain/RAG CAG GraphRAG]]
- [[02-Areas/Kryonix/ai-brain/Aura]]
- [[01-MOCs/Mapa - Kryonix]]
- [[04-Recursos/templates/README]]
