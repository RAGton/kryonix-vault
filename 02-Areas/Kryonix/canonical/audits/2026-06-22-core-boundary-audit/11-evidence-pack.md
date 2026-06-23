# Evidence Pack — Kryonix Core Boundary Audit

Gerado em: 2026-06-22
Comandos executados contra os repositórios DEV (`/home/rocha/kryonix/kryonix`, `/home/rocha/kryonix/kryonixos`, `/etc/kryonixos`).

---

## E1: `hosts/inspiron` no core — é resíduo?

### Comando
```bash
cd /home/rocha/kryonix/kryonix
rg -n "hosts/inspiron|nixosConfigurations\.inspiron" flake.nix flake/ hosts/ modules/ profiles/ docs/ scripts/ --glob '*.nix' --glob '*.md' --glob '*.sh' | grep -v '/archive/' | grep -v '/legacy_'
```

### Output relevante
```
hosts/common/default.nix:8:  # Mantém os hosts (inspiron, glacier, iso) focados em hardware/partições/boot.
modules/nixos/common/default.nix:485:  # Habilite por-host (ex.: hosts/inspiron/default.nix) com programs.winbox.enable = true.
modules/nixos/services/greetd-dms/default.nix:13:  # No host (ex.: hosts/inspiron/default.nix):
modules/nixos/branding/kryonix/default.nix:16:  # Importe este módulo em um host (ex.: hosts/inspiron/default.nix)
docs/ARCHITECTURE.md:18:  hosts/  # Definições base e ISO (common, inspiron base, iso)
docs/ai/FOLDER_STRUCTURE.md:15:  hosts/: hosts mantidos NESTE repo (motor) — apenas common/, inspiron/ e iso/.
```

### Segundo comando
```bash
rg -n "nixosConfigurations" flake.nix flake/ --glob '*.nix'
```

### Output
```
flake.nix:140:  nixosConfigurations = import ./flake/data/hosts.nix { inherit inputs lib; };
flake/checks.nix:55:  nixos-iso-drvpath
```

### Terceiro comando — conteúdo de `flake/data/hosts.nix`
```nix
{
  iso = inputs.nixpkgs.lib.nixosSystem { ... };
}
```

### Conclusão
**CONFIRMADO: O flake do core expõe APENAS `iso` como nixosConfiguration.**
`hosts/inspiron/` existe como diretório no core mas **não é exportado pelo flake**. É referenciado apenas em comentários/documentação como exemplo de uso. O verdadeiro `inspiron` vive no downstream (`kryonixos`). A afirmação da auditoria está correta, mas agora com evidência.

**Status: CONFIRMADO — resíduo/referência**

---

## E2: `profiles/glacier-*` no core — são usados?

### Comando
```bash
rg -n "glacier-ai|glacier-base|glacier-gamer|server-ai" /home/rocha/kryonix/kryonix /home/rocha/kryonix/kryonixos /etc/kryonixos --glob '*.nix' --glob '*.md' | grep -v '/archive/' | grep -v '/legacy_' | grep -v '/\.git/'
```

### Output relevante — core
```
./profiles/default.nix:21:  ./server-ai.nix
./profiles/default.nix:26:  ./glacier-base.nix
./profiles/default.nix:27:  ./glacier-ai.nix
./profiles/default.nix:28:  ./glacier-gamer.nix
```

### Output relevante — downstream (DEV + PROD)
```
hosts/glacier/default.nix:23:  kryonix.profiles.glacier-base.enable = true;
hosts/glacier/default.nix:24:  kryonix.profiles.glacier-ai.enable = true;
hosts/glacier/default.nix:25:  kryonix.profiles.glacier-gamer.enable = true;
```

### Conclusão
**CORREÇÃO NECESSÁRIA. Os profiles são ATIVOS e importados por `profiles/default.nix` no core, E ativados pelo downstream.** Não podem ser simplesmente removidos do core. No entanto, a questão arquitetural persiste: profiles específicos de servidor (com hardware paths, runtime config) deveriam estar no core ou no downstream?

**Status: PENDENTE DISCUSSÃO — ativos no core, usados no downstream. Decisão arquitetural necessária.**

---

## E3: Submódulo brain-lightrag vs flake input

### Comandos
```bash
git submodule status packages/kryonix-brain-lightrag
```
```
58d905d72102406055fc8816533baa10715a7b06 packages/kryonix-brain-lightrag (heads/main)
```

```bash
rg -A3 '"kryonix-brain-lightrag"' flake.lock
```
```
"rev": "95dfc2ec656e72bec1a5caaac032c22e56cb386d"
```

### Package que consome:
```nix
# packages/kryonix-brain-lightrag.nix
{ lib, stdenvNoCC, kryonix-brain-lightrag-src }:
stdenvNoCC.mkDerivation {
  src = kryonix-brain-lightrag-src;  # <-- VEM DO INPUT EXTERNO
  installPhase = ''mkdir -p $out; cp -r . $out/'';
}
```

### Conclusão
**CONFIRMADO: O submódulo (`58d905d`) está DESATUALIZADO em relação ao flake input (`95dfc2e`).** O package Nix usa `kryonix-brain-lightrag-src` que vem de `inputs.kryonix-brain-lightrag` — o submódulo é uma cópia local obsoleta NÃO utilizada pelo build.

**Status: CONFIRMADO — submódulo pode ser removido, build usa o input externo**

---

## E4: `kryonix-home` — input externo e referências

### Comandos
```bash
git submodule status packages/kryonix-home
```
```
0edd0ffcf0fae428071898b9a722a791ec926306 packages/kryonix-home (heads/main)
```

```bash
rg -n "kryonix-home|kryonixHome" flake.nix flake/ overlays/
```
```
flake.nix:96:    kryonix-home = { ... };  # input externo
flake/packages.nix:9:    kryonixHome = pkgs.callPackage ../packages/kryonix-home.nix { kryonixHomeSrc = inputs.kryonix-home; };
overlays/default.nix:290:  kryonix-home = final.callPackage ../packages/kryonix-home.nix { kryonixHomeSrc = inputs.kryonix-home; };
```

### Conclusão
**CONFIRMADO: `kryonix-home` JÁ é consumido como flake input externo** (`inputs.kryonix-home`). O submódulo em `packages/` segue o mesmo padrão do brain — cópia local que não é usada pelo build. O package `.nix` recebe `kryonixHomeSrc` do input.

**Status: CONFIRMADO — submódulo pode ser removido, build usa o input**

---

## E5: `.agents/` — LEGACY ou ativo?

### Comandos
```bash
find .agents -maxdepth 2 -type f | sort | wc -l
```
~50 arquivos

```bash
git log --oneline -5 -- .agents/
```
```
8e8f329a chore(repo): purge Hermes + audit cleanup pre-P0
9437cb70 refactor: retire Kora from Kryonix
a1c24ac5 chore: reorganiza diretórios (auditoria) — .agents/, docs/, docs/archive/
ff12fb65 feat(assets): add Jenifer voice preview and antigravity agent context
c2457be9 chore(voice): finalize voice pipeline integration, infrastructure skills, and refactor CLI
```

```bash
head -15 .agents/INDEX.md
```
```
A Kora foi removida... os papéis kora-* foram removidos.
## Agentes ativos
| kryonix-nixos-integrator | Integração NixOS & HM Declarativa | ... |
```

```bash
rg -n "\.agents" AGENTS.md
```
```
40: - Skills de IA: `.agents/skills/**`
```

### Conclusão
**CORREÇÃO NECESSÁRIA. `.agents/` NÃO é LEGACY.** AGENTS.md (canônico) referencia `.agents/skills/`. `.agents/INDEX.md` lista agentes ativos. `docs/agents/CONTEXT_ARCHITECTURE.md` descreve `.agents/rules/` e `.agents/workflows/` como mecanismos ativos. Há sobreposição com `.ai/`, `.claude/` e `docs/ai/`, mas `.agents/` em si é canônico.

**Status: CONFIRMADO — `.agents/` é ATIVO e canônico. Reclassificar como CANONICAL_AGENT_CONTEXT.**

---

## E6: `desktop/` — separar assets de config funcional

### Comandos
```bash
ls desktop/wallpapers/ desktop/sddm/  # assets puros
ls desktop/hyprland/core/             # config funcional
ls desktop/kde/*.nix                  # config funcional
```

### Conclusão
**Assets puros:** `desktop/sddm/kryonix-aurora/`, `desktop/wallpapers/kryonix-aurora/`, `assets/` (avatar, grub-theme, wallpaper png)
**Config funcional:** `desktop/hyprland/core/` (monitores, keybinds, cursor, dconf, mime, xdg), `desktop/kde/` (keybinds, tiling, focus, scheme, launcher, lockscreen, wallpaper config, etc.)
**Híbrido:** `desktop/kde/theme.nix`, `desktop/hyprland/theme/` — contêm lógica de tema + referências a assets

**Status: CONFIRMADO — separação necessária. Assets vão para repo de assets; config funcional fica no core como módulos.**

---

## E7: `kryonix-hardware-probe` usos

### Comando
```bash
rg -n "kryonix-hardware-probe|hardware-probe|hardwareProbe" . --glob '*.nix' --glob '*.md' --glob '*.sh'
```

### Output
```
specs/02-packages.md:23:  | Hardware | kryonix-hardware-probe | ...
hosts/iso/default.nix:128:  kryonix-hardware-probe
flake/packages.nix:15:  kryonixHardwareProbe = pkgs.callPackage ...
modules/nixos/installer/web-kiosk.nix:192:  KRYONIX_HARDWARE_PROBE = ...
modules/nixos/installer/default.nix:228:  pkgs.kryonix-hardware-probe
overlays/default.nix:293:  kryonix-hardware-probe = final.callPackage ...
packages/kryonix-cli/installer.sh:10:  kryonix-hardware-probe
packages/kryonix-cli.nix:26:  kryonix-hardware-probe
```

### Conclusão
**CONFIRMADO: `kryonix-hardware-probe` é usado por: ISO build, installer TUI, web-kiosk, CLI principal, overlay.** É compartilhado entre core (CLI `kryonix doctor` potencial), installer e ISO. A classificação `CORE_SHARED_CANDIDATE` está correta — não pode ser movido para o installer sem impactar a CLI.

**Status: CONFIRMADO — reclassificar como `CORE_SHARED`**

---

## E8: PR numeração — divergência

### Verificação
`07-migration-plan.md` lista PRs #91 a #98
`08-pr-backlog.md` lista PRs #90 a #98

### Conclusão
**CORREÇÃO NECESSÁRIA. O PR #90 (docs) aparece no backlog mas não no plano de migração.** Sincronizar numeração.

**Status: CORRIGIR — harmonizar #90-#98 em ambos os documentos**

---

## Sumário de correções necessárias

| Item | Afirmação original | Correção | Status |
|---|---|---|---|
| E1 | hosts/inspiron é resíduo | ✅ Correto, mas sem evidência | Adicionar evidência |
| E2 | profiles glacier-* devem sair do core | ❌ INCORRETO | São ativos e usados pelo downstream |
| E3 | brain-lightrag submódulo obsoleto | ✅ Correto | Adicionar diff de commits |
| E4 | kryonix-home consumido via input | ✅ Correto | Adicionar evidência |
| E5 | `.agents/` é LEGACY | ❌ INCORRETO | É ativo e canônico |
| E6 | desktop/ inteiro é asset | ❌ INCORRETO | Separar assets de config funcional |
| E7 | hardware-probe = INSTALLER_PRODUCT | ❌ PARCIAL | É CORE_SHARED (usado pela CLI) |
| E8 | PR numeração consistente | ❌ INCORRETO | Divergência entre docs |
