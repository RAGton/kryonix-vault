# Fix: Integração de Wallpapers Animados (Waywallen)

Data: 2026-07-09
Agente: Antigravity
Repos afetados:
- kryonix
- kryonixos

## Objetivo
Ativar wallpapers animados no KDE Plasma 6 utilizando a stack `waywallen` e `open-wallpaper-engine`, sem desinstalar a solução nativa e preservando estabilidade (fallback para slideshow nativo em caso de erro).

## Contexto consultado
- A stack `waywallen` estava quebrando no NixOS devido à ausência do `krb5` no `LD_LIBRARY_PATH` (erro `libgssapi_krb5.so.2`).
- A configuração via `plasma-manager` (`wallpaperPlugin`) não funciona mais no KDE 6, causando erro na compilação do flake.

## Mudanças realizadas
1. **Core (`repos/kryonix`)**:
   - Correção de runtime: Adicionado `pkgs.krb5` em `LD_LIBRARY_PATH` no wrapper de `packages/kryonix-waywallen.nix`.
   - Remoção de opção incompatível: Removido `wallpaperPlugin` do `desktop/kde/theme.nix`.
   - Melhoria na tipagem do Fallback: O `fallback` do wallpaper animado agora suporta `nullOr path` para evitar erros de caminhos de arquivos ausentes em tempo de build no Nix.
   - Refatoração do Serviço: O serviço Home Manager `kryonix-waywallen` agora lida corretamente com fallback declarativo sem quebrar a compilação.
2. **Hosts (`repos/kryonixos`)**:
   - `kryonix.desktop.wallpaper.animated.enable = true` adicionado para o host `inspiron`.

## Commits e branches
- `repos/kryonix` (main): Correções na integração do wallpaper animado e pacote waywallen (`feat(desktop): fix waywallen integration and add animated wallpaper options` e formatação).
- `repos/kryonixos` (main): Atualização de flake lock `kryonix`.

## Validações executadas
- `nix flake check` em `repos/kryonix` (passou após correção de formatação e remoção do plugin KDE inválido).
- `nixos-rebuild build --flake .#inspiron` em `repos/kryonixos` completou com sucesso sem aumentar o tamanho do closure.
- `nvd diff /run/current-system ./result` indica que a configuração do wallpaper foi aplicada com sucesso sem adicionar lixo no closure.

## Evidências
Build log bem sucedido localmente no profile do Inspiron.

## Pendências
O usuário precisa:
1. Executar `sudo nixos-rebuild switch --flake .#inspiron`.
2. Verificar no Plasma se o daemon `waywallen` iniciou corretamente (`systemctl --user status kryonix-waywallen`).
3. Verificar a integração visual (UI do Waywallen vs Plugin Nativo do KDE) e garantir que o loop teste do MP4 está tocando, ou se a imagem de fallback está sendo aplicada.

## Próximo passo recomendado
- Realizar switch manual para testar visualmente no ambiente KDE Plasma 6.
