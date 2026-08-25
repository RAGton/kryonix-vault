# GPU Passthrough Completo — glacier → VM 100 (Windows 11 Gamer)

Data: 2026-08-24
Agente: Aura (MiniMax-M3)
Host: glacier (10.1.1.2 / 168.227.125.70)
Proxmox: pve-manager/9.2.11

## Objetivo

Configurar GPU passthrough da RTX 4060 + NVMe passthrough do Lexar 1TB, criar VM 100 Windows 11 com 12 GB RAM via hugepages 1G, e fixar vCPUs nos cores 2-7 + SMT 10-15 via hook script.

## Contexto consultado

- [[00-INDEX]] — índice da sessão 2026-08-23
- [[09-Logs/2026-08-23-sessao-infra-glacier-proxmox/03-proxmox-instalacao-e-usuarios]]
- [[../../02-Areas/Kryonix/canonical/ADR-006-shell-web-patch-dtach]]
- https://forum.proxmox.com/threads/shell-access-for-oidc-user.154886/ — origem do patch dtach

## Hardware descoberto

| Componente | Modelo | Detalhes |
|---|---|---|
| CPU | AMD Ryzen 7 9700X | 8C/16T monolítico (1 CCD), NUMA 1 |
| RAM | 14 GiB total | DDR5 + 8 GiB swap |
| GPU dedicada | NVIDIA RTX 4060 (AD107) | `[10de:2882]` rev a1, IOMMU grupo 13 |
| GPU integrada | AMD Granite Ridge Radeon | `[14:00.0]` rev c5, IOMMU grupo 31 |
| Audio HDMI | NVIDIA AD107 HDA | `[10de:22be]` rev a1, **mesmo IOMMU grupo 13 da GPU** |
| NVMe boot | ADATA IM2P33F3A 256GB | `nvme1n1` — Proxmox instalado |
| NVMe passthrough | Lexar SSD NM620 1TB | `nvme0n1` (PCI 02:00.0) — VM |
| BIOS | UEFI | ativo, CSM desligado |

**Observação crítica:** O plano original previa 2 NVMes idênticos, mas a instalação do Proxmox pegou o ADATA 256GB (menor) e deixou o Lexar 1TB livre. **Decisão:** inverter papéis — Proxmox no ADATA, VM no Lexar.

## Fases executadas

### Fase 1 — Repositório + Microcode ✅

**1.1 Repositório não-enterprise**

Script oficial `community-scripts/ProxmoxVE/tools/pve/post-pve-install.sh` falhou (`'unknown': I need something more specific`). **Workaround manual:**

```bash
sudo cp /etc/apt/sources.list.d/pve-enterprise.sources /etc/apt/sources.list.d/pve-enterprise.sources.bak.20260824
sudo bash -c "cat > /etc/apt/sources.list.d/pve-enterprise.sources <<EOF
Types: deb
URIs: https://enterprise.proxmox.com/debian/pve
Suites: trixie
Components: pve-enterprise
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
Enabled: false
EOF"
sudo tee /etc/apt/sources.list.d/pve-no-subscription.sources >/dev/null <<'EOF'
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
sudo rm /etc/apt/sources.list.d/proxmox.sources
sudo apt update
```

**1.2 Microcode AMD**

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/microcode.sh)"
```

→ `amd64-microcode 3.20251202.1~bpo13+1` instalado (aguarda reboot).

### Fase 2 — Desabilitar HA + Journald RAM ✅

```bash
sudo systemctl stop pve-ha-lrm.service
sudo systemctl disable pve-ha-lrm.service
sudo systemctl stop pve-ha-crm.service
sudo systemctl disable pve-ha-crm.service

sudo cp /etc/systemd/journald.conf /etc/systemd/journald.conf.bak.20260824
sudo bash -c "cat > /etc/systemd/journald.conf <<EOF
[Journal]
Storage=volatile
RuntimeMaxUse=64M
EOF"
sudo systemctl restart systemd-journald
```

### Fase 3 — IOMMU + Huge Pages no GRUB ✅

```bash
sudo cp /etc/default/grub /etc/default/grub.bak.20260824
sudo sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="quiet"|GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt default_hugepagesz=1G hugepagesz=1G hugepages=12"|' /etc/default/grub
sudo update-grub
sudo mkdir -p /dev/hugepages1G
sudo cp /etc/fstab /etc/fstab.bak.20260824
echo "none /dev/hugepages1G hugetlbfs pagesize=1G 0 0" | sudo tee -a /etc/fstab
```

### Fase 4 — Blacklist NVIDIA + VFIO bind ✅

```bash
sudo tee /etc/modprobe.d/blacklist.conf >/dev/null <<EOF
blacklist nouveau
blacklist nvidia
blacklist nvidiafb
blacklist nvidia_drm
blacklist nvidia_modeset
EOF

sudo tee /etc/modprobe.d/vfio.conf >/dev/null <<EOF
softdep nvidia pre: vfio-pci
softdep snd_hda_intel pre: vfio-pci
options vfio-pci ids=10de:2882,10de:22be disable_vga=1
EOF

sudo tee -a /etc/modules >/dev/null <<EOF
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
EOF

sudo update-initramfs -u -k all
```

⚠️ **Plano original tinha `[10de:2803]` (ERRADO)**. **ID correto é `[10de:2882]`** (RTX 4060 AD107). Aplicado manualmente.

### Fase 5 — Reboot + Validação ✅

**Auditoria pós-reboot (todos os 11 checks passaram):**

| Check | Resultado |
|---|---|
| Kernel | `7.0.14-12-pve` ✅ |
| Cmdline | `amd_iommu=on iommu=pt default_hugepagesz=1G hugepagesz=1G hugepages=12` ✅ |
| HugePages Total | 12 ✅ |
| AMD-Vi IOMMU | `Using global IVHD, Passthrough` ✅ |
| RTX 4060 driver | `vfio-pci` ✅ |
| Audio HDMI driver | `vfio-pci` ✅ |
| Módulos VFIO | `vfio_pci`, `vfio_pci_core`, `vfio_iommu_type1` ✅ |
| /dev/hugepages1G | `hugetlbfs (rw,relatime,pagesize=1024M)` ✅ |
| journald | `volatile` ✅ |
| HA | `disabled` ✅ |
| microcode | `0xb404022` ✅ |
| Web Proxmox | `200 OK` ✅ |

### Fase 6 — Criar VM 100 ✅

```bash
sudo qm create 100 \
  --name "glacier-win" \
  --memory 12288 --cores 12 --sockets 1 \
  --cpu host,hidden=1 \
  --numa 1 \
  --machine q35 --bios ovmf \
  --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=1 \
  --tpmstate0 local-lvm:1,version=v2.0 \
  --ide0 local:iso/Win11_25H2_Spanish_x64_v2.iso,media=cdrom \
  --ide1 local:iso/virtio-win-0.1.285.iso,media=cdrom \
  --net0 virtio,bridge=vmbr0,macaddr=BC:24:11:99:88:77 \
  --hostpci0 01:00,pcie=1,x-vga=on \
  --hostpci1 02:00,pcie=1 \
  --vga none \
  --boot order='ide0;hostpci1' \
  --agent 1 --balloon 0 --hugepages 1024

sudo qm set 100 --args "-cpu 'host,-hypervisor,kvm=off,hv_vendor_id=null'"
```

**Erro resolvido:** `numa needs to be enabled to use hugepages` → `sudo qm set 100 --numa 1`.

### Fase 7 — CPU Pinning via hook script ✅

**Problema detectado:** VM rodando com %CPU 158% no host (vCPUs flutuando entre todos cores, disputando com host).

**Solução:** Hook script `post-start` que fixa vCPUs nos cores 2-7 + SMT 10-15.

```bash
sudo mkdir -p /var/lib/vz/snippets
sudo tee /var/lib/vz/snippets/vm-optimize-hook.sh >/dev/null <<'EOF'
#!/bin/bash
VMID="$1"
PHASE="$2"

if [[ "$PHASE" == "post-start" ]]; then
    sleep 2
    VM_PID="$(cat /run/qemu-server/$VMID.pid 2>/dev/null)"
    if [ -n "$VM_PID" ] && [ -d "/proc/$VM_PID" ]; then
        VCPU_THREADS=$(ps -L -p "$VM_PID" -o tid= | tr -d ' ' | grep -v "^$")
        HOST_CPUS=(2 10 3 11 4 12 5 13 6 14 7 15)
        i=0
        for tid in $VCPU_THREADS; do
            cpu=${HOST_CPUS[$((i % 12))]}
            taskset -cp "$cpu" "$tid" 2>/dev/null
            i=$((i + 1))
        done
    fi
fi
EOF
sudo chmod +x /var/lib/vz/snippets/vm-optimize-hook.sh
sudo qm set 100 --hookscript local:snippets/vm-optimize-hook.sh
```

**Validação pós-reboot da VM:**

```
TID PSR COMMAND
29345   2 kvm              ← kvm principal no core 2
29346  10 call_rcu         ← RCU no SMT do core 2
29374   3 vhost-29345      ← vhost-net no core 3
29387  11 CPU 0/KVM        ← vCPU 0 no SMT do core 2
29388   4 CPU 1/KVM        ← vCPU 1 no core 4
29389  12 CPU 2/KVM        ← vCPU 2 no SMT do core 4
29390   5 CPU 3/KVM        ← vCPU 3 no core 5
...
```

**Resultado:** vCPUs fixadas nos cores 2-7 + SMT 10-15. Cores 0-1 + SMT 8-9 livres pro host.

**Lentidão resolvida:** load caiu de 1.04-1.75 → 0.60.

## Estado final do glacier (após desligar VM)

| Item | Status |
|---|---|
| Load average | 0.00, 0.02, 0.22 |
| Memória | 14 GiB total, 13 GiB used (hugepages), 800 MiB available |
| VM 100 | stopped |
| HugePages Total/Free | 12/12 (12 GB reservados, livres) |
| GPU passthrough | funcional (validados em boot anterior) |
| NVMe passthrough | funcional (Windows instalado no Lexar) |
| CPU pinning hook | vinculado, executa no post-start |

## Pending (não finalizado)

- [ ] Driver NVIDIA instalado dentro da VM (pra jogos 3D com aceleração)
- [ ] RDP ativado na VM
- [ ] QEMU Guest Agent confirmado rodando (`nvidia-smi` via Proxmox)
- [ ] Backup automatizado da VM 100 (Veeam Agent ou PBS)

## Problemas e decisões

| Problema | Decisão |
|---|---|
| Script oficial `post-pve-install.sh` quebrado | Workaround manual editando `/etc/apt/sources.list.d/` |
| Plano original com IDs errados `[10de:2803]` | Corrigido manualmente pra `[10de:2882]` |
| Ferramenta `read_terminal` do Hermes bloqueada | Você resetou Hermes; tool destravou |
| Tool `terminal`/`execute_code` exigindo `ssh_host`/`ssh_user` | Resolvido após reset/config |
| VM lenta (load 1.75) | Causa: CPU pinning não estava vinculado. Fix: hook script + `qm set hookscript` |
| Planos grandes como `qemum` em heredoc | Migrar pra scripts .pl/.sh com `scp` ou upload |

## Próximo passo recomendado

1. **Ligar a VM 100** (`sudo qm start 100`)
2. **Instalar driver NVIDIA completo** dentro da VM
3. **Ativar RDP** pra acesso remoto
4. **Configurar backups** da VM (clonagem semanal pra segundo disco)
5. **Resolver Huawei EG8145V5-V2** (você disse que não conseguia acessar)
6. **Investigar dispositivo 10.1.1.253** (`lwip0`, hostname suspeito)

## Links relacionados

- [[00-INDEX]] — índice da sessão
- [[01-investigacao-rede]] — topologia LAN MikroTik
- [[02-ssh-glacier-chave-e-porta]] — SSH hardening
- [[05-shell-web-patches]] — patch dtach
- [[06-tailscale-estado]] — Tailscale IP 100.110.225.98
- [[07-problemas-e-pendencias]] — pendências diversas
- [[08-validacoes-e-testes]] — testes anteriores
- [[../../02-Areas/Kryonix/canonical/ADR-007-passthrough-nvme-via-pcie|ADR-007 — decisão passthrough NVMe]]

#gpu-passthrough #proxmox #ryzen #rtx4060 #nvme #hugepages #iommu #vfio
