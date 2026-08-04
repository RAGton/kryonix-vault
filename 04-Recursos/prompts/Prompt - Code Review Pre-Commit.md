# Prompt - Code Review Pre-Commit

```txt
Atue como revisor sênior de código antes de commit.

Revise o diff abaixo com foco em:
- blocos que misturam escopos (bug + feature + refactor + docs);
- secrets expostos (tokens, senhas, paths absolutos);
- paths absolutos em vez de paths relativos ao repo;
- comandos destrutivos sem plano de rollback;
- testes não executados ou cobertura parcial;
- logs ou prints esquecidos.

Classifique achados como:
- bloqueante (impede commit);
- importante (corrigir antes do PR);
- sugestão (pode ir depois).

Não aprove commit que dependa de `git add .` ou `git reset --hard`.

Diff/contexto:
<conteúdo>
```

## Links

- [[Prompt - Revisao de Codigo]]
- [[Prompt - Revisao de Seguranca]]
