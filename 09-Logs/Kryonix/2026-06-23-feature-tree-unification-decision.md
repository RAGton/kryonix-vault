# Feature tree unification decision

## Decisão

Unificar as árvores de features (`features/` e `modules/nixos/features/`) adotando `modules/nixos/features/` como a árvore canônica. O installer deixará de usar catálogos hardcoded e passará a consumir um Feature Registry exportado em JSON pelo upstream. Profiles antigos serão convertidos em compat layers para não quebrar hosts existentes (como o Glacier).

## Motivo

O projeto encontra-se em um estado perigoso com duas árvores de features paralelas competindo pelo mesmo namespace (`kryonix.features.*`). Isso causa risco de drift, código duplicado e comportamentos imprevisíveis (já documentado em incidentes anteriores). A lógica do installer está separada do motor Nix, o que agrava a dissonância.

## Arquivos criados

- `ADR-001-feature-tree-unification.md`: Decisão arquitetural de unificação.
- `FEATURE_TREE_MIGRATION_MAP.md`: Mapeamento das refatorações e impactos esperados.
- `2026-06-23-feature-tree-unification-decision.md`: Este log operacional.

## Auditorias realizadas

Auditorias de namespace, árvores legadas, profiles e uso downstream e installer foram executadas com sucesso para mensurar a amplitude da mudança.

## Próximo passo

Abrir PR audit-only no upstream para consolidar o migration map no repo `kryonix`, sem mover código ainda.
