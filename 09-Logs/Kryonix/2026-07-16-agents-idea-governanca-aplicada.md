# Aplicação da revisão de governança — AGENTS.md e IDEA.md

Data: 2026-07-16
Agente: Aura
Repos afetados:

- kryonix-dev
- kryonix-vault

## Objetivo

Aplicar ao `AGENTS.md` do workspace as recomendações de governança registradas para reduzir risco de commits/pushes automáticos, evitar varredura ampla do Vault e tornar explícita a natureza do `kryonix-dev` como workspace orquestrador com submódulos.

## Contexto consultado

- `AGENTS.md` do workspace
- `IDEA.md` existente
- `repos/kryonix-vault/09-Logs/Kryonix/2026-07-16-agents-governanca-review.md`
- Skills `kryonix-safe-executor` e `obsidian`

## Mudanças realizadas

- Reescrito `AGENTS.md` do workspace com:
  - definição de `kryonix-dev` como workspace orquestrador;
  - seção de precedência de instruções;
  - classificação de tarefas (`Trivial`, `Relevante`, `Crítica`);
  - estados de conclusão permitidos;
  - política explícita de autorização para commit/push/PR/pointer;
  - política de branch sem assumir `main`;
  - regra para submódulo em detached HEAD;
  - preflight multi-repo com `git submodule status --recursive`;
  - ordem segura para commit no repo filho e atualização de pointer;
  - uso seletivo do Vault;
  - guarda para `scripts/capture_evidence.sh` e `EVIDENCE_BLOCKED`;
  - fallback `MCP_TEST_UNAVAILABLE` para MCP indisponível;
  - matriz de repositórios com fonte de verdade e validação principal.
- Regravado `IDEA.md` com resumo curto para Hermes, mantendo o texto recomendado.

## Commits e branches

- Nenhum commit realizado.
- Branch observada do workspace: `main...origin/main [ahead 7]`.

## Validações executadas

- `git diff --check -- AGENTS.md IDEA.md` — passou.
- `git diff --stat -- AGENTS.md IDEA.md` — `AGENTS.md | 448`, 337 inserções e 111 remoções.
- `git status --short -- AGENTS.md IDEA.md SOUL.md` — `AGENTS.md` modificado e `IDEA.md` novo/untracked.
- `git -C repos/kryonix-vault diff --check -- <logs de governança>` — passou.
- Busca escopada por padrões removidos (`git push origin main`, regra absoluta de Vault obrigatório e leitura ampla do Vault) — não encontrou os padrões perigosos; restaram apenas caminhos permitidos de destino/log/canônico.

## Evidências

- `AGENTS.md` agora não prescreve `git push origin main` como fluxo obrigatório.
- `AGENTS.md` deixa explícito que commit, push, PR e pointer exigem autorização.
- `IDEA.md` contém apenas resumo curto, não o `AGENTS.md` inteiro.

## Pendências

- Verificar se `SOUL.md` deve ser criado na raiz, já que `AGENTS.md` e `IDEA.md` agora o referenciam.
- Revisar com Gabriel antes de tratar o documento como `CANONICAL`.

## Próximo passo recomendado

Rodar diff escopado, revisar o texto final e só então decidir se cria `SOUL.md` ou se a identidade da Aura continuará apenas na configuração Hermes.
