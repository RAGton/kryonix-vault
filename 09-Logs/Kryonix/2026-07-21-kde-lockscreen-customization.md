# Personalização da Tela de Bloqueio KDE (Plasma 6)

Data: 2026-07-21
Agente: Antigravity
Repos afetados:
- repos/kryonix
- repos/kryonixos

## Objetivo
Atender ao pedido do usuário para customizar a tela de bloqueio nativa do KDE, alterando wallpaper (paisagem), aumentando o tempo de bloqueio e mostrando os controles de mídia, de forma totalmente declarativa via Home Manager / Plasma Manager.

## Mudanças realizadas
1. **Geração de Wallpaper:**
   - Gerado um novo wallpaper com temática de paisagem ("A breathtaking digital art landscape wallpaper...").
   - A imagem foi inserida diretamente em `repos/kryonix/assets/wallpaper/landscape.png`.
2. **Atualização no Módulo de Lockscreen (`desktop/kde/lockscreen.nix`):**
   - Alterado o caminho de `lockWallpaper` para apontar para `landscape.png`.
   - Modificado `timeout = 15;` (aumentando o bloqueio automático para 15 minutos de inatividade).
   - Configurado `alwaysShowClock = false;`.
   - Habilitado `showMediaControls = true;`.
3. **Commit e Downstream:**
   - As alterações no motor `kryonix` foram commitadas e o `flake.lock` do `kryonixos` atualizado para consumir as novas diretivas.

## Validações executadas
- Todos os arquivos no `kryonix` e `kryonixos` comitados limpos.
- A sintaxe Nix validada visualmente; os ponteiros dos arquivos e submódulos encontram-se atualizados no root `kryonix-dev`.

## Pendências
- O usuário deve dar pull no `/etc/kryonixos` e no `/etc/kryonix` na máquina alvo local e executar o switch.
- Após o switch, testar o lockscreen bloqueando a máquina manualmente (`Meta+L` ou via UI).

## Próximo passo recomendado
O usuário deve aplicar a configuração no host de destino via rebuild switch.
