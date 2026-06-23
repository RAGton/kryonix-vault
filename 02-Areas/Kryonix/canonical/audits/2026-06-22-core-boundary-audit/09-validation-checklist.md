# Checklist de validação

## Antes de mover qualquer coisa

- [ ] `nix flake check --keep-going` passando no core
- [ ] `git status` limpo
- [ ] Branch separada para o PR
- [ ] Backup do estado atual (`git stash` ou branch backup)

## Depois de mover hosts (PR #91)

- [ ] `nix flake check --keep-going` no core SEM `hosts/inspiron/`
- [ ] `nix flake check --keep-going --impure` no downstream COM `hosts/inspiron/`
- [ ] Nenhuma referência quebrada a `.#nixosConfigurations.inspiron` no core
- [ ] `rg "hosts/inspiron"` no core não retorna resultados (exceto docs/archive)

## Depois de remover profiles (PR #92)

- [ ] `rg "glacier-ai|glacier-base|glacier-gamer" modules/ flake.nix` não retorna imports
- [ ] `nix flake check --keep-going` passando

## Depois de remover submódulo brain (PR #93)

- [ ] `nix build .#kryonix-brain-lightrag --no-link -L` funciona (vem do flake input)
- [ ] `packages/kryonix-brain-lightrag/` não existe mais

## Depois de separar home (PR #94)

- [ ] `nix build .#kryonix-home --no-link -L` funciona
- [ ] Overlay atualizado para consumir do input externo

## Depois de mover assets (PR #97)

- [ ] Build do `nixosConfigurations.iso` não quebra (ISO pode usar assets)
- [ ] Tema SDDM ainda é encontrado

## Depois de mover installer (PR #98)

- [ ] `nix build .#nixosConfigurations.iso.config.system.build.toplevel --no-link -L` no kryonix-installer
- [ ] Outputs do flake do core não expõem mais `nixosConfigurations.iso`

## Comandos seguros

```bash
nix flake check --keep-going
nix build .#<package> --no-link -L
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
rg "<pattern>" --glob '*.nix'
```

## Comandos proibidos

```bash
nixos-rebuild switch        # NUNCA durante auditoria/migração
kryonix switch              # NUNCA durante auditoria/migração
nix flake update            # Só quando explicitamente pedido
git reset --hard            # NUNCA
git clean -fdx              # NUNCA
rm -rf                      # NUNCA para diretórios versionados
```
