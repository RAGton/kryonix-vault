# ADR-007 — GPU + NVMe Passthrough via PCIe direto no glacier

**Status:** Aceito
**Data:** 2026-08-24
**Decisor:** Gabriel (após experimentação com a comunidade Proxmox)

## Contexto

glacier (Proxmox 9.2.11) tem hardware Ryzen 7 9700X + RTX 4060 + 2 NVMes (ADATA 256GB + Lexar 1TB). Gabriel queria rodar Windows 11 com performance bare-metal pra jogos (anti-cheat não detecta VM). Três caminhos possíveis:

1. **Disco virtual LVM** (host controla storage, performance boa mas overhead 10-30%)
2. **PCI Passthrough** (VM tem acesso direto ao hardware físico)
3. **VirtIO + VirtFS** (emulação parcial, melhor portabilidade)

## Decisão

**PCI Passthrough bare-metal:**
- RTX 4060 GPU (`01:00.0` + audio `01:00.1`) → passthrough direto
- Lexar NM620 1TB NVMe (`02:00.0`) → passthrough direto
- CPU: 12 vCPUs pinned nos cores 2-7 + SMT 10-15 via hook script
- RAM: 12 GB via 1GB hugepages
- VM vê dispositivos como se fossem metal puro

## Consequências

### Positivas

| Benefício | Detalhe |
|---|---|
| Performance máxima | NVMe ~7 GB/s, GPU sem overhead de emulação |
| Anti-cheat invisível | Flags `-hypervisor,kvm=off,hv_vendor_id=null` mascaram hypervisor |
| Controle total da VM | Formatar, particionar, secure-erase direto |
| Sem acoplamento Proxmox ↔ VM | Backup via Veeam/clonagem dentro da VM |
| Zero overhead de I/O | IOMMU traduz DMA direto |

### Negativas / Trade-offs

| Risco | Detalhe |
|---|---|
| Proxmox não faz snapshot do disco | Backup manual via VM |
| VM corrompe disco → host não recupera | Sem fallback LVM |
| **Patch some a cada `apt upgrade` do pve-manager** | Reaplicar manualmente |
| Patch some também no `Nodes.pm` (dtach) | Mesma natureza |
| GPU dedicada fica **presa** na VM 100 | Outras VMs usam VirtIO vGPU |
| NVMe preso na VM 100 | Outros VMs usam disco virtual |

## Alternativas consideradas

| Alternativa | Por que rejeitada |
|---|---|
| Disco virtual LVM (`local-lvm:64`) | Performance 10-30% menor; sem anti-cheat robustness |
| VirtIO + VirtFS | Overhead de I/O; jogos AAA sentem |
| Cross-host migration | Single-node; sem cluster |
| vGPU (SR-IOV) | RTX 4060 consumer **não suporta** SR-IOV |
| USB passthrough (controladora) | Limitado a 1-2 USB por controladora; passthrough completo melhor |

## Implementação

### Hardware

- RTX 4060 AD107 — IOMMU group 13 (isolado, só tem GPU + audio)
- Lexar NM620 — IOMMU group separado
- iGPU Radeon — IOMMU group 31 (fica no Proxmox)

### Cmdline do kernel

```
amd_iommu=on iommu=pt default_hugepagesz=1G hugepagesz=1G hugepages=12
```

### Módulos VFIO

`/etc/modprobe.d/vfio.conf`:
```
softdep nvidia pre: vfio-pci
softdep snd_hda_intel pre: vfio-pci
options vfio-pci ids=10de:2882,10de:22be disable_vga=1
```

⚠️ **Nota crítica:** ID correto da RTX 4060 AD107 é `[10de:2882]`, **NÃO** `[10de:2803]` (que aparece em alguns planos antigos na internet).

### VM config

```bash
qm create 100 --name "glacier-win" \
  --memory 12288 --cores 12 --sockets 1 \
  --cpu host,hidden=1 --numa 1 \
  --machine q35 --bios ovmf \
  --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=1 \
  --tpmstate0 local-lvm:1,version=v2.0 \
  --hostpci0 01:00,pcie=1,x-vga=on \
  --hostpci1 02:00,pcie=1 \
  --vga none --boot order='ide0;hostpci1' \
  --agent 1 --balloon 0 --hugepages 1024

qm set 100 --args "-cpu 'host,-hypervisor,kvm=off,hv_vendor_id=null'"
```

### CPU Pinning hook

`/var/lib/vz/snippets/vm-optimize-hook.sh`:

```bash
#!/bin/bash
VMID="$1"
PHASE="$2"

if [[ "$PHASE" == "post-start" ]]; then
    sleep 2
    VM_PID="$(cat /run/qemu-server/$VMID.pid 2>/dev/null)"
    VCPU_THREADS=$(ps -L -p "$VM_PID" -o tid= | tr -d ' ' | grep -v "^$")
    HOST_CPUS=(2 10 3 11 4 12 5 13 6 14 7 15)
    i=0
    for tid in $VCPU_THREADS; do
        cpu=${HOST_CPUS[$((i % 12))]}
        taskset -cp "$cpu" "$tid" 2>/dev/null
        i=$((i + 1))
    done
fi
```

```bash
qm set 100 --hookscript local:snippets/vm-optimize-hook.sh
```

## Reversão

```bash
qm stop 100
qm set 100 --delete hookscript
qm set 100 --delete hostpci0
qm set 100 --delete hostpci1
qm set 100 --delete hugepages
rm /var/lib/vz/snippets/vm-optimize-hook.sh
```

## Monitoramento

Após cada `apt upgrade` do `pve-manager`:

```bash
# Conferir se hook ainda tá vinculado
grep hookscript /etc/pve/qemu-server/100.conf

# Conferir se VM ainda inicia sem erro NUMA
qm start 100 && qm status 100

# Conferir pinning
ps -L -p $(cat /run/qemu-server/100.pid) -o tid,psr,comm | head -15
```

## Referências

- https://pve.proxmox.com/wiki/Pci_passthrough — guia oficial Proxmox
- https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF — detalhes IOMMU
- Forum Proxmox (search: "gpu passthrough Ryzen 9700X")
- [[../../09-Logs/2026-08-23-sessao-infra-glacier-proxmox/11-gpu-passthrough-completo|11-gpu-passthrough-completo]] — log detalhado da sessão

## Tags

#adr #proxmox #passthrough #iommu #vfio #hugepages #cpu-pinning
