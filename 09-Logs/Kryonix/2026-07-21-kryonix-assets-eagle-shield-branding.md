# Padronização dos ativos Kryonix — Águia K com Escudo

Data: 2026-07-21
Agente: Aura
Repos afetados:

- repos/kryonix-assets
- repos/kryonix
- repos/kryxd
- repos/kryonix-vault

## Objetivo

Centralizar os ativos visuais ativos na marca oficial Kryonix Águia K com Escudo e remover referências ativas ao branding legado RAGOS nos assets.

## Contexto consultado

- [[VAULT_INDEX]]
- `repos/kryonix-vault/AGENTS.md`
- Logs Kryonix relacionados a `kryxd`, branding e assets.
- Estado Git dos repos afetados antes da alteração.

## Mudanças realizadas

### kryonix-assets

- Criado logo master:
  - `logos/kryonix-eagle-shield.png`
  - `logos/kryonix-eagle-shield.svg`
  - `logos/logo.png`
- Substituídos logos ativos de boot:
  - `boot/logo.png`
  - `boot/node/logo.png`
  - `boot/node/background.jpg`
  - `boot/node/source-background.jpg`
- Criados novos fundos oficiais:
  - `boot/ipxe-bg.png`
  - `wallpapers/kryonix-dark-4k.png`
  - `wallpapers/kryonix-aurora.png`
- Renomeados arquivos Plymouth de Node para remover path legado `ragos.*`:
  - `boot/node/node.plymouth`
  - `boot/node/node.script`
- Criado `boot/node/README.md`.
- Renomeado wallpaper legado `wallpapers/ragos-logo-terminal.png` para `wallpapers/kryonix-node-terminal.png` com conteúdo atualizado.
- Removidos wallpapers herdados/antigos do pacote ativo (`01.png` a `12.png` e `plasma-slide-*`), mantendo apenas composições derivadas da Águia K com Escudo em `wallpapers/`.

### kryonix

- `packages/kryonix-branding.nix` agora consome `logos/kryonix-eagle-shield.png`.
- `packages/kryonix-sddm-theme.nix` agora consome `logos/kryonix-eagle-shield.png` e corrige permissões de arquivos copiados do store antes de sobrescrever `assets/logo.png`.
- `packages/kryonix-wallpapers.nix` atualiza exemplo para `kryonix-dark-4k.png`.
- `modules/nixos/branding/kryonix/default.nix` usa `kryonix-dark-4k.png` e `kryonix-eagle-shield.png`.
- `desktop/kde/wallpaper.nix` aponta o wallpaper padrão para `kryonix-dark-4k.png`.

### kryxd

- Login PAM e Sidebar importam `ui/src/assets/logo.png` em vez do raster antigo em `ui/src/assets/images/`.
- Rasters antigos de UI/cópia Vite foram substituídos por versões derivadas da Águia K com Escudo.

## Validações executadas

- `git diff --check` em `kryonix-assets`: PASS.
- `git diff --check` em `kryonix`: PASS.
- `git diff --check` em `kryxd`: PASS.
- `nix flake check path:$PWD --keep-going` em `kryonix-assets`: PASS.
- `nix build .#kryonix-branding .#kryonix-sddm-theme .#kryonix-wallpapers --override-input kryonix-assets path:../kryonix-assets --no-link -L` em `kryonix`: PASS após corrigir `chmod -R u+w` no tema SDDM.
- Após purgar os wallpapers antigos, `nix flake check path:$PWD --keep-going` em `kryonix-assets`: PASS.
- Após purgar os wallpapers antigos, `nix build .#kryonix-branding .#kryonix-sddm-theme .#kryonix-wallpapers --override-input kryonix-assets path:../kryonix-assets --no-link -L` em `kryonix`: PASS.
- `nix flake check --keep-going --override-input kryonix-assets path:../kryonix-assets` em `kryonix`: PASS.
- `npm run build` em `kryxd/ui`: PASS.

## Evidências

- Busca por `ragos`/`RAGOS` em nomes e fontes textuais de `kryonix-assets`: 0 ocorrências.
- Busca por referências funcionais obsoletas em Nix (`kryonix-dark.png`, `wallpapers/01.png`, `ragos-logo-terminal`): 0 ocorrências no escopo ajustado.
- `nix build` dos pacotes de branding, SDDM e wallpapers concluiu sem erro usando `kryonix-assets` local via override.

## Pendências

- O build completo de `nixosConfigurations.inspiron.config.system.build.toplevel` não existe no flake do core `repos/kryonix`; o core expõe apenas `iso` e `iso-e2e` como `nixosConfigurations`.
- O repo downstream `repos/kryonixos` expõe `inspiron`, mas o próprio `AGENTS.md` do downstream orienta validar por eval/flake check, não buildar o toplevel localmente, porque a closure do Inspiron é grande.
- Commits não foram criados nesta execução para não misturar com mudanças preexistentes nos repos.

## Próximo passo recomendado

Revisar visualmente os PNGs gerados, separar commits por repo e atualizar o submodule pointer do `kryonix-dev` depois dos commits em `kryonix-assets`, `kryonix`, `kryxd` e `kryonix-vault`.

#kryonix #branding #assets #vault-log
