# Implementação do Motor de Execução `kryx deploy`

Data: 2026-07-14
Agente: Antigravity
Repos afetados:
- repos/kryonix
- repos/kryonix-dev

## Objetivo
Implementar o orquestrador nativo em Rust (`kryx deploy`) para assumir o processo de instalação real de uma máquina usando a configuração declarativa gerada pelo translator, evitando chamadas de shell legadas propensas a erros.

## Contexto consultado
O usuário forneceu as seguintes diretrizes:
1. `kryx deploy` deve receber o arquivo NixOS gerado.
2. Deve orquestrar `disko` e `nixos-install` de maneira resiliente.
3. Tratamento de erros robusto e aborto da pipeline se o `disko` falhar (para evitar tentar formatar arquivos num sistema não pronto).
4. Foram necessárias abstrações para possibilitar testes unitários, não poluindo o file system local do desenvolvedor.

## Mudanças realizadas
- Atualizamos o `cli/mod.rs` do `kryx` para aceitar `config_path` (um Option<String>) via o comando `kryx deploy [config_path]`.
- Em `main.rs`, o argumento desestruturado agora é passado ao `services::deployment::run_deploy`.
- Reescrevemos por completo o `deployment.rs`:
  - Implementada uma abstração de `CommandRunner` e injeção de dependência via `run_deploy_inner`.
  - Fluxo:
    1. Verifica existência da configuração em `/tmp/...`.
    2. Invoca o `disko` nativamente usando `sudo nix run github:nix-community/disko`.
    3. Aborta via `Err` se o `disko` falhar, blindando o restante da execução.
    4. Ao concluir com sucesso, prepara determinísticamente `/mnt/etc/kryonixos/` e injeta a cópia do plano Nix.
    5. Executa `nixos-install --target-directory /mnt --flake .#srv-rag --no-root-passwd`.
- Foram introduzidos testes mock no `deployment.rs` assegurando as ramificações e falhas.
- Adicionado `tempfile` no `Cargo.toml` (`dev-dependencies`) para suporte aos testes de filesystem simulado.

## Commits e branches
- `repos/kryonix` (branch fix/installer-iso-e2e): `feat(kryx): implementar orquestrador nativo de deploy`
- `repos/kryonix-dev` (branch main): `chore(dev): update kryonix submodule pointer`

## Validações executadas
- Execução global de `cargo test` no workspace demonstrou as suítes 100% corretas. (13 testes passados em `kryx`).
- Todos os testes de mock validaram com sucesso que se o Disko falha o nixos-install não é disparado.

## Evidências
- Logs da execução do teste confirmaram o output `Disko falhou. O particionamento não foi concluído. Abortando deploy.` em falhas simuladas.
- O walkthrough do projeto foi atualizado refletindo essas decisões.

## Pendências
- Validar se o flake `.#srv-rag` deve ser defaultado de acordo com a meta-informação enviada pelo frontend ou se o installer possuirá um alvo mais dinâmico futuramente.
- A migração de contexto "Think Server" (se forçará ZFS/Single automaticamente) ainda é uma pendência requisitada pelo usuário para tarefas futuras.

## Próximo passo recomendado
- Realizar a validação "Think Server" no backend (verificar se `isThinkServer` força `topology: single` e `filesystem: zfs`).
- Iniciar a Fase 3: Evolução Gráfica e Limpeza (TUI).
