# AI Feature Migration Audit

## Motivo

Antes de mover `features/ai.nix` para a árvore canônica (`modules/nixos/features/ai.nix`), era necessário entender os impactos, namespaces e dependências ocultas, dado o alto risco envolvendo GPU/CUDA, portas, secrets e pastas locais como `/var/lib/kryonix`.

## Arquivos analisados

- `features/ai.nix` (Legado)
- `modules/nixos/features/ai.nix` (Canônico alvo atual)
- `modules/nixos/features/schema.nix` e `registry.nix`
- Perfil downstream `glacier` e referências a ports/secrets/storages.

## Descobertas principais

- A feature legada encapsula multiplas áreas: LightRAG, Ollama, servidor Brain e portas customizadas.
- A árvore canônica atual separa tudo individualmente: `ollama.enable`, `openWebui.enable`, `neo4j.enable`, `lightrag.enable`, `kryonixBrain.enable`.
- O schema já prevê a separação em clients e servers (`kryonix.features.ai.brain.client.enable`, `kryonix.features.ai.brain.server.enable`, etc).
- As chaves secretas são manipuladas via wrappers `.env`, o que reduz o risco no Git, mas exige cuidado na inicialização de serviços.
- Nenhum serviço GPU/CUDA está diretamente acoplado na raiz do `ai.nix` legado; `glacier` faz isso no nível de hardware/GPU isoladamente, o que é ótimo.

## Riscos

- Migrar "cegamente" ativando serviços Neo4j ou Ollama em máquinas clientes (como Inspiron) acidentalmente.
- Conflitos nas definições de portas locais entre o design legado e a declaração canônica modular.

## Recomendação

- A migração deve ser fatiada (Brain Client/Server, Ollama, Neo4j, LightRAG).
- Não misturar F5-TTS, MCP e configurações CUDA neste mesmo passo.
- Criar a fundação canônica primeiro sem tocar no legado, e então transformar o legado em um wrapper transitório até ser removido.

## Próximo PR técnico sugerido

1. Refatorar namespaces e consolidar as opções individuais no schema e em `modules/nixos/features/ai.nix` (Brain client/server, Ollama, Neo4j).
2. Manter `features/ai.nix` como um compat layer apontando para essas opções.
