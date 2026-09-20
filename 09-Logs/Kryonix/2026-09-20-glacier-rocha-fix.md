# Correção do erro de avaliação do usuário legado 'rocha' no Glacier

Data: 2026-09-20
Agente: Antigravity
Repos afetados:
- kryonixos
- kryonix

## Objetivo
Resolver o erro de `flake check` no host Glacier que reclamava sobre a ausência de assertions de `isNormalUser` e grupo para `users.users.rocha`. O usuário `rocha` foi renomeado para `garton` na configuração principal.

## Contexto consultado
O usuário informou que as configurações do `glacier` deveriam ser limpas de referências antigas a `rocha`, já que o usuário foi alterado para `garton`.

## Mudanças realizadas
1. Limpeza em `kryonixos`:
   - Remoção da declaração legada do `rocha` no arquivo `users.nix`.
   - Remoção da referência a `rocha` nos comentários de permissão do podman em `hosts/glacier/hermes.nix`.

2. Correção Root Cause (upstream `kryonix`):
   - Ao executar o `flake check` downstream, o motor principal acessava remotamente (`github:RAGton/kryonix`) o flake upstream.
   - Constatou-se que vários módulos no `kryonix` possuíam hardcodes para o usuário `"rocha"` ou geravam variáveis undefined quando se usava dynamic mappings.
   - Foram substituídos hardcodes por `${userConfig.name}` em:
     - `modules/nixos/services/kryonix-state.nix` (tmpfiles do Vault)
     - `modules/home-manager/programs/git/default.nix` (SSH User mapping)
     - `modules/nixos/features/mcp.nix` (Caminhos de repositórios do MCP)
     - `modules/nixos/features/hermes.nix` (Caminho fallback do Hermes)
   - Adicionada a dependência do argumento `userConfig ? { name = "garton"; }` nestes módulos para evitar o erro `undefined variable 'userConfig'`.

## Commits e branches
- `kryonix`: `fix(users): remove legacy rocha references and use dynamic userConfig.name`
- `kryonix`: `fix(mcp): add userConfig argument to fix undefined variable`
- `kryonix`: `fix(hermes): add userConfig argument to fix undefined variable`
- `kryonix`: `fix: add userConfig argument to fix undefined variable`
- `kryonixos`: `chore(dev): update kryonix inputs and remove legacy rocha user`
- `kryonix-dev`: `chore(dev): update kryonix and kryonixos submodule pointers`

## Validações executadas
- `nix flake check --keep-going --impure` em `kryonixos` retornou `all checks passed!`.

## Evidências
- Sem dependência forçada em `rocha`
- O `flake check` foi finalizado com sucesso.

## Pendências
- Nenhuma pendência referente a este fix.

## Próximo passo recomendado
- Realizar deploy (switch) da configuração atualizada no Glacier para aplicar a limpeza da infraestrutura e ativação do `gaming.nix`.
