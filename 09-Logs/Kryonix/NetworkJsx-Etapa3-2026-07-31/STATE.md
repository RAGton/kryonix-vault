# Refatoração Network.jsx — Etapa 3 (Decomposição Visual) — 2026-07-31

## Resumo

O componente monolítico `ui/src/pages/Network.jsx` foi quebrado em **8
subcomponentes de apresentação puros** isolados em
`ui/src/components/network/`. O componente raiz virou orquestrador
estrito de estado (hooks) e injeção de dependências (props).

## Data

2026-07-31

## Agente

Aura

## Repos afetados

- `kryonix-dev/repos/kryxd`

## Commit

- Branch: `main`
- SHA: `081ce33`
- Mensagem: `refactor(network): decompose JSX into modular presentation components`

## Estatísticas do diff

```
 9 files changed, 893 insertions(+), 678 deletions(-)
```

| Arquivo | Mudança |
|---|---|
| `ui/src/pages/Network.jsx` | Modificado. 948 → **348** linhas (-600). Vira orquestrador puro. |
| `ui/src/components/network/NetworkHeader.jsx` | **Novo.** Header + toggle DHCP/Static (53 linhas) |
| `ui/src/components/network/LanCard.jsx` | **Novo.** Card 1 — LAN/PXE, DHCP ou Static (212 linhas) |
| `ui/src/components/network/WanCard.jsx` | **Novo.** Card 2 — WAN/PPPoE (150 linhas) |
| `ui/src/components/network/ApplyAction.jsx` | **Novo.** Erros inline + confirmação física + botão Aplicar (95 linhas) |
| `ui/src/components/network/ConnectionStatusPanel.jsx` | **Novo.** Status de conexão + offline (81 linhas) |
| `ui/src/components/network/WifiInlinePanel.jsx` | **Novo.** Sub-bloco Wi-Fi: scan + conectar (91 linhas) |
| `ui/src/components/network/ConfigSummaryPanel.jsx` | **Novo.** Resumo lateral (54 linhas) |
| `ui/src/components/network/RequirementsChecklist.jsx` | **Novo.** Requisitos de avanço (71 linhas) |

## Decomposição arquitetural

### Antes (Etapa 2)

```
Network.jsx (948 linhas)
├── Hooks + bootstrap (useRef latest-ref pattern)
├── 8 useState locais
├── wifiNameSet memoizado
├── onChange + refreshStatusRef
├── scanWifi + connectWifi callbacks
├── continueOffline + handleApplyNetwork handlers
├── handleWanInterfaceChange + handleIpv4Change + setDns handlers
├── JSX monolítico (650+ linhas inline)
└── SummaryRow local
```

### Depois (Etapa 3)

```
Network.jsx (348 linhas — orquestrador puro)
├── Hooks + bootstrap (mantido da Etapa 2)
├── Estado local Wi-Fi/UI (mantido)
├── Handlers (mantidos)
└── JSX de composição:
    ├── <NetworkHeader />        (53 linhas)
    ├── <LanCard />              (212 linhas)
    ├── <WanCard />              (150 linhas)
    ├── <ApplyAction />          (95 linhas)
    ├── <ConnectionStatusPanel>
    │   └── <WifiInlinePanel />  (81 + 91 = 172 linhas)
    ├── <ConfigSummaryPanel />   (54 linhas)
    └── <RequirementsChecklist /> (71 linhas)
```

## Contratos de props (resumo)

Cada subcomponente recebe **dados prontos via props**, sem acoplar a
hooks ou ref. O componente raiz mantém toda a lógica de domínio e
faz a injeção.

| Componente | Props principais |
|---|---|
| `NetworkHeader` | `isDhcp, onChange, busy` |
| `LanCard` | `wizard, onChange, fieldErrors, busy, isDhcp, ifaceNames, dns1, dns2, setDns, handleIpv4Change` |
| `WanCard` | `wizard, onChange, fieldErrors, busy, ifaceNames, wanEnabled, handleWanInterfaceChange, handleIpv4Change, showPppoePassword, setShowPppoePassword` |
| `ApplyAction` | `wizard, error, sameNicSelected, busy, onApply` |
| `ConnectionStatusPanel` | `wizard, netStatus, hasWifi, loading, onRefresh, wifiProps, onContinueOffline` |
| `WifiInlinePanel` | `wifiIfaces, selectedWifiIface, setSelectedWifiIface, wifiScanning, wifiList, wifiSsid, setWifiSsid, wifiPassword, setWifiPassword, connecting, connectMsg, onScan, onConnect` |
| `ConfigSummaryPanel` | `loading, interfaceCount, isDhcp, mgmtInterface, serverIp, wanEnabled, wanInterface` |
| `RequirementsChecklist` | `wizard, warnings` |

## Bug colateral consertado

Durante a migração, foi detectado que o botão "Atualizar" do
`ConnectionStatusPanel` original (linha 743 do arquivo pré-Etapa 3)
chamava `loadInterfaces` — **símbolo morto desde a Etapa 2**
(renomeado para `refreshInterfaces` quando encapsulado no hook).

Sem essa migração, o build passaria mas o botão quebraria em runtime
ao clicar (`TypeError: loadInterfaces is not a function`).

**Hoje:** botão chama `refreshInterfaces` (correto, estável, sem dead code).

## Validações executadas

### `npm test` — ✅ 123/123 verde

```
# tests 123
# suites 13
# pass 123
# fail 0
# duration_ms 1294.053415
```

### `npm run build` — ✅ verde

```
✓ 3109 modules transformed.
dist/assets/index-3gpeIfnc.js   1,812.41 kB │ gzip: 506.95 kB
✓ built in 8.76s
```

### Verificação ad-hoc estrutural (15 checks)

```
PASS — 8 subcomponentes criados
PASS — Network.jsx < 400 linhas (349 linhas)
PASS — Network.jsx importa todos os 7 componentes principais
PASS — Network.jsx não referencia mais `loadInterfaces` (dead code)
PASS — Network.jsx usa `refreshInterfaces` (símbolo pós-Etapa-2)
PASS — Network.jsx removeu SummaryRow local
PASS — Network.jsx removeu FieldError (movido pros subcomponentes)
PASS — network.test.js 9/9 verde
```

## Princípios aplicados

1. **Single Responsibility** — cada componente faz UMA coisa (apresentar).
2. **Dependency Injection** — dados via props, sem acoplamento a hooks/refs.
3. **Container/Presentational split** — Network.jsx é container (lógica),
   subcomponentes são presentational (markup).
4. **i18n isolada** — cada subcomponente chama `useTranslation`
   localmente (não prop drilling).
5. **Lifting state up** — estado Wi-Fi continua em Network.jsx (compartilhado
   entre scan e connect), passado via `wifiProps` ao subcomponente.
6. **JSX 100% preservado** — diff em tags/handlers = 0, apenas realocação.

## Próximo passo recomendado

**Estabilização crítica CONCLUÍDA.** Próximos alvos possíveis (em
ordem de prioridade):

1. **GAP PPPoE no InstallPlanV2** (débito arquitetural documentado na Etapa 1)
   — exige decisão de produto (V2 vai gerar NixOS, ou delega ao Flake?)
2. **SystemFeatures.jsx** (31kB, segundo maior componente da UI) — provavelmente
   merece o mesmo tratamento (SSoT → hooks → decomposição)
3. **Cargo clippy + cargo fmt** — drift pré-existente em `src/storage.rs:80`
4. **PR remote** — fazer `git push` (a definir se a sessão tem permissão)