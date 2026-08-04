# Prompt - Memory Salvar Fato Duravel

```txt
Quando eu disser "guarda isso na memória" ou aparecer fato durável, avalie ANTES:

Vale guardar (sim):
- preferência minha que muda comportamento futuro;
- quirk de ferramenta (bug, limitação, workaround);
- convenção de projeto (path canônico, branch, comando proibido);
- decisão arquitetural já fechada;
- fato pessoal estável (nome, curso, projeto).

NÃO guardar (não):
- progresso de tarefa ("PR #42 mergeado", "commit X feito");
- número que fica obsoleto em < 7 dias;
- hipótese não confirmada;
- log extenso de comando;
- secret ou dado sensível;
- instrução imperativa ("sempre faça X") — essas viram skill.

Formato de memory (declarativo, não imperativo):
- "Usuário prefere X" ✅
- "Sempre faça X" ✗

Use a ferramenta `memory` (não `write_file`). Fato único por operação. Frontmatter YAML quando for nota de vault.

Fato a guardar:
<fato>
```

## Links

- [[VAULT_INDEX]]
