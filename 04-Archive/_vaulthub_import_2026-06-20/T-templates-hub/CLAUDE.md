# CLAUDE.md — Kryonix Vault

Entry point for **Claude Code** and any Claude-family agent operating this vault.

## Leia antes de agir

Na ordem abaixo, sem pular:

1. **[[AGENTS]]** — regras invioláveis, folder ownership, padrões de qualidade
2. **[[VAULT_INDEX]]** — mapa geral do vault, entradas para cada área
3. **[[PROMPT_MASTER]]** — identidade operacional padrão (system prompt canônico)
4. **[[01-MOCs/Mapa - Kryonix]]** — hub de navegação do projeto Kryonix
5. **`09-Logs/sessions/`** — leia os logs mais recentes antes de qualquer edição

Leitura mínima obrigatória: **AGENTS.md** + **VAULT_INDEX.md**.

---

## Protocolo de sessão

Antes de criar ou modificar qualquer nota:

1. Confirme o layout real do vault (`find . -maxdepth 2 -type d | sort`)
2. Verifique se existe nota equivalente antes de criar
3. Crie log de sessão em `09-Logs/sessions/YYYY-MM-DD/` com frontmatter completo
4. Use wikilinks com caminho completo a partir da raiz (ex: `[[04-Recursos/skills/revisao-pr/SKILL]]`)
5. Commit pequeno e escopo estrito; nunca `git add .`

---

## Layout real do vault (verificado 2026-06-16)

```txt
00-Inbox/         captura rápida
01-MOCs/          mapas de navegação (hub)
02-Areas/         conhecimento de longo prazo
03-Projetos/      trabalho ativo com prazo
04-Archive/       inativo / legacy
04-Recursos/      reutilizáveis
  ├── templates/
  ├── skills/
  ├── playbooks/
  │   └── runbooks/
  └── prompts/
08-Referencias/   curadoria externa
09-Logs/          sessões, revisões, evidências
  ├── sessions/
  └── evidence/
```

**Atenção**: `04-Archive` e `04-Recursos` compartilham o prefixo `04-` intencionalmente.
Não existem: `05-Skills/`, `06-Playbooks/`, `07-Prompts/`.

---

## Regras de segurança

- **Nunca** commitar secrets, tokens, credenciais ou PIIs
- **Nunca** usar `git add .`
- **Nunca** fazer push sem revisão humana
- **Nunca** apagar conteúdo existente sem justificar no commit
- **Nunca** criar arquivo duplicado — atualize o existente
- **Nunca** agir em repositório errado (confirme `pwd` e `git remote -v`)
- Comandos destrutivos exigem confirmação humana explícita

---

## Agentes reconhecidos

| Agente       | Papel                          | Nota de referência                           |
|-------------|-------------------------------|----------------------------------------------|
| Claude Code  | edição / revisão / arquitetura | este arquivo                                 |
| Antigravity  | orquestração / planejamento    | [[PROMPT_MASTER]], [[AGENTS]]               |
| Codex        | implementação com issues       | [[04-Recursos/playbooks/Playbook - Configurar Repo para Codex]] |
| Aura         | agente operacional principal atual | [[02-Areas/Kryonix/ai-brain/Aura]]      |
| Hermes       | referência histórica / compatibilidade quando aplicável | [[02-Areas/Kryonix/ai-brain/Hermes]] |

---

## Docs-âncora canônicos

| Arquivo                              | Papel                                   |
|-------------------------------------|-----------------------------------------|
| `AGENTS.md`                         | contrato de operação (regras + escopo)  |
| `CLAUDE.md`                         | entry point Claude Code (este arquivo)  |
| `VAULT_INDEX.md`                    | home do cérebro, navegação geral        |
| `PROMPT_MASTER.md`                  | system prompt canônico para qualquer IA |
| `04-Recursos/templates/README.md`   | convenções YAML + XML Claude + TOON     |
| `04-Recursos/prompts/PROMPT_AGENT_KRYONIX_VAULT.md` | prompt de edição do vault |

---

## Separação de certeza (obrigatória em notas)

Toda nota técnica deve separar explicitamente:

- **Fato**: verificável, com fonte
- **Boa prática**: consenso da área, mas contextual
- **Opinião**: ponto de vista do autor, marcado como tal
- **Hipótese**: não verificada ainda
- **Risco**: cenário de falha possível

---

## Links

- [[AGENTS]]
- [[VAULT_INDEX]]
- [[PROMPT_MASTER]]
- [[01-MOCs/Mapa - Kryonix]]
- [[03-Projetos/Kryonix-Aura-2026-06/00 Index]]
