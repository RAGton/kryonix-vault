# Resolução de Conflitos e Compilação (Host Inspiron)

Data: 2026-07-20
Agente: Antigravity
Repos afetados:

- repos/kryonix
- repos/kryonixos
- repos/kryonix-dev

## Objetivo
Resolver conflitos de merge na pasta `/etc/kryonixos` que impediam a compilação do sistema, preservar as configurações customizadas de hardware e ZFS do Inspiron, e unificar as mudanças locais com os remotos.

## Contexto consultado
O usuário encontrou problemas ao tentar compilar sua configuração do host `inspiron` após o ambiente upstream sofrer diversas mudanças, como a atualização do `flake.lock`, duplicação do bloco de configuração do Incus (`virtualisation.incus`), erros de sintaxe no arquivo de hardware e alteração de tipo (upstream) no `hermes-agent`. 

## Mudanças realizadas
1. **Limpeza de Sintaxe e Conflitos:** Removidos restos de marcação de conflito de merge (e um caractere isolado `.`) nos arquivos do `inspiron` em `repos/kryonixos`.
2. **Atualização do `flake.lock`:** Regenerado o lockfile no repositório `kryonixos` para resolver dependências ausentes de plugins do Flake.
3. **Consolidação do Incus (Kryonix Core):** Removida a duplicata do bloco de configuração `incus = { ... }` em `virtualization.nix`, migrando as opções customizadas de ZFS (`backend = "zfs"`, `poolName = "kryonix-incus"`) para o bloco padrão e desfazendo conflitos de avaliação.
4. **Adequação ao Hermes Agent Upstream:** Em `hosts/inspiron/hermes.nix`, `engine = "podman"` foi renomeado para `backend = "podman"`, e o tipo da variável `environment.files` foi ajustado de um array (`[ "..." ]`) para uma string pura (`"..."`), conformando-se às novas restrições do módulo upstream.

## Commits e branches
- `kryonixos (main)`:
  - Limpeza de caracteres soltos e quebras de linha em `hosts/inspiron/default.nix`.
  - Atualização do `flake.lock`.
  - Fix: rename `engine` para `backend` em `hermes.nix`.
  - Fix: mudança de array para string em `environment.files` no `hermes.nix`.
- `kryonix (main)`:
  - Fix: Remoção de duplicata no módulo `virtualization.nix`, consolidando defaults de ZFS.

## Validações executadas
O comando `sudo nixos-rebuild switch --flake /etc/kryonixos#inspiron` rodou com sucesso até o fim, ativando corretamente a configuração `26.05.20260625.4062d36` e gerando com sucesso as derivações para os serviços.

## Evidências
Saída de compilação sem erros: "Done. The new configuration is /nix/store/...-nixos-system-inspiron-..."

## Pendências
- Testar e confirmar se os containers em Incus iniciam perfeitamente na rede bridge configurada (`incusbr-kryonix`).
- Validar se o `hermes-agent` tem as permissões de leitura adequadas no arquivo do `.env`.

## Próximo passo recomendado
Continuar o ciclo de desenvolvimento/uso do loop; sempre manter o `/etc/kryonix` puxado do upstream antes de disparar atualizações do lockfile em máquinas de produção.

### Update (Grub e Splash)
- **GRUB**: Removido o tema antigo que estava quebrado (`kryonix-grub-theme`) e implementado nativamente o `splashImage` apontando para o background `01.png` oficial tratado.
- **KDE Splash**: Definido `Engine = "none"` no `ksplashrc` via Home Manager (plasma-manager) para desabilitar a tela de splash imitando o macOS do tema WhiteSur. Isso permite uma transição limpa e perfeita do Plymouth direto para o Desktop sem flashes estranhos.

### Update (Estabilidade Plasma 6 Wayland)
- **Plasmashell Crash Loop**: Resolvido um problema de instabilidade severa pós-login onde a interface recarregava repetidamente. 
  - `overrideConfig` do `plasma-manager` foi definido como `false`. Com isso, os arquivos de configuração (como o `appletsrc`) deixam de ser symlinks *read-only* na store do Nix, permitindo que o KDE salve o estado e geometria sem estourar falhas fatais no shell.
  - `floating` dos painéis principal e inferior foram definidos como `false`. Painéis flutuantes (3-island topology) associados ao motor de blur no KWin Wayland causam um recalculo infinito na textura de blur (`No QSGTexture provided`) ao tocarem as bordas, resultando em crash do KWin. Isso implementou o fallback documentado.

### Update (Visual GRUB)
- **Sleek GRUB**: A pedido do usuário, o GRUB com imagem de fundo não agradou. Substituímos toda a base do GRUB pelo pacote visual moderno e organizado `sleek-grub-theme`. Como o usuário solicitou uma cor sólida, modificamos dinamicamente os tokens da paleta do Sleek para usar o código `#081018` (Azul escuro oficial Kryonix) em vez de uma imagem de background. Isso traz fontes modernas (`Poppins`), iconografia, barra de progresso organizada e um menu profissional e limpo.

### Update (Ferramentas CLI)
- **Aura, Kryx e Hermes**: As ferramentas de linha de comando (`aura`, `kryx`, `hermes`) estavam corretamente referenciadas no repositório base/backend, mas os binários não estavam explicitamente exportados para o `PATH` do usuário. Elas foram injetadas no ambiente `environment.systemPackages` do host `inspiron` e agora estarão disponíveis no terminal assim que as modificações forem aplicadas localmente.
