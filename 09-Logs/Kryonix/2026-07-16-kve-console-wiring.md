# KVE Console Wiring — Xterm.js → Axum Proxy

Data: 2026-07-16
Agente: Aura
Repos afetados:

- kryxd
- kryonix-vault

## Objetivo

Finalizar o fluxo de Console Web do KVE, conectando a aba contextual `Console` ao componente real `KcpTerminal` e removendo a tela antiga do Control Plane do fluxo Core.

## Contexto consultado

- Imagem enviada pelo Gabriel mostrando a tela antiga `Control Plane` com sidebar legada e rota de Storage.
- `ui/src/App.jsx`
- `ui/src/components/kcp/console/KcpTerminal.jsx`
- `ui/src/layouts/DashboardLayout.jsx`
- `ui/src/pages/kcp/Storage.jsx`

## Diagnóstico

A tela da imagem ainda vinha do layout legado `DashboardLayout.jsx`:

```txt
Control Plane
Dashboard / Fleet / Storage / Virtualization / Local Settings
```

Esse shell coexistia com a nova UI `/kcp/...`, então rotas antigas como `/storage` ainda abriam a experiência antiga em vez de entrar no KVE Master UI Clone.

## Mudanças realizadas

### Remoção do fluxo Core legado

Arquivo:

- `ui/src/App.jsx`

Mudanças:

- Removido o uso de `DashboardLayout` para Core.
- Removidos imports do shell antigo no fluxo Core.
- Rotas legadas agora redirecionam para o KVE novo:

| Rota antiga | Destino novo |
|---|---|
| `/` | `/kcp/datacenter/summary` |
| `/fleet` | `/kcp/datacenter/cluster` |
| `/storage` | `/kcp/node/pve-alpha/storage/local-zfs/summary` |
| `/virt` | `/kcp/node/pve-alpha/vm/100/summary` |

- `Storage Command Center` foi integrado dentro do contexto novo em:

```txt
/kcp/node/:nodeId/storage/:poolId/summary
```

### Console Web nativo em aba

Arquivo:

- `ui/src/components/kcp/console/KcpTerminal.jsx`

Mudanças:

- `KcpTerminal` agora importa `useParams` de `react-router-dom`.
- Captura dinamicamente:

```txt
:nodeId
:vmId
:ctId
```

- Monta o WebSocket usando a rota Axum esperada:

```txt
/api/v2/virt/instances/:instanceId/console/ws?node=:nodeId&kind=vm|ct
```

- Removeu `onClose` e o botão de fechar modal.
- O console agora vive nativamente dentro da tab `Console`.
- Cleanup garantido no unmount:
  - fecha WebSocket se estiver `OPEN` ou `CONNECTING`;
  - desmonta `ResizeObserver`;
  - executa `term.dispose()`.
- Container ajustado para preencher a tab:

```txt
h-[calc(100vh-12rem)] min-h-[420px] w-full bg-black p-2 rounded-b-lg border border-slate-800
```

### Integração no router

Arquivo:

- `ui/src/App.jsx`

Mudanças:

- Rotas VM/CT console renderizam diretamente:

```jsx
<KcpTerminal />
```

Rotas:

```txt
/kcp/node/:nodeId/vm/:vmId/console
/kcp/node/:nodeId/ct/:ctId/console
```

## Segurança

- Nenhuma chave, token ou secret Incus foi colocado no frontend.
- O frontend conhece apenas a rota WebSocket do Axum.
- O fluxo esperado permanece:

```txt
Frontend → WebSocket → Axum → Unix Socket → Incus
```

## Validações executadas

- `npm run build --prefix repos/kryxd/ui` — passou.
  - Avisos conhecidos: `/img/noise.png` não resolvido em build time e chunk JS > 500 kB.
- `git diff --check -- ui/src/App.jsx ui/src/components/kcp/console/KcpTerminal.jsx` — passou.
- Verificação ad-hoc em `/tmp/nix-shell-266339-3526915383/hermes-verify-*.py` — passou; script removido após execução (`cleanup ok`).
- `ui/dist` gerado pelo Vite foi removido após build.
- Smoke visual no navegador:
  - `/storage` redireciona/renderiza dentro do layout KVE novo.
  - `/kcp/node/pve-alpha/vm/100/console` renderiza `KcpTerminal` dentro da tab Console.
  - Console JS sem erros reportados pelo navegador.

## Evidência ad-hoc

```txt
AD-HOC VERIFY KVE CONSOLE WIRING: PASS
- legacy DashboardLayout/Core screen is no longer mounted
- legacy /storage redirects into new KVE tree route
- legacy /fleet redirects into Datacenter Cluster tab
- legacy /virt redirects into contextual VM route
- Storage Command Center is integrated into contextual storage summary
- VM/CT console routes render KcpTerminal directly
- KcpTerminal imports useParams
- KcpTerminal captures nodeId/vmId/ctId from URL
- KcpTerminal uses Axum virt console websocket endpoint
- KcpTerminal opens WebSocket and cleans up on unmount
- modal close button was removed from native tab console
- terminal fills tab height with requested styling
- frontend terminal contains no secret/key material
- npm production build passed
- scoped git diff --check passed
- generated ui/dist removed after build
```

## Estado

`READY_FOR_REVIEW`

## Riscos e limites

- O frontend agora aponta para o endpoint WebSocket Axum esperado. Se o backend real não estiver rodando esse proxy, o terminal exibe indisponibilidade/conexão fechada.
- O mock de preview atual não implementa WebSocket real de console.
- `DashboardLayout.jsx` ainda existe no repositório, mas não é mais montado no fluxo Core. Remoção física do arquivo pode ser feita em limpeza posterior se nenhum outro fluxo precisar dele.

## Próximo passo recomendado

Validar com backend Axum real rodando e endpoint `/api/v2/virt/instances/:id/console/ws` ativo para confirmar tráfego até o Unix socket do Incus.
