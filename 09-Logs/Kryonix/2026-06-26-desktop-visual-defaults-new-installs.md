# Kryonix Desktop Visual Defaults para Novas Instalações

Data: 2026-06-26
Agente: Codex
Repos afetados:

- `repos/kryonix`
- `repos/kryonixos`
- `repos/kryonix-vault`

## Objetivo

Publicar primeiro o upstream `repos/kryonix` com os commits visuais já validados e,
depois, aplicar no downstream `repos/kryonixos` defaults visuais para instalações
desktop padrão via `lib.mkDefault`, sem tornar o módulo global obrigatório.

## Contexto consultado

- `repos/kryonix-vault/AGENTS.md`
- `repos/kryonix-vault/VAULT_INDEX.md`
- `repos/kryonix-vault/09-Logs/Kryonix/2026-06-26-kde-blue-glass.md`
- `repos/kryonix-vault/09-Logs/Kryonix/2026-06-26-sddm-clean-theme.md`
- `repos/kryonix-vault/09-Logs/Kryonix/2026-06-26-branding-kde-sddm-wallpapers.md`
- `repos/kryonix-vault/09-Logs/Kryonix/2026-06-26-waywallen-wallpaper-dinamico.md`

## Mudanças realizadas

1. Publicado `repos/kryonix` em `origin/main` no commit `d39fec0`, contendo os
   commits visuais já validados:
   - `3e89ab0` `feat(branding): add shared Kryonix branding package`
   - `1e76627` `refactor(branding): reuse shared assets in KDE and SDDM`
   - `2c1bf10` `docs(branding): document shared KDE and SDDM branding`
   - `f74cedf` `style(nix): format removed options module`
   - `17101cd` `feat(desktop): add opt-in waywallen wallpaper integration`
   - `358689d` `docs(desktop): document dynamic wallpaper support`
   - `d39fec0` `fix(features): use programs.virt-manager in virtualization feature`
2. Atualizado no downstream apenas o input `kryonix` do `flake.lock`:
   - de `9a507171c36fea54cb111ad0542124ae67882e4a`
   - para `d39fec040eecd40248a24aee55aaf92ff0385c6f`
3. Criado profile local `repos/kryonixos/profiles/desktop-visual-defaults.nix`
   com defaults via `lib.mkDefault`:
   - `kryonix.desktop.kde.theme.preset = "kryonix-blue-glass-dark"`
   - `kryonix.desktop.sddm.theme.preset = "kryonix-clean"`
   - `kryonix.desktop.wallpaper.dynamic.enable = true`
   - `engine = "waywallen"`
   - `steam.enable = false`
   - `wallpaperEngine.enable = false`
4. Importado o profile apenas em:
   - `hosts/inspiron/default.nix`
   - `hosts/inspiron-nina/default.nix`
5. `glacier` permaneceu intocado.

## Commits e branches

- `repos/kryonix`
  - branch local antes do push: `fix/virtualization-virt-manager-program`
  - publicado em `origin/main`: `d39fec0`
- `repos/kryonixos`
  - commit esperado: `feat(desktop): enable Kryonix visual defaults for new installs`
- `repos/kryonix-vault`
  - commit esperado: `docs(vault): log desktop visual defaults activation`

## Validações executadas

- `PASS` `repos/kryonix: git status --short`
- `PASS` `repos/kryonix: git diff --stat`
- `PASS` `repos/kryonix: git diff --check`
- `PASS` `repos/kryonix: secret scan no diff`
- `PASS` `repos/kryonix: nix flake check --keep-going`
- `PASS` `repos/kryonix: git push origin HEAD:main`
- `PASS` `git ls-remote https://github.com/RAGton/kryonix.git refs/heads/main`
- `PASS` `repos/kryonixos: nix flake lock --update-input kryonix`
- `PASS` `repos/kryonixos: git diff --check`
- `PASS` `repos/kryonixos: nix flake check 'path:.' --keep-going`
- `PASS` `repos/kryonixos: nix build 'path:.#nixosConfigurations.inspiron.config.system.build.toplevel' --no-link -L --show-trace`

## Evidências

- O remoto `RAGton/kryonix` avançou para `d39fec040eecd40248a24aee55aaf92ff0385c6f`.
- `origin/main` passou a conter `358689d`.
- O downstream voltou a reconhecer `kryonix.desktop.wallpaper.dynamic`.
- O preset ficou ativo por default apenas nos hosts desktop downstream que
  importam o profile local, sem alterar o default global do motor.

## Pendências

- Não houve `switch`; estado runtime permanece `UNKNOWN`.
- Não houve ativação em ISO/installer; escopo aplicado apenas aos hosts
  downstream `inspiron` e `inspiron-nina`.
- O cliente ainda pode sobrescrever qualquer valor no host com definição
  explícita, pois foi usado `lib.mkDefault`.

## Próximo passo recomendado

Executar manualmente, quando for desejado validar runtime:

```bash
PATH="/run/wrappers/bin:$PATH" kryonix switch inspiron --dry
PATH="/run/wrappers/bin:$PATH" kryonix switch inspiron
```
