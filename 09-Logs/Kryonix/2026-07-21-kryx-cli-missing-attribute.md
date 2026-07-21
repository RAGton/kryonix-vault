# Resolução do erro de Flake 'attribute missing' após extração do kryx-cli

Data: 2026-07-21
Agente: Antigravity
Repos afetados:
- repos/kryonix
- repos/kryonixos

## Objetivo
Corrigir a quebra da build do NixOS causada por dependências residuais no módulo `programs.kryonix.package` que ainda tentavam extrair `kryonix` de `outputs.packages`, sendo que a CLI em Rust já havia sido externalizada sob a chave `kryx`.

## Mudanças realizadas
1. Atualizado `modules/nixos/programs/kryonix/default.nix` no repositório `kryonix`. O default package foi mudado de `outputs.packages.${system}.kryonix` para `outputs.packages.${system}.kryx`.
2. Atualizado `flake/checks.nix` que injetava `inputs.self.packages.x86_64-linux.kryonix` (no `cliHelpCheck`). Foi substituído também para `kryx`.

## Validações executadas
- Comando `nix flake check /home/rocha/kryonix-dev/repos/kryonix` está limpo.
- `nix build --no-link` simulando o host Inspiron passa a validar todo o contexto NixOS sem erros de atributo não encontrado.

## Pendências
- O módulo interno continua nomeado `programs.kryonix`. Isso não afeta a compilação, é apenas a variável NixOS, mas em refatorações futuras pode-se mudar para `programs.kryx` por sanidade, porém deixado como está para preservar retrocompatibilidade de `hosts` existentes.

## Próximo passo recomendado
Garantir que a máquina local do rocha recupere o commit e consiga usar o comando de switch sem o erro de avaliação.
