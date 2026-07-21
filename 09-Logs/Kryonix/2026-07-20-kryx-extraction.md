# Extração do Kryx CLI para repositório externo

Data: 2026-07-20
Agente: Antigravity
Repos afetados:

- repos/kryonix
- repos/kryonixos
- repos/kryx-cli

## Objetivo
Resolver a duplicação e precedência indevida do comando bash legado `kryonix` sobre o novo `kryx` no sistema. O usuário criou o repositório `kryx-cli` para ser o lar definitivo da nova ferramenta.

## Contexto consultado
- O usuário relatou que `kryonix` ainda funcionava em paralelo ao substituto em Rust `kryx`.
- Analisando `kryonix/flake/packages.nix` e `kryonix/overlays/default.nix`, o pacote legado `kryonix-cli.nix` (bash) continuava instanciado, alimentando a instalação do host `inspiron` via downstream.
- O novo repositório `RAGton/kryx-cli` estava vazio.

## Mudanças realizadas
1. **Clonagem e Popularização**:
   - Clonado o repositório vazio `https://github.com/RAGton/kryx-cli.git`.
   - Movido todo o código Rust de `repos/kryonix/packages/kryx` para dentro do novo `kryx-cli`.
   - Criado um `flake.nix` standalone para o `kryx-cli`.
   - Comitado (sem GPG) e executado push para o repositório externo.
2. **Atualização do Workspace**:
   - Limpado estado local e executado `git submodule add` para associar o novo repositório no `kryonix-dev`.
3. **Limpeza do Engine (Kryonix)**:
   - Removidos completamente os diretórios `packages/kryx` e `packages/kryonix-cli/`.
   - Deletado o artefato `packages/kryonix-cli.nix`.
   - Atualizado `flake.nix` do Kryonix adicionando o input `kryx-cli = { url = "github:RAGton/kryx-cli"; }`.
   - Modificada a overlay `kryxd-tools` para apontar `kryx` diretamente para o `inputs.kryx-cli` e eliminado o binário `kryonix`.
   - Ajustado `flake/packages.nix` para usar e expor o `kryx` empacotado externamente como pacote default e `kryx`.
4. **Atualização do Downstream (Kryonixos)**:
   - Atualizado o lockfile (`nix flake update kryonix`) para puxar as revisões limpas.

## Commits e branches
- `kryx-cli`: Commit inicial (`a97aba3`) branch `main`.
- `kryonix`: Refactor de extração do kryx e remoção do bash-cli (`449431c`) branch `main`.
- `kryonixos`: Update do flake.lock (`45d1739`) branch `main`.

## Validações executadas
- Avaliado se pacotes internos do NixOS (`modules/nixos/installer`) dependeriam do nome antigo. Identificado dependência correta com `kryxd` e ferramentas granulares.
- Lockfiles atualizados. O novo input resolve corretamente a derivação Rust através de `github:RAGton/kryx-cli`.

## Evidências
O binário legado não mais existe na árvore de pacotes principal e as chaves de fallback `pkgs.kryonix` foram abandonadas do overlay de ferramentas.

## Pendências
Nenhuma identificada para o processo de remoção. A adoção nos scripts de automação ou uso pessoal (`aura`, `kryx`) segue o planejado.

## Próximo passo recomendado
O usuário deve realizar um dry-run ou rebuild local (`nixos-rebuild switch`) no host `inspiron` para consolidar a alteração e limpar o perfil antigo do `kryonix` caso tenha ficado em gerações anteriores.
