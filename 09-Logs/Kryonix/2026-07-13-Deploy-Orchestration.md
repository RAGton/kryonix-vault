# Refatoração Dinâmica do Motor de Deploy (Kryx)

Data: 2026-07-13
Agente: Antigravity
Repos afetados:
- repos/kryonix (kryx-cli)

## Objetivo
Refatorar a orquestração do `kryx deploy` para suportar dinamicamente os targets de Flake gerados (`--hostname`), acionar o Disko através de um arquivo injetado com modo `destroy,format,mount`, e espelhar o arquivo `.nix` gerado para a raiz estrutural `/mnt/etc/kryonixos/systems/`.

## Mudanças realizadas
1. **Adição do parâmetro `--hostname` (`-h`)**: No `cli/mod.rs`, permitindo a definição dinâmica do target de Flake pro NixOS Install.
2. **Adaptação do Disko (`deployment.rs`)**: Foi modificado para passar o parâmetro absoluto (o próprio arquivo de configuração) invés do módulo `.flake` de forma rígida. Modo substituído para `destroy,format,mount`.
3. **Injeção de Path Estrutural**: O método `copy_config` foi alterado para criar `/mnt/etc/kryonixos/systems` e copiar o `generated-install-config.nix` determinísticamente pra dentro, em vez de na raiz solta.

## Validações executadas
- Testes de domínio, tradutor e orquestrador no `cargo test` validaram sucesso absoluto nas injeções.
- O I/O do Rust foi verificado e já possuia suporte natural a output vivo pro console (via `Stdio::inherit()`), impedindo locks de buffers na etapa crítica.

## Pendências
- O layout de particionamento deve ser perfeitamente testado numa máquina virtual física para garantir que a transição entre o disko via Nix direct run e a string dinâmica está livre de artefatos residuais.
