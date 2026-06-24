---
title: "Resoluções arquiteturais — GPU/CPU features batch"
type: log
status: completed
tags: [kryonix, architecture, features, resolutions, gpu, cpu, nvidia, amd]
created: 2026-06-24
---

# Resoluções arquiteturais — GPU/CPU features batch (PRs 96-100)

## Problemas encontrados e resoluções

### 1. `hardware.nvidia.package` — definição duplicada

**Problema**: A feature NVIDIA e o profile `glacier-base.nix` ambos definiam
`hardware.nvidia.package` com prioridade direta, causando erro:
```
error: The option `hardware.nvidia.package' is defined multiple times
while it's expected to be unique.
```

**Resolução**: Usar `lib.mkDefault` no valor retornado pelo `lib.mkIf`:

```nix
hardware.nvidia.package = lib.mkIf (cfg.nvidia.package != "default") (
  lib.mkDefault (
    # ... package selection logic
  )
);
```

Isso permite que profiles ou hosts que definem o package diretamente
(prioridade mais alta) coexistam sem conflito.

**Aprendizado**: Sempre que uma feature pode coexistir com um profile que
define a mesma opção, usar `lib.mkDefault` para que o profile tenha prioridade.

---

### 2. `services.xserver.videoDrivers` — concatenação vs conflito

**Problema**: Quando NVIDIA e AMD estão habilitados juntos, ambas as features
definem `services.xserver.videoDrivers` com `lib.mkDefault`. No NixOS module
system, opções do tipo `listOf` com a mesma prioridade são **concatenadas**,
não sobrescritas.

**Resultado**: `["nvidia", "amdgpu", "nvidia"]` — com duplicata inócua.

**Resolução**: Aceitar a concatenação — ambos os drivers estão presentes.
O host pode sobrescrever explicitamente se quiser uma lista limpa:

```nix
services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];  # sobrescreve mkDefault
```

**Aprendizado**: List options no NixOS concatenam definições de mesma
prioridade. `mkDefault` em features diferentes → concatenação automática.
Para lista limpa, o host define diretamente.

---

### 3. `nixpkgs.config.cudaSupport` — escopo global vs per-package

**Problema**: Ativar `cudaSupport` globalmente faz todos os pacotes com
suporte CUDA serem rebuildados — caro e desnecessário.

**Resolução**: A opção `kryonix.features.gpu.cuda.cudaSupport.enable` existe
mas fica `false` por padrão. A abordagem recomendada no Kryonix é usar
overrides por pacote:

```nix
pkgs.llama-cpp.override { cudaSupport = true; }
```

**Aprendizado**: `nixpkgs.config.cudaSupport` global é uma ferramenta pesada.
Preferir per-package override.

---

### 4. Perda de `amdgpu` ao remover glacier-base

**Problema**: Quando o bloco NVIDIA do `profiles/glacier-base.nix` foi removido
(PR #99), o driver `amdgpu` (iGPU AMD do Ryzen 7 9700X) foi perdido porque
a feature NVIDIA só define `[ "nvidia" ]`.

**Resolução**: Três passos:
1. Preservar `services.xserver.videoDrivers = [ "nvidia" "amdgpu" ]` no host
2. Criar `kryonix.features.gpu.amd` (PR #100)
3. Após validar via `nix eval` que ambos drivers estavam presentes, remover
   o fallback manual

**Aprendizado**: Nunca remover `videoDrivers` explícito de um host sem antes
ter a feature AMD correspondente. Validar sempre com `nix eval` antes de
remover fallback.

---

### 5. Branch PR empilhada — merge order

**Problema**: PR #97 (CPU) continha commits do PR #96 (GPU) porque foi
criado antes do merge do PR #96. O diff mostrava arquivos de ambos.

**Resolução**:
1. Mergear PR #96 primeiro
2. Rebasear PR #97 sobre o novo `main`
3. Force-push para limpar o diff
4. PR #97 passou a mostrar só arquivos de CPU

```bash
gh pr merge 96 --merge --delete-branch
git switch pr-06-cpu-intel-amd
git rebase origin/main
git push --force origin pr-06-cpu-intel-amd
```

**Aprendizado**: PRs empilhados devem ser rebaseados após o merge do PR
base. `git rebase origin/main` elimina commits já presentes no main.

---

### 6. `lib.mkForce` vs `lib.mkDefault`

**Regra estabelecida**: No ecossistema Kryonix:
- **Features usam `lib.mkDefault`** — o host pode sobrescrever
- **Hosts usam valor direto** — override final
- **`lib.mkForce`** é reservado para casos excepcionais (boot loader, por
  exemplo, onde o host precisa desabilitar algo que o upstream força)

---

### 7. Feature Registry vs Schema

**Decisão**: O schema (`modules/nixos/features/schema.nix`) declara as opções.
O registry (`modules/nixos/features/registry.nix`) contém metadados. Ambos
são carregados via `modules/nixos/features/default.nix`.

**Separação de responsabilidades**:
| Arquivo | O que faz |
|---|---|
| `features/gpu.nix` | Declara opções + implementação (Intel, NVIDIA, AMD, CUDA) |
| `features/cpu.nix` | Declara opções + implementação (Intel, AMD) |
| `modules/nixos/features/schema.nix` | Apenas declara opções (schema público) |
| `modules/nixos/features/registry.nix` | Metadados das features |

---

## Checklist para futuros PRs de features

Antes de criar uma nova feature:

1. [ ] Feature existe no schema `modules/nixos/features/schema.nix`?
2. [ ] Feature está catalogada no registry `modules/nixos/features/registry.nix`?
3. [ ] Feature usa `lib.mkDefault` para coexistir com profiles?
4. [ ] Feature é importada via `features/default.nix`?
5. [ ] Todas as subopções têm `default = false` ou valor seguro?
6. [ ] Docs em `docs/hardware/` existem?
7. [ ] `nix flake check --keep-going` passa?

Ao migrar um host para feature:

1. [ ] Adicionar feature no host (`kryonix.features.<categoria>.<nome>.enable = true`)
2. [ ] Validar com `nix eval` que o valor final está correto
3. [ ] Remover bloco hardcoded
4. [ ] Validar novamente com `nix eval`
5. [ ] Build do host passa?
6. [ ] Se houver conflito de `mkDefault` (ex: dois drivers), o host define explicitamente