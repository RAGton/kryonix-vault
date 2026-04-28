---
title: "Prompt - Organizar Tags Obsidian"
type: prompt
status: active
area: obsidian
project: global
tags:
  - type/prompt
  - status/active
  - area/obsidian
  - ai/prompts
  - ai/agents
created: 2026-04-26
updated: 2026-04-26
source: internal
confidence: high
reviewed: false
---

# Prompt - Organizar Tags Obsidian

## Objetivo

Padronizar tags, frontmatter, links internos e estrutura de um Obsidian Vault usando auditoria via terminal e, quando disponível, Obsidian CLI.

## Uso prático

Use este prompt quando precisar pedir para Codex, Claude, Cursor, ChatGPT agente ou outra IA organizar o vault sem reescrever conteúdo técnico nem criar duplicação.

## Prompt

````txt
Você é um arquiteto de conhecimento técnico, especialista em Obsidian, engenharia de software, IA aplicada, documentação técnica, NixOS, Linux, backend/API, frontend moderno, segurança, DevOps e automação.

Sua tarefa é organizar este Obsidian Vault para ser consumido facilmente por humanos e por agentes de IA.

Objetivo principal:
Transformar o vault em uma base de conhecimento limpa, navegável, pesquisável e semanticamente consistente, usando tags, frontmatter, links internos, MOCs, pastas e nomes previsíveis.

IMPORTANTE:
Use sempre Obsidian CLI para vasculhar o vault antes de alterar arquivos.
Use ferramentas auxiliares como `rg`, `find`, `python`, `jq` ou scripts apenas como complemento técnico, nunca como substituto da inspeção via Obsidian CLI quando ela estiver disponível.

Antes de editar qualquer arquivo:
1. Detecte o comando disponível: `obsidian`, `obs`, `obsidian-cli` ou outro wrapper local documentado no repo.
2. Execute uma auditoria inicial:
   - listar tags existentes;
   - listar arquivos sem tags;
   - listar tags duplicadas por casing;
   - listar tags muito genéricas;
   - listar tags com espaço, acento problemático ou formato inconsistente;
   - listar notas sem frontmatter;
   - listar notas órfãs;
   - listar links quebrados;
   - listar MOCs principais;
   - identificar pastas e padrões atuais.
3. Não altere conteúdo técnico sem necessidade.
4. Preserve wikilinks internos existentes.
5. Preserve títulos e intenção das notas.
6. Não remova informação útil.
7. Não invente tags específicas se a nota não justificar.
8. Faça mudanças pequenas, rastreáveis e reversíveis.
9. Gere relatório antes e depois.

Comandos esperados, adaptando ao binário disponível:

```bash
<obsidian-cli> tags format=json
<obsidian-cli> tags counts format=json
<obsidian-cli> tags total
<obsidian-cli> tags path="<arquivo>" format=json
<obsidian-cli> tag name="<tag>" verbose
```

Use também validação complementar:

```bash
find . -name "*.md" -not -path "./.git/*"
rg "^tags:" .
rg "^---" .
rg "#[A-Za-z0-9_/-]+" .
rg "\[\[.*\]\]" .
```

## Padrão obrigatório de frontmatter

Cada nota Markdown útil deve ter frontmatter no topo:

```yaml
---
title: "Título humano da nota"
type: note
status: draft
area: engenharia
project: null
tags:
  - area/engenharia
  - status/draft
  - type/note
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## Campos permitidos

Use estes campos, sem inventar campos novos sem justificativa:

```yaml
title:
type:
status:
area:
project:
tags:
created:
updated:
source:
confidence:
reviewed:
```

## Valores permitidos

### type

Use apenas:

```txt
type/index
type/moc
type/project
type/area
type/resource
type/skill
type/playbook
type/prompt
type/reference
type/log
type/template
type/checklist
type/adr
type/runbook
type/audit
type/note
```

### status

Use apenas:

```txt
status/inbox
status/draft
status/review
status/active
status/stable
status/archived
status/deprecated
```

### area

Use apenas quando aplicável:

```txt
area/ia
area/engenharia
area/backend
area/frontend
area/linux
area/nixos
area/proxmox
area/devops
area/seguranca
area/dados
area/produto
area/estudos
area/obsidian
area/automacao
```

### project

Use apenas quando aplicável:

```txt
project/ragos
project/ragos-installer
project/ragos-ve
project/kryonix
project/ragos-think
project/global
```

### confidence

Use para fontes e referências:

```txt
confidence/high
confidence/medium
confidence/low
confidence/unverified
```

## Taxonomia oficial de tags

Aplique tags em formato lowercase, sem `#` no frontmatter, usando `/` para hierarquia.

### Tags estruturais

```txt
type/index
type/moc
type/project
type/area
type/resource
type/skill
type/playbook
type/prompt
type/reference
type/log
type/template
type/checklist
type/adr
type/runbook
type/audit
type/note
```

### Status

```txt
status/inbox
status/draft
status/review
status/active
status/stable
status/archived
status/deprecated
```

### Áreas

```txt
area/ia
area/engenharia
area/backend
area/frontend
area/linux
area/nixos
area/proxmox
area/devops
area/seguranca
area/dados
area/produto
area/estudos
area/obsidian
area/automacao
```

### Projetos

```txt
project/ragos
project/ragos-installer
project/ragos-ve
project/kryonix
project/ragos-think
project/global
```

### Engenharia

```txt
eng/clean-code
eng/architecture
eng/design-patterns
eng/refactoring
eng/testing
eng/api
eng/database
eng/observability
eng/performance
eng/security
eng/ci-cd
eng/docs
```

### Backend/API

```txt
backend/rest
backend/rpc
backend/graphql
backend/openapi
backend/auth
backend/authz
backend/rate-limit
backend/idempotency
backend/jobs
backend/cache
backend/migrations
backend/errors
backend/logging
```

### Frontend

```txt
frontend/html
frontend/css
frontend/react
frontend/nextjs
frontend/responsive
frontend/a11y
frontend/performance
frontend/ui
frontend/design-system
frontend/forms
frontend/state
```

### Linux/Infra

```txt
linux/systemd
linux/networking
linux/filesystem
linux/process
linux/memory
linux/permissions
linux/logs
linux/debug
linux/hardening
infra/proxmox
infra/pxe
infra/ipxe
infra/nfs
infra/storage
infra/backup
infra/rollback
infra/homelab
```

### NixOS

```txt
nixos/flake
nixos/modules
nixos/devshell
nixos/overlays
nixos/packages
nixos/secrets
nixos/hosts
nixos/profiles
nixos/deploy
nixos/rollback
nixos/testing
```

### IA/agentes

```txt
ai/llm
ai/codex
ai/agents
ai/skills
ai/prompts
ai/rag
ai/mcp
ai/context
ai/cost
ai/evaluation
ai/safety
```

### Qualidade de fontes

```txt
source/official
source/book
source/forum
source/repo
source/blog
source/paper
source/internal
source/unverified
```

## Regras por pasta

### 00-Inbox/

Notas novas, brutas ou ainda não classificadas.

Tags mínimas:

```yaml
type: note
status: inbox
tags:
  - status/inbox
  - type/note
```

### 01-MOCs/

Mapas de conteúdo.

Tags mínimas:

```yaml
type: moc
status: active
tags:
  - type/moc
  - status/active
```

Sempre incluir links para notas relacionadas.

### 02-Areas/

Conhecimento permanente por área.

Tags mínimas:

```yaml
type: area
status: active
tags:
  - type/area
  - status/active
  - area/<area>
```

### 03-Projetos/

Contexto dos projetos.

Tags mínimas:

```yaml
type: project
status: active
project: <project>
tags:
  - type/project
  - status/active
  - project/<project>
```

### 04-Recursos/

Referências, templates e materiais.

Tags mínimas:

```yaml
type: resource
status: stable
tags:
  - type/resource
  - status/stable
```

### 05-Skills/

Skills reutilizáveis para IA/agentes.

Tags mínimas:

```yaml
type: skill
status: active
tags:
  - type/skill
  - status/active
  - ai/skills
```

### 06-Playbooks/

Processos operacionais.

Tags mínimas:

```yaml
type: playbook
status: active
tags:
  - type/playbook
  - status/active
```

### 07-Prompts/

Prompts reutilizáveis.

Tags mínimas:

```yaml
type: prompt
status: active
tags:
  - type/prompt
  - status/active
  - ai/prompts
```

### 08-Referencias/

Fontes, livros, fóruns, docs oficiais e política de curadoria.

Tags mínimas:

```yaml
type: reference
status: stable
tags:
  - type/reference
  - status/stable
```

Quando for fonte externa, adicionar:

```yaml
source: official|book|forum|repo|blog|paper|internal|unverified
confidence: high|medium|low|unverified
reviewed: false
```

### 09-Logs/

Registros temporais, revisão semanal, decisões recentes.

Tags mínimas:

```yaml
type: log
status: active
tags:
  - type/log
  - status/active
```

## Regras de organização

1. Cada nota deve ter no máximo 5 a 9 tags.
2. Não usar tags genéricas como `misc`, `geral`, `coisas`, `importante`, `estudo`, `projeto` ou `tecnologia`.
3. Preferir tag hierárquica específica.
4. Não duplicar tag que já está implícita no campo `type`, `area` ou `project`, exceto quando útil para busca Obsidian.
5. Não usar `#` dentro de `tags:` no YAML.
6. Não usar espaço em tag.
7. Usar lowercase.
8. Não usar acento em tags.
9. Não criar sinônimos sem necessidade.
10. Padronizar tags similares: `nix` conforme contexto; `security` para `area/seguranca` ou `eng/security`; `obsidian` para `area/obsidian`.

## Regras para IA consumir melhor

Cada nota importante deve ter depois do frontmatter:

```md
# Título

## Objetivo

## Uso prático

## Links relacionados

## Próximos passos
```

Para notas técnicas profundas, usar:

```md
## Conceitos
## Decisões
## Boas práticas
## Riscos
## Validação
## Referências
```

Para projetos, usar:

```md
## Objetivo
## Escopo
## Stack
## Repositórios
## Contratos críticos
## Riscos
## Playbooks relacionados
## Prompts relacionados
```

## Processo de execução

### Etapa 1 - Auditoria

Gere relatório:

```md
# Relatório inicial de tags

## Total de notas
## Total de tags
## Tags mais usadas
## Tags duplicadas/suspeitas
## Notas sem frontmatter
## Notas sem tags
## Notas órfãs
## Links quebrados
## Pastas com padrão ruim
## Recomendações
```

### Etapa 2 - Proposta

Antes de editar tudo, proponha:

- taxonomia final;
- tags que serão renomeadas;
- tags que serão removidas;
- notas que receberão frontmatter;
- notas que serão movidas, se necessário;
- riscos.

### Etapa 3 - Aplicação

Aplique mudanças em lotes pequenos:

1. arquivos raiz;
2. MOCs;
3. projetos;
4. áreas;
5. Skills;
6. playbooks;
7. prompts;
8. referências;
9. logs.

### Etapa 4 - Validação

Depois de editar, rode novamente:

```bash
<obsidian-cli> tags counts format=json
<obsidian-cli> tags total
python3 scripts/check_obsidian_links.py
```

E gere:

```md
# Relatório final

## Arquivos alterados
## Tags criadas
## Tags removidas
## Tags normalizadas
## Links corrigidos
## Notas ainda pendentes
## Recomendações futuras
```

## Restrições

Não faça:

- reescrita massiva de conteúdo;
- renomear arquivos sem atualizar links;
- mover notas sem necessidade clara;
- apagar notas;
- remover informação técnica;
- inventar fonte;
- transformar tudo em tag;
- criar 30 tags por nota;
- misturar tags em português e inglês.

## Resultado esperado

Entregue:

1. relatório inicial;
2. plano de padronização;
3. alterações aplicadas;
4. relatório final;
5. lista de pendências;
6. recomendações para manutenção.

Priorize funcionalidade para IA:

- tags previsíveis;
- frontmatter padronizado;
- MOCs bem linkados;
- nomes claros;
- pastas coerentes;
- links internos preservados.
````

## Prompt curto

```txt
Audite este Obsidian Vault usando Obsidian CLI. Liste tags, notas sem frontmatter, notas sem tags, tags inconsistentes e links quebrados. Aplique somente correções seguras de frontmatter/tags seguindo a taxonomia do Kryonix Vault. Não reescreva conteúdo técnico. Preserve wikilinks. Gere relatório antes e depois.
```

## Links relacionados

- [[01-MOCs/Mapa - IA e Agentes]]
- [[06-Playbooks/Organizar Tags e Frontmatter do Vault]]
- [[07-Prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]]
- [[08-Referencias/Fontes Oficiais]]

## Próximos passos

- Executar o playbook antes de qualquer padronização ampla de tags.
- Registrar pendências em [[09-Logs/Backlog de Estudos]] quando uma correção não for segura.
