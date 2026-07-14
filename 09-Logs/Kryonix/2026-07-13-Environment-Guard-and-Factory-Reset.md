# Implementação do Environment Guard e Factory Reset

Data: 2026-07-13
Agente: Antigravity
Repos afetados:
- repos/kryonix (kryx-cli)

## Objetivo
Criar uma camada de proteção (Environment Guard) no comando `deploy` para impedir sua execução acidental em ambientes já instalados, além de introduzir um fluxo seguro e explícito de restauração de sistema (`factory-reset`).

## Contexto consultado
- O motor `deployment.rs` roda nativamente no instalador, manipulando o `disko` e o `nixos-install`.

## Mudanças realizadas
1. **Environment Guard (`env.rs`)**: Foi implementada a função `check_is_live_iso()` que utiliza heurísticas (procura pela flag `/run/kryonix-live` ou pelo `fstype overlay/squashfs` montado na raiz `/`).
2. **Flag `--force`**: Adicionada como um *break glass* no comando `deploy` para contornar o bloqueio de segurança caso um admin deseje forçar um re-deploy num ambiente hostil/manutenção.
3. **Comando `factory-reset`**: Roteamento adicionado e ligado a uma rotina interativa (`run_factory_reset`) no motor de deployment. Exige confirmação "y" e controla a instrução pro particionador Nix `disko` (modo `zap_create_mount` vs modo `disko`) com base no uso da flag `--preserve-home`.
4. **State Snapshot**: Ao fim da instalação ou reset bem sucedido, injeta-se `/mnt/etc/kryonixos/state.json` com `status` e `timestamp` pra telemetria.

## Commits e branches
- `feat(cli): implement Environment Guard and Factory Reset` no repositório `kryonix`.
- Submodule atualizado no `kryonix-dev`.

## Validações executadas
- `cargo test` validou as dependências (13 testes Ok).
- `cargo check` atestou sintaxe correta e integração de módulos.

## Pendências
Nenhuma.

## Próximo passo recomendado
Integrar o `state.json` gerado para acionar notificações ou atualizar o `status` do servidor RAGOS dentro da malha.
