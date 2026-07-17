# Review de governança — AGENTS.md do kryonix-dev

Data: 2026-07-16
Agente: Aura
Status: proposta registrada; não aplicada ao `AGENTS.md`

## Objetivo

Registrar a revisão de governança proposta para amadurecer o `AGENTS.md` do workspace `kryonix-dev` antes de tratá-lo como regra canônica.

## Diagnóstico

Arquitetura desejada:

```text
SOUL.md
└── identidade, personalidade e postura da Aura

AGENTS.md do kryonix-dev
└── governança global do workspace multi-repo

repos/<repo>/AGENTS.md
└── regras específicas de cada repositório

Vault
└── memória, decisões, ADRs, evidências e continuidade

IDEA.md do projeto Hermes
└── resumo curto do propósito e caminhos principais
```

O `AGENTS.md` deve permanecer frio, verificável e operacional; personalidade da Aura deve ficar no `SOUL.md`.

## Recomendações principais

1. Descrever `kryonix-dev` como workspace orquestrador com submódulos, não como repo funcional de desenvolvimento.
2. Explicitar que commit, push, PR e atualização de pointer exigem autorização explícita, salvo pedido direto.
3. Não assumir `main`; detectar branch default e usar branch/PR para features, migrações e refactors.
4. Tornar o registro no Vault obrigatório só para tarefas relevantes/críticas, evitando ruído em typos, formatação e consultas.
5. Substituir leitura ampla do Vault por busca seletiva: índices, MOCs e `rg` temático.
6. Adicionar preflight multi-repo obrigatório com `git submodule status --recursive` e classificação de estados.
7. Definir regra para submódulo em detached HEAD: não commitar em detached, identificar branch remota e pedir autorização se ambíguo.
8. Separar atualização de pointer: commit/push no repo filho antes do commit do pointer no `kryonix-dev`.
9. Guardar `capture_evidence.sh` atrás de condição de existência/ambiente; registrar `EVIDENCE_BLOCKED` quando indisponível.
10. Definir fallback quando MCP `kryonix-test` estiver indisponível: não fingir execução; marcar `MCP_TEST_UNAVAILABLE`/`UNKNOWN`.
11. Adicionar precedência de regras: segurança/humano > workspace AGENTS > repo AGENTS > regras locais > workflow > docs > Vault > memória > conhecimento geral.
12. Definir classificação de tarefas: trivial, relevante e crítica.
13. Definir estados de conclusão permitidos: `VALIDATED`, `READY_FOR_REVIEW`, `PARTIAL`, `BLOCKED`, `BROKEN`, `UNKNOWN`, `NOT_TESTED`, `EVIDENCE_BLOCKED`.
14. Expandir matriz de repositórios com fonte de verdade e validação principal.
15. Criar `IDEA.md` curto para Hermes com propósito, caminhos e regras essenciais.

## Veredito proposto

Estado atual do documento:

```text
READY_FOR_REVIEW
```

Após ajustes:

```text
CANONICAL
```

## Regra central a preservar

> Aura pode alterar arquivos e validar. Commit, push, PR e mudança de pointer continuam sendo decisões explicitamente autorizadas pelo Gabriel.

## Próximo passo recomendado

Aplicar esses ajustes no `AGENTS.md` em uma missão separada, com diff pequeno e revisão explícita antes de transformar o documento em canônico.
