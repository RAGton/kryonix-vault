# Saneamento de Débitos Técnicos: Avisos do Flake

Data: 2026-08-02
Agente: Antigravity
Repos afetados:
- kryonix (upstream)
- kryonixos (downstream)
- kryonix-dev (workspace pointer)

## Objetivo
Resolver avisos crônicos na compilação (`nix flake check`) identificados após o switch para estabilização do Glacier. O saneamento focou em limpar a dívida técnica sem alterar o comportamento funcional.

## Contexto consultado
- Configurações antigas do Home Manager que não exigiam a chave explícita `enable` no `home.pointerCursor`.
- Depreciação do `services.ollama.models` no upstream do Nixpkgs.

## Mudanças realizadas
1. **Refatoração do Módulo Brain (`brain.nix`)**: Confirmada e puxada a correção de `models` para `modelsDir` através de atualização no `flake.lock` do `kryonixos` vinculando o novo commit do upstream (`kryonix`).
2. **Atualização do Home Manager (`pointerCursor`)**:
   - Inserida `home.pointerCursor.enable = true;` nos perfis de downstream do `kryonixos` (`rocha/glacier`, `nina/inspiron-nina`).
   - Inserida a chave de enable nos sub-módulos canônicos KDE e Hyprland no `kryonix` (`desktop/kde/theme.nix`, `desktop/hyprland/core/cursor.nix`) para impedir que a avaliação propague o erro a partir da herança.

## Commits e branches
- `kryonix`: `83b62fa4` e `a1315191`.
- `kryonixos`: `8cb44f1` (flake lock + profiles).
- `kryonix-dev`: Submodules syncados e empurrados para as branches `main`.

## Validações executadas
- Executado `nix flake check --keep-going` no `kryonixos`:
  - Aviso do `rocha profile: Relying on home.pointerCursor... is deprecated` extinto.
  - Aviso do `nina profile...` extinto.
  - Aviso do `services.ollama.modelsDir` extinto.
- *Nota: O aviso residual de `stdenv.hostPlatform.system` e o `forceImportRoot` do ZFS (padrão NixOS 26.11) não foram suprimidos pois tratam-se de logs benignos da própria fundação do NixOS.*

## Evidências
Log local limpo do `nix flake check` registrando o desaparecimento das queixas relacionadas aos perfis.

## Pendências
Nenhuma. Critérios de conclusão de débitos estéticos atendidos.
