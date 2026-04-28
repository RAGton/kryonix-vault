---
title: "Manual - Ativar Segundo Cerebro da IA"
type: playbook
status: active
area: ia
project: global
tags:
  - type/playbook
  - status/active
  - area/ia
  - ai/context
  - ai/agents
created: 2026-04-26
updated: 2026-04-26
source: internal
confidence: high
reviewed: false
---

# Manual - Ativar Segundo Cerebro da IA

## Objetivo

Ativar este repositório Obsidian + Git como segundo cérebro técnico para humanos e agentes de IA em qualquer projeto.

O objetivo não é guardar texto infinito. O objetivo é criar contexto reutilizável, versionado, pesquisável e seguro para acelerar engenharia, arquitetura, backend/API, frontend, Linux, NixOS, DevOps, segurança, produto e estudos.

## Modelo mental

```txt
Obsidian = interface humana de leitura e escrita
Git = histórico, backup e sincronização
Vault = conhecimento global reutilizável
Projeto atual = contexto local e fonte de verdade operacional
AGENTS.md = contrato de comportamento para agentes
PROMPT_MASTER.md = identidade e regras do cérebro de IA
VAULT_INDEX.md = mapa inicial de navegação
MOCs = mapas por área
Playbooks = procedimentos reutilizáveis
Skills = workflows repetíveis para IA
Prompts = comandos reutilizáveis para agentes
Logs = decisões, revisões e aprendizado contínuo
```

## Ativação rápida

1. Clone ou abra este repositório localmente.
2. Abra a pasta como vault no Obsidian.
3. Comece por [[VAULT_INDEX]].
4. Leia [[AGENTS]] para entender as regras de manutenção.
5. Leia [[PROMPT_MASTER]] para entender como a IA deve operar.
6. Use [[07-Prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]] como prompt inicial para qualquer agente.
7. Para usar em outro projeto, siga [[IMPLEMENTAR_EM_OUTROS_PROJETOS]].
8. Para manutenção diária, use [[06-Playbooks/Rotina de Treinamento do Cerebro Obsidian]].

## Estrutura de ativação

### 1. Abrir como Obsidian Vault

No Obsidian:

```txt
Open folder as vault -> selecione a pasta kryonix-vault
```

Depois confira:

- os links internos funcionam;
- o Graph View mostra tags;
- snippets de CSS estão ativos, se desejar cores por categoria;
- o vault não contém secrets.

### 2. Ativar Git

Use Git como trilha de auditoria. Antes de uma sessão:

```bash
git status
git pull
```

Depois de uma sessão:

```bash
git status
git diff
git add <arquivos>
git commit -m "Update AI knowledge vault"
git push
```

Se usar plugin de Git no Obsidian, mantenha a mesma regra: revisar diff antes de sincronizar.

### 3. Ativar para uma IA

Quando abrir Codex, Claude, ChatGPT, Cursor ou outro agente, forneça este contrato:

```txt
Use este repositório Obsidian como segundo cérebro técnico.

Leia primeiro:
1. VAULT_INDEX.md
2. AGENTS.md
3. PROMPT_MASTER.md
4. 01-MOCs/Mapa - Cerebro Supremo de IA.md
5. 07-Prompts/PROMPT_IA_CONSUMIR_OBSIDIAN.md

Prioridade:
1. contexto do projeto atual;
2. este vault;
3. documentação oficial atual;
4. código existente;
5. memória interna do modelo.

Regras:
- não invente fatos;
- preserve wikilinks;
- crie a menor mudança correta;
- não adicione secrets;
- registre decisões importantes;
- transforme conhecimento repetido em nota, prompt, Skill ou playbook.
```

## Usar em qualquer projeto

Existem dois modos seguros.

## Modo A - Referência externa

Use quando o projeto não deve carregar o vault dentro do repositório.

No prompt do agente, diga:

```txt
Consulte o vault em:
C:\Users\aguia\Documents\kryonix-vault

Antes de executar a tarefa, leia:
- VAULT_INDEX.md
- AGENTS.md
- PROMPT_MASTER.md
- MOC relacionado à área da tarefa
- playbook ou Skill relacionado
```

Vantagem:

- simples;
- sem mexer no repo do projeto;
- bom para uso local.

Risco:

- outro computador/agente pode não ter o mesmo caminho local.

## Modo B - Submódulo Git

Use quando quiser levar o cérebro de IA junto com o projeto.

Dentro do projeto alvo:

```bash
git submodule add <url-do-repo-kryonix-vault> .ai/kryonix-vault
git commit -m "Add AI knowledge vault"
```

Atualizar depois:

```bash
git submodule update --remote .ai/kryonix-vault
git add .ai/kryonix-vault
git commit -m "Update AI knowledge vault"
```

No `AGENTS.md` do projeto alvo, adicione:

```md
## Segundo cerebro de IA

Antes de executar tarefas complexas, consulte:

- .ai/kryonix-vault/VAULT_INDEX.md
- .ai/kryonix-vault/AGENTS.md
- .ai/kryonix-vault/PROMPT_MASTER.md
- .ai/kryonix-vault/07-Prompts/PROMPT_IA_CONSUMIR_OBSIDIAN.md

O projeto atual vence o vault global quando houver conflito.
```

Vantagem:

- reprodutível;
- funciona em CI/agentes;
- histórico explícito da versão do vault usada no projeto.

Risco:

- exige disciplina para atualizar submódulo;
- não deve carregar secrets no vault.

## Contexto mínimo por projeto

Cada projeto que usar este vault deve ter pelo menos:

```txt
AGENTS.md
PROJECT_CONTEXT.md
README.md
```

Para projetos maiores:

```txt
ARCHITECTURE.md
SECURITY.md
OPERATIONS.md
DECISIONS.md
```

Modelo mínimo de `PROJECT_CONTEXT.md`:

```md
# Project Context

## Objetivo

## Stack

## Como rodar

## Como testar

## Contratos críticos

## Áreas sensíveis

## Fora do escopo para agentes

## Deploy e rollback

## Links para o vault
```

## Rotina diária de alimentação

No fim de cada sessão, registre apenas o que será reutilizável.

Use este bloco:

```md
## Captura do dia

### O que aprendi

### Erro que não quero repetir

### Comando útil

### Decisão tomada

### Prompt que funcionou

### Algo que deve virar playbook ou Skill

### Próxima melhoria do vault
```

Regra prática:

- apareceu 1 vez: pode ficar no log;
- apareceu 2 vezes: vira nota curta;
- apareceu 3 vezes: vira playbook, checklist ou Skill;
- virou regra operacional: entra em `AGENTS.md` ou no `AGENTS.md` do projeto.

## Como melhorar a cada dia

Escolha uma melhoria pequena por dia:

- limpar uma nota da inbox;
- corrigir links quebrados;
- transformar uma resposta boa em prompt;
- transformar um procedimento repetido em playbook;
- transformar uma tarefa recorrente em Skill;
- resumir uma decisão técnica em ADR;
- adicionar checklist de validação;
- atualizar MOC com nota importante;
- remover duplicação;
- revisar tags/frontmatter.

Evite reorganizações grandes sem motivo claro. O vault melhora por acumulação disciplinada, não por faxina heroica.

## Fluxo recomendado com agentes

Antes de pedir implementação:

1. Aponte o agente para este manual.
2. Aponte para [[VAULT_INDEX]].
3. Aponte para a nota do projeto em `03-Projetos/` ou `PROJECT_CONTEXT.md`.
4. Aponte para o MOC da área.
5. Aponte para o playbook ou Skill aplicável.
6. Defina escopo permitido e fora do escopo.
7. Exija validação.

Prompt curto:

```txt
Use o Kryonix Vault como segundo cérebro de IA.
Leia MANUAL_ATIVAR_SEGUNDO_CEREBRO_IA.md, VAULT_INDEX.md, AGENTS.md e PROMPT_MASTER.md.
Depois leia o contexto do projeto atual.
Execute somente a menor mudança correta.
Preserve links, segurança, testes e rastreabilidade.
Ao final, diga o que virou conhecimento reutilizável para o vault.
```

## Segurança

Nunca coloque no vault:

- senhas;
- tokens;
- chaves privadas;
- `.env` real;
- dados pessoais sensíveis;
- credenciais de produção;
- dumps de banco;
- logs com segredo;
- comandos destrutivos sem aviso e rollback.

Todo conteúdo de segurança deve separar:

- fato confirmado;
- hipótese;
- risco;
- validação;
- rollback;
- decisão humana necessária.

## Validação

Depois de mudanças no vault:

```bash
python scripts/check_obsidian_links.py
```

Se o Python do sistema não estiver disponível, use o runtime configurado pelo ambiente ou instale Python antes.

Checklist:

- [ ] `git status` revisado;
- [ ] links internos válidos;
- [ ] notas novas linkadas a MOC;
- [ ] frontmatter e tags coerentes;
- [ ] nenhum secret adicionado;
- [ ] nenhuma reescrita massiva desnecessária;
- [ ] decisão importante registrada;
- [ ] próxima ação clara.

## Links relacionados

- [[VAULT_INDEX]]
- [[01-MOCs/Mapa - Cerebro Supremo de IA]]
- [[01-MOCs/Mapa - IA e Agentes]]
- [[AGENTS]]
- [[PROMPT_MASTER]]
- [[IMPLEMENTAR_EM_OUTROS_PROJETOS]]
- [[07-Prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]]
- [[06-Playbooks/Como Fazer Outra IA Consumir Este Vault]]
- [[06-Playbooks/Rotina de Treinamento do Cerebro Obsidian]]

## Próxima ação

Use este manual como primeira leitura em qualquer projeto novo que precise consumir o Kryonix Vault como segundo cérebro de IA.
