# KVE Master UI Clone — Proxmox Reverse Engineering

Data: 2026-07-16
Agente: Aura
Repos afetados:

- kryxd
- kryonix-vault

## Objetivo

Expandir a Fase 1 da TreeView para uma experiência contextual Proxmox-like mais completa, usando o design system Industrial Dark/Blue do Kryonix.

A missão não altera backend, storage, rede ou estado real do sistema. O escopo é UI/roteamento React.

## Contexto consultado

- `repos/kryxd/ui/src/layouts/DashboardLayoutWithTree.jsx`
- `repos/kryxd/ui/src/components/kcp/TreeView.jsx`
- `repos/kryxd/ui/src/layouts/ContextLayout.jsx`
- `repos/kryxd/ui/src/App.jsx`
- `repos/kryxd/ui/src/components/kcp/console/KcpTerminal.jsx`

## Mudanças realizadas

### Top Header & Layout Global

Arquivo:

- `ui/src/layouts/DashboardLayoutWithTree.jsx`

Mudanças:

- Adicionado header fixo no topo com:
  - `h-16`
  - `bg-slate-950/80`
  - `backdrop-blur`
  - borda `border-slate-800`
- Adicionado Global Search visual/falso.
- Adicionado CTA azul `Create VM/CT` com `bg-blue-600 hover:bg-blue-500`.
- Layout abaixo do header dividido em:
  - left sidebar com `TreeView`;
  - right pane com `<Outlet />`.

### TreeView Proxmox-like hardcoded

Arquivo:

- `ui/src/components/kcp/TreeView.jsx`

Mudanças:

- Substituída a árvore dinâmica temporariamente por estrutura hardcoded completa para validação visual Proxmox-like:

```txt
Datacenter
└── pve-alpha
    ├── local-zfs
    ├── 100 (web-server)
    └── 101 (db-postgres)
```

Links:

```txt
/kcp/datacenter/summary
/kcp/node/pve-alpha/summary
/kcp/node/pve-alpha/storage/local-zfs/summary
/kcp/node/pve-alpha/vm/100/summary
/kcp/node/pve-alpha/ct/101/summary
```

- Ícones `lucide-react` usados:
  - `Globe2`
  - `Server`
  - `Database`
  - `Monitor`
  - `Box`
- Estilo ajustado para Industrial Dark/Blue:
  - `bg-slate-950`
  - `border-slate-800`
  - active state azul.

### ContextLayout inteligente

Arquivo:

- `ui/src/layouts/ContextLayout.jsx`

Mudanças:

- Tabs passam a variar conforme a URL atual:

| Contexto | Detecção | Tabs |
|---|---|---|
| Datacenter | `/datacenter/` | `Summary`, `Cluster`, `Storage`, `Firewall` |
| VM | `/vm/` | `Summary`, `Console`, `Hardware`, `Snapshots` |
| CT | `/ct/` | `Summary`, `Console`, `Hardware`, `Snapshots` |
| Storage Pool | `/storage/` | `Summary`, `Volumes`, `Replication` |
| Node | fallback `/node/` | `Summary`, `Shell`, `Network`, `Disks` |

- Active Tab agora usa:
  - `border-b-2`
  - `border-blue-500`
  - `text-blue-400`
- Fundo e áreas de conteúdo usam `bg-[#0a0a0a]`/`bg-slate-950`.

### Roteamento aninhado e Console

Arquivo:

- `ui/src/App.jsx`

Mudanças:

- Adicionadas rotas aninhadas de datacenter:
  - `/kcp/datacenter/summary`
  - `/kcp/datacenter/cluster`
  - `/kcp/datacenter/storage`
  - `/kcp/datacenter/firewall`
- Node tabs:
  - `/kcp/node/:nodeId/summary`
  - `/kcp/node/:nodeId/shell`
  - `/kcp/node/:nodeId/network`
  - `/kcp/node/:nodeId/disks`
- VM tabs:
  - `/kcp/node/:nodeId/vm/:vmId/summary`
  - `/kcp/node/:nodeId/vm/:vmId/console`
  - `/kcp/node/:nodeId/vm/:vmId/hardware`
  - `/kcp/node/:nodeId/vm/:vmId/snapshots`
- CT tabs:
  - `/kcp/node/:nodeId/ct/:ctId/summary`
  - `/kcp/node/:nodeId/ct/:ctId/console`
  - `/kcp/node/:nodeId/ct/:ctId/hardware`
  - `/kcp/node/:nodeId/ct/:ctId/snapshots`
- O `KcpTerminal` existente foi conectado à rota de console:
  - `/kcp/node/:nodeId/vm/:vmId/console`
  - também reaproveitado para `/ct/:ctId/console`.
- Rotas antigas preservadas:
  - `/`
  - `/fleet`
  - `/storage`
  - `/virt`
  - `/local-settings`

## Validações executadas

- `npm run build --prefix repos/kryxd/ui` — passou.
  - Avisos conhecidos: `/img/noise.png` não resolvido em build time e chunk JS > 500 kB.
- `git diff --check -- ui/src/App.jsx ui/src/components/kcp/TreeView.jsx ui/src/layouts/ContextLayout.jsx ui/src/layouts/DashboardLayoutWithTree.jsx` — passou.
- Verificação ad-hoc em `/tmp/nix-shell-266339-3526915383/hermes-verify-*.py` — passou; script removido após execução (`cleanup ok`).
- `ui/dist` gerado pelo Vite foi removido após a validação.

## Evidência ad-hoc

```txt
AD-HOC VERIFY KVE MASTER UI CLONE: PASS
- top header uses h-16 bg-slate-950/80 backdrop-blur
- global search and Create VM/CT CTA are present
- layout mounts left TreeView and right Outlet with w-72 sidebar
- TreeView hardcodes full Proxmox-like validation tree
- TreeView uses lucide native resource icons
- TreeView uses Industrial Dark/Blue border/background tokens
- ContextLayout selects Datacenter tabs from URL
- ContextLayout selects VM tabs from URL
- ContextLayout selects CT tabs from URL
- ContextLayout selects Node tabs and blue active-tab underline
- App.jsx mounts datacenter, CT and snapshots nested routes
- VM console route uses existing KcpTerminal
- legacy dashboard routes remain mounted
- npm production build passed
- scoped git diff --check passed
- generated ui/dist removed after build
```

## Estado

`READY_FOR_REVIEW`

## Riscos e limites

- A TreeView foi hardcoded de propósito para validação visual da experiência Proxmox-like; isso substitui temporariamente a versão dinâmica anterior.
- `KcpTerminal` abre WebSocket real quando a aba console é acessada; se o backend console não estiver disponível, a UI deve mostrar erro/desconexão dentro do terminal.
- Nenhuma rota backend nova foi criada nesta missão.
- Nenhum commit, push ou pointer de submódulo foi feito.

## Próximo passo recomendado

Rodar preview visual em `/kcp/datacenter/summary`, `/kcp/node/pve-alpha/vm/100/console` e `/kcp/node/pve-alpha/ct/101/summary` antes de consolidar commit.
