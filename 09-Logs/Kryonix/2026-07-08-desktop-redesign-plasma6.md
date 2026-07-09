# Redesign da Camada Desktop KDE Plasma 6

Data: 2026-07-08
Agente: Antigravity (Opus role)
Repos afetados:
- repos/kryonix
- repos/kryonixos

## Objetivo
Refatorar a camada visual do KDE Plasma 6 no Kryonix para atingir um visual coeso, profissional e moderno (estilo macOS/Hyprland Glass), substituindo temas misturados (BonaFides) e launchers incorretos por uma configuração declarativa baseada em WhiteSur, Kvantum e Rofi.

## Contexto consultado
O ambiente estava sofrendo com um design visual feio/quebrado, barra de tarefas preta/opaca e comportamento inesperado de widgets e paginadores devido a configurações legadas no `plasma-manager`.

## Mudanças realizadas
1. **Limpeza de Tema:**
   - O tema global e os ícones foram migrados para `WhiteSur-dark`.
   - O ColorScheme foi mantido como `KryonixDark` (definido no downstream) para injetar a paleta de cores azul/escura oficial do projeto sobre os assets base do WhiteSur.
   - Tema SDDM atualizado de `kryonix-aurora` para `sddm-astronaut` para maior estabilidade e aparência premium.

2. **Refatoração do Painel:**
   - Substituiu-se a configuração problemática de 3 painéis `fit` independentes por **1 único painel flutuante `fill`** com 36px de altura.
   - O efeito visual de "3 ilhas" foi recriado usando `org.kde.plasma.panelspacer` entre o Launcher/Pager, o Relógio e a System Tray. Isso resolveu falhas de sobreposição e resgatou a renderização do paginador.

3. **Restauro do Rofi:**
   - Fuzzel foi completamente removido do fluxo do KDE.
   - Rofi-wayland foi reinstaurado como default launcher (`Meta+A`), estilizado via `xdg.configFile` com um tema coerente `kryonix.rasi` (fundo semitransparente, accent azul #38BDF8).
   - O pacote duplicado (`programs.rofi.package`) que conflitava entre a base do home-manager e a config do KDE foi isolado e corrigido.

4. **Correções no Sistema:**
   - Falhas no `kryonix-libvirt-network-ragthink.service` (conflito de XML no start) foram ignoradas com fallback gracefully, permitindo que a unidade iniciasse com sucesso sem abortar a ativação.
   - `baloo` foi desativado corretamente usando `configFile."baloofilerc"` em vez da chave inválida `.enable` no `plasma-manager`.
   - Input do `kryonixos` corrigido para apontar para `git+file:///etc/kryonix`.

## Commits e branches
- `repos/kryonixos`: `chore(deps): point kryonix input to local engine` (lock atualizado).
- `repos/kryonix`: commits de fix no `desktop/kde/theme.nix`, `desktop/kde/rofi.nix` e `desktop/sddm/default.nix`.

## Validações executadas
- `nixos-rebuild build --flake .#inspiron` executado com sucesso e avaliado via `nvd diff`.
- Verificação do serviço `kryonix-libvirt-network-ragthink.service` confirmando inicialização limpa.
- `kreadconfig6` para LookAndFeel e ColorScheme.
- Reset da sessão Plasma executado via script.

## Pendências
- Criar a task: `fix(jupyter): make kernels and lab environment declarative` (O Jupyter continuou a tentar instalar via `pip install` durante a ativação).

## Próximo passo recomendado
Atualizar o submodule pointer de `repos/kryonix`, `repos/kryonixos` e `repos/kryonix-vault` no `kryonix-dev` (repositório raiz).
