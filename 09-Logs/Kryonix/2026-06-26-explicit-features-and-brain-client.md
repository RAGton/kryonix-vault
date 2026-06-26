# Explicit Features Mapping and Brain Client Address

Data: 2026-06-26
Agente: Antigravity
Repos afetados:
- kryonix (core)
- kryonixos (downstream)

## Objetivo
Adicionar `serverAddress` na schema de `ai.brain.client` e tornar explícitas todas as features do Canonical Schema (`kryonix.features.*.enable = false` vs `true`) nos arquivos downstream (`inspiron`, `inspiron-nina` e `glacier`).

## Mudanças realizadas
1. **Core (`kryonix`)**: Adicionado a opção `serverAddress` para `kryonix.features.ai.brain.client` em `modules/nixos/features/schema.nix`, permitindo indicar com quem o cliente deve conversar.
2. **Downstream (`kryonixos`)**:
   - `flake.lock` atualizado apontando para o core atualizado.
   - Os hosts `glacier`, `inspiron` e `inspiron-nina` agora possuem um bloco explícito setando `kryonix.features.*.enable` para todas as features disponíveis no schema. As não ativadas pelo host estão explicitamente como `false`, garantindo visibilidade total do estado das features.
   - `inspiron/default.nix` agora declara `kryonix.features.ai.brain.client.serverAddress = "glacier";`.

## Validações executadas
- Avaliações em dry-run `nix build ... --dry-run` para os três hosts e `nix flake check`.
- Validação bem sucedida sem erros de avaliação ou conflitos.

## Próximo passo recomendado
Validar se há necessidade de provisionar o endereço DNS ou IP Tailscale do servidor "glacier" de forma estrita no backend do `ai.brain.client`.
