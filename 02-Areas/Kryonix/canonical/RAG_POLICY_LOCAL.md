---
status: ativo
validade: validado_por_decisao_humana
tipo: politica
projeto: kryonix
componente: rag-local
fonte_verdade: decisao_humana
confianca: alta
rag: ativo
graph: true
validado_em: 2026-06-19
tags: [kryonix, rag, graphrag, politica, operation-mode, skills]
---

# Kryonix — Política Local de RAG

> Esta política rege indexação local de RAG e GraphRAG no Vault do Kryonix.
> Escopo: **Vault local real** (`/home/rocha/kryonix/kryonix-vault`) + **Inspiron** + **Hermes local** + **OpenRouter**.
> Glacier está fora de escopo temporário (ver `[[02-Areas/Kryonix/canonical/CURRENT_OPERATION_MODE]]`).

## Decisão

Por decisão humana (2026-06-19), o modo operacional atual é:

```
Inspiron       = runtime ativo
Hermes local   = agente principal
OpenRouter     = provider/modelos externos
Vault local    = /home/rocha/kryonix/kryonix-vault
Glacier        = congelado para runtime/servicos ate reinstalacao via ISO oficial
```

Toda política RAG/GraphRAG aplica-se apenas a este escopo. Nada aqui assume Glacier como runtime.

## Modo operacional atual

| Camada | Valor |
|---|---|
| Máquina | Inspiron |
| Agente | Hermes local |
| Provider | OpenRouter |
| Vault canônico | `/home/rocha/kryonix/kryonix-vault` |
| Repo código | `/home/rocha/kryonix/kryonix` (DEV) / `/etc/kryonix` (checkout instalado) |
| Foco P0 | Finalizar installer + ISO oficial Kryonix |

## Fora de escopo temporário

NÃO validar, corrigir, depender ou indexar como verdade operacional:

- `glacier` (host)
- `ssh glacier`
- `ollama.service`, `neo4j.service`, `kryonix-lightrag`, `kryonix-brain-api.service` no Glacier
- LightRAG remoto, MCP remoto via Glacier
- `/var/lib/kryonix` no Glacier
- Storage compartilhado Inspiron↔Glacier
- Path antigo `/home/rocha/.local/share/kryonix/kryonix-vault` (vazio/desalinhado)

> Qualquer validação envolvendo Glacier deve ser registrada como `SKIPPED_BY_OPERATION_MODE`, não como PASS nem FAIL.

## Política rag: ativo

Indexação forte. Estas notas são **memória operacional real** do Kryonix:

```
AGENTS.md
CLAUDE.md
PROMPT_MASTER.md
VAULT_INDEX.md
02-Areas/Kryonix/canonical/**             (incluindo CURRENT_OPERATION_MODE, RAG_POLICY_LOCAL, Roadmap, Architecture, Operations, Security, Testing, Troubleshooting, Usage, Install, Main, Agents, Kryonix Entity Schema)
02-Areas/Kryonix/systems/**               (Brain, Glacier, Inspiron, Ollama, LightRAG, MCP, Vault)
03-Projetos/Kryonix-Aura-2026-06/**       (auditoria Boot Identity P3, Backlog P3/P4/P5, CI Debt, Aprendizados, Skills git-dev-prod, etc.)
04-Recursos/skills/**                     (22 skills Kryonix — SOMENTE skills atuais, não duplicadas, específicas do Kryonix e compatíveis com o modo operacional atual)
04-Recursos/prompts/**                    (PROMPT_*, Prompt - * — 15 prompts)
04-Recursos/playbooks/**                  (Playbook - * — 13 playbooks, exceto kepano)
09-Logs/evidence/**                       (4 docs com timestamp 2026-06-18)
09-Logs/prs/PR-003*                       (disk visualizer — validado)
09-Logs/prs/PR-004*                       (preserve install contract — validado)
08-Referencias/Politica*                  (curadoria de fontes e código)
08-Referencias/Checklist*                 (avaliação de código externo)
08-Referencias/Radar*                     (documentação engenharia)
08-Referencias/Fontes*                    (fontes oficiais)
```

Critério de promoção para `rag: ativo`:
- Memória operacional real ou template reusável do Kryonix
- Tem fonte clara (repo, docs, sessão datada, evidência)
- Não conflita com runtime local Inspiron
- Não é duplicata

## Política rag: baixo_peso

Indexação como referência, contexto auxiliar. Não é verdade operacional Kryonix.

```
MOCs gerais (01-MOCs/Mapa - *.md), exceto Mapa - Kryonix.md
04-Recursos/livros/**                     (notas de livros externos)
04-Recursos/FullStack/**                  (notas de curso)
04-Recursos/Inteligencia-Artificial/**    (notas de curso)
04-Recursos/templates/README.md e outros templates genéricos da raiz
08-Referencias/obsidian/**                (subset curado do vaulthub — 40 notas PKM úteis: Dataview, MOC, Zettelkasten, MARKDOWN, YAML, Mermaid, PARA, Graph customization, Pandoc, GitHub Actions)
04-Recursos/playbooks/Playbook - Usar Obsidian Skills kepano.md     (referência kepano)
material conceitual externo em geral
skills genéricas
skills importadas
skills conceituais
skills antigas sem validação recente
```

Critério:
- Material didático, cursos, livros, roundups datados
- Pode virar contexto, mas não pode afirmar estado do Kryonix
- Sem score para "implementado" sem evidência runtime

## Política rag: excluir

NÃO indexar. Risco de inflar RAG, duplicar respostas ou vazar lixo.

```
04-Archive/_lixo_inbox_2026-06-15/**           (duplicatas SHA256 da estrutura antiga)
qualquer arquivo com SHA256 identico a outro ja indexado
logs brutos gigantes sem curadoria
chats repetidos
arquivos 0 bytes                              (ex.: Anthony Gold.md)
summary_compacted_2026-06-18.json              (nao e nota de conhecimento)
secrets, .env, .key, .pem, tokens              (regra geral)
04-Archive/_vaulthub_import_2026-06-20/**      (arquivo morto — subset já movido para 08-Referencias/obsidian/)
conteudo obsoleto sem evidencia
conteudo que contradiz runtime local Inspiron
skills duplicadas por SHA256
skills em 04-Archive/_lixo_inbox_2026-06-15/**
skills obsoletas
skills sem escopo claro
skills que mandam executar comandos destrutivos sem aprovacao
skills que conflitam com CURRENT_OPERATION_MODE.md
```

## Política graph: true

Candidatos a nós/relações em Neo4j (ou equivalente local, se aplicável):

```
Hosts:          inspiron, glacier, iso, inspiron-nina
Componentes:    ollama, lightrag, neo4j, brain-api, mcp, vault, kryonix-cli, hermes, openrouter
Servicos:       kryonix-brain-api, ollama, kryonix-lightrag, neo4j
Projetos:       Kryonix System, Kryonix Installer, Kryonix VE, RAGOS, RAGOS Installer, Ragos VE
Decisoes:       PRs e ADRs
Roadmap items:  itens do vault 02-Areas/Kryonix/canonical/Roadmap.md (com status NOT_IMPLEMENTED/PARTIAL/PRODUCTION)
Incidentes:     docs em 09-Logs/evidence/
Sessoes:        09-Logs/sessions/2026-06-{14,15,16}
Skills:         22 skills como Capability nodes
Prompts:        15 prompts como Prompt nodes
MOCs:           16 MOCs como Index nodes
```

Relações sugeridas:

```
(Host)-[RUNS]->(Service)
(Service)-[DEPENDS_ON]->(Component)
(Project)-[HAS_DOC]->(Doc)
(Doc)-[STATUS]->(Status:Production|Partial|NotImplemented|Derived)
(Doc)-[LAST_SYNC]->(Date)
(PR)-[TARGETS]->(Host|Service|Component)   -- com flag se roadmap_disfarcado
(Skill)-[USED_BY]->(Project)
(Vault)-[CONTAINS]->(MOC)
(Vault)-[SHOULD_SYNC_TO]->(LIGHTRAG_VAULT_DIR)  -- com flag misaligned=true enquanto Glacier congelado
```

Neo4j remoto está fora de escopo enquanto Glacier estiver congelado. Esta lista é **pronta para uso futuro**, mas só pode ser populada quando houver runtime local de grafo (Inspiron ou via ISO).

## Política de uso correto das skills

Skills são instruções operacionais especializadas, não memória geral. Esta seção define como Avaliar, Carregar e Usar skills no Vault do Kryonix.

1. **Skills são instruções operacionais especializadas, não memória geral.** Elas guiam comportamento do agente em tarefas específicas. Não substituem docs canônicas, repo, runtime ou decisões humanas.

2. **Uma skill só deve ser usada quando o tema da tarefa bater com o escopo dela.** Antes de carregar uma skill, verificar se o escopo declarado da skill realmente cobre o tema. Skill fora de escopo = ruído + gasto de tokens.

3. **Antes de usar uma skill, verificar:**
   - **nome do arquivo** — bate com a tarefa?
   - **objetivo** — declarado no frontmatter?
   - **escopo** — bate com o contexto (Kryonix? Inspiron? modo operacional atual)?
   - **restrições** — quais comandos estão proibidos? exige aprovação?
   - **comandos permitidos/proibidos** — explicitados no corpo?
   - **critérios de validação** — tem checklist ou evidência exigida?
   - **se está duplicada ou obsoleta** — comparar com versões em `_lixo_inbox_2026-06-15/` (SHA256) e frontmatter `last_sync`.

4. **Se houver conflito entre skill e docs canônicas, prevalece a hierarquia:**
   ```
   código real > docs canônicas > CURRENT_OPERATION_MODE > RAG_POLICY_LOCAL > skills > logs/chats antigos
   ```
   Skill que afirma "implementado" sem evidência perde para repo. Skill que manda executar `nixos-rebuild switch` perde para `CURRENT_OPERATION_MODE` (Glacier congelado).

5. **Skills antigas, duplicadas ou importadas não devem ser usadas automaticamente.** Mesmo que o nome pareça certo, se o `last_sync` estiver atrasado ou se houver cópia idêntica em `04-Archive/_lixo_inbox_2026-06-15/`, tratar como suspeita até validar.

6. **Skills dentro de `_lixo_inbox_2026-06-15/` ou duplicadas por SHA256 devem ser marcadas como `rag: excluir`.** Já estão catalogadas nesta política (ver §Política rag: excluir).

7. **Skills boas e atuais podem ser `rag: ativo`, mas somente se forem:**
   - específicas do Kryonix (não genéricas/kepano/vaulthub);
   - acionáveis (com procedimento claro, não só conceituais);
   - com regras claras (incluem restrições e comandos proibidos);
   - sem claims falsos (não dizem "implementado" sem evidência);
   - sem secrets (não embutem tokens, chaves, senhas ou caminhos sensíveis);
   - sem comandos destrutivos automáticos (não executam `rm -rf`, `nixos-rebuild switch`, `git reset --hard`, `disko`, `mkfs.*` ou `git add .` sem aprovação humana explícita).

8. **Skills conceituais/genéricas ficam como `rag: baixo_peso`.** Podem ser referenciadas para contexto, mas não devem fundamentar decisão operacional sobre o Kryonix.

9. **A Aura/Hermes deve citar qual skill usou no relatório final quando uma skill guiar a tarefa.** Formato sugerido: "Skill usada: `[[04-Recursos/skills/<nome>/SKILL]]`". Isso permite auditoria e revisão humana.

10. **Se nenhuma skill adequada existir, declarar isso e seguir pelas regras canônicas.** Não improvisar skill nem usar skill genérica só para "preencher". Preferir sempre `[[AGENTS]]` + `[[VAULT_INDEX]]` + `[[CURRENT_OPERATION_MODE]]` + `RAG_POLICY_LOCAL` como fallback canônico.

## Regras de validação

Toda nota indexada deve respeitar estas regras:

1. **Nota que afirma `implementado` precisa de evidência.** Evidência = comando com output, link para commit/PR mergeado, doc oficial, ou runtime check.
2. **Nota sem evidência vira `precisa_validar`.** Não pode ser tratada como verdade.
3. **Repo real vence Vault.** Quando houver divergência, `/etc/kryonix/` (ou `/home/rocha/kryonix/kryonix/` para DEV) tem prioridade.
4. **Runtime local Inspiron vence claim antigo.** Se runtime local diz X e nota antiga diz Y, X vence.
5. **Glacier fica `SKIPPED_BY_OPERATION_MODE`.** Toda referência a serviço Glacier é `skipped`, não `pass` nem `fail`.
6. **Conteúdo externo não pode afirmar estado do Kryonix.** Material de curso, livro, vaulthub, kepano = `rag: baixo_peso` ou `rag: excluir`.
7. **PR/plano sem merge ou evidência não pode ser tratado como implementado.** Ex.: `09-Logs/prs/PR-005` é roadmap disfarçado — manter como flag.
8. **Frontmatter obrigatório** para indexação: `status`, `validade`, `tipo`, `projeto`, `componente`, `fonte_verdade`, `confianca`, `rag`, `graph`, `validado_em`, `evidencias`.
9. **Duplicatas SHA256** nunca entram no RAG duas vezes.
10. **Path de vault** é apenas `/home/rocha/kryonix/kryonix-vault`. Path antigo `/home/rocha/.local/share/kryonix/kryonix-vault` está fora.

## Regras contra alucinação

Para o agente que consome este RAG (Hermes local + OpenRouter):

1. **Separar Fato / Boa prática / Opinião / Hipótese / Risco** em toda resposta longa.
2. **Marcar incerteza explicitamente** quando não houver evidência. Nunca inventar comando, output ou service.
3. **Citar fonte** (path da nota + repo ou runtime) em qualquer afirmação factual sobre o Kryonix.
4. **Em conflito Vault vs repo**, citar o repo como verdade e a nota como opinião datada.
5. **Em conflito nota vs runtime local Inspiron**, runtime vence.
6. **Glacier**: não especular sobre estado. Use `SKIPPED_BY_OPERATION_MODE`.
7. **Claims perigosos** ("implementado", "100%", "produção", "validado") exigem evidência inline. Sem evidência, rebaixar para `precisa_validar` ou `roadmap`.
8. **Plano/PR sem merge** ≠ feature pronta. Manter flag `roadmap_disfarcado` quando aplicável.
9. **Conteúdo externo** (kepano, vaulthub, livros, cursos) não pode fundamentar decisão sobre o Kryonix sem validação local.
10. **Quando não souber**: dizer "não sei / precisa validar". Nunca preencher lacuna com alucinação plausível.

## Manifesto futuro de indexação

Quando Glacier for reinstalado com a ISO oficial Kryonix e o Brain/LightRAG voltar a ser runtime ativo, esta política deve ser revisada para:

1. **Adicionar `rag: ativo`** o subconjunto curado + filtrado por evidência runtime no Glacier.
2. **Popular Neo4j** com os nós da seção `graph: true` (Hosts, Componentes, Serviços, Projetos, Decisões, Roadmap items, Incidentes, Sessões, Skills, Prompts, MOCs).
3. **Configurar sync contínuo** via `kryonix vault scan` + cron + watcher de `last_sync`.
4. **Implementar autocura** que detecta duplicatas SHA256, arquivos 0 bytes e notas órfãs sem link.
5. **Re-auditar** a cada 30 dias usando este relatório como baseline.
6. **Versionar a política** junto com o installer — ela passa a ser parte do contrato de deploy da ISO.

## Próximas ações seguras

Todas exigem aprovação humana + dry-run + diff antes de aplicar:

```
A1. Renomear 09-Logs/prs/PR-005 para "Plano - Remote Web Mode" e mover para 03-Projetos/
A2. Mover 04-Archive/_lixo_inbox_2026-06-15/ para 04-Archive/_duplicatas_2026-06-15/
A3. Mover 04-Recursos/templates/vaulthub/ para 04-Archive/external/obsidian-hub/
A4. Anotar/apagar Anthony Gold.md (0 bytes)
A5. Mover summary_compacted_2026-06-18.json para 09-Logs/_meta/
A6. Re-sincronizar 02-Areas/Kryonix/canonical/* e systems/* com /etc/kryonix/docs/
A7. Marcar kryonix-brain-api.service como partial em /etc/kryonix/docs/CURRENT_STATE.md
A8. Aplicar frontmatter padrao nos arquivos ativos (status, validade, rag, graph, etc.)
A9. Revisar skill 04-Recursos/skills/revisao-nixos-flake/SKILL.md (match em sudo/rm -rf/mkfs/disko/nixos-rebuild switch/git add .)
A10. Indexar subset "rag: ativo" no Hermes local via OpenRouter (somente leitura)
```

Nada disso toca Glacier, `/etc/kryonix` direto, `/var/lib/kryonix`, ou faz commit sem revisão.

---

**Política ativa e validada por decisão humana em 2026-06-19.**
**Reavaliar quando Glacier for reinstalado com ISO oficial Kryonix.**
**Enquanto Glacier estiver congelado, validações relacionadas devem ser `SKIPPED_BY_OPERATION_MODE`.**
