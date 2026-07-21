# Inspiron — crash Electron/Chromium em radeonsi

Data: 2026-07-21
Agente: Aura
Repos afetados:

- kryonixos
- kryonix-vault

## Objetivo

Resolver falhas de abertura em programas Electron/Chromium no host `inspiron`, preservando Wayland.

## Contexto consultado

- `kryonix-dev/AGENTS.md`
- `repos/kryonixos/AGENTS.md`
- `repos/kryonix-vault/AGENTS.md`
- `repos/kryonix-vault/VAULT_INDEX.md`
- `repos/kryonixos/hosts/inspiron/default.nix`
- Precedente em `repos/kryonixos/hosts/inspiron-nina/default.nix`

## Causa confirmada

Os coredumps mostram `electron`, `code`, `chrome` e `antigravity` falhando em `libgallium-26.1.3.so` / `radeonsi`, durante criação de contexto GBM/DRI.

O host tem GPU híbrida:

- `card0`: AMD Radeon `0x1002:0x6665`, driver `radeon`
- `card1`: Intel `0x8086:0x3ea0`, driver `i915`, `boot_vga=1`

O crash ocorre quando apps Electron/Chromium encostam no caminho Mesa/radeonsi da AMD.

## Mudanças realizadas

1. Em `repos/kryonixos/hosts/inspiron/default.nix`, foi adicionado workaround declarativo por host:
   - `DRI_PRIME=0`
   - `MESA_LOADER_DRIVER_OVERRIDE=iris`
   - `LIBVA_DRIVER_NAME=iHD`

2. Em `repos/kryonix/modules/home-manager/programs/obsidian/default.nix`, o launcher `kryonix-obsidian` foi reforçado com:
   - `--disable-gpu`
   - `--disable-gpu-compositing`

3. Em `repos/kryonixos/users/rocha/inspiron/default.nix`, foram adicionados atalhos Home Manager para VSCode, Google Chrome, Microsoft Edge e Google Antigravity com `--disable-gpu --disable-gpu-compositing`, mantendo Wayland ativo.

4. Para corrigir a sessão atual sem esperar rebuild/relogin, foi criado:
   - `/home/rocha/.config/environment.d/99-kryonix-gui-driver.conf`
   - overrides em `/home/rocha/.local/share/applications/`
   - `/home/rocha/.config/code-flags.conf`

5. O ambiente do systemd user recebeu as mesmas variáveis via `systemctl --user set-environment`.

## Validações executadas

- `kryonix-obsidian --no-sandbox` ficou vivo por 8s, carregou o app e não gerou novo coredump Electron.
- `code --disable-gpu --disable-gpu-compositing --disable-extensions --new-window` não gerou novo coredump.
- `systemctl --user show-environment` confirmou as três variáveis na sessão do usuário.
- `nix run nixpkgs#nixfmt -- hosts/inspiron/default.nix` passou.
- `nix run nixpkgs#nixfmt -- modules/home-manager/programs/obsidian/default.nix` passou.
- `nix run nixpkgs#nixfmt -- users/rocha/inspiron/default.nix hosts/inspiron/default.nix` passou.
- `nix eval --impure '.#nixosConfigurations.inspiron.config.environment.sessionVariables' --json` confirmou as variáveis no host `inspiron`.
- `nix eval --impure --override-input kryonix git+file:///home/rocha/kryonix-dev/repos/kryonix '.#nixosConfigurations.inspiron.config.home-manager.users.rocha.xdg.desktopEntries.code.exec' --raw` confirmou `code --disable-gpu --disable-gpu-compositing %F`.

## Evidências

Trechos relevantes observados:

- Crash original: `radeonsi: error: can't create border_color_buffer` e `Failed to create a context`.
- Teste aprovado: `obsidian_alive_after_8s True`, `new_electron_coredumps 0`.
- Ajuste adicional necessário: sem `--disable-gpu`, Electron mudou de SIGSEGV para SIGTRAP (`GPU process isn't usable`). A solução final preserva Wayland e desativa apenas o processo GPU dos apps afetados.
- Teste negativo: `LIBGL_ALWAYS_SOFTWARE=1` não resolve; reproduziu `SIGSEGV` em `radeonsi`.

## Pendências

- Aplicar a configuração declarativa em `/etc/kryonixos` via fluxo normal do Kryonix quando Gabriel autorizar o switch.
- Se algum app específico ainda falhar, validar se ele ignora `environment.d` ou precisa de wrapper/flag própria.

## Próximo passo recomendado

Reabrir Obsidian, VSCode, Chrome e Antigravity pelo launcher KDE. Se já estavam abertos/quebrados, fechar as instâncias antigas antes de reabrir.

#kryonix #inspiron #nixos #wayland #electron #mesa
