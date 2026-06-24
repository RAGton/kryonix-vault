# Migração do Glacier para kryonix.features.remote.ssh

Data: 2026-06-24
Agente: Antigravity/Aura
Repos afetados:

- `repos/kryonix` (PR #102 aberto - merge pendente)
- `repos/kryonixos` (PR #16 aberto - Migrar Glacier)

## Objetivo

Ativar a feature declarativa `kryonix.features.remote.ssh` no host Glacier (downstream), utilizando a implementação upstream recém-criada (mas ainda não merjada na `main`).

## Contexto Consultado

- A regra arquitetural central: "Upstream decide quais features existem. Downstream decide quais features estão ativas."
- O PR #102 introduziu a feature, mas possuía um bug: o `features/default.nix` foi indevidamente referenciado em vez do `modules/nixos/features/default.nix`.
- No host Glacier, a porta `2224` e as políticas SSH estavam duplicadas/difusas entre `glacier-base.nix` (upstream genérico) e `rve-compat.nix` (downstream específico).

## Mudanças Realizadas

1. **Correção Upstream (Branch `pr-15-remote-ssh-feature` / PR #102):**
   - Inserido `../../modules/nixos/features` no `hosts/common/default.nix` para garantir que o upstream exporte a feature e o downstream possa avaliá-la.

2. **Ativação Downstream (Branch `pr-16-glacier-remote-ssh-feature` / PR #16):**
   - Adicionado o bloco `kryonix.features.remote.ssh = { ... }` em `hosts/glacier/default.nix`.
   - Adicionado `programs.seahorse.enable = false;` no Glacier para resolver um conflito de definição do `programs.ssh.askPassword` entre o `ksshaskpass` (KDE Plasma) e o `seahorse` (forçado pelo `common/default.nix`), o que impedia a avaliação do build.
   - Atualizado localmente o `flake.lock` no downstream, apontando a referência `kryonix` para o commit correspondente da branch `pr-15-remote-ssh-feature` do upstream, permitindo a validação do pull request downstream independentemente do merge upstream.

## Validações Executadas

1. Avaliação do `nix eval` apontou que a declaração da feature assumiu os valores corretos.
2. `nix flake check` rodou no repositório `kryonixos` com sucesso.
3. Conflito NixOS detectado durante construção completa (Seahorse vs Plasma askPassword) foi mapeado e resolvido.
4. `nix build .#nixosConfigurations.glacier.config.system.build.toplevel --dry-run` finalizou com sucesso (árvore limpa e renderizável sem conflitos).

## Commits e Branches

- **Upstream (`RAGton/kryonix`):** `fix(common): load modules/nixos/features in hosts/common` (commit `105dff5be`).
- **Downstream (`RAGton/kryonixos`):** `feat(host): enable remote SSH feature on Glacier` (commit `07218ce`), branch `pr-16-glacier-remote-ssh-feature`.
- **Pull Request Downstream:** [#7](https://github.com/RAGton/Kryonixos/pull/7).

## Pendências

- O bloco manual `services.openssh` ainda está presente no profile upstream `profiles/glacier-base.nix`.
- O bloco manual `services.openssh` ainda está presente no profile downstream `rve-compat.nix`.

## Próximo Passo Recomendado

1. Fazer o **merge do PR #102** (`pr-15-remote-ssh-feature`) no upstream.
2. Atualizar o downstream `Kryonixos` (`flake.lock`) para usar a `main` novamente.
3. Fazer o **merge do PR #16** no downstream.
4. (Pós-validação em Glacier) Criar **PR upstream de limpeza** removendo `services.openssh` do arquivo genérico `profiles/glacier-base.nix`.
5. (Após deploy upstream) Limpar as sobras manuais do `rve-compat.nix`.
