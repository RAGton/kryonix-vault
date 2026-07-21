---
title: git-github-operacional
type: skill
status: ativo_revisao_pendente
purpose: Aplicar Git e GitHub operacionalmente em projetos reais do Kryonix, baseado em Casa do Código
validade: revisao_humana_pendente
tipo: skill
projeto: kryonix
componente: versionamento
fonte_verdade: livro (Controlando Versões com Git e GitHub, Casa do Código)
confianca: media
rag: baixo_peso
graph: true
validado_em: 2026-06-20
operation_mode: inspiron-local-hermes-openrouter
author: aura
source_book: "Controlando Versões com Git e GitHub (Casa do Código)"
source_path: 04-Recursos/livros/
tags: [kryonix, skill, git, github, versionamento, books]
---

# git-github-operacional

## Objetivo

Aplicar Git e GitHub de forma operacional e segura no contexto do Kryonix, baseado no livro **Controlando Versões com Git e GitHub** (Casa do Código). Foco em fluxos de trabalho reais: local, remoto, branches, PRs, conflitos.

## Resumo

O livro cobre 11 capítulos do básico (init, add, commit) ao avançado (rebase, cherry-pick, hooks). A skill condensa em 5 fluxos operacionais + procedimentos para situações problemáticas + checklist de segurança.

> **⚠️ Amostragem parcial** — Esta skill é derivada de amostragem limitada (apenas 15 páginas por livro + metadados via `pdfinfo`) e consolidação de múltiplas fontes. **NÃO é verdade operacional do Kryonix.** Requer validação prática em uso real antes de ser promovida para confiança alta. Use como checklist orientativo; para decisão crítica, consulte o livro original.

## Quando usar

- Ao criar commit no kriptonix / kryonixos / kryxd / kryonix-vault.
- Ao resolver conflito de merge.
- Ao criar/revisar PR.
- Ao precisar desfazer algo no git (revert, reset, checkout).
- Ao configurar git hooks para o projeto.

## Quando não usar

- Não serve para monorepo tools (nx, turborepo).
- Não serve para gitOps (Flux, ArgoCD) — usar skills NixOS-specific.


## Procedimento

Use o fluxo apropriado conforme a situação. Os cinco fluxos operacionais estão detalhados em **Princípios-chave consolidados** acima, numerados:

1. **Trabalho local simples** — fluxo do dia-a-dia (status → add → commit → pull → push).
2. **Feature branch + PR** — criação de branch local + push + abertura de PR.
3. **Resolver conflito de merge** — quando pull falha por conflito.
4. **Desfazer commit local** (não pushado) — reset/checkout.
5. **Desfazer commit já pushado** (SEGURO) — `git revert` (sempre preferir).

Ordem de segurança:

```txt
antes de qualquer mudança grande:
  1. git status              (entender o estado)
  2. git stash               (guardar trabalho em progresso se necessário)
  3. git pull origin main    (sincronizar)
  4. executar a operação
  5. git status novamente    (confirmar resultado)
```

## Princípios-chave consolidados

### Estrutura fundamental

```txt
Working dir (arquivos editados)
   ↓ git add
Staging area (preparados para commit)
   ↓ git commit
Local repo (.git/ — commits persistem)
   ↓ git push
Remote repo (GitHub, etc.)
```

### Comandos de cada dia

```txt
git status            → estado atual
git log --oneline     → histórico resumido
git diff              → mudanças não-stageadas
git diff --cached     → mudanças stageadas
git add <file>        → preparar arquivo específico
git commit -m "..."   → commit local
git pull --ff-only    → atualizar sem criar merge commits
git push              → enviar commits locais
```

### Fluxo 1: trabalho local simples

```txt
1. git status                  (ver estado)
2. git add <files-específicos> (nunca `git add .` no Kryonix!)
3. git diff --cached           (conferir o que vai no commit)
4. git commit -m "<tipo>: <mensagem>"
5. git pull --ff-only origin main
6. git push origin main
```

### Fluxo 2: feature branch + PR

```txt
1. git checkout -b feature/<nome>
2. (editar, commitar)
3. git push origin feature/<nome>
4. (abrir PR via web ou `gh pr create`)
5. (revisão, ajustes)
6. (merge via GitHub — "squash and merge" ou "merge commit")
```

### Fluxo 3: resolver conflito de merge

```txt
1. git pull origin main (falha com conflito)
2. abrir arquivos marcados com <<<<<<< HEAD / ======= / >>>>>>> 
3. resolver manualmente
4. git add <arquivos-resolvidos>
5. git commit (continua o merge)
6. git push
```

### Fluxo 4: desfazer commit local (não pushado)

```txt
git reset HEAD~1                       # mantém mudanças no working dir
git reset --hard HEAD~1                # DESCARDA mudanças (cuidado!)
git checkout -- <arquivo>              # descarta de 1 arquivo
```

### Fluxo 5: desfazer commit já pushado (SEGuro)

```txt
git revert <commit-sha>                # cria NOVO commit que desfaz o anterior
                                         # histórico preservado — SEMPRE preferir
```

### Mensagens de commit (conventional)

```txt
feat(installer): adiciona detecção de GPU NVIDIA
fix(flake): corrige hash do input nixpkgs
docs(readme): atualiza seção de instalação
chore(ci): atualiza versão do cachix-action
refactor(module): extrai lógica de detecção de hardware

[escopo opcional]: <tipo>: <descrição concisa>
```

### Hooks úteis

```txt
pre-commit:  validar lint antes do commit (ex: nix flake check)
commit-msg:  validar formato da mensagem (conventional commits)
pre-push:    rodar testes básicos antes de push
```

## Checklist — commit seguro no Kryonix

```txt
- [ ] Sem `git add .` (adicionar arquivos específicos)
- [ ] Sem secrets no staging (grep .env, token, password)
- [ ] Mensagem no formato conventional (feat/fix/docs/chore/refator)
- [ ] Mensagem em português (ou inglês — mas consistente)
- [ ] diff revisado (git diff --cached)
- [ ] Pull feito antes de push (--ff-only de preferência)
- [ ] CI verde (se aplicável)
- [ ] Sem arquivos gerados (result, target/, bin/)
```


## Aplicação no Kryonix

```txt
Cenário: commit no kriptonix-dev (DEV core /home/rocha/kryonix/kryonix)
1. git status                              (ver o que mudou)
2. git diff                                (revisar mudanças antes de commitar)
3. git add <arquivos-específicos>          # NUNCA `git add .`
4. git commit -m "feat(installer): adiciona detecção de GPU"
5. git pull --ff-only origin main          (sincronizar antes do push)
6. git push origin main

Para kryonixos (DEV-user): fluxo idêntico mas o remote é github.com/RAGton/Kryonixos.
Para PROD /etc/kryonix: SOMENTE LEITURA — nunca commitar direto.
Para /etc/kryonixos (ainda não existe): SKIPPED_BY_OPERATION_MODE.
```

## Riscos

- `git push --force`: reescreve histórico do remote (evitar a todo custo).
- `git reset --hard` em branch compartilhada: perde commits de outros.
- `git add .` sem revisar: commita .env, IDE files, binários.
- Merge sem resolver conflito direito: código quebrado.

## Token-saving mechanism

Consolida 1 livro (209 páginas) em 5 fluxos + comandos + checklist. Uso: consulta rápida antes de git.

## Base prompt

```txt
Atue como desenvolvedor com domínio profundo de Git.
Dada a situação abaixo, aplique a skill [[04-Recursos/skills/livros/git-github-operacional/SKILL]].
Produza: (1) comando apropriado, (2) explicação do que faz,
(3) risco associado, (4) alternativa mais segura se houver.
```

## Livro-fonte

```txt
04-Recursos/livros/Controlando Versões com Git e GitHub - Autor (Casa do Código).pdf
```

## Links relacionados

- [[04-Recursos/skills/livros/devops-ci-cd-practices/SKILL]]
- [[04-Recursos/skills/livros/clean-code-professionalism/SKILL]]
- [[01-MOCs/Mapa - Biblioteca]]
- [[01-MOCs/Mapa - NixOS e Infra Declarativa]]
