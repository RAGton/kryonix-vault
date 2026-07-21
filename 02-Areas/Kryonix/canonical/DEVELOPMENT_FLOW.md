# Development Flow

## Ciclo de desenvolvimento

1. **DEV** → `/home/rocha/kryonix/kryonix` (ou kryonixos, ou kryxd)
2. **Commit** → `git add <arquivos explícitos>` (NUNCA `git add .`)
3. **PR** → GitHub PR para `main`
4. **CI** → `nix flake check --keep-going` no PR
5. **Merge** → Aprovado por Gabriel
6. **Sync** → `git pull --ff-only origin main` em `/etc/kryonix` ou `/etc/kryonixos`

## Regras

- Branches: `feat/<nome>`, `fix/<nome>`, `refactor/<nome>`
- Commits: `feat(nixos):`, `fix(installer):`, `refactor(core):`, `docs(vault):`
- PRs pequenos: cada PR faz uma coisa só
- Validação: `nix flake check --keep-going` antes de qualquer PR
- Rollback: `git revert` do commit ou PR

## Comandos seguros

```bash
nix flake check --keep-going
nix build .#<package> --no-link -L
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
```

## Links

[[CORE_DOWNSTREAM_INSTALLER]]
[[BOUNDARIES]]
