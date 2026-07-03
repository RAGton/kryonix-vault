# KDE Theme Rebuild from BonaFides Baseline

Data: 2026-07-03
Agente: Claude Opus (via Antigravity)
Repos afetados:
- kryonix
- kryonixos

## Objetivo
Refatorar a interface do Kryonix KDE para restaurar a estética "Professional Dark Blue Glass", eliminando problemas de renderização (como a "cápsula preta gigante") causados por SVGs customizados com geometria quebrada.

## Contexto consultado
- Workspace: `/home/rocha/kryonix/kryonix-dev`
- Pesquisa de SVGs do tema base (`BonaFides-Color-Plasma`)
- Pesquisa de alternativas no nixpkgs (Graphite, Layan, etc.)

## Mudanças realizadas
- **Remoção de SVGs Customizados**: Os arquivos artesanais em `desktop/kde/kryonix-blue-glass/desktoptheme/...` foram removidos pois não implementavam corretamente a estrutura FrameSVG do Plasma 6 (faltavam `hint-margins`, masks para blur e shadows).
- **Herança do BonaFides**: O `metadata.json` do `kryonix-blue-glass` foi atualizado com `"X-Plasma-FallbackTheme": "BonaFides-Color-Plasma"`. O Plasma agora herda a geometria profissional do BonaFides.
- **Color Scheme**: A paleta Kryonix (`KryonixBlueGlassDark` - tons navy e accent azul) continua sendo aplicada automaticamente pelo Plasma via classes `ColorScheme-Background` nos SVGs do BonaFides.
- **theme.nix**: Ajuste de headers e confirmação das propriedades dos painéis (top bar: 28px fixa; dock: 40px flutuante). O `pager` de workspaces permaneceu removido para manter o visual limpo e evitar quebras.

## Commits e branches
- Core: `3f8485e style(kde): rebuild desktop theme from professional baseline`
- Downstream: `908282a chore(deps): bump kryonix core for kde theme rebuild`
- Workspace: `fd494e6 chore(dev): sync kde theme rebuild`

## Validações executadas
- `nix flake check` no `kryonix` (sucesso).
- `nix build .#homeConfigurations."rocha@inspiron".activationPackage` no `kryonixos` (sucesso, via dry-run log).
- Verificação de `allowDestructiveReconcile` não modificado.

## Evidências
O layout do Plasma herdará SVGs maduros (BonaFides) com a identidade do Kryonix, corrigindo transparência (blur/glass real) e limites dos painéis.

## Pendências
Nenhuma.

## Próximo passo recomendado
O usuário deve aplicar o update na sua máquina host usando `git pull --ff-only origin main` em `/etc/kryonixos`, seguido de `kryonix home` e restart do Plasma shell para forçar a reconstrução do cache de SVGs.
