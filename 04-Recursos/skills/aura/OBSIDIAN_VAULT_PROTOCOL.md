---
title: "Aura — Protocolo de Uso Eficiente do Obsidian Vault"
status: active
type: skill
area: IA
project: Kryonix
agent: Aura
tags:
  - aura
  - obsidian
  - vault
  - rag
  - graphrag
  - agente
  - kryonix
---

<skill>
Aura — Protocolo de Uso Eficiente do Obsidian Vault
</skill>

## Objetivo

Ensinar a Aura/Hermes a interagir com o Obsidian Vault de forma eficiente, segura e padronizada, transformando interações efêmeras em conhecimento técnico reutilizável e de alta densidade.

## Quando usar

- Ao iniciar qualquer tarefa que envolva leitura ou escrita no `kryonix-vault`.
- Antes de criar novas notas, ADRs, prompts ou playbooks.
- Para orientar a estruturação de saídas complexas que devam ser persistidas.
- Sempre que houver dúvida sobre o local correto de armazenamento de uma informação.

## Papel da Aura no Vault

A Aura atua como **curadora e arquiteta de conhecimento**. Ela não apenas joga informações no vault, mas as integra semânticamente, garantindo que:
1. O conhecimento seja linkável e navegável.
2. A entropia do sistema permaneça baixa.
3. As decisões técnicas sejam rastreáveis (ADRs).
4. Os procedimentos operacionais sejam repetíveis (Runbooks/Playbooks).

## Layout do Vault

O Vault segue uma numeração própria (não é PARA puro):

- `00-Inbox`: Captura rápida, rascunhos temporários.
- `01-MOCs`: Mapas de Conteúdo (hubs de navegação). Toda nota deve apontar para um MOC.
- `02-Areas`: Conhecimento de longo prazo (IA, Backend, NixOS, etc.).
- `03-Projetos`: Notas de projetos ativos com prazo e entregáveis.
- `04-Archive`: Notas inativas ou legadas (prefixo 04 compartilhado).
- `04-Recursos`: Assets reutilizáveis (Templates, Skills, Playbooks, Prompts).
- `08-Referencias`: Curadoria de fontes externas e sumários.
- `09-Logs`: Logs de sessão, evidências de validação e decisões diárias.

## Documentos-âncora

Antes de agir, consulte (nesta ordem):
1. [[VAULT_INDEX]]: O ponto de entrada universal.
2. [[AGENTS]]: O contrato operacional e regras invioláveis.
3. [[01-MOCs/Mapa - Cerebro Supremo de IA]]: Visão geral da estratégia de IA.
4. [[04-Recursos/prompts/PROMPT_IA_CONSUMIR_OBSIDIAN]]: Protocolo de leitura.

## Workflow obrigatório

1. **Pesquisa Inicial**: Use `grep` ou `find` para verificar se já existe nota sobre o tema.
2. **Navegação MOC-first**: Identifique o MOC da área (ex: `Mapa - Backend`) para entender o contexto.
3. **Classificação**: Decida se o output é Nota, ADR, Skill, Prompt ou Playbook.
4. **Aplicação Mínima**: Prefira atualizar uma nota existente a criar uma nova.
5. **Formatação**: Use Frontmatter YAML e tags XML conforme os templates oficiais.
6. **Conectividade**: Adicione [[wikilinks]] para o MOC pai e notas relacionadas.
7. **Validação**: Verifique links quebrados e integridade do YAML.

## Como escolher a saída correta

| Se o conteúdo for... | Use o Tipo/Pasta... | Template |
|---|---|---|
| Fato técnico reutilizável | Nota Técnica (`02-Areas/`) | `template-nota-tecnica` |
| Decisão arquitetural | ADR (`09-Logs/` ou `02-Areas/`) | `template-adr` |
| Procedimento passo-a-passo | Playbook (`04-Recursos/playbooks/`) | `template-playbook` |
| Comando/Script operacional | Runbook (`04-Recursos/playbooks/runbooks/`) | `template-playbook` |
| Workflow para agente IA | Skill (`04-Recursos/skills/`) | `template-skill` |
| Prompt reutilizável | Prompt (`04-Recursos/prompts/`) | `template-prompt` |
| Resumo de estado de projeto | Project Summary (`03-Projetos/`) | `template-projeto` |

## Como evitar duplicação

- **Busca exaustiva**: Antes de criar `Nota X`, procure por `X` no vault.
- **Merge**: Se encontrar `Nota Y` que cobre 80% do tema, adicione os 20% restantes nela em vez de criar a `Nota X`.
- **Generalização**: Se o tema for específico de um projeto mas útil para outros, mova para `02-Areas` e linke no projeto.

## Como usar wikilinks

- Use `[[Caminho/Completo/Para/Nota|Alias]]` para clareza.
- Evite caminhos absolutos do sistema (ex: `/home/rocha/...`).
- Use wikilinks para conectar conceitos, não apenas para citar arquivos.
- Toda nova nota EM `02-Areas` DEVE ter um link para seu MOC correspondente.

## Como separar certeza

Use o protocolo de classificação de fonte antes de escrever afirmações técnicas:

- **Fato**: Confirmado por execução real, arquivo no sistema ou documentação oficial.
- **Boa prática**: Recomendação padrão da indústria ou do projeto Kryonix.
- **Opinião**: Interpretação técnica subjetiva (justifique).
- **Hipótese**: Suposição que ainda precisa de validação técnica.
- **Risco**: Impacto negativo potencial ou falha conhecida.

## Templates de saída

### Nota técnica
Foco em "Como funciona" e "Por que". Deve ser atemporal e reutilizável.

### ADR
Foco em "O que decidimos" e "Quais eram as alternativas". Inclui status (Proposed, Accepted, Deprecated).

### Runbook
Foco em "Como executar". Deve conter comandos `bash` exatos e verificações de sucesso.

### Prompt versionado
Foco em "Como instruir". Deve conter Role, Task, Context, Constraints e Examples.

### Skill
Foco em "Workflow complexo". Define um mini-programa para ser executado por outra IA.

## Segurança

- **NUNCA** salve secrets, API keys, tokens ou PII no Vault.
- Se precisar referenciar um segredo, use o nome da variável de ambiente ou o caminho no `sops`/`vault`.
- Não sugira comandos destrutivos sem avisos claros de backup e rollback.

## Anti-alucinação

1. **Não invente**: Se o vault não diz e a doc oficial não confirma, declare como **Hipótese**.
2. **Verifique**: Use `run_shell_command` para confirmar caminhos de arquivos e versões antes de documentar.
3. **Curadoria**: Não trate o output bruto de uma ferramenta como fato permanente sem limpeza e estruturação.

## Economia de tokens

- Use **TOON** para listas com mais de 5 itens repetitivos.
- Mantenha notas densas e diretas.
- Use links em vez de duplicar conteúdo.
- Referencie o UID ou o caminho curto da nota em vez de ler o arquivo inteiro repetidamente.

## Validação

Toda alteração deve passar por:
1. `git diff --check`: Para detectar espaços em branco e conflitos.
2. `python3 scripts/check_obsidian_links.py`: Para validar conectividade.
3. Revisão visual do Frontmatter YAML.

## Checklist de aceite

- [ ] A nota segue a estrutura de pastas 00-09?
- [ ] Existe um wikilink para o MOC da área?
- [ ] O Frontmatter YAML está completo (title, status, type, tags, etc)?
- [ ] Foram evitadas duplicações com notas existentes?
- [ ] Informações sensíveis (secrets) foram omitidas?
- [ ] A distinção entre Fato/Hipótese/Risco está clara?
- [ ] O conteúdo é denso, reutilizável e de baixo custo de token?

## Próximos passos

- Integrar esta Skill no workflow padrão da Aura via `AGENTS.md`.
- Adicionar link para esta nota no `VAULT_INDEX.md`.
- Converter logs de sessão recentes em notas técnicas seguindo este protocolo.


## Autonomous loops (L0–L4)

Loops de engenharia autônoma seguem o template `template-loop` e produzem 4 arquivos em `09-Logs/Kryonix/Loops/<loop-id>/`:

- `STATE.md` — Objective/Metrics/Boundary, autonomy level, current tick
- `EVENTS.jsonl` — um evento NDJSON por linha (ts/tick/actor/action/outcome/ref/rollback)
- `EVIDENCE.md` — outputs literais de comandos, sem resumo
- `FINAL_REPORT.md` — outcome vs objective, métricas, desvios, follow-ups

Regras: L0/L1 livre; **L2 exige human review**; **L3 exige human gate**; **L4 nunca autônomo**. Fechar o loop atual antes de abrir o próximo.

Veja também: a skill Hermes `kryonix-vault-workflow` operacionaliza este protocolo (busca→save contínuo).