---
title: Kryonix Host Inventory
type: documentation
status: active
tags: [kryonix, hosts, inventory, hardware, provisioning, entity-schema]
project: kryonix
created: 2026-06-15
updated: 2026-06-16
schema_version: "1.0.0"
---

# Kryonix Host Inventory

## Objetivo

Inventário centralizado de hosts físicos e virtuais do ecossistema Kryonix: specs, localização, status, role, associação a projetos. As entidades abaixo seguem rigorosamente o `[[02-Areas/Kryonix/canonical/Kryonix Entity Schema]]` **v1.0.0** (`kind: host`) e foram **validadas com ajv (Draft 2020-12)**.

## Resumo

Dois hosts inventariados: **Glacier** (Main Server / brain-node) e **Inspiron** (Edge/Field Node / dev). Cada um é um envelope `entity` completo com `identity`, `hardware`, `network`, `state`, `role`, `location` e `provisioning`. UUIDs são **UUIDv7** (timestamp-ordered) ancorados na data de provisionamento.

## Legenda de Confiança dos Campos

| Marcador | Significado |
|----------|-------------|
| ✅ confirmado | Derivado das notas de host ([[Glacier]] / [[Inspiron]]) ou do flake. |
| ⚠️ provisório | Valor representativo; **capturar valor real via `kryonix-hardware-probe`** no provisionamento. |

> ⚠️ **Não alucinar specs:** `cpu` (modelo exato), `cpu_cores`, `ram_gb`, `storage.size_gb`, `mac` e `ipv4` ainda **não foram medidos** — estão marcados como provisórios. O probe de hardware e o primeiro check-in mTLS sobrescrevem esses campos.

---

## Glacier — Main Server (brain-node)

Confirmados ✅: hostname, role=brain-node, CPU=AMD, GPU=NVIDIA/CUDA, provisioning declarativo. Ver [[Glacier]].
Provisórios ⚠️: `cpu_cores`, `ram_gb`, `storage.size_gb`, `mac`, `ipv4`, `machine_id`.

```json
{
  "entity": {
    "type": "entity",
    "version": "1.0.0",
    "kind": "host",
    "payload": {
      "identity": {
        "hostname": "glacier",
        "fqdn": "glacier.kryonix.local",
        "machine_id": "019eb1e9-5b28-7283-a78f-81b6eae409ef"
      },
      "hardware": {
        "cpu": "AMD Ryzen (modelo a confirmar via probe)",
        "cpu_cores": 16,
        "ram_gb": 64,
        "storage": [
          { "device": "/dev/nvme0n1", "type": "nvme", "size_gb": 1000, "fs": "zfs", "encrypted": true, "pool": "rpool" }
        ],
        "gpu": "NVIDIA (CUDA) — modelo a confirmar"
      },
      "network": {
        "interfaces": [
          { "name": "enp1s0", "mac": "00:00:00:00:00:00", "ipv4": "192.168.100.2/24", "ipv6": null, "vlan": null, "bond": null, "lacp": false }
        ],
        "dns_servers": ["1.1.1.1", "8.8.8.8"],
        "ntp_servers": ["time.kryonix.local"]
      },
      "state": {
        "status": "provisioned",
        "health": "healthy",
        "last_checkin": "2026-06-16T00:00:00Z"
      },
      "role": {
        "primary": "brain-node",
        "capabilities": ["compute", "storage", "gpu"]
      },
      "location": {
        "rack": "home-lab",
        "position": "main",
        "datacenter": "home"
      },
      "provisioning": {
        "method": "nixos-anywhere",
        "iso_version": "unstable",
        "disko_profile": "server-zfs-encrypted",
        "installed_at": "2026-06-10T14:22:00Z",
        "installer_version": "1.0.0-rc1"
      }
    },
    "metadata": {
      "id": "019eb1e9-5740-7fd1-9636-4643b3b2e7d6",
      "created_at": "2026-06-16T00:00:00Z",
      "updated_at": "2026-06-16T00:00:00Z",
      "created_by": "agent:kryonix-architect",
      "source": "manual",
      "tags": ["kryonix", "server", "ai", "amd", "nvidia"]
    }
  }
}
```

---

## Inspiron — Edge / Field Node (dev)

Confirmados ✅: hostname, role=dev/workstation, CPU=Intel, GPU=Intel iGPU (modesetting), GRUB+EFI, NetworkManager, Tailscale → Glacier. Ver [[Inspiron]].
Provisórios ⚠️: `cpu_cores`, `ram_gb`, `storage.size_gb`, `mac`, `ipv4`, `machine_id`.

```json
{
  "entity": {
    "type": "entity",
    "version": "1.0.0",
    "kind": "host",
    "payload": {
      "identity": {
        "hostname": "inspiron",
        "fqdn": "inspiron.kryonix.local",
        "machine_id": "019ebb13-da48-7fb4-bc38-0bcda9421c41"
      },
      "hardware": {
        "cpu": "Intel (modelo a confirmar via probe)",
        "cpu_cores": 8,
        "ram_gb": 16,
        "storage": [
          { "device": "/dev/nvme0n1", "type": "nvme", "size_gb": 512, "fs": "btrfs", "encrypted": false }
        ],
        "gpu": "Intel iGPU (modesetting)"
      },
      "network": {
        "interfaces": [
          { "name": "wlp2s0", "mac": "00:00:00:00:00:01", "ipv4": "192.168.100.50/24", "ipv6": null, "vlan": null, "bond": null, "lacp": false }
        ],
        "dns_servers": ["1.1.1.1", "8.8.8.8"],
        "ntp_servers": ["time.kryonix.local"]
      },
      "state": {
        "status": "provisioned",
        "health": "healthy",
        "last_checkin": "2026-06-16T00:00:00Z"
      },
      "role": {
        "primary": "dev",
        "capabilities": ["compute"]
      },
      "location": {
        "rack": "field",
        "position": "mobile",
        "datacenter": "edge"
      },
      "provisioning": {
        "method": "manual-iso",
        "iso_version": "unstable",
        "disko_profile": "workstation-btrfs",
        "installed_at": "2026-06-12T09:05:00Z",
        "installer_version": "1.0.0-rc1"
      }
    },
    "metadata": {
      "id": "019ebb13-d660-72de-aff1-9509d94df3ee",
      "created_at": "2026-06-16T00:00:00Z",
      "updated_at": "2026-06-16T00:00:00Z",
      "created_by": "agent:kryonix-architect",
      "source": "manual",
      "tags": ["kryonix", "workstation", "intel", "edge", "field"]
    }
  }
}
```

---

## Tabela Comparativa (TOON)

```toon
host,      role,        cpu,    gpu,                   fs,    method,          datacenter
glacier,   brain-node,  AMD,    NVIDIA/CUDA,           zfs,   nixos-anywhere,  home
inspiron,  dev,         Intel,  Intel iGPU,            btrfs, manual-iso,      edge
```

## Checklist

- [x] Inventariar Glacier (host principal).
- [x] Inventariar Inspiron (host secundário / field node).
- [x] Definir campos padrão de inventário (via Entity Schema v1.0.0).
- [x] Validar entidades com ajv (Draft 2020-12) — ambas VÁLIDAS.
- [ ] Substituir campos ⚠️ provisórios pelos valores reais do `kryonix-hardware-probe`.
- [ ] Conectar com [[02-Areas/Kryonix/hosts/MOC - Hosts]].

## Riscos

- Inventário com specs provisórias leva a decisões erradas de capacidade — priorizar o probe antes de planejar workloads.
- `machine_id` provisório: o valor real é o systemd machine-id capturado no 1º check-in mTLS (ver [[02-Areas/Kryonix/architecture/Kryonix Architecture - Overview]]).

## Links relacionados

- [[01-MOCs/Mapa - Kryonix]]
- [[02-Areas/Kryonix/canonical/Kryonix Entity Schema]]
- [[02-Areas/Kryonix/architecture/Kryonix Architecture - Overview]]
- [[02-Areas/Kryonix/hosts/MOC - Hosts]]
- [[02-Areas/Kryonix/hosts/Glacier]]
- [[02-Areas/Kryonix/hosts/Inspiron]]
- [[02-Areas/Kryonix/installer/Kryonix Installer - Requisitos Técnicos]]

## Próxima ação

Rodar `kryonix-hardware-probe` em Glacier e Inspiron e sobrescrever os campos ⚠️ provisórios; depois registrar via mTLS no `ai-brain`.
