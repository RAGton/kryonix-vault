# Classificação de Packages

## Taxonomia oficial

| Categoria | Significado | Exemplos |
|---|---|---|
| `CORE_KEEP` | Deve permanecer no core | flake/, lib/ |
| `CORE_SHARED` | Compartilhado, fica no core | overlays/, hosts/common/ |
| `CORE_MODULE` | Módulo reutilizável | modules/nixos/features/* |
| `CORE_PACKAGE` | Package essencial | kryonix-cli, kryonix-bar |
| `CORE_CLI` | CLI base | kryonix-cli |
| `DOWNSTREAM_ONLY` | Deve ir para kryonixos | hosts/inspiron/, profiles/glacier-* |
| `ISO_ONLY` | ISO build | hosts/iso/ |
| `INSTALLER_PRODUCT` | Produto installer | disk-planner, hardware-probe |
| `BRAIN_PRODUCT` | Produto Brain | kryonix-brain-lightrag |
| `HOME_PRODUCT` | Produto Home | kryonix-home |
| `AURA_PRODUCT` | Produto Aura | packages/aura/ |
| `DESKTOP_ASSET` | Asset de desktop | wallpapers, sddm-theme |
| `LEGACY` | Legado | docs/archive/, .ai/ |

## Regras de decisão

**Fica no core se:**
- Módulo reutilizável desativado por padrão
- Package essencial do motor
- Lib compartilhada
- Template genérico
- Não depende de host real, usuário real, estado ou segredo

**Vai para downstream se:**
- Contém configuração de máquina real
- Contém usuário real
- Ativa features para máquina específica
- Define hardware, rede, GPU real

**Vai para installer se:**
- ISO, live environment
- Fluxo de instalação
- Disk planner, hardware probe
- Só faz sentido antes do sistema estar instalado

## Links

[[CORE_DOWNSTREAM_INSTALLER]]
[[audits/2026-06-22-core-boundary-audit/README]]
