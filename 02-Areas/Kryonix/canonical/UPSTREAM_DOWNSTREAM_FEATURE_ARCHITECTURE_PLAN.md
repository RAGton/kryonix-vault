---
title: "Upstream/Downstream/Installer — Feature Architecture Plan"
type: canonical
status: draft
tags: [kryonix, architecture, features, profiles, upstream, downstream, installer]
created: 2026-06-23
updated: 2026-06-23
---

# Upstream/Downstream/Installer — Feature Architecture Plan

> Plano canônico de refatoração da arquitetura de features, profiles e boundaries
> entre core (upstream), hosts (downstream), installer e vault.

---

## 1. Contexto arquitetural

```
upstream/core:
  repo: repos/kryonix
  papel: fornecer módulos, opções públicas, features, profiles genéricos,
         templates e contratos

downstream:
  repo: repos/kryonixos
  papel: conter hosts reais, usuários reais, hardware real e ativação
         das features por host

installer:
  repo: repos/kryonix-installer
  papel: coletar escolhas do usuário e escrever arquivos declarativos
         em /etc/kryonixos

dev workspace:
  repo: kryonix-dev
  papel: workspace oficial multi-repo, agentes, scripts, coordenação
         e submodules

vault:
  repo: repos/kryonix-vault
  papel: memória persistente, decisões, rastreabilidade, auditorias
         e planos
```

---

## 2. Regra central

```
core/upstream  →  decide quais features existem
downstream     →  decide quais features estão ativas
installer      →  decide como perguntar e gerar configuração
vault          →  registra decisões, histórico e evidências
kryonix-dev    →  coordena o trabalho multi-repo
```

Nenhuma camada invade a responsabilidade da outra:

- O core **não** decide se uma feature está ativa num host real.
- O downstream **não** define novas features (só ativa as existentes).
- O installer **não** edita o core nem sobrescreve configuração local do usuário.
- O vault **não** contém código — só memória e rastreabilidade.

---

## 3. Problemas atuais

### 3.1 Responsabilidades sobrepostas

Existem **três sistemas paralelos** de features/profiles com namespaces confusos:

| Camada | Onde vive | Exemplo | Problema |
|---|---|---|---|
| `features/` | core (profile-layer) | `kryonix.features.gaming.enable` | Concorre com modules/nixos/features/ |
| `modules/nixos/features/` | core (module-layer) | `kryonix.features.gamer.steam.enable` | Namespace similar mas diferente |
| `profiles/` | core | `kryonix.profiles.glacier-gamer.enable` | Profiles host-specific no core |

### 3.2 Profiles host-specific no core

Profiles que deveriam estar no downstream ou serem genéricos:

| Profile | Problema |
|---|---|
| `glacier-base.nix` | NVIDIA, SSH, Tailscale, Fail2Ban, branding — tudo host-specific |
| `glacier-ai.nix` | Ollama + Brain + LightRAG + CUDA — host-specific |
| `glacier-gamer.nix` | Gaming + desktop — poderia ser genérico |
| `server-ai.nix` | Duplicata do glacier-ai |

### 3.3 Configurações acopladas em profiles/base

Configurações que deveriam ser features atômicas independentes:

- kernel Zen
- rede bridge (`net-ragthink.nix`)
- Tailscale
- SSH
- NVIDIA/CUDA
- libvirt/KVM
- comportamento Proxmox-like (bridge + libvirt + firewall)
- Brain/Ollama/LightRAG/Neo4j
- OpenRGB
- GPU drivers (Intel, AMD, NVIDIA)

### 3.4 Inspiron com ativações misturadas

O host `inspiron` ativa features via:

1. Opções diretas no `default.nix`
2. Profiles (laptop, dev, virtualization, tools, university, ti)
3. Imports diretos de path (`zen.nix`, `net-ragthink.nix`)
4. Serviços diretos (`services.kryonix.tailscale`)
5. Features (`ai.brain`, `remoteDesktop.client`)

Isso dificulta entender o que está ativo e por quê.

### 3.5 Installer com catálogo próprio

O installer tem `featureCatalog.js` com profiles como `desktop-plasma`,
`developer`, `kryonix-full` que **não** correspondem aos profiles reais
do core. Risco de divergência.

### 3.6 Downstream sem separação gerado/local

O downstream hoje não separa o que foi gerado pelo installer do que foi
editado manualmente pelo usuário. Se o installer re-escrever o arquivo,
configuração local pode ser perdida.

---

## 4. Arquitetura alvo

### 4.1 Definições

```
feature  = capacidade atômica (ex: desktop.plasma, gpu.nvidia)
profile  = preset/bundle genérico que ativa várias features (ex: laptop-dev)
host     = decisão real de ativação num arquivo features.nix por host
installer preset = UI que expande para flags em features.generated.nix
```

### 4.2 Exemplo concreto

```txt
features:
  desktop.plasma
  desktop.hyprland
  desktop.audio
  desktop.bluetooth
  desktop.printing
  gpu.intel
  gpu.nvidia
  gpu.cuda
  gpu.amd
  kernel.zen
  kernel.hardened
  kernel.lowLatency
  network.tailscale
  network.bridge
  network.vlan
  network.firewall.strict
  remote.ssh
  remote.desktop.client
  remote.desktop.server
  development.*
  virtualization.libvirt
  virtualization.podman
  virtualization.docker
  virtualization.proxmoxLike
  ai.brain.client
  ai.brain.server
  ai.ollama
  ai.lightrag
  ai.neo4j
  gaming.*
  server.*
  hardware.laptop
  hardware.sensors

profiles (genéricos, no core):
  desktop-dev
  laptop-dev
  ai-server
  gaming-workstation
  minimal-server

hosts (no downstream, com ativação granular):
  inspiron
  inspiron-nina
  glacier
  iso
```

---

## 5. Feature Registry

O core deve expor um **Feature Registry** — fonte de verdade única para
metadados de cada feature.

### 5.1 Formato conceitual

```nix
{
  id = "desktop.plasma";
  label = "KDE Plasma";
  category = "desktop";
  risk = "medium";
  default = false;
  conflicts = [ "desktop.hyprland" ];
  requires = [ "desktop.audio" ];
  installerVisible = true;
  experimental = false;
  requiresReboot = true;
  affects = [ "boot" ];
}
```

### 5.2 Atributos por feature

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | string | Identificador único (ex: `desktop.plasma`) |
| `label` | string | Nome amigável para UI |
| `category` | string | Categoria agrupadora |
| `risk` | `"low"` / `"medium"` / `"high"` | Risco de ativar |
| `default` | bool | `false` (sempre opt-in) |
| `conflicts` | list[string] | Features incompatíveis |
| `requires` | list[string] | Dependências obrigatórias |
| `installerVisible` | bool | Aparece na UI do installer? |
| `experimental` | bool | Ainda não estável? |
| `requiresReboot` | bool | Precisa de reboot após ativar? |
| `affects` | list[string] | Domínios afetados: `boot`, `network`, `gpu`, `storage`, `ssh` |

### 5.3 Consumo pelo installer

O installer deve consumir o Feature Registry (como JSON exportado ou
catálogo espelhado validado) para:

- Renderizar a tela de seleção de features
- Validar conflitos e dependências
- Agrupar por categoria
- Exibir risco e badges
- Gerar presets

---

## 6. Schema público de features

Namespace único: `kryonix.features.*`

### 6.1 Schema completo proposto

```nix
kryonix.features = {
  base.enable;

  # Desktop
  desktop.plasma.enable;
  desktop.hyprland.enable;
  desktop.audio.enable;
  desktop.bluetooth.enable;
  desktop.printing.enable;

  # Hardware
  hardware.laptop.enable;
  hardware.sensors.enable;

  # GPU
  gpu.intel.enable;
  gpu.amd.enable;
  gpu.nvidia.enable;
  gpu.cuda.enable;

  # Kernel
  kernel.zen.enable;
  kernel.hardened.enable;
  kernel.lowLatency.enable;

  # Network
  network.tailscale.enable;
  network.bridge.enable;
  network.vlan.enable;
  network.firewall.strict.enable;

  # Remote access
  remote.ssh.enable;
  remote.ssh.port;
  remote.desktop.client.enable;
  remote.desktop.server.enable;

  # Development
  development.enable;
  development.languages.nix.enable;
  development.languages.rust.enable;
  development.languages.python.enable;
  development.languages.c.enable;
  development.languages.go.enable;
  development.editors.vscode.enable;

  # Virtualization
  virtualization.enable;
  virtualization.libvirt.enable;
  virtualization.podman.enable;
  virtualization.docker.enable;
  virtualization.proxmoxLike.enable;

  # AI
  ai.brain.client.enable;
  ai.brain.server.enable;
  ai.ollama.enable;
  ai.lightrag.enable;
  ai.neo4j.enable;

  # Gaming
  gaming.enable;
  gaming.steam.enable;
  gaming.lutris.enable;
  gaming.gamemode.enable;
  gaming.mangohud.enable;

  # Server
  server.enable;
  server.containers.enable;
  server.database.enable;
  server.reverseProxy.enable;
};
```

### 6.2 Regras de nomenclatura

| Correto | Incorreto | Motivo |
|---|---|---|
| `kryonix.features.kernel.zen.enable` | `kryonix.features.kernel-zen.enable` | Hierarquia com ponto, não hífen |
| `kryonix.features.remote.ssh.enable` | `kryonix.features.network.ssh.enable` | SSH é remote, não network |
| `kryonix.features.remote.desktop.client.enable` | `kryonix.features.remoteDesktop.client.enable` | camelCase não, hierarchy sim |
| `kryonix.features.ai.brain.client.enable` | `kryonix.features.ai.brain` com role=client | Flags booleanas explícitas, não enum |
| `kryonix.features.ai.brain.server.enable` | `kryonix.features.ai.brain` com role=server | Idem |

---

## 7. Modelo downstream

### 7.1 Estrutura de diretório por host

```
/etc/kryonixos/hosts/<hostname>/
├── default.nix                 ← entry point
├── hardware-configuration.nix  ← gerado por nixos-generate-config
├── disks.nix                   ← disko, se aplicável
├── network.nix                 ← IP, bridge, DNS
├── features.generated.nix      ← escrito pelo installer
├── features.local.nix          ← editado pelo usuário manualmente
└── users.nix                   ← usuários e permissões
```

### 7.2 Regras

```
features.generated.nix = escrito pelo installer (NUNCA editado manualmente)
features.local.nix     = editado pelo usuário (NUNCA sobrescrito pelo installer)
default.nix            = importa hardware + features.generated + features.local
```

### 7.3 Exemplo de `default.nix`

```nix
{ inputs, lib, pkgs, hostname, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ./network.nix
    ./features.generated.nix
    ./features.local.nix
  ];

  networking.hostName = hostname;
  system.stateVersion = "26.05";
}
```

### 7.4 Exemplo de `features.generated.nix` (escrito pelo installer)

```nix
{ ... }: {
  kryonix.features = {
    desktop.plasma.enable = true;
    desktop.audio.enable = true;
    desktop.bluetooth.enable = true;
    desktop.printing.enable = true;
    development.enable = true;
    network.tailscale.enable = true;
    ai.brain.client.enable = true;
    ai.brain.server.enable = false;
    ai.ollama.enable = false;
    gaming.enable = false;
  };
}
```

### 7.5 Exemplo de `features.local.nix` (editado pelo usuário)

```nix
{ ... }: {
  # Overrides locais que o installer não deve tocar
  kryonix.features = {
    gaming.enable = true;
  };
}
```

---

## 8. Modelo para o installer

### 8.1 Princípios

1. Exibir presets amigáveis para o usuário final
2. Expandir presets para flags individuais
3. Validar conflitos e dependências
4. Mostrar riscos e estimativas
5. Escrever `/etc/kryonixos/hosts/<hostname>/features.generated.nix`
6. Preservar `features.local.nix` (NUNCA sobrescrever)
7. Permitir edição futura manual (re-installer detecta e pergunta)
8. Nunca editar o core

### 8.2 Presets sugeridos

| Preset | Features que ativa |
|---|---|
| **Desktop KDE** | desktop.plasma, desktop.audio, desktop.bluetooth, desktop.printing |
| **Desktop Dev** | Desktop KDE + development.*, ai.brain.client |
| **Laptop Dev** | Desktop Dev + hardware.laptop, network.tailscale |
| **Gaming** | gaming.*, gpu.nvidia (se NVIDIA) |
| **AI Server** | ai.brain.server, ai.ollama, ai.lightrag, remote.ssh |
| **Brain Client** | ai.brain.client, network.tailscale, development.enable |
| **Proxmox-like** | virtualization.libvirt, virtualization.proxmoxLike, network.bridge, remote.ssh |
| **Minimal Server** | remote.ssh, server.containers |
| **Custom** | Todas as features desligadas, usuário escolhe |

### 8.3 Fluxo da UI

```txt
1. Selecionar preset
   ↓
2. Ajustar features individuais (toggle por feature)
   ↓
3. Validar conflitos e dependências (feedback visual)
   ↓
4. Preview do que será gerado
   ↓
5. Confirmar → escreve /etc/kryonixos/hosts/<hostname>/features.generated.nix
```

---

## 9. Hosts reais: Inspiron

### 9.1 Papel

```
Desktop / laptop pessoal
Workstation de desenvolvimento
Cliente Brain remoto (consulta Glacier)
GPU Intel apenas
Sem servidor AI local
```

### 9.2 Deve ativar

```
kryonix.features.desktop.plasma.enable = true;
kryonix.features.desktop.audio.enable = true;
kryonix.features.desktop.bluetooth.enable = true;
kryonix.features.desktop.printing.enable = true;
kryonix.features.hardware.laptop.enable = true;
kryonix.features.gpu.intel.enable = true;
kryonix.features.network.tailscale.enable = true;
kryonix.features.development.enable = true;
kryonix.features.development.languages.rust.enable = true;
kryonix.features.development.languages.c.enable = true;
kryonix.features.development.languages.python.enable = true;
kryonix.features.development.languages.nix.enable = true;
kryonix.features.virtualization.libvirt.enable = true;
kryonix.features.virtualization.podman.enable = true;
kryonix.features.ai.brain.client.enable = true;
kryonix.features.remote.desktop.client.enable = true;
kryonix.features.kernel.zen.enable = true;  # se aprovado
```

### 9.3 Deve manter desligado

```
kryonix.features.gpu.nvidia.enable = false;
kryonix.features.gpu.cuda.enable = false;
kryonix.features.ai.brain.server.enable = false;
kryonix.features.ai.ollama.enable = false;
kryonix.features.ai.lightrag.enable = false;
kryonix.features.ai.neo4j.enable = false;
kryonix.features.network.bridge.enable = false;
kryonix.features.virtualization.proxmoxLike.enable = false;
kryonix.features.server.*.enable = false;
kryonix.features.gaming.enable = false;  # por padrão
kryonix.features.remote.desktop.server.enable = false;
```

---

## 10. Hosts reais: Glacier

### 10.1 Papel

```
Servidor AI e GPU
Brain server (Ollama, LightRAG, Neo4j)
Virtualização pesada (libvirt, bridge, Proxmox-like)
Gaming opcional (GPU NVIDIA + CUDA)
Headless com acesso SSH e KRDP
```

### 10.2 Deve ativar (a definir conforme decisão)

```
kryonix.features.gpu.nvidia.enable = true;
kryonix.features.gpu.cuda.enable = true;
kryonix.features.kernel.zen.enable = true;
kryonix.features.network.tailscale.enable = true;
kryonix.features.network.bridge.enable = true;
kryonix.features.network.firewall.strict.enable = true;
kryonix.features.remote.ssh.enable = true;
kryonix.features.virtualization.libvirt.enable = true;
kryonix.features.virtualization.proxmoxLike.enable = true;
kryonix.features.ai.brain.server.enable = true;
kryonix.features.ai.ollama.enable = true;
kryonix.features.ai.lightrag.enable = true;
kryonix.features.ai.neo4j.enable = true;
kryonix.features.server.enable = true;
kryonix.features.gaming.enable = true;  # se usado como gamer
```

---

## 11. Checklist de implementação

### Fase 0 — Auditoria e contrato (atual)

- [x] Confirmar estado limpo dos repos
- [x] Confirmar arquivos atuais de features/profiles
- [x] Confirmar usos em kryonixos
- [x] Confirmar catálogo atual do installer
- [x] Registrar plano no Vault (este documento)
- [ ] Não alterar runtime

### Fase 1 — Core feature schema

Repo: `repos/kryonix`

- [ ] Criar/organizar opções públicas `kryonix.features.*`
- [ ] Todas com `default = false`
- [ ] Não mudar comportamento real dos hosts
- [ ] Não remover profiles antigos
- [ ] Manter compat temporária
- [ ] Validar com `nix fmt`
- [ ] Validar com `nix flake check --keep-going`
- [ ] Criar PR pequeno

### Fase 2 — Feature Registry

Repo: `repos/kryonix`

- [ ] Definir formato do registry
- [ ] Criar registry inicial com metadados
- [ ] Exportar formato consumível pelo installer
- [ ] Validar que registry não ativa nada sozinho
- [ ] Criar PR pequeno

### Fase 3 — Features reais no core

Repo: `repos/kryonix`

- [ ] Separar `kernel.zen` como feature
- [ ] Separar `network.tailscale` como feature
- [ ] Separar `network.bridge` como feature
- [ ] Separar `remote.ssh` como feature
- [ ] Separar `gpu.intel` como feature
- [ ] Separar `gpu.nvidia` como feature
- [ ] Separar `gpu.cuda` como feature
- [ ] Separar `hardware.laptop` como feature
- [ ] Separar `ai.brain.client` como feature
- [ ] Separar `ai.brain.server` como feature
- [ ] Separar `virtualization.proxmoxLike` como feature
- [ ] Validar cada feature isoladamente
- [ ] Criar PRs pequenos por grupo de risco

### Fase 4 — Compat de profiles antigos

Repo: `repos/kryonix`

- [ ] `glacier-base` passa a ativar features novas
- [ ] `glacier-ai` passa a ativar features novas
- [ ] `glacier-gamer` passa a ativar features novas
- [ ] `server-ai` vira perfil genérico preferencial
- [ ] Marcar profiles `glacier-*` como deprecated com warning
- [ ] Não quebrar hosts existentes
- [ ] Validar flake

### Fase 5 — Downstream por host

Repo: `repos/kryonixos`

- [ ] Criar `hosts/inspiron/features.nix` com ativação granular
- [ ] Criar `hosts/glacier/features.nix` com ativação granular
- [ ] Importar esses arquivos no `default.nix`
- [ ] Não remover comportamento antigo no primeiro PR
- [ ] Validar avaliação dos hosts

### Fase 6 — Limpeza dos hosts

Repo: `repos/kryonixos`

- [ ] Remover imports diretos de kernel Zen (usar feature)
- [ ] Remover import direto de `net-ragthink.nix` do Inspiron
- [ ] Remover redundância de profiles no Inspiron
- [ ] Limpar `glacier/default.nix`
- [ ] Separar `network.nix`, `hardware.nix`, `features.nix`
- [ ] Validar com build/eval seguro
- [ ] Não executar switch sem aprovação humana

### Fase 7 — Installer

Repo: `repos/kryonix-installer`

- [ ] Ler Feature Registry do core ou manter catálogo espelhado validado
- [ ] Criar tela de features baseada em categorias
- [ ] Criar presets
- [ ] Validar conflitos e dependências
- [ ] Escrever `features.generated.nix`
- [ ] Preservar `features.local.nix`
- [ ] Nunca editar core
- [ ] Nunca sobrescrever config local do usuário
- [ ] Gerar preview antes de aplicar
- [ ] Adicionar testes

### Fase 8 — Docs e Vault

Repo: `repos/kryonix-vault`

- [ ] Atualizar arquitetura canônica
- [ ] Criar guia de usuário final
- [ ] Criar guia de desenvolvimento para novas features
- [ ] Registrar decisões e PRs
- [ ] Atualizar VAULT_INDEX
- [ ] Registrar riscos conhecidos

---

## 12. Plano de PRs recomendado

| PR # | Repo | Escopo |
|---|---|---|
| PR 1 | core | Generic feature schema + namespace `kryonix.features.*` |
| PR 2 | core | Feature Registry com metadados |
| PR 3 | core | Feature modules: kernel, network, remote |
| PR 4 | core | Feature modules: gpu, hardware |
| PR 5 | core | AI brain client/server split |
| PR 6 | core | Profile compatibility layer (glacier-* → deprecated) |
| PR 7 | kryonixos | Host feature files (inspiron, glacier) |
| PR 8 | kryonixos | Clean Inspiron (remover imports diretos, redundâncias) |
| PR 9 | kryonixos | Clean Glacier (idem) |
| PR 10 | installer | Feature selection UI / catalog sync |
| PR 11 | installer | Generate `features.generated.nix` |
| PR 12 | vault | Final architecture guide + docs update |

---

## 13. Validações por PR

| PR em | Comandos de validação |
|---|---|
| **core** | `nix fmt && nix flake check --keep-going` |
| **kryonixos** | `nix flake show --all-systems && nix build .#nixosConfigurations.inspiron.config.system.build.toplevel --no-link -L && nix build .#nixosConfigurations.glacier.config.system.build.toplevel --no-link -L` |
| **installer** | `cargo fmt && cargo clippy -- -D warnings && cargo test` |
| **vault** | `rg` de links principais, validar frontmatter |

### Comandos proibidos sem aprovação humana explícita

```
nixos-rebuild switch
kryonix switch
disko
mkfs.*
reboot
poweroff
git add .
git reset --hard
git clean -fdx
git push --force
rm -rf
```

---

## 14. Riscos

| Risco | Probabilidade | Mitigação |
|---|---|---|
| Quebrar boot com kernel feature | Baixa | Validar boot com VM antes de aplicar |
| Quebrar rede/SSH com bridge/firewall | Média | Testar network feature isoladamente; rollback via revert |
| Ativar NVIDIA/CUDA em host errado | Baixa | Feature é opt-in; Inspiron não ativa |
| Puxar Ollama/Neo4j/LightRAG para cliente | Baixa | AI brain client != AI brain server |
| Duplicar pacotes entre profiles e features | Alta (já acontece) | PR específico para limpar duplicações |
| Installer divergir do core | Média | Feature Registry como contrato compartilhado |
| Sobrescrever config local do usuário | Média | `features.generated.nix` != `features.local.nix` |
| Flake check passar mas runtime quebrar | Média | Testes de runtime em VM antes de switch |
| Migração `glacier-*` quebrar host real | Alta | Compat layer com warnings; validar eval antes |

---

## 15. Critérios de conclusão

A arquitetura será considerada pronta quando:

- [ ] `kryonix.features.*` tiver schema genérico estável no core
- [ ] O core tiver Feature Registry exportável
- [ ] O installer usar o mesmo contrato do core
- [ ] `kryonixos` tiver ativação clara por host em `features.nix`
- [ ] `features.generated.nix` e `features.local.nix` estiverem definidos
- [ ] Inspiron não puxar server AI local
- [ ] Glacier concentrar server AI/GPU/Brain
- [ ] Profiles antigos (`glacier-*`) forem compat ou deprecated
- [ ] O Vault tiver documentação canônica atualizada
- [ ] Todos os PRs tiverem validação registrada

---

## 16. Links relacionados

- [[VAULT_INDEX]]
- [[02-Areas/Kryonix/canonical/BOUNDARIES]]
- [[02-Areas/Kryonix/canonical/CORE_DOWNSTREAM_INSTALLER]]
- [[02-Areas/Kryonix/canonical/DEVELOPMENT_FLOW]]
- [[01-MOCs/MOC - Kryonix Core Boundaries]]
- [[09-Logs/Kryonix/2026-06-23-upstream-downstream-feature-plan]]
- [[03-Projetos/Kryonix System]]
- [[03-Projetos/Kryonix Installer]]