---
title: ISO Kiosk Branding
type: branding
status: proposal
tags: [kryonix, branding, iso, kiosk, palette, nixos, chromium, plymouth]
project: kryonix
created: 2026-06-16
updated: 2026-06-16
---

# ISO Kiosk Branding — Kryonix Identity

<role>
Proposta de branding declarativo para a ISO do instalador: paleta única + boot direto na GUI (Kiosk Mode) sem flash branco.
</role>

## Paleta Canônica (Kryonix Identity)

| Token | Hex | Uso |
|-------|-----|-----|
| `deepBlack` | `#0D0D0D` | Fundo base (kiosk, pre-paint do Chromium, console). |
| `neonGreen` (Cyber Lime) | `#39FF14` | Acento/realce, foco, progresso, logo. |
| `spaceBlue` | `#1A1A2E` | Painéis, superfícies elevadas, gradiente de boot. |

<facts>
- A ISO **já** inicia direto na GUI: `kryonix.installer.kiosk.enable = true` em `hosts/iso/default.nix` faz autologin no TTY1 → `cage` (Wayland) → `chromium --app`.
- O kiosk hoje **pisca branco** antes do React pintar (Chromium sem `--default-background-color`).
- Cores de boot estão hardcoded como `#081018` no módulo de branding (Plymouth/blackPixel).
</facts>

## Proposta (3 mudanças)

### 1. Paleta como fonte única — `modules/nixos/branding/kryonix/default.nix`

```diff
   options.kryonix.branding = {
     enable = lib.mkEnableOption "Ativa branding do sistema como Kryonix";
+
+    palette = lib.mkOption {
+      type = lib.types.attrsOf lib.types.str;
+      default = {
+        deepBlack = "#0D0D0D";
+        neonGreen = "#39FF14";
+        spaceBlue = "#1A1A2E";
+      };
+      description = "Paleta canônica Kryonix (fonte única para Plymouth/GRUB/kiosk).";
+    };
```

E trocar o pixel/colorize hardcoded pela paleta:

```diff
-  blackPixel = pkgs.runCommand "black-pixel.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
-    magick -size 1x1 xc:"#081018" PNG32:$out
+  blackPixel = pkgs.runCommand "black-pixel.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
+    magick -size 1x1 xc:"${cfg.palette.deepBlack}" PNG32:$out
   '';
```

### 2. Matar o flash branco do kiosk — `modules/nixos/installer/web-kiosk.nix`

```diff
           exec ${pkgs.cage}/bin/cage -s -- \
             ${pkgs.chromium}/bin/chromium \
               --app="${cfg.url}" \
               --no-sandbox \
               --test-type \
+              --default-background-color=FF0D0D0D \
+              --force-dark-mode \
               --autoplay-policy=no-user-gesture-required \
               --no-first-run \
```

> ⚠️ `--default-background-color` espera ARGB hex (`FF0D0D0D` = Deep Black opaco). Confirmar o formato no Chromium do pin antes do merge.

Opcional (fundo do compositor antes do Chromium subir): `cage` não expõe bg color; usar um `swaybg`/cor sólida exigiria trocar de compositor. O `--default-background-color` já resolve 99% do flash.

### 3. UI (web) — mapear tokens em `ui/src/index.css`

A UI hoje usa ciano (`--primary: #00d4ff`). Para alinhar à marca:

```diff
 :root {
-  --bg:       #0a0d12;
-  --primary:  #00d4ff;
+  --bg:       #0D0D0D;   /* deepBlack */
+  --bg2:      #1A1A2E;   /* spaceBlue */
+  --primary:  #39FF14;   /* neonGreen / cyber lime */
```

## Validação obrigatória (antes do merge)

- [ ] `nix fmt`
- [ ] `nix flake check --keep-going --impure`
- [ ] Build da ISO: `nix build .#nixosConfigurations.iso...` (ou alvo de ISO do flake)
- [ ] Boot da ISO em VM: confirmar **sem flash branco** e paleta aplicada no Plymouth/kiosk.

<risks>
- Arquivo sensível (`modules/nixos/installer/*`): mudança no comando do kiosk pode quebrar o autologin → testar boot real em VM.
- `--force-dark-mode` pode reinterpretar cores da UI; como a UI já é dark e definirá os tokens, validar contraste do Neon Green sobre Deep Black (acessibilidade).
</risks>

## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]
- [[02-Areas/Kryonix/branding/KryonixOS Identity]]
- [[02-Areas/Kryonix/branding/Boot Identity]]
- [[02-Areas/Kryonix/architecture/Installer]]
- [[02-Areas/Kryonix/hosts/ISO]]
