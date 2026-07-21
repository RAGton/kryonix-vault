# Hosts reais e fronteira com downstream

## Hosts encontrados no core

| Host | Core | Downstream (kryonixos) | Status |
|---|---|---|---|
| `inspiron` | ✅ `hosts/inspiron/` (residual) | ✅ `hosts/inspiron/` (ativo) | **DUPLICADO** — remover do core |
| `glacier` | ❌ Ausente | ✅ `hosts/glacier/` (ativo) | Correto — só no downstream |
| `inspiron-nina` | ❌ Ausente | ✅ `hosts/inspiron-nina/` (ativo) | Correto — só no downstream |
| `iso` | ✅ `hosts/iso/` (ativo) | ❌ Ausente | Deve ir para kryxd |
| `common` | ✅ `hosts/common/` (ativo) | ❌ Ausente | Correto — shared module |

## O que deve ir para kryonixos

**Do core → kryonixos:**
- `hosts/inspiron/default.nix` (config real da máquina)
- `hosts/inspiron/disks.nix` (layout de disco real com UUIDs)
- `hosts/inspiron/hardware-configuration.nix` (hardware real)
- `profiles/glacier-ai.nix` (perfil de servidor)
- `profiles/glacier-base.nix` (perfil de servidor)
- `profiles/glacier-gamer.nix` (perfil de servidor)
- `profiles/server-ai.nix` (perfil de servidor)

## O que deve permanecer como template

- `hosts/common/default.nix` — template de common compartilhado
- `profiles/laptop.nix`, `profiles/vm.nix`, `profiles/workstation-gamer.nix` — templates genéricos

## Como o downstream deve consumir o core

O downstream (`kryonixos`) já segue o padrão correto:
```
inputs.kryonix.url = "git+file:///etc/kryonix"
```

E usa `inputs.kryonix.nixosModules` e `inputs.kryonix.lib` para montar os hosts.

## Plano de migração seguro

1. Confirmar que `hosts/inspiron` no core NÃO é referenciado pelo flake outputs
2. Remover `hosts/inspiron/` do core
3. Remover `profiles/glacier-*.nix` do core (verificar se há imports)
4. Validar build do kryonixos com `nix flake check --keep-going`
5. Commit e merge
