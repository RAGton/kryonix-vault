---
title: Auditoria Boot Identity (P3)
date: 2026-06-14
type: audit
status: in-progress
tags: [kryonix, branding, boot, grub, plymouth, iso, p3]
related:
  - "[[00 Index]]"
  - "[[05 Backlog P3 P4 P5]]"
---

# Auditoria Boot Identity — P3

Auditoria read-only feita após o merge do PR #80 (terminal identity).
Mapeia o que falta para "KryonixOS no boot" completo, sem aplicar patch
no momento da auditoria.

## Inventário de arquivos relevantes

```txt
modules/nixos/branding/kryonix/default.nix    # módulo principal (GRUB theme + Plymouth + os-release/issue/motd)
modules/nixos/common/default.nix              # boot.plymouth default (theme="spinner"), loader.timeout
hosts/iso/default.nix                         # system.nixos.distroName/label, isoImage.*, plymouth.enable
hosts/inspiron/default.nix                    # boot.loader.grub (enable/efiSupport), stateVersion
modules/nixos/installer/default.nix           # ISO ferramenta kryonix-install
modules/nixos/installer/web-kiosk.nix         # ISO kiosk
assets/grub-theme/theme.txt                   # tema GRUB cyan/preto
assets/wallpaper/01.png                       # bg plymouth + grub splash
assets/avatar/ragton.jpeg                     # ⚠️ usado como "logo" Plymouth (avatar pessoal)
```

## Estado por área

### GRUB
- Tema em `assets/grub-theme/theme.txt`:
  - Label: **`K R Y O N I X`** (24pt cyan) ← *não* "KryonixOS"
  - Boot menu cyan/cinza
  - Progress bar cyan
- `boot.loader.grub.theme = lib.mkForce "${grubTheme}/kryonix"` quando branding habilitado
- `extraConfig`: cores `color_normal`, `menu_color_*`
- ISO: `isoImage.grubTheme/splashImage/efiSplashImage` substituídos via
  `lib.optionalAttrs (options ? isoImage)`
- **Não há** customização de `GRUB_DISTRIBUTOR`, `menuentry`,
  `extraEntries`

### Plymouth
- Tema script-mode `"kryonix"` gerado por `pkgs.runCommand "kryonix-plymouth-theme"`:
  - Background: `assets/wallpaper/01.png` blurrado + escurecido
  - **Logo: `assets/avatar/ragton.jpeg`** ← achado importante
  - Animação: fade in/out simples + handler password (LUKS)
- ISO força `boot.plymouth.enable = lib.mkForce true` + silenciamento
  (`quiet splash`, `loglevel=0`)

### system label / generation labels
- `hosts/iso/default.nix`:
  - `system.nixos.distroName = lib.mkForce "Kryonix"` ← *não* "KryonixOS"
  - `system.nixos.label = lib.mkForce "Kryonix-Installer"`
  - `image.baseName = lib.mkForce "kryonix"` (ok)
  - `isoImage.volumeID = lib.mkForce "KRYONIX"`
  - `isoImage.appendToMenuLabel = lib.mkForce "Installer"`
- `hosts/inspiron/default.nix`:
  - Sem `system.nixos.distroName/label/tags` (defaults NixOS)
  - `system.stateVersion = "26.05"` ← não tocar

Renderização confirmada por inspeção do toplevel:
```
nixos-system-kryonix-Kryonix-Installer/nixos-version  →  "Kryonix-Installer"
```

### channel / release track
- `kryonix.branding.versionId` default `"25.11"`
- `hosts/inspiron`: `system.stateVersion = "26.05"`
- **Desalinhado**: VERSION_ID=25.11 vs stateVersion=26.05
- Sem opção pública pra channel/release tag

## Bug colateral detectado

```
/etc/kryonix-version atual:
  KRYONIX_PRETTY_NAME="KryonixOS KryonixOS (v30d84ad6)"
```

Causa: `modules/nixos/meta/version.nix:30`
```nix
prettyName = "KryonixOS ${brandingPrettyName} (v${lib.substring 0 8 commit})";
```

Com `brandingPrettyName = "KryonixOS"` (default atualizado no PR #71),
gera duplicação. **Virou bug com o merge do #71** — antes funcionava
porque o default era "Kryonix".

## Tabela de gaps

| #  | Item                                          | Estado                             | Risco | Sugestão           |
|----|-----------------------------------------------|------------------------------------|:-----:|--------------------|
| 1  | GRUB label `K R Y O N I X`                    | literal, não KryonixOS             | baixo | `KryonixOS`        |
| 2  | Plymouth logo                                 | `ragton.jpeg` (avatar)             | médio | logo dedicado (P4) |
| 3  | `system.nixos.distroName` em hosts não-ISO    | default `NixOS`                    | médio | P5 (opção branding)|
| 4  | `system.nixos.label` em hosts não-ISO         | default                            | baixo | P5                 |
| 5  | ISO label `Kryonix-Installer`                 | force `Kryonix`/`Kryonix-Installer`| médio | `KryonixOS-Installer` |
| 6  | ISO `appendToMenuLabel = "Installer"`         | atual                              | baixo | manter             |
| 7  | Bug `KRYONIX_PRETTY_NAME` duplicado           | bug ativo                          | baixo | corrigir formato   |
| 8  | versionId vs stateVersion                     | 25.11 vs 26.05                     | baixo | doc separada       |
| 9  | channel/release track                         | ausente                            | baixo | opcional (P5+)     |
| 10 | Plymouth refactor pesado                      | OK funcionalmente                  | alto  | **não tocar** P3   |
| 11 | GRUB hint texto PT-BR                          | "ENTER iniciar…"                   | baixo | opcional           |
| 12 | `boot.consoleLogLevel = 0` hosts não-ISO      | default                            | baixo | manter             |

## Escopo P3 aprovado (reduzido)

PR `branding/boot-identity-p3` cobre **3 itens** apenas:

1. `assets/grub-theme/theme.txt` — label `K R Y O N I X` → `KryonixOS`
2. `modules/nixos/meta/version.nix` — fix duplicação:
   - `"KryonixOS ${brandingPrettyName} (v<sha>)"` → `"${brandingPrettyName} (v<sha>)"`
3. `hosts/iso/default.nix`:
   - `system.nixos.distroName = "KryonixOS"`
   - `system.nixos.label = "KryonixOS-Installer"`

**Fora**: kryonix.branding.systemLabel, labels hosts não-ISO,
Plymouth logo, assets novos, channel/release track, GRUB extraEntries.

## Validações esperadas (P3)

```bash
nix fmt
git diff --check
nix flake show --all-systems
nix build .#nixosConfigurations.iso.config.system.build.toplevel --no-link -L --show-trace
nix build .#kryxd --no-link -L --show-trace

TOP="$(nix build .#nixosConfigurations.iso.config.system.build.toplevel --print-out-paths --no-link)"

cat $TOP/nixos-version                         # esperado: "KryonixOS-Installer"
cat $TOP/etc/kryonix-version                   # NÃO conter "KryonixOS KryonixOS"
cat $TOP/etc/os-release | rg "NAME=|PRETTY"    # KryonixOS preservado
```

Smoke-test visual real (ISO boot KVM) fica como pendência manual.

## Estado da branch P3 (não-commitada / não-pushada)

Branch `branding/boot-identity-p3` criada a partir de `30d84ad6`.
3 arquivos modificados em working tree:

- `assets/grub-theme/theme.txt` (label + comentário cabeçalho)
- `modules/nixos/meta/version.nix` (formato + default fallback)
- `hosts/iso/default.nix` (distroName + label)

A sessão foi pausada por pedido do usuário para salvar a memória no
Obsidian Vault. Patches existem na working tree, sem commit, sem push.

Ver: [[05 Backlog P3 P4 P5]] · [[02 PRs Mergeados]]
