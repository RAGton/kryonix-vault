# RAG Pipeline Interno (Kryonix Brain)

## O que é
O motor de inteligência e recuperação do Kryonix, responsável por transformar consultas em linguagem natural em respostas técnicas precisas baseadas no grafo de conhecimento e no armazenamento vetorial do projeto.

## Como funciona
O pipeline utiliza uma arquitetura de **Grounding Semântico com Expansão de Grafo e Ranking Vetorial**.

### Etapas do Pipeline:
1. **Query Planning**: Analisa se a pergunta é técnica ou conceitual para decidir o modo de busca (`hybrid` vs `global`) e o número de "hops" no grafo.
2. **Semantic Expansion**: Sonda o banco de entidades para adicionar termos técnicos relacionados à consulta original.
3. **Graph Retrieval (Multi-hop)**: Recupera entidades iniciais e expande a busca em até 2 níveis de conexão no grafo (hops), capturando dependências e arquiteturas relacionadas.
4. **Manual Grounding**: Mapeia as entidades e relações encontradas para seus respectivos "chunks" de texto originais no sistema de arquivos.
5. **Semantic Ranking**: Implementado via `numpy` (similaridade de cosseno), ordena os chunks recuperados por score de relevância vetorial. Chunks do Vault têm peso equalizado com chunks do repositório.
6. **LLM Synthesis**: O modelo local (Qwen2.5-Coder) gera a resposta final usando o contexto rankeado. O sistema força o uso do contexto via `ANSWER_SYSTEM_PROMPT` para minimizar alucinações.

## Uso prático
O pipeline é acessado via CLI `rag` ou via MCP (Model Context Protocol) no Obsidian.

### Comandos de Diagnóstico:
- `.\rag.bat diagnostics`: Mostra a saúde do grounding e estatísticas de cobertura.
- `.\rag.bat search "termo" --verbose`: Exibe scores de ranking e as entidades expandidas.

## Exemplos
### Fluxo de Recuperação para "Hyprland Config"
1. **Query**: "Como configurar o Hyprland?"
2. **Expansion**: Adiciona "Wayland", "NixOS", "Caelestia".
3. **Graph Hops**: Hyprland -> depend_on -> Wayland; Hyprland -> configured_by -> modules/nixos/desktop.
4. **Ranking**: Chunks de `default.nix` do desktop ganham score ~0.85; Chunks sobre Wayland genérico ganham score ~0.60.
5. **Resultado**: O usuário recebe a instrução específica dos módulos NixOS do repositório.

## Problemas comuns
- **Semantic Loss**: O grafo tem nós mas não tem relações, resultando em respostas rasas. Resolvido com `rag graph heal`.
- **Inconsistência de VDB**: Os vetores não batem com o conteúdo do grafo. Corrigido com `rag repair-vdb`.
- **Alucinação por Falta de Contexto**: O pipeline aborta se o grounding resultar em 0 chunks para proteger a precisão.

## Boas práticas
- Mantenha o grafo "saudável" rodando indexações incrementais.
- Use `rag top` para verificar quais entidades são os "hubs" centrais do seu conhecimento.
- Documente novos serviços de forma técnica no Vault para facilitar a extração de relações densas.

## Links
- [[01-MOCs/Mapa - IA e Agentes]]
- [[02-Areas/IA e Agentes/Graph + Vector Hybrid Search]]
- [[packages/kryonix-brain-lightrag/kryonix_brain_lightrag/rag.py]]
