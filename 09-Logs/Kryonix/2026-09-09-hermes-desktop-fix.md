# Fix: Hermes Desktop "Update Server" Error

Data: 2026-09-09
Agente: Antigravity (IA)
Repos afetados:

- repos/kryonix

## Objetivo
Corrigir erro "We couldn't reach the update server" no Hermes Desktop e erro de truncamento de contexto na interface.

## Contexto consultado
O usuário instalou o backend do Hermes fora do gerenciador de pacotes Nix utilizando o script curl oficial (`install.sh`), que configurou o agente com a versão mais recente da API. No entanto, a interface Hermes Desktop instalada através da configuração do NixOS (`hermes.nix`) usava o pino `v2026.7.7.2` no `flake.nix`. Essa versão mais antiga do cliente omitia o parâmetro `confirm_truncate=true` que o servidor backend atual exige para operações de "rewind", resultando na recusa das chamadas pelo servidor (erro `truncation parameters require confirm_truncate=true`).

## Mudanças realizadas
- `repos/kryonix/flake.nix`: Removida a limitação rígida da versão do `hermes-agent` (de `github:NousResearch/hermes-agent/v2026.7.7.2` para `github:NousResearch/hermes-agent`).
- Atualizado o `flake.lock` (`nix flake update hermes-agent`) para puxar o commit mais recente da branch `main` do Hermes, alinhando a interface Desktop com o servidor de API independente que o usuário instalou.

## Commits e branches
- `repos/kryonix`: `fix(hermes): point hermes-agent flake to latest main branch to align desktop client with api server`
- `kryonix-dev`: `chore(dev): update kryonix submodule pointer for hermes fix`

## Validações executadas
- Bypass executado para avaliar a flake `nix flake check --keep-going --impure` no `repos/kryonix`. Todas as checagens foram aprovadas.

## Próximo passo recomendado
O usuário deve executar `kryx update --force-sync` para sincronizar o `/etc/kryonix` e em seguida `kryx switch` ou equivalente para rebuildar o sistema com a versão atualizada da interface do Hermes.
