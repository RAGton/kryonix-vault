# Network.jsx — Etapa 1 (Centralização de Helpers) — 2026-07-31

## Resumo

Refatoração cirúrgica do `ui/src/pages/Network.jsx` para adotar `ui/src/utils/network.js`
(canônico, porém órfão) como **Single Source of Truth** dos helpers de IP/máscara/DNS.
Sem mudança de comportamento em runtime, zero alteração de JSX ou hooks.

## Data

2026-07-31

## Agente

Aura

## Repos afetados

- `kryonix-dev/repos/kryxd`

## Commit

- Branch: `main`
- SHA: `bd313ac`
- Mensagem: `refactor(network): centralize ip helpers in utils/network.js`

## Estatísticas do diff

```
 ui/src/WizardInstaller.jsx    |  25 +---------
 ui/src/pages/Network.jsx      | 112 ++++++++++++------------------------------
 ui/src/pages/RemoteAccess.jsx |  18 +------
 ui/src/state/wizardState.js   |   4 +-
 ui/src/utils/installPlan.js   |  53 ++++----------------
 ui/src/utils/network.js       |  71 ++++++++++++++++++++++++--
 ui/src/tests/utils/network.test.js (novo)
 7 files changed, 286 insertions(+), 170 deletions(-)
```

Net: **-57 linhas** (eliminação de duplicações + código morto).

## Arquivos no escopo

| Arquivo | Mudança |
|---|---|
| `ui/src/utils/network.js` | Expandido: agora exporta `DEFAULT_DNS_LIST`, `DEFAULT_DNS_CSV`, `sanitizeIp`, `isValidIpv4`, `netmaskToPrefix` (canônica estrita), `isUsableRemoteIp`, `formatIpv4Input`, `normalizeDnsList`, `isValidDnsList`, `validateStaticNetwork`. |
| `ui/src/pages/Network.jsx` | Removidos 4 helpers locais (`sanitizeIp`, `netmaskToPrefix`, `isUsableRemoteIp`, `formatIpv4Input`). Imports adicionados. `'1.1.1.1,8.8.8.8'` hardcoded → `DEFAULT_DNS_CSV`. JSX intocado. |
| `ui/src/pages/RemoteAccess.jsx` | Removidos `sanitizeIp` e `isValidIp` locais (idênticos aos do Network). Importa `sanitizeIp` + `isUsableRemoteIp` (chamada renomeada). |
| `ui/src/utils/installPlan.js` | Removido `netmaskToPrefix` local. `sanitizeDnsList`, `hasOnlyValidDnsItems`, `isValidIpv4` viraram wrappers finos sobre imports do `utils/network.js`. |
| `ui/src/state/wizardState.js` | `mgmtDns: '1.1.1.1,8.8.8.8'` → `mgmtDns: DEFAULT_DNS_CSV`. |
| `ui/src/WizardInstaller.jsx` | Removido `netmaskToPrefix` local **morto** (definido mas nunca usado). |
| `ui/src/tests/utils/network.test.js` | **Novo.** 9 testes cobrindo todas as funções exportadas, incluindo edge cases de máscara contígua, IPv6 rejeitado, loopback/link-local/0.0.0.0, dedup de DNS, e quirks históricos do `formatIpv4Input`. |

## Validações executadas

### `npm test` — ✅ 123/123 verde

```
# tests 123
# suites 13
# pass 123
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 1184.738935
```

### `npm run build` — ✅ verde

```
✓ 3109 modules transformed.
dist/index.html                     0.53 kB │ gzip:   0.33 kB
dist/assets/logo--SY328LB.png     678.64 kB
dist/assets/index-De6ulri2.css    120.67 kB │ gzip:  21.30 kB
dist/assets/index-BWPkoD5h.js   1,809.79 kB │ gzip: 506.11 kB
✓ built in 8.13s
```

### `cargo clippy` — ⚠️ bloqueado por ambiente

Erro `clang-sys v1.8.1` exige `libclang.so` ausente. **Não é regressão da Etapa 1**:
arquivos Rust não foram tocados. Drift pré-existente em `src/storage.rs:80` (indentação,
`cargo fmt --check`) também não relacionado.

Para validação completa do backend em ambiente adequado:
```bash
nix-shell -p llvmPackages.libclang --run "cargo clippy -- -D warnings"
```

## Descobertas importantes

### 1. `utils/network.js` já existia (órfão)

Tinha 100 linhas com funções canônicas (`validateStaticNetwork`, `normalizeDnsList`,
`isValidDnsList`, `netmaskToPrefix` estrita) mas **nenhum arquivo importava dele**. A
Etapa 1 não foi "criar do zero" — foi **adotar código canônico órfão** e completar.

### 2. `netmaskToPrefix` existia em 4 lugares

| Local | Versão | Destino |
|---|---|---|
| `Network.jsx:32` (antiga) | Fraca — retornava `24` como fallback | Removida |
| `installPlan.js:55` | Estrita — retornava `null` | Removida |
| `WizardInstaller.jsx:34` | Morta — definida mas nunca usada | Removida |
| `utils/network.js:17` (canônica) | Estrita — idêntica à do installPlan | **Mantida** |

Agora é 1 só função, com semântica estrita (retorna `null` para inválido).

### 3. `sanitizeIp` existia em 2 lugares

Idêntico em `Network.jsx:28` e `RemoteAccess.jsx:5`. Centralizado.

### 4. Mudança sutil de comportamento documentada

`netmaskToPrefix` antiga (fraca) → retornava `24` para máscara vazia.
`netmaskToPrefix` nova (estrita) → retorna `null`.

Hoje o ternário `wizard.mgmtNetmask ? netmaskToPrefix(...) : 24` em `Network.jsx:261`
protege o caso em runtime. Documentei no cabeçalho do `utils/network.js` para futuros
callers não quebrarem.

### 5. GAP ARQUITETURAL — PPPoE não chega no InstallPlanV2

**Severidade: débito arquitetural, NÃO bloqueia refactor de código limpo.**

| Camada | Estado |
|---|---|
| `Network.jsx` UI | Coleta `pppoeUser` + `pppoePassword` ✅ |
| `validateStep('network')` | Exige ambos se modo=pppoe ✅ |
| `buildInstallPlanV2` | **NÃO inclui bloco `network.wan`** ❌ |
| `src/domain/secrets.rs` | Tem `InstallSecretsV2.pppoe_password` ✅ |
| Backend V1 (`NetworkPlan.wan`) | Tem `pppoeUser` mas **não conectado ao V2** ❌ |

**Resultado:** usuário preenche PPPoE → avança → senha vai via secrets → mas
`pppoeUser` se perde → translator não gera `configuration.nix` com PPPoE.

**Decisão de produto pendente:** V2 vai gerir rede via translator, ou delega
puro pro NetworkManager/Flake? Acompanhar em card separado após Etapas 2-4.

## Pendências conhecidas

1. **Cargo clippy não rodado** — bloqueado por `libclang` ausente. Não é regressão.
2. **Drift pré-existente em `src/storage.rs`** — 1 linha de indentação fora do padrão
   `cargo fmt`. Não relacionado à Etapa 1.
3. **GAP PPPoE no V2** — débito arquitetural. Card separado.

## Próximo passo recomendado

**Etapa 2: Hooks customizados para matar God-Effects do Network.jsx**
- `useNetworkInterfaces.js` — encapsula estado + refresh + `wifiIfaces` (memoizado)
- `useNetworkStatus.js` — encapsula `refreshStatus` + conectividade
- `Network.jsx` recebe os 2 hooks, bootstrap em `useEffect(..., [])` com `useRef` para `onChange`
- Correção O(1) no auto-scan Wi-Fi: `wifiNameSet.has(...)` em vez de `wifiIfaces.some(...)`

Card já alinhado com Gabriel (2026-07-31):
- Hooks recebem `onChange` como argumento e invocam para atualizar `wizardState`
- Bootstrap: `useRef(onChange)` + `useEffect(..., [])`