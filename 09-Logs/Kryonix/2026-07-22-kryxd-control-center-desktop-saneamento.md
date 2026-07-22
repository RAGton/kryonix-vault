# Kryonix Control Center — saneamento Desktop e identidade de sessão

Data: 2026-07-22
Agente: Aura
Repos afetados:

- repos/kryxd
- repos/kryonixos
- repos/kryonix-vault
- kryonix-dev

## Objetivo

Corrigir a crise de identidade do painel Desktop: remover aparência de Installer/Node/Think Server/PXE, exibir o usuário real autenticado, reduzir menus de infraestrutura e substituir o storage pendente por telemetria local somente leitura.

## Contexto consultado

- `kryonix-dev/AGENTS.md`.
- `repos/kryonixos/AGENTS.md`.
- `repos/kryonix-vault/AGENTS.md`.
- `repos/kryonix-vault/VAULT_INDEX.md`.
- Logs anteriores de absorção do Control Center, autenticação PAM e wiring KVE.
- Código real de `kryxd/src/api/auth.rs`, `kryxd/src/api/system.rs`, `kryxd/ui/src/App.jsx`, `Sidebar.tsx`, `Topbar.tsx`, `DesktopSummary.jsx`, `Login.tsx`.

## Problemas confirmados

- título do navegador era `Kryonix Installer`;
- Topbar exibia usuário fixo `Aguiar Rocha` e `root@kve-pve`;
- Desktop exibia `KRYONIX NODE`, `BOOT: PXE/HTTP`, IDs de cluster e referências de API;
- menu Desktop expunha Logs, Contratos API e Storage de Core mesmo em host Desktop;
- `DesktopSummary` mostrava `V2 API Bind pendente` em vez de dados reais;
- `/api/v2/storage/pools` e `/api/v1/storage/quotas` retornavam 403 para Desktop por RBAC Core;
- sessão PAM não retornava username, nome real, UID ou administração.

## Mudanças realizadas em `repos/kryxd`

### Commit `16356c1`

`feat(ui): expose real local session identity in control center`

- `<title>` alterado para `Kryonix Control Center`.
- Login deixou de exibir mensagens `KVE Gateway` e texto confuso de escopo no host Desktop.
- Sessão PAM agora inclui:
  - `username`;
  - `real_name` lido do GECOS de `/etc/passwd`;
  - `uid`;
  - `is_admin` derivado de UID 0 ou grupos `wheel`/`sudo`.
- Claims assinados carregam a identidade real para sobreviver a reload.
- Card principal passou a exibir sessão atual, username, UID e permissão.
- Removidos texto de API/mock/PAM do resumo Desktop.

### Commit `87892f6`

`refactor(ui): rebrand desktop navigation and hide infrastructure menus`

- `Sidebar` recebeu `desktopMode`.
- Desktop agora mostra somente:
  - Visão geral;
  - Meu usuário;
  - Configurações.
- Logs, Storage Core, Contratos API e menus de infraestrutura não são renderizados no Desktop.
- Branding `KRYONIX NODE` substituído por `Kryonix Control Center` no Desktop.
- Topbar deixou de exibir:
  - `KRYONIX VE-DC-01`;
  - `BOOT: PXE/HTTP`;
  - carga falsa `LOAD: 0.42` no Desktop;
  - usuário falso `Aguiar Rocha`/`root@kve-pve`.
- Avatar e menu do Topbar usam a sessão real.
- Footer deixou de mostrar endpoints Axum.

### Commit `7138901`

`feat(ui): show real root storage telemetry on desktop`

- `GET /api/v2/metrics/host` agora inclui storage somente leitura do mount `/`.
- Coleta usa `df -Pk /` dentro do backend.
- UI exibe uso percentual, espaço usado, espaço livre e mountpoint.
- Não foram adicionadas ações destrutivas nem mutações de storage.
- Nenhum mock de capacidade foi usado para storage.

## Mudanças em `repos/kryonixos`

### Commit `9ef1e1b`

`chore(flake): pin kryxd control center desktop telemetry`

- `flake.lock` atualizado de `d707851` para `7138901`.
- O host passou a consumir o daemon/UI novos sem `--override-input`.
- Arquivos preexistentes fora do escopo, especialmente `hosts/inspiron/default.nix`, foram preservados.

## Validações

### Frontend

```bash
npm run build
```

Resultado: PASS.

Warnings não bloqueantes:

- `/img/noise.png` permanece para resolução em runtime;
- chunk principal acima de 500 kB.

### Rust

```bash
BINDGEN_EXTRA_CLANG_ARGS="-I/nix/store/pv8aczqkk94gzxhx0gk168gpxcll0svi-linux-pam-1.7.1/include" \
nix shell nixpkgs#linux-pam nixpkgs#clang nixpkgs#pkg-config -c cargo check -p kryxd
```

Resultado: PASS.

Warnings preexistentes:

- `private_interfaces` em `load_install_state`;
- `dead_code` em `expected_password`.

### Build Nix

```bash
nix build .#default --no-link -L --show-trace
```

Resultado: PASS.

### Downstream

```bash
nix flake check --keep-going --impure
```

Resultado: PASS.

### Rebuild sem override

```bash
sudo nixos-rebuild test --flake .#inspiron --impure --show-trace -L
```

Resultado: PASS. Serviço novo ativado.

### Runtime

```txt
kryxd.service: active
```

`GET /api/v2/metrics/host` retornou telemetria real:

```json
{
  "cpuPercent": 5.2,
  "memory": {"usedPercent": 68.0},
  "storage": {
    "mountpoint": "/",
    "totalBytes": 443912028160,
    "usedBytes": 3660185600,
    "availableBytes": 440251842560,
    "usedPercent": 1
  }
}
```

`GET /api/v1/system/identity` retornou:

```json
{"role":"Desktop","edition":"Kryonix Desktop"}
```

Login inválido retornou corretamente:

```txt
HTTP/1.1 401 Unauthorized
INVALID_CREDENTIALS
```

Browser:

```txt
title = Kryonix Control Center
```

## Limitações honestas

- Login real com senha PAM não foi executado pela Aura.
- Configuração declarativa de features/storage ainda não foi implementada; a UI agora não finge que mutações estão funcionando.
- O endpoint de storage Incus continua protegido para Core/ThinkServer e não aparece no Desktop.
- A sessão continua com TTL fixo de 15 minutos, sem rolling renewal.
- A ocorrência de `Aguiar Rocha` em `ui/src/views/Publish.tsx` pertence a uma tela legada fora do fluxo Desktop e não é renderizada nesse perfil.

## Próximo passo recomendado

Implementar o contrato real de capabilities/features do host e conectar as configurações de usuário a um estado declarativo seguro. Não reabrir Logs, Incus, PXE ou menus de Core no Desktop até haver capability explícita.
