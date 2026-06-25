---
status: active
date: 2026-06-23
area: Kryonix
type: canonical-catalog
scope:
  - upstream
  - features
  - installer-future
---

# Existing Kryonix Features Catalog

## Objetivo

Este documento lista as features existentes do Kryonix, para que serve cada uma, onde vive no código e qual é o estado de migração para a árvore canônica.

## Regras

- A árvore canônica é `modules/nixos/features/`.
- A árvore `features/` é legado temporário.
- O namespace público é `kryonix.features.*`.
- Features novas de app/kernel externo estão congeladas até a unificação estrutural terminar.
- O installer futuramente deve consumir o Feature Registry/export JSON, não catálogo hardcoded.

## Estados possíveis

| Status | Significado |
|---|---|
| `canonical` | Implementação real já vive em `modules/nixos/features/` |
| `legacy-wrapper` | Arquivo em `features/` existe apenas para compat |
| `legacy-pending` | Ainda precisa migrar de `features/` |
| `conflict-resolved` | Nome/conflito já foi resolvido |
| `needs-audit` | Precisa auditoria antes de migrar |
| `deprecated-compat` | Mantido temporariamente para não quebrar downstream |

## Catálogo resumido

| Feature | Namespace | Arquivo canônico | Arquivo legado | Status | Serve para | Risco |
|---|---|---|---|---|---|---|

## Features base/core

### `base`

Namespace esperado:

```nix
kryonix.features.base.enable
```

Serve para:

* ativar base mínima do sistema Kryonix;
* servir como fundação para profiles/hosts;
* separar sistema mínimo de desktop/server/dev.

Status:

* preencher após auditoria.

Risco:

* baixo/médio, dependendo do que ativa.

## Desktop

### `desktop.plasma`

Namespace:

```nix
kryonix.features.desktop.plasma.enable
```

Serve para:

* ativar KDE Plasma;
* representar desktop padrão atual recomendado para Inspiron;
* substituir defaults escondidos em workstation/Hyprland.

Risco:

* médio, afeta sessão gráfica/display manager.

### `desktop.hyprland`

Namespace:

```nix
kryonix.features.desktop.hyprland.enable
```

Serve para:

* ativar ambiente Hyprland;
* manter suporte a setups Wayland avançados.

Risco:

* médio, pode afetar login gráfico e sessão do usuário.

### `desktop.audio`

Serve para:

* áudio desktop;
* PipeWire/Pulse compat, se aplicável.

Risco:

* baixo/médio.

### `desktop.bluetooth`

Serve para:

* Bluetooth em laptops/desktops.

Risco:

* baixo.

### `desktop.printing`

Serve para:

* impressão/scanner/CUPS, se aplicável.

Risco:

* baixo.

## Hardware/GPU

### `hardware.laptop`

Serve para:

* ajustes de laptop;
* energia, touchpad, bateria, sensores, se aplicável.

Risco:

* baixo/médio.

### `hardware.sensors`

Serve para:

* sensores de temperatura/fan/hardware.

Risco:

* baixo.

### `gpu.intel`

Serve para:

* stack gráfica Intel;
* VAAPI/hardware acceleration, se aplicável.

Risco:

* médio, afeta vídeo/aceleração.

### `gpu.amd`

Serve para:

* stack gráfica AMD.

Risco:

* médio.

### `gpu.nvidia`

Serve para:

* driver NVIDIA;
* módulos kernel proprietários/abertos.

Risco:

* alto, pode quebrar boot ou display.

### `gpu.cuda`

Serve para:

* CUDA/compute para IA e workloads GPU.

Risco:

* alto, depende de driver NVIDIA e kernel.

## Kernel

### `kernel.zen`

Namespace:

```nix
kryonix.features.kernel.zen.enable
```

Serve para:

* ativar Linux Zen kernel;
* melhorar responsividade desktop/gaming;
* manter opt-in sem alterar hosts por padrão.

Risco:

* alto, afeta boot e drivers externos.

### `kernel.hardened`

Serve para:

* kernel com foco em hardening.

Risco:

* alto, pode quebrar drivers/performance.

### `kernel.lowLatency`

Serve para:

* baixa latência para áudio/gaming/desktop.

Risco:

* médio/alto.

## Network/Remote

### `network.tailscale`

Serve para:

* rede privada Tailscale;
* acesso remoto seguro entre hosts.

Risco:

* médio, afeta rede/acesso remoto.

### `network.bridge`

Serve para:

* bridge de rede, VMs, Proxmox-like, Glacier.

Risco:

* crítico no Glacier por `br0`/SSH remoto.

### `network.vlan`

Serve para:

* VLANs e segmentação.

Risco:

* alto.

### `network.firewall.strict`

Serve para:

* política de firewall mais restritiva.

Risco:

* alto, pode causar lockout.

### `remote.ssh`

Namespace:

```nix
kryonix.features.remote.ssh.enable
kryonix.features.remote.ssh.port
```

Serve para:

* OpenSSH;
* acesso remoto;
* hardening e porta controlada.

Risco:

* crítico em host remoto.

### `remote.desktop.client`

Serve para:

* cliente de desktop remoto.

Risco:

* baixo.

### `remote.desktop.server`

Serve para:

* servidor de desktop remoto.

Risco:

* médio/alto, expõe superfície remota.

## Development

### `development`

Namespace:

```nix
kryonix.features.development.*
```

Arquivo canônico:

```txt
modules/nixos/features/development.nix
```

Arquivo legado:

```txt
features/development.nix
```

Status:

```txt
canonical + legacy-wrapper
```

Serve para:

* ambiente de desenvolvimento;
* linguagens e ferramentas como Rust, Python, Node, C/C++;
* Kubernetes/Ansible, se presentes no módulo;
* editores/ferramentas de dev;
* base para perfil de workstation/dev.

Risco:

* baixo/médio;
* aumenta pacotes e superfície local, mas não deve afetar boot/rede.

## Virtualization

### `virtualization`

Namespace:

```nix
kryonix.features.virtualization.*
```

Arquivo canônico:

```txt
modules/nixos/features/virtualization.nix
```

Arquivo legado:

```txt
features/virtualization.nix
```

Status:

```txt
canonical + legacy-wrapper
```

Serve para:

* KVM/QEMU/libvirt;
* virt-manager;
* Podman/Docker, se presentes no módulo;
* LXC/containers, se presentes;
* base para labs, VMs e workloads locais.

Risco:

* médio;
* pode afetar grupos, serviços systemd, NAT/firewall e performance.

## Gaming

### `gaming`

Namespace:

```nix
kryonix.features.gaming.*
```

Arquivo canônico:

```txt
modules/nixos/features/gaming.nix
```

Arquivo legado:

```txt
features/gaming.nix
```

Status:

```txt
canonical + legacy-wrapper + conflict-resolved
```

Serve para:

* Steam;
* Lutris;
* GameMode;
* MangoHud;
* Heroic Games Launcher;
* Wine/proton helpers, se presentes;
* udev rules para controles.

Risco:

* baixo/médio;
* pode afetar pacotes gráficos, 32-bit libs e drivers.

Observação:

* `gamer` foi descartado em favor de `gaming`.

## AI

### `ai`

Namespace esperado:

```nix
kryonix.features.ai.*
```

Status:

```txt
partial canonical namespace + compat runtime switches
```

Serve para:

* Brain client/server ownership é schema.nix;
* Ollama (ainda em compat/satellite options);
* LightRAG (ainda em compat/satellite options);
* Neo4j (ainda em compat/satellite options);
* OpenWebUI (ainda em compat/satellite options);
* Serviços e integração local/remota de IA.

Observação:
* AI runtime ainda não está migrado.

Risco:

* médio/alto;
* pode afetar serviços, portas, storage, GPU/CUDA e secrets.

## Workstation

### `workstation`

Status:

```txt
legacy-pending + needs-audit
```

Serve para:

* agrupar ambiente desktop/dev/workstation.

Risco:

* médio/alto;
* pode esconder defaults de desktop, como Hyprland;
* precisa auditoria antes de migrar.

## Remote Desktop

### `remote-desktop`

Namespace legado:

```nix
kryonix.features.remoteDesktop.*
```

Namespace alvo:

```nix
kryonix.features.remote.desktop.*
```

Status:

```txt
legacy-pending
```

Serve para:

* cliente/servidor remoto;
* acesso desktop remoto.

Risco:

* médio/alto.

## OpenRGB

### `openrgb`

Namespace legado:

```nix
kryonix.features.openrgb.*
```

Namespace alvo provável:

```nix
kryonix.features.hardware.openrgb.*
```

Status:

```txt
legacy-pending
```

Serve para:

* controle RGB/periféricos compatíveis.

Risco:

* baixo/médio.

## F5-TTS Server

### `f5-tts-server`

Namespace alvo provável:

```nix
kryonix.features.ai.f5tts.*
```

Status:

```txt
legacy-pending
```

Serve para:

* servidor TTS local;
* workloads de voz/IA.

Risco:

* médio;
* pode afetar serviços, GPU/modelos e storage.

## Server

### `server`

Namespace:

```nix
kryonix.features.server.*
```

Serve para:

* workloads de servidor;
* containers;
* databases;
* reverse proxy.

Risco:

* médio/alto.

## Storage

### `storage`

Serve para:

* storage persistente;
* diretórios de dados;
* paths como `/srv`, `/var/lib/kryonix`, modelos de IA.

Risco:

* alto se mexer em dados reais.

## Security

### `security.firewall`

Serve para:

* firewall base;
* política de rede.

Risco:

* alto em host remoto.

### `security.fail2ban`

Serve para:

* proteção contra brute force em serviços expostos.

Risco:

* baixo/médio.

## Observability

### `observability.prometheus`

Serve para:

* métricas.

Risco:

* baixo/médio.

### `observability.grafana`

Serve para:

* dashboards.

Risco:

* baixo/médio.

## MCP

### `mcp.*`

Serve para:

* integração com ferramentas MCP;
* filesystem, GitHub, Neo4j, Ollama, etc.

Risco:

* médio;
* cuidado com permissões e secrets.

## Features futuras congeladas

Estas estão documentadas no backlog e não devem ser implementadas agora:

* CachyOS kernels
* Antigravity
* Codex Desktop
* Claude Desktop
* Warp Terminal

## Próximas ações

1. Atualizar este catálogo a cada PR de migração.
2. Depois de migrar todas as features, gerar Feature Registry JSON.
3. Só depois alterar o installer.
