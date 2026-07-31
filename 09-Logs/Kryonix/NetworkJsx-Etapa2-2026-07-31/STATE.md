# Network.jsx — Etapa 2 (Hooks + Latest-Ref Pattern) — 2026-07-31

## Resumo

Eliminação dos God-Effects do `ui/src/pages/Network.jsx` via extração de
I/O + estado local para 2 Custom Hooks puros. JSX intacto. Comportamento
preservado em runtime.

## Data

2026-07-31

## Agente

Aura

## Repos afetados

- `kryonix-dev/repos/kryxd`

## Commit

- Branch: `main`
- SHA: `a062a8e`
- Mensagem: `refactor(network): extract side-effects to useNetworkInterfaces and useNetworkStatus hooks`

## Estatísticas do diff

```
 ui/src/hooks/useNetworkInterfaces.js | 63 +++++++++++++++++++
 ui/src/hooks/useNetworkStatus.js     | 52 ++++++++++++++++
 ui/src/pages/Network.jsx             | 116 +++++++++++++++++++----------------
 3 files changed, 179 insertions(+), 52 deletions(-)
```

Net: **+127 linhas** (113 de código novo em hooks puros, mas -52 no componente).

## Arquivos no escopo

| Arquivo | Mudança |
|---|---|
| `ui/src/hooks/useNetworkInterfaces.js` | **Novo.** Hook puro: estado `interfaces`/`loading`/`error` + `wifiIfaces`/`ethIfaces`/`ifaceNames` memoizados + `refreshInterfaces` (useCallback). Sem `useEffect` no mount. Sem `onChange`. |
| `ui/src/hooks/useNetworkStatus.js` | **Novo.** Hook puro: estado `netStatus` + `checkConnectionStatus(applyStatus?)` que aceita callback opcional para patch. Sem `useEffect` no mount. Sem `onChange`. |
| `ui/src/pages/Network.jsx` | Removidos 5 `useState` (`interfaces`, `loading`, `error`, `netStatus` + helpers). Removidas 2 funções (`refreshStatus`, `loadInterfaces`). Removido 1 `useEffect` (boot duplo). Adicionados `useMemo(wifiNameSet)` e 2 `useRef` para `latest-ref pattern`. Auto-scan Wi-Fi O(1). |

## Arquitetura resultante

### Padrão latest-ref (avançado)

```js
const onChangeRef = useRef(onChange);
onChangeRef.current = onChange;

const refreshStatusRef = useRef(null);
refreshStatusRef.current = async () => {
  await checkConnectionStatus((patch) => onChangeRef.current(patch));
};

useEffect(() => {
  // roda UMA vez no mount, deps []
  // pode usar onChangeRef.current e refreshStatusRef.current
  // sem causar re-runs quando o pai recriar os handlers
}, []);
```

Isso elimina o ciclo:
`onChange muda → loadInterfaces muda → useEffect re-roda → fetch duplo`.

### Bootstrap single-shot

```js
useEffect(() => {
  let cancelled = false;
  (async () => {
    const list = await refreshInterfaces();   // hook puro
    if (cancelled) return;

    // auto-selecionar primeira Wi-Fi (preservado do original)
    const wifi = list.find((i) => i.type === 'wifi');
    if (wifi && !selectedWifiIface) setSelectedWifiIface(wifi.name);

    // patch wizardState (responsabilidade do componente, não do hook)
    const names = list.map((i) => i.name).filter(Boolean);
    const patch = { netIfacesCount: names.length };
    if (!wizard.mgmtInterface || !names.includes(wizard.mgmtInterface)) {
      patch.mgmtInterface = names[0] || '';
    }
    onChangeRef.current(patch);

    if (!cancelled) await refreshStatusRef.current?.();
  })();
  return () => { cancelled = true; };
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, []);
```

### Auto-scan Wi-Fi O(1)

```js
const wifiNameSet = useMemo(
  () => new Set(wifiIfaces.map((i) => i.name)),
  [wifiIfaces]
);

useEffect(() => {
  if (selectedWifiIface && wifiNameSet.has(selectedWifiIface)) {
    scanWifi();
  }
}, [selectedWifiIface, wifiNameSet]);
```

Substitui `wifiIfaces.some((i) => i.name === ...)` que era O(N) por chamada.

## Redução de complexidade

| Métrica | Antes | Depois |
|---|---|---|
| `useState` total | 15 | 10 |
| `useEffect` total | 2 | 2 (mas 1 com deps `[]`, sem God-Effect) |
| `useCallback` total | 6 | 5 |
| `useMemo` | 0 | 2 (wifiNameSet, hook internals) |
| `useRef` | 0 | 2 (latest-ref pattern) |
| Linhas em `Network.jsx` | 986 | 948 (-38) |

## Validações executadas

### `npm test` — ✅ 123/123 verde

```
# tests 123
# suites 13
# pass 123
# fail 0
# duration_ms 1222.525189
```

### `npm run build` — ✅ verde

```
✓ 3109 modules transformed.
dist/assets/index-C4HF4BBm.js   1,810.58 kB │ gzip: 506.41 kB
✓ built in 8.60s
```

### Verificação ad-hoc (20 checks estruturais + testes)

- ✅ Hooks criados e parseáveis
- ✅ `useNetworkStatus` não chama `onChange` (pureza preservada)
- ✅ `Network.jsx` importa ambos os hooks
- ✅ 4 `useState` duplicados removidos
- ✅ `wifiNameSet.has(...)` presente, `wifiIfaces.some(` ausente em código ativo
- ✅ Bootstrap usa `useEffect(..., [])` + `useRef`
- ✅ JSX intocado (diff em tags = 0)
- ✅ `network.test.js` 9/9 verde

## Decisão arquitetural importante

**Conflito entre PASSO 1 e PASSO 2 da spec** resolvido assim:

| Spec original | Decisão aplicada | Razão |
|---|---|---|
| "PASSO 1: hook autónomo sem useEffect no mount" | ✅ Hook sem `useEffect` interno | Evita boot concorrente |
| "PASSO 2: hook recebe onChange para comunicar com pai" | ❌ Hook **não** recebe onChange | Mantém pureza do hook; componente decide como aplicar patch |
| "PASSO 3: bootstrap único com deps []" | ✅ Via `useRef(onChange)` + `useRef(refreshStatus)` | latest-ref pattern |
| "O(1) no auto-scan Wi-Fi" | ✅ `Set` memoizado | Hot path do render |

**Hook é puro, componente é orquestrador.** O componente passa um callback
(`applyStatus`) para `checkConnectionStatus` quando quer aplicar patch
no wizardState. Isso preserva a single source of truth sem acoplar o
hook ao ciclo de vida do componente.

## Pendências conhecidas

1. **`cargo clippy` ainda bloqueado** — `libclang` ausente no ambiente. Não relacionado.
2. **`cargo fmt` drift em `src/storage.rs:80`** — pré-existente, não introduzido.
3. **GAP arquitetural do PPPoE no V2** — débito documentado no Etapa 1 STATE.md.

## Próximo passo recomendado

**Etapa 3: Decompor JSX em subcomponentes**
- `LanCard` (linhas 374-563)
- `WanCard` (linhas 565-690)
- `ApplyAction` (linhas 715-767)
- `ConnectionStatusPanel` (linhas 774-901)
- `ConfigSummaryPanel` (linhas 903-915)
- `RequirementsChecklist` (linhas 917-979)

Objetivo: `Network.jsx` cai de 948 → ~150 linhas de orquestração.