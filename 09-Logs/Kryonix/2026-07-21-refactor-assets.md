# Refatoração e Centralização de Assets (Fase 1)

Data: 2026-07-21
Agente: Antigravity
Repos afetados:
- kryonix
- kryonix-assets
- kryonix-dev

## Objetivo
Centralizar todos os recursos gráficos (wallpapers, temas SDDM, telas de boot Plymouth, logos) em uma única Fonte de Verdade (`kryonix-assets`), reduzindo o ruído no repositório core (`kryonix`) e mantendo coerência na identidade Kryonix OS.

## Contexto consultado
O usuário indicou o uso exclusivo do repositório `kryonix-assets` para todos os temas, wallpapers e identidades visuais ("Kryonix Node Think"). O core passaria a consumir este repositório como um Flake input `inputs.kryonix-assets`.

## Mudanças realizadas
1. `kryonix/flake.nix`: Declarado `inputs.kryonix-assets.url = "github:RAGton/kryonix-assets"`.
2. `kryonix/flake/packages.nix`: Repassado `kryonixAssets` para pacotes.
3. Repositório `kryonix`: Excluídas as pastas legadas de assets (`desktop/sddm`, `desktop/wallpapers`, `modules/node/core/themes`, `assets`).
4. Repositório `kryonix-assets`: Todo o material de UI em QML para SDDM e imagens/scripts para o Plymouth transferidos para este repositório, que atua como SSOT real.
5. Ajustes e Correções: Formatado overlays, corrigido subcomandos de `kryx` faltantes nos checks.

## Commits e branches
- kryonix-assets (main): `feat(assets): add complete SDDM and Plymouth themes` e `feat: migrate assets from core to dedicated flake repo`.
- kryonix (main): `refactor(assets): migrate to unified kryonix-assets flake`.
- kryonix-dev (main): `chore(dev): update submodule pointers for assets refactor`.

## Validações executadas
- `nix flake check --keep-going` rodou com sucesso.
- `nix build .#nixosConfigurations.inspiron.config.system.build.toplevel` completado com sucesso sem pendências de caminhos no SDDM e Wallpapers.

## Evidências
- Builds de pacotes concluídos sem erros (`nixfmt-check`, `kryonix-cli-help-check` pass).
- Código QML, imagens PNG/SVG centralizadas no repositório de assets.

## Pendências
- Testar visualmente a injeção do Plymouth/SDDM no modo gráfico do instalador.
- Iniciar a Fase 2: Modernização Estética Global e Painel (KPanel React) caso aprovado.

## Próximo passo recomendado
Prosseguir para a Fase 2 de KPanel React e Transição de SDDM/Lockscreen.
