# Migração e Modernização de Branding (RAGOS -> Kryonix)

Data: 2026-07-21
Agente: Antigravity
Repos afetados:
- repos/kryonix
- repos/kryonixos

## Objetivo
Centralizar toda a terminologia do ecossistema e remover referências legadas ao "RAGOS", padronizando como Kryonix. O instalador do RAGOS também foi deletado para focar os esforços no `kryxd`. O boot dos nós via iPXE também recebeu uma interface moderna sem terminal, com fallback para o shell.

## Mudanças realizadas
1. **Limpeza do Instalador Antigo**: 
   - Deletada a pasta `repos/kryonix/modules/node/installer/` que continha a UI em React desatualizada do RAGOS. O `kryxd` é agora o instalador oficial.
2. **Branding no NixOS Base**:
   - Atualizado comentário no `default.nix` que mencionava RAGOS.
3. **Modernização do PXE Boot**:
   - Modificado `repos/kryonix/modules/node/core/server/pxe/menus/menu.ipxe` e `autoexec.ipxe` para ocultar menus de texto (`colour --basic 0 7`).
   - Injetado `console --picture splash.png` para atuar como Loading Screen (Splash estática) antes de o Plymouth arrancar de fato no SO alvo.
   - Adicionado `splash.png` em alta qualidade no diretório pxe (usando a mesma imagem belíssima do lockscreen).
   - O menu interativo de seleção de boot foi removido, focando na agilidade do loading e boot direto (`chain ${filename}`). Há um atalho secreto oculto de 2s pressionando 's' para recuperar o shell de debug.

## Validações executadas
- Git commits salvos no `kryonix` (removendo 74 arquivos antigos).
- `flake.lock` sincronizado nos repos `kryonixos`.

## Próximo passo recomendado
Fazer pull na máquina local do servidor host Kryonix (`sudo git pull`) e rodar `nixos-rebuild switch` para aplicar as novas configs do serviço HTTP de PXE.
