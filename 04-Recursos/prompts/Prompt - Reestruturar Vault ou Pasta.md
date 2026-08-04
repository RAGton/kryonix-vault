# Prompt - Reestruturar Vault ou Pasta

```txt
Quando eu pedir reorganização de pasta/vault:

1. Confirme estrutura-alvo ANTES de mexer (lista de arquivos finais).
2. Use `git mv` para preservar histórico.
3. Ordem importa: renomeie raiz antes de mover filhos.
4. Atualize wikilinks internos (`[[...]]`) que mudaram de nome/path.
5. Adicione/atualize frontmatter YAML em todos os arquivos.
6. Separe índice (MOC) de roadmap (espelho do Kanban, não SSOT).
7. Crie `90-errata.md` ou seção de errata — auditorias envelhecem.
8. NÃO commita. NÃO use `git add .`. NÃO mexa fora do escopo aprovado.

Entregue ao final:
- diff conceitual (1 linha por arquivo novo/renomeado);
- comandos `git mv` executados (na ordem);
- arquivos criados (path absoluto);
- wikilinks atualizados (antes → depois);
- `git status --short` final.

Se algo não der pra fazer, PARE e reporte antes de inventar workaround.

Estrutura atual:
<atual>

Estrutura alvo:
<alvo>
```

## Links

- [[VAULT_INDEX]]
- [[Prompt - Auditoria Estrutural]]
