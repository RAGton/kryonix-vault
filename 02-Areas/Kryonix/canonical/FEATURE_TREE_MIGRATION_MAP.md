# Feature Tree Migration Map

## Objetivo

Mapear a migração de `features/` para `modules/nixos/features/`.

## Matriz de migração

| Legado | Canônico alvo | Namespace atual | Namespace alvo | Conflitos | Risco | Ação |
|---|---|---|---|---|---|---|
| `features/development.nix` | `modules/nixos/features/development.nix` | `kryonix.features.development` | `kryonix.features.development` | Nenhum | Baixo | Mover |
| `features/gaming.nix` | `modules/nixos/features/gaming.nix` | `kryonix.features.gaming` | `kryonix.features.gaming` | `gamer.nix` em modules | Baixo | Renomear/Substituir |
| `features/workstation.nix` | `modules/nixos/features/workstation.nix` | `kryonix.features.workstation` | `kryonix.features.workstation` | Nenhum | Médio | Mover |
| `features/virtualization.nix`| `modules/nixos/features/virtualization.nix` | `kryonix.features.virtualization` | `kryonix.features.virtualization` | Nenhum | Baixo | Mover |
| `features/ai.nix` | `modules/nixos/features/ai.nix` | `kryonix.features.ai.*` | `kryonix.features.ai.*` | Opções diferentes no alvo | Médio | Consolidar |
| `features/remote-desktop.nix`| `modules/nixos/features/remote.nix` | `kryonix.features.remoteDesktop` | `kryonix.features.remote.desktop` | Namespace | Baixo | Renomear namespace |
| `features/openrgb.nix` | `modules/nixos/features/hardware/openrgb.nix`| `kryonix.features.openrgb` | `kryonix.features.hardware.openrgb` | Nenhum | Baixo | Mover |
| `features/f5-tts-server/` | `modules/nixos/features/ai/f5-tts.nix` | `kryonix.features.f5tts` | `kryonix.features.ai.f5tts` | Nenhum | Baixo | Mover |

## Mapeamento inicial esperado

| Legado | Canônico alvo | Observação |
|---|---|---|
| `features/development.nix` | `modules/nixos/features/development.nix` | preservar implementação madura |
| `features/gaming.nix` | `modules/nixos/features/gaming.nix` | vence nome `gaming`, evitar `gamer` |
| `features/workstation.nix` | `modules/nixos/features/workstation.nix` ou split em `desktop.nix`/`development.nix` | remover Hyprland default escondido |
| `features/virtualization.nix` | `modules/nixos/features/virtualization.nix` | consolidar libvirt/podman/docker |
| `features/ai.nix` | `modules/nixos/features/ai.nix` | AI migration must be split by subfeature: brain client/server, ollama, neo4j, lightrag. Do not mix GPU/CUDA or F5-TTS in the same PR. |
| `features/remote-desktop.nix` | `modules/nixos/features/remote.nix` | novo namespace `remote.desktop.*` |
| `features/openrgb.nix` | `modules/nixos/features/hardware/openrgb.nix` ou `misc/openrgb.nix` | decidir destino |
| `features/f5-tts-server/` | `modules/nixos/features/ai/f5-tts.nix` | tratar como AI/server |

## Profiles dependentes

Listar:

- `glacier-base`
- `glacier-ai`
- `glacier-gamer`
- `server-ai`
- `desktop`
- `laptop`
- `workstation-gamer`

## Downstream dependente

Mapear hosts afetados:

- `glacier`
- `inspiron`
- `inspiron-nina`
- `iso`, se existir

## Installer dependente

Mapear catálogos hardcoded:

- `featureCatalog.js`
- `profileCatalog.js`
- outros arquivos encontrados

## Plano de PRs

1. PR audit-only de migration map.
2. PR move development — migrated
3. PR move virtualization — migrated
4. PR move gaming/gamer — migrated / gamer conflict resolved
5. PR move AI.
6. PR move workstation/desktop.
7. PR compat profiles `glacier-*`.
8. PR export registry JSON.
9. PR downstream features.generated/local.
10. PR installer consumes JSON.

## Critérios antes de tocar no installer

- [ ] `features/` legado não existe ou não é importado.
- [ ] `modules/nixos/features/` contém todas as features.
- [ ] Feature Registry cobre todas.
- [ ] Existe exportador JSON.
