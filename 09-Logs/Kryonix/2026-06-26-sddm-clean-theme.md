# Implementacao do Kryonix SDDM Clean

Data: 2026-06-26
Agente: Codex
Repos afetados:

- repos/kryonix
- repos/kryonix-vault

## Objetivo

Adicionar um preset opt-in de tema SDDM chamado `Kryonix SDDM Clean`, sem
misturar a camada de login com o tema Plasma e sem alterar o comportamento
default atual dos hosts.

## Contexto consultado

- `repos/kryonix/AGENTS.md`
- `repos/kryonix-vault/AGENTS.md`
- `repos/kryonix-vault/VAULT_INDEX.md`
- `repos/kryonix/modules/nixos/desktop/kde/default.nix`
- `repos/kryonix/modules/nixos/desktop/default.nix`
- `repos/kryonix/desktop/hyprland/system.nix`
- `repos/kryonix/packages/kryonix-sddm-theme.nix`
- `repos/kryonix/docs/desktop/KRYONIX_SDDM.md`
- `repos/kryonixos/hosts/inspiron/default.nix`

## Diagnostico

1. O projeto ja usa `SDDM` hoje.
2. O fluxo KDE usa SDDM Wayland em `modules/nixos/desktop/kde/default.nix`.
3. O fluxo Hyprland continua com SDDM + `sddm-astronaut-theme`.
4. Ja existia tema SDDM proprio: `kryonix-aurora`.
5. O host downstream explicitamente afetado por opt-in antigo e o `inspiron`
   (`kryonix.desktop.kde.sddm.theme = "kryonix-aurora"`).
6. Era viavel adicionar preset novo sem trocar o default.

## Mudancas realizadas

- refatorado `packages/kryonix-sddm-theme.nix` para empacotar:
  - `kryonix-aurora`
  - `kryonix-clean`
- criado `desktop/sddm/kryonix-clean/` com:
  - `Main.qml`
  - `metadata.desktop`
  - `theme.conf`
  - `README.md`
  - `assets/background-dark.svg`
  - `assets/background-light.svg`
  - `assets/logo.svg`
  - `assets/avatar-placeholder.svg`
- criado `modules/nixos/desktop/sddm/default.nix`
- integrado o novo modulo em `modules/nixos/desktop/default.nix`
- mantida compatibilidade com o caminho legado:
  - `kryonix.desktop.kde.sddm.theme = "kryonix-aurora"`
- criado o caminho canônico novo:
  - `kryonix.desktop.sddm.theme.preset = "default" | "kryonix-clean"`
- mantido o default efetivo atual:
  - KDE continua com Breeze por default
  - Hyprland continua no fluxo atual com astronaut
- documentacao adicionada:
  - `docs/desktop/SDDM.md`
  - `docs/desktop/KRYONIX_SDDM_CLEAN.md`

## Estrutura tecnica do tema

- tema SDDM separado da camada Plasma;
- QML simples, sem dependencia de internet;
- card central com legibilidade alta;
- visual glass leve com fallback sem blur real;
- usuario, sessao, layout de teclado e mensagens de erro continuam expostos;
- botoes de energia respeitam capacidades do `sddm`.

## Validacoes executadas

### Core `repos/kryonix`

- `git diff --check`
- `nix flake show --all-systems`
- `nix build .#kryonix-sddm-theme --no-link -L --show-trace`
- `nix flake check --keep-going`
- `git diff --cached --stat`
- `git diff --cached | rg -n "api[_-]?key|token|secret|password|passwd|bearer|authorization|private|id_ed25519|KRYONIX_BRAIN_API_KEY|NEO4J_AUTH|BEGIN .*PRIVATE" -i || true`
- `rg -n "kryonix-clean|kryonix-aurora|kryonix.desktop.sddm.theme.preset|kryonix.desktop.kde.sddm.theme|services\\.displayManager\\.sddm" modules desktop docs packages hosts profiles`

### Downstream `repos/kryonixos`

- `nix flake check --keep-going`
- `nix build .#nixosConfigurations.inspiron.config.system.build.toplevel --no-link -L --show-trace`

## Evidencias

- `.#kryonix-sddm-theme` continuou exposto em `nix flake show --all-systems`
- build do pacote `kryonix-sddm-theme-1.1` passou
- `nix flake check --keep-going` do core passou apos ajuste de `nixfmt`
- `nix flake check --keep-going` do downstream passou
- build do `nixosConfigurations.inspiron.config.system.build.toplevel` passou
- nenhum `--impure` foi necessario

## Classificacao final

- uso atual de SDDM no projeto: PASS
- preset opt-in `kryonix-clean`: PASS
- default preservado: PASS
- compatibilidade com `kryonix-aurora`: PASS
- validacao de build do pacote: PASS
- validacao downstream: PASS
- preview runtime com `sddm-greeter --test-mode`: WARN
- switch runtime em host real: WARN

## Riscos restantes

- o preview visual do greeter nao foi executado nesta sessao;
- o tema novo foi integrado apenas ao fluxo KDE no caminho canônico;
- Hyprland foi preservado no fluxo atual, sem migracao para o preset novo.

## Rollback

1. voltar `kryonix.desktop.sddm.theme.preset = "default";`
2. se o host usa o caminho legado, voltar `kryonix.desktop.kde.sddm.theme = "breeze";`
3. validar com `kryonix test`
4. aplicar depois com `kryonix switch`

## Commits e branches

Commits previstos no core:

- `feat(sddm): add Kryonix Clean login theme package`
- `feat(sddm): wire opt-in SDDM theme preset`
- `docs(sddm): document Kryonix Clean login theme`

Commit previsto no Vault:

- `docs(vault): log SDDM Clean implementation`

## Proximo passo recomendado

Executar preview local do greeter:

```bash
THEME_PATH="$(nix build .#kryonix-sddm-theme --no-link --print-out-paths)/share/sddm/themes/kryonix-clean"
sddm-greeter --test-mode --theme "$THEME_PATH"
```

Se o host estiver pronto para teste controlado:

```bash
kryonix test
kryonix switch
```
