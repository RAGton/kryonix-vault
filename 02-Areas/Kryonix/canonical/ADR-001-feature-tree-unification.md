---
status: accepted
date: 2026-06-23
area: Kryonix
type: architecture-decision
scope:
  - upstream
  - downstream
  - installer
  - vault
---

# ADR-001 — Unificação da árvore de features canônica

## Status

Accepted.

## Contexto

- existem duas árvores paralelas:
  - `features/`
  - `modules/nixos/features/`
- ambas competem pelo mesmo namespace `kryonix.features.*`
- profiles antigos dependem da árvore `features/`
- fluxos novos e installer apontam para `modules/nixos/features/`
- installer tem `featureCatalog.js`/`profileCatalog.js` hardcoded e divergente do motor Nix
- isso cria risco de drift, bugs, features duplicadas e comportamento imprevisível

## Problema

O Kryonix possui uma dupla personalidade arquitetural onde duas árvores de features paralelas causam conflitos de namespace e confusão, culminando em bugs reais (como o erro no PR #102). O installer utiliza um catálogo hardcoded que não reflete a realidade do motor Nix.

## Decisão

1. `modules/nixos/features/` é a árvore canônica.
2. `features/` é árvore legada e será migrada gradualmente.
3. O namespace público continua sendo `kryonix.features.*`.
4. O installer não deve ter catálogo hardcoded.
5. O Feature Registry do upstream será a fonte de verdade.
6. O downstream apenas ativa features.
7. O installer apenas escreve `features.generated.nix`.
8. `features.local.nix` pertence ao usuário e nunca deve ser sobrescrito.
9. profiles `glacier-*` serão mantidos temporariamente como compat/deprecated.
10. Nenhuma nova feature de app/kernel externo deve ser criada até concluir a unificação estrutural.

A árvore canônica de features do upstream é `modules/nixos/features/`.
A árvore `features/` é legada e será migrada gradualmente.

## Regras

- Upstream/Core define o catálogo de features, schema e implementação.
- Downstream ativa features (`enable = true`).
- Installer apenas escreve `features.generated.nix`.
- Installer nunca sobrescreve `features.local.nix` ou altera o Core.

## Consequências

- A árvore `features/` será completamente esvaziada e removida.
- O installer precisará ser refatorado para ler o Feature Registry do Nix.
- Profiles genéricos e hosts downstreams precisarão apontar para as novas localizações sem quebrar as ativações de features.

## Riscos

- colisão de namespace `kryonix.features.*`
- quebra de profiles antigos
- quebra do downstream Glacier
- perda de SSH remoto no Glacier (CRÍTICO)
- perda de bridge/br0/firewall/rve-compat no Glacier (CRÍTICO)
- installer gerar opções inexistentes
- flake check passar mas runtime quebrar

## Plano de migração

(Veja FEATURE_TREE_MIGRATION_MAP.md)

## Critérios de conclusão

- [ ] `features/` legado não é mais usado.
- [ ] Todas as features vivem em `modules/nixos/features/`.
- [ ] Profiles antigos viraram compat/deprecated.
- [ ] Feature Registry exporta JSON.
- [ ] Installer consome JSON do upstream.
- [ ] Downstream usa `features.generated.nix` e `features.local.nix`.

## Proibições temporárias

- [ ] Não criar novas features de app.
- [ ] Não mexer no installer UI.
- [ ] Não remover `glacier-*` ainda.
- [ ] Não migrar rede/SSH do Glacier sem plano de rollback/acesso físico.
