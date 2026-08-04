# Prompt - Commit Canonico Kryonix

```txt
Gere mensagem de commit no padrão Kryonix.

Formato:
<tipo>(<escopo>): <descrição curta em português, imperativo, sem ponto final>

Tipos válidos:
- feat: feature nova
- fix: correção de bug
- refactor: mudança que nem corrige bug nem adiciona feature
- docs: só documentação
- chore: manutenção (deps, configs, CI)
- test: só testes
- security: correção de segurança
- perf: melhoria de performance

Regras do projeto Kryonix:
- SEMPRE `git add <caminho/explícito>` — nunca `git add .`
- 1 commit = 1 escopo (não misturar bug + feature + docs)
- mensagem em português, imperativo, < 72 chars na primeira linha
- corpo (opcional) explica o PORQUÊ, não o quê
- referências a KCR ou PR quando aplicável

Contexto da mudança:
<contexto>
```

## Links

- [[VAULT_INDEX]]
