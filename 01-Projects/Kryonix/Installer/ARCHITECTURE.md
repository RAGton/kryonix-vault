# Kryonix Installer Architecture

O Instalador Kryonix é projetado como uma plataforma modular com desacoplamento forte entre UI (frontend) e execução destrutiva (backend).

## Diagrama de Blocos

```text
Browser/Kiosk
  |
  +-- (HTTP/SSE) --> Installer API (Rust/Axum)
                        |
                        +--> Plan Validator (Schema, Auth, Disk Mode)
                        |
                        +--> Disk Planner (Disko, fdisk)
                        |
                        +--> Disko Dry Run (validação sem commit no disco)
                        |
                        +--> NixOS Installer Executor (nixos-install, chroot)
                        |
                        +--> Log/Event Stream (SSE broadcast para a UI)
  |
  +-- (Hardware/VM Target)
```

## Camadas

### UI Layer (Frontend)
- **Tecnologias**: React/Vite, TailwindCSS (design system customizado).
- **Responsabilidades**: Gerenciamento de estado em cliente, validação leve, acessibilidade, apresentação premium, e fluxo em assistente (stepper).
- **Comunicação**: Monta e envia `InstallPlan` completo para `/dry-run` antes de invocar `/install`. Nunca executa comandos shell diretamente.

### API Layer
- **Tecnologias**: Rust (Axum, Tokio).
- **Responsabilidades**: Rotas seguras (CORS estrito, checagem de loopback, Tokens de Sessão CSRF), streaming de logs (SSE), e roteamento de comandos.

### Domain Layer
- **Modelos**: `InstallPlan`, `DiskPlan`, `NetworkPlan`, `UserPlan`, `SafetyGate`.
- **Validação**: Valida exaustivamente os dados para garantir integridade e sanitização antes de enviá-los ao executor (e.g., modos de particionamento `destroy,format,mount`).

### Executor Layer
- **Tecnologias**: Interação com OS nativo (`nixos-install`, `disko`, `mount`, `umount`).
- **Dry-run**: Permite validar partições (`disko --mode dry-run`) sem formatar.
- **Log Collector**: Redireciona stdout e stderr de processos como `nixos-install` via canais mpsc/broadcast para a API Layer.

### Test Layer
- **Níveis**:
  - `L0`: Static Analysis (`nix fmt`, lint, typecheck).
  - `L1`: Unit Tests (Rust).
  - `L2`: Integration Tests.
  - `L3`: VM Dry (Kiosk abre, backend valida disko fake).
  - `L4`: VM Install (VM QEMU formata QCOW2 real via skill libvirt).
  - `L5`: Hardware Gate (validação manual em bare-metal).
