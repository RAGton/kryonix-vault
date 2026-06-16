---
title: 07 Aprendizados e Regras Operacionais
date: 2026-06-14
type: lessons-learned
status: stub
tags: [kryonix, aura, lessons, regras, operacional]
project: Kryonix
parent: "[[00 Index]]"
---

# 07 Aprendizados e Regras Operacionais

## Objetivo

Consolidar regras práticas e aprendizados da sessão Aura 2026-06 que devem
guiar futuras sessões de trabalho no projeto Kryonix.

## Resumo

Stub criado durante a reorganização do vault (Fase 4, 2026-06-15).
Formato TOON para permitir leitura densa de regras com baixo custo de token.
Conteúdo real a ser preenchido a partir da memória da sessão Aura.

## Quando usar

- Ao iniciar uma nova sessão longa no projeto Kryonix (ou projeto similar).
- Ao revisar PRs e PR drafts — aplicar regras antes de aprovar.
- Ao treinar novo agente / colaborador no fluxo DEV/PROD Kryonix.

## Procedimento / Conteúdo

### Regras operacionais (TOON)

```toon
id,  categoria,  regra,  origem,  severidade
R01, git,        nunca usar git add . — sempre paths explicitos, AGENTS.md, critico
R02, git,        nunca git reset --hard ou git clean -fdx, AGENTS.md, critico
R03, git,        commits pequenos e escopados, AGENTS.md, alta
R04, dev-prod,   DEV=/home/rocha/kryonix/kryonix e PROD=/etc/kryonix — fluxo explicito, sessao-aura, alta
R05, dev-prod,   PROD sincroniza via sudo git pull --ff-only origin main, sessao-aura, alta
R06, nixos,      nix build .#kryonix-installer --no-link -L --show-trace, sessao-aura, alta
R07, nixos,      nunca nixos-rebuild switch sem aprovacao humana, AGENTS.md, critico
R08, nixos,      nunca --impure ou --accept-flake-config, AGENTS.md, critico
R09, secrets,    nunca commitar secret, token, chave ou credencial, AGENTS.md, critico
R10, secrets,    nunca logar credencial/PII, PROMPT_MASTER, critico
R11, instalacao, nunca disko/mkfs/nixos-install sem aprovacao, AGENTS.md, critico
R12, instalacao, nunca reboot/poweroff sem aprovacao, AGENTS.md, critico
R13, instalacao, kryonix switch proibido, AGENTS.md, critico
R14, branding,   identidade KryonixOS e padrao do sistema, PR #71, media
R15, branding,   terminal identity segue KryonixOS Identity, PR #80, media
R16, token,      max 3 file edits/round e max 2 tests/round, profile-economia, alta
R17, token,      parar a cada 10 min para confirmar com humano, profile-economia, alta
R18, ci,        workflows quebrados sao debt — issue #79 aberta, issue-79, media
```

### Aprendizados qualitativos (TOON)

```toon
id,  aprendizado,  contexto,  impacto
L01, fluxo DEV→PR→merge→PROD via ff-only mostrou-se confiavel, sessao-aura, base para repetir
L02, branches de preservacao historica (#65-69) dao seguranca para experimentar, sessao-aura, acelera onboarding
L03, identidade KryonixOS so estabiliza com PR #71 (default) + PR #80 (terminal), sessao-aura, evitar fragmentacao
L04, CI debt (#79) acumula rapido — tratar em onda, sessao-aura, previne degradao continua
L05, mensagens de commit semanticas (chore/feat/fix/refactor) facilitam revisao, AGENTS.md, qualidade historica
```

## Checklist

- [ ] Adicionar regra R19+ a partir de cada nova sessão Aura.
- [ ] Adicionar aprendizado L06+ sempre que um workaround vira padrão.
- [ ] Revisar regras a cada milestone Kryonix (semestral ou após grande refactor).

## Riscos

- Lista TOON desatualizada vira documentação morta. Regra "viva": só regra
  que ainda se aplica fica na tabela; regra obsoleta vai pra tabela
  `historico` (abaixo).
- Severidade "critico" implica bloqueio automatico em revisão humana.
  Não usar para regras que são preferencias.

### Histórico de regras removidas (TOON)

```toon
id,  regra,  removida_em,  motivo
H01, exemplo: regra X que nao se aplica mais, 2026-06-15, contexto mudou
```

## Links relacionados

- [[00 Index]] · [[01 DEV-PROD Layout]] · [[02 PRs Mergeados]] · [[03 Skills git-dev-prod]]
- [[04 Auditoria Boot Identity P3]] · [[05 Backlog P3 P4 P5]] · [[06 CI Debt Issue 79]]
- [[02-Areas/Kryonix/kryonix-meta/ACTIVE_WORK]] · [[02-Areas/Kryonix/kryonix-meta/DECISIONS]]
- [[02-Areas/Kryonix/operations/Safe Git Workflow]]
- [[AGENTS]] · [[PROMPT_MASTER]]

## Próxima ação

Preencher tabela `Regras operacionais` com aprendizados reais da sessão
Aura a partir de [[02-Areas/Kryonix/kryonix-meta/DECISIONS]] e logs
em `09-Logs/sessions/2026-06-14/`.
