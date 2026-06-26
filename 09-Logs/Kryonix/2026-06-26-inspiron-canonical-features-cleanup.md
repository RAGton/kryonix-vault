# Limpeza de features legadas e contenção do PR #8

Data: 2026-06-26
Agente: Antigravity
Repos afetados:
- repos/kryonix (Core)
- repos/kryonixos (Downstream)

## Objetivo
Corrigir o estado arquitetural após uma tentativa falha de migração que contaminou o PR #8 no downstream. O objetivo era remover opções "mortas" no core (como `serverAddress`) e limpar referências a opções legadas nos hosts `inspiron` e `inspiron-nina`, sem usar o anti-pattern de listar explicitamente `enable = false` para todo o registry.

## Contexto consultado
- Auditoria das features no core (`modules/nixos/features/schema.nix` vs implementações).
- Identificado que muitas features são apenas declarativas (schema-only) e o hardware é geralmente configurado por módulos legados ou `nixos-hardware`.
- PR #8 no downstream havia acidentalmente removido `gaming.enable` e `nvidia.enable` do host `Glacier` e introduzido o anti-pattern de registry global.

## Mudanças realizadas
1. **Fase A (Core - PR #113):**
   - Removida a opção morta `kryonix.features.ai.brain.client.serverAddress` de `schema.nix`.
   - Adicionado `removed-options.nix` usando `lib.mkRemovedOptionModule` para shims de opções descontinuadas (`cpu.intel`, `openrgb`, `remoteDesktop.client`, `legacyVaapi`, etc.), garantindo que os hosts downstream quebrem com mensagens de erro claras na avaliação.
   - PR mergeado na main do `kryonix`.

2. **Fase B (Downstream - PR #8):**
   - Fechado o PR #8 contaminado com comentário explicando as regressões arquiteturais.

3. **Fase C (Downstream - PR #9):**
   - Criado novo branch limpo (`fix/inspiron-clean-canonical-features`) a partir da main.
   - Limpas as opções descontinuadas (que agora lançam erro via shim) nos arquivos `hosts/inspiron/default.nix` e `hosts/inspiron-nina/default.nix`.
   - Flake lock atualizado para consumir as mudanças do core.
   - `hosts/glacier/default.nix` não foi alterado.

## Commits e branches
- `kryonix` (PR #113): `fix/remove-dead-brain-client-option` mergeado.
- `kryonixos` (PR #9): `fix/inspiron-clean-canonical-features` aguardando merge.

## Validações executadas
- `nix flake check --keep-going` executado no `kryonix` com sucesso.
- `nix flake check --keep-going` executado no `kryonixos` com sucesso.

## Pendências
- Mergear PR #9 no downstream se aprovado.
- Atualizar pointer do submodule `kryonix` e `kryonixos` no workspace `kryonix-dev` (opcional, será feito em batch).

## Próximo passo recomendado
- Revisar e dar merge no PR #9 no repositório `kryonixos`.
- Após o merge, realizar `git add repos/kryonix repos/kryonixos repos/kryonix-vault` no workspace raiz e commitar os submodule pointers.
