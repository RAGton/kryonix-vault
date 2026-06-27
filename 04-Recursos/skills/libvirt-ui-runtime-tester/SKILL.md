---
name: libvirt-ui-runtime-tester
description: Habilidade e roteiro de automação para orquestrar e testar a ISO do Kryonix e a execução do Installer (UI + Backend) de forma isolada e realista usando Libvirt e QEMU.
---

# Libvirt UI Runtime Tester

## Objetivo
Testar o Kryonix Installer de ponta a ponta sem risco para discos reais, utilizando máquinas virtuais. Cobre desde o boot da ISO construída via Nix flakes, passando pelo roteamento da rede, exibição do web kiosk (Vite) no terminal gráfico da VM e o apply do backend Rust formatando um disco virtual.

## Pré-requisitos
- Host rodando KryonixOS/NixOS.
- QEMU e libvirtd instalados e operacionais.
- Bridge de rede virtual ativada (e.g. `virbr0`).
- Arquivo de imagem `.iso` compilado via `nix build path:.#nixosConfigurations.iso.config.system.build.isoImage`.

## Comandos Recomendados

### 1. Criar Disco Virtual Limpo
Sempre antes de um novo L4 teste, garanta um disco virtual limpo:
```bash
qemu-img create -f qcow2 /tmp/kryonix-test-disk.qcow2 30G
```

### 2. Rodar a VM KVM Efêmera
Usar o script padrão do repositório (ex: `test-installer-libvirt.sh`) ou subir manualmente:

```bash
qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 \
  -drive file=/path/to/kryonix.iso,media=cdrom,readonly=on \
  -drive file=/tmp/kryonix-test-disk.qcow2,format=qcow2 \
  -boot d \
  -vga qxl -device virtio-serial-pci -spice port=5900,disable-ticketing=on \
  -netdev user,id=net0,hostfwd=tcp::8080-:8080 -device virtio-net-pci,netdev=net0
```
*Dica: o `hostfwd` permite que você acesse a API/Backend da VM (porta 8080) pelo seu host (para testes curl e depuração).*

### 3. Conectar ao SPICE/VNC
Para observar o Web Kiosk (React/Vite) ou TUI abrir:
```bash
spicy -h localhost -p 5900
# ou
remote-viewer spice://localhost:5900
```

### 4. Validações Pós-Instalação
Após o Backend avisar (INSTALL_SUCCESS) e o Kiosk pedir reboot:
- Encerre o QEMU.
- Reinicie a VM **sem o CD-ROM**, apenas com o `qcow2`.
- Verifique se o sistema sobe corretamente com os perfis e senhas solicitadas pela UI.

## O que a automação futura deste Skill deve realizar
- [ ] Construir a ISO de forma headless.
- [ ] Fazer o reset programático do `qcow2`.
- [ ] Usar Playwright/Selenium batendo na porta do frontend roteado do QEMU para preencher dados.
- [ ] Validar a finalização e fazer reboot automático, rodando SSH na máquina finalizada.
