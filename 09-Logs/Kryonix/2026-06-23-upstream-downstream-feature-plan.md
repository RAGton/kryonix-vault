---
title: "Auditoria e plano de arquitetura upstream/downstream/features"
type: session
status: completed
tags: [kryonix, architecture, features, profiles, audit, plan, vault]
created: 2026-06-23
agente: Aura
repos: [kryonix, kryonixos, kryonix-installer, kryonix-vault]
---

# 2026-06-23 — Plano de arquitetura upstream/downstream/features

## Contexto

Após a migração do workspace `kryonix-dev` e a limpeza do core,
identificamos a necessidade de refinar a arquitetura de features
e profiles entre upstream (core), downstream (kryonixos) e installer.

## O que foi feito

### Auditoria completa de profiles/features

Foram auditados:

1. **Core (`repos/kryonix`)**:
   - 3 sistemas paralelos de features: `features/`, `modules/nixos/features/`, `profiles/`
   - Profiles host-specific: `glacier-base`, `glacier-ai`, `glacier-gamer`
   - Duplicata: `server-ai.nix` (mesmo que `glacier-ai.nix`)
   - Configurações acopladas em profiles que deveriam ser features atômicas

2. **Downstream (`repos/kryonixos`)**:
   - 3 hosts: `inspiron`, `inspiron-nina`, `glacier`
   - Inspiron ativa features de 5 formas diferentes (opções diretas, profiles, imports, serviços, features)
   - Redundância entre profiles e features
   - Kernel Zen e bridge network importados direto por path

3. **Installer (`repos/kryonix-installer`)**:
   - `featureCatalog.js` com profiles que não correspondem aos do core
   - Já gera `features.generated.nix` na target tree
   - Já tem lógica de escrita de features

### Plano canônico criado

Arquivo: `02-Areas/Kryonix/canonical/UPSTREAM_DOWNSTREAM_FEATURE_ARCHITECTURE_PLAN.md`

Contém:
- Contexto arquitetural (5 camadas)
- Regra central de responsabilidades
- Problemas atuais documentados
- Arquitetura alvo com definições
- Feature Registry conceitual
- Schema público `kryonix.features.*`
- Modelo downstream (features.generated.nix + features.local.nix)
- Modelo para o installer (presets, fluxo UI)
- Hosts reais: Inspiron e Glacier com features recomendadas
- Checklist de implementação (Fase 0-8)
- Plano de 12 PRs recomendados
- Validações por PR
- Riscos e mitigações
- Critérios de conclusão

## Consultas realizadas no Vault

- `01-MOCs/MOC - Kryonix Core Boundaries`
- `02-Areas/Kryonix/canonical/BOUNDARIES`
- `02-Areas/Kryonix/canonical/CORE_DOWNSTREAM_INSTALLER`
- `02-Areas/Kryonix/canonical/DEVELOPMENT_FLOW`
- `02-Areas/Kryonix/systems/Inspiron`
- `02-Areas/Kryonix/systems/Glacier`
- `02-Areas/Kryonix/systems/Vault`
- `09-Logs/2026-06-22 - Kryonix core boundary audit`
- `03-Projetos/Kryonix Installer`
- `03-Projetos/Kryonix System`

## Arquivos consultados nos repos

### Core (repos/kryonix)

```
profiles/default.nix
profiles/laptop.nix
profiles/desktop.nix
profiles/dev/default.nix
profiles/glacier-base.nix
profiles/glacier-ai.nix
profiles/glacier-gamer.nix
profiles/server-ai.nix
profiles/workstation-gamer.nix
profiles/virtualization.nix
features/default.nix
features/workstation.nix
features/gaming.nix
features/virtualization.nix
features/development.nix
features/ai.nix
features/remote-desktop.nix
modules/nixos/features/default.nix
modules/nixos/features/desktop.nix
modules/nixos/features/ai.nix
modules/nixos/features/gamer.nix
modules/nixos/features/server.nix
modules/nixos/features/remote.nix
modules/nixos/common/default.nix
modules/kernel/zen.nix
modules/virtualization/net-ragthink.nix
flake.nix
```

### Downstream (repos/kryonixos)

```
hosts/inspiron/default.nix
hosts/inspiron/hardware-configuration.nix
hosts/inspiron/disks.nix
hosts/inspiron-nina/default.nix
hosts/glacier/default.nix
hosts/glacier/rve-compat.nix
flake.nix
```

### Installer (repos/kryonix-installer)

```
ui/src/data/featureCatalog.js
ui/src/pages/Profile.jsx
ui/src/pages/SystemFeatures.jsx
src/executor/target_tree.rs
```

## Arquivos criados

| Arquivo | Tipo |
|---|---|
| `02-Areas/Kryonix/canonical/UPSTREAM_DOWNSTREAM_FEATURE_ARCHITECTURE_PLAN.md` | Plano canônico |
| `09-Logs/Kryonix/2026-06-23-upstream-downstream-feature-plan.md` | Log de sessão |

## Pendências

- Nenhum código foi alterado (conforme regras)
- PRs reais começam após aprovação do plano
- Decisão pendente: ordem exata dos PRs
- Decisão pendente: quantos ciclos de compat para `glacier-*`

## Próximo passo recomendado

1. Revisar e aprovar o plano
2. Iniciar PR 1 — core feature schema (opções públicas, default=false)
3. Seguir checklist por fase

## Validações executadas

- `git status -sb` em todos os 4 repos: ✅ limpos
- `git submodule status` no kryonix-dev: ✅ 8/8 heads/main
- Conteúdo dos arquivos auditados: ✅ lido e classificado