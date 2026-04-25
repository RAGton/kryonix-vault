# obsidian-vault

Vault Obsidian para funcionar como **cérebro operacional de IA**: uma base de conhecimento reutilizável para engenharia de software, backend/API, Linux, NixOS, DevOps, segurança, produto, estudos, prompts, Skills e agentes.

Este repo foi pensado para ser usado com:

- Obsidian
- Codex / agentes de código
- ChatGPT / LLMs
- GitHub
- projetos backend/API
- infraestrutura declarativa
- NixOS / flakes
- estudos técnicos contínuos

## Objetivo

Criar uma base única, versionada e pesquisável para reduzir repetição, economizar tokens e aumentar qualidade técnica.

O vault deve responder rapidamente:

- Qual é meu padrão de arquitetura?
- Como crio uma API vendável?
- Como reviso segurança?
- Como preparo uma issue boa para Codex?
- Quais prompts e Skills eu já uso?
- Quais decisões técnicas já tomei?
- O que estou estudando?
- Quais playbooks uso em produção?

## Entrada principal no Obsidian

Abra:

- [[VAULT_INDEX]]
- [[01-MOCs/Mapa - Engenharia de Software]]
- [[01-MOCs/Mapa - IA e Agentes]]
- [[PROMPT_MASTER]]
- [[AGENTS]]

## Estrutura

```txt
obsidian-vault/
├── AGENTS.md
├── PROMPT_MASTER.md
├── VAULT_INDEX.md
├── 00-Inbox/
├── 01-MOCs/
├── 02-Areas/
├── 03-Projetos/
├── 04-Recursos/
├── 05-Skills/
├── 06-Playbooks/
├── 07-Prompts/
├── 08-Referencias/
├── 09-Logs/
├── scripts/
└── .github/workflows/
```

## Como criar o repo no GitHub

Com GitHub CLI:

```bash
cd obsidian-vault
git init
git add .
git commit -m "Initial Obsidian AI brain vault"
gh repo create RAGton/obsidian-vault --private --source=. --remote=origin --push
```

Para repo público, troque `--private` por `--public`.

## Rotina de uso

Diariamente:

1. Capturar ideias em [[00-Inbox/Inbox]].
2. Processar notas para uma área ou projeto.
3. Criar links internos no formato de wiki links.
4. Atualizar MOCs quando surgir um conceito importante.
5. Registrar decisões em ADRs.

Semanalmente:

1. Revisar [[09-Logs/Revisao Semanal]].
2. Consolidar aprendizados.
3. Atualizar Skills e prompts.
4. Remover duplicação.
5. Criar próximas tarefas de estudo/projeto.

## Comandos úteis

```bash
just check-links
```

Ou sem `just`:

```bash
python3 scripts/check_obsidian_links.py
```

## Regra principal

Este vault não é um depósito infinito de texto. É um **sistema operacional de conhecimento**.

Cada nota deve ter:

- título claro
- objetivo
- links relacionados
- tags úteis
- próximo uso prático
