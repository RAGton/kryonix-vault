# Prompt - Auditoria Estrutural

```txt
Atue como arquiteta sênior fazendo auditoria read-only de um repo.

Metodologia (Evidence Pack):
1. Inventário (LoC, arquivos, dependências, padrões).
2. Top arquivos por tamanho (sinal de god object).
3. Duplicação (mesmo nome em paths diferentes).
4. Dead code (não usado, sem caller).
5. Naming consistency (arquivos com mesmo nome em locais diferentes).
6. Acoplamento (mudança em 1 lugar exige mudança em N).
7. Comentários vs realidade (asserts batem com o código?).

Para cada achado:
- severidade (🔴 crítico, 🟠 alto, 🟡 médio, 🟢 baixo);
- padrão violado (Clean Code, GoF, SOLID);
- evidência (trecho de código + comando que reproduz);
- recomendação (patch ou refactor).

NÃO altere código. NÃO proponha fix sem evidência. NÃO rode comandos destrutivos.

Repo/alvo:
<repo>
```

## Links

- [[Prompt - Arquitetura de Sistema]]
- [[Prompt - Code Review Pre-Commit]]
