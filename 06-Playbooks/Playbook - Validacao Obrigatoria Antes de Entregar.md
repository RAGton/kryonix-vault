# Playbook - Validação Obrigatória Antes de Entregar

Este playbook define os critérios rígidos de aceitação para qualquer alteração no sistema de conhecimento LightRAG / Kryonix Brain.

## Bateria Obrigatória
Sempre execute o comando abaixo antes de declarar uma tarefa como concluída:

```powershell
.\rag.bat test all
```

Este comando valida:
1. **Pytest**: Testes unitários e de integração.
2. **Doctor**: Integridade do ambiente e arquivos críticos (GraphML).
3. **Stats**: Consistência entre Grafo e Bancos Vetoriais.
4. **MCP**: Registro e funcionalidade do servidor MCP.
5. **Ollama**: Conectividade local com modelos de LLM e Embedding.
6. **Search Smoke**: Validação de busca híbrida com síntese.
7. **Graph Smoke**: Validação de carregamento e estrutura do grafo.
8. **MCP RPC**: Validação de saída limpa para comunicação stdio.

## Erros Comuns e Soluções

### GraphML Corrompido ou Vazio
Se o `doctor` ou `stats` falhar reportando erro no `graphml`:
- **Causa**: Queda de energia, interrupção brusca ou erro de escrita.
- **Reparo**: `.\rag.bat repair-graph`

### Divergência de Stats (entities=0)
Se `stats` mostra 0 entidades mas o GraphML parece existir:
- **Causa**: O arquivo pode estar com 0 bytes ou XML inválido.
- **Reparo**: `.\rag.bat repair-graph` seguido de `.\rag.bat repair-vdb` se necessário.

### MCP Quebrado
Se o MCP falhar ou não responder:
- **Causa**: Stray prints em `server.py` ou erro de importação.
- **Validar**: `.\rag.bat mcp-check`

## Regra de Entrega
**NÃO ENTREGUE** se qualquer teste falhar. Corrija o problema real, nunca silencie exceções com `try-except` vazios. A resiliência do cérebro é a prioridade número 1.
