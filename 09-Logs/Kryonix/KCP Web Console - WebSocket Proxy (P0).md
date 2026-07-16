# KCP Web Console - WebSocket Proxy (P0) + Storage Command Center (P2)

Data: 2026-07-16
Agente: Hermes
Repos afetados: kryonix-installer

## Objetivo

Implementar (P0) a ponte WebSocket segura entre a API do Incus e o frontend KCP, e (P2) o Storage Command Center com visualização de Storage Pools.

## Contexto consultado

- `repos/kryonix-installer/src/api/virt.rs` - API existente de virtualização
- `repos/kryonix-installer/src/api/v1/rbac.rs` - Middleware RBAC RequireCoreRole
- `repos/kryonix-installer/src/api/mod.rs` - Estrutura de rotas v2
- `repos/kryonix-installer/src/api/install.rs` - Padrão de resposta ErrorResponse
- `repos/kryonix-installer/ui/src/pages/kcp/Virt.jsx` - Página de instâncias, padrão de botões
- `repos/kryonix-installer/ui/src/components/VirtWizard.jsx` - Padrão de modal

## Mudanças realizadas - Fase P0 (WebSocket Console)

### Backend (Rust/Axum)

1. **Cargo.toml** - Adicionadas dependências:
   - `axum = { version = "0.7", features = ["ws"] }` - Suporte WebSocket
   - `tokio-tungstenite = "0.24"` - Cliente WebSocket para conectar ao Incus
   - `url = "2.5"` - Parsing de URLs WebSocket

2. **src/api/console.rs** (novo) - Proxy WebSocket bidirecional:
   - Rota `GET /api/v2/console/instances/:name/console/ws`
   - Middleware `RequireCoreRole` para RBAC (apenas Core/ThinkServer)
   - `get_incus_console_url()` - Executa `incus exec --raw` para obter WebSocket URL
   - `handle_websocket_upgrade()` - Proxy bidirecional Browser <-> Axum <-> Incus
   - Regra de ouro: segredos do Incus NUNCA saem do backend

3. **src/api/mod.rs** - Incluído o módulo console com `.nest("/console", console::router())`

### Frontend (React/xterm.js)

1. **Dependências** - Instaladas:
   - `@xterm/xterm`
   - `@xterm/addon-fit`
   - `@xterm/addon-web-links`

2. **src/components/kcp/console/KcpTerminal.jsx** (novo) - Componente de terminal:
   - xterm.js integrado com tema escuro (Kryonix Dark)
   - WebSockets connection to `/api/v2/console/instances/:name/console/ws`
   - ResizeObserver para redimensionamento automático
   - Botão fechar no header

3. **src/pages/kcp/Virt.jsx** - Modificado:
   - Botão Console (>_ Console) na coluna Ações
   - Modal overlay com KcpTerminal
   - Estado `consoleInstance` para controle do modal
   - Botão desativado para instâncias paradas

---

## Mudanças realizadas - Fase P2 (Storage Command Center)

### Backend (Rust/Axum)

**src/api/storage.rs** (novo) - API read-only de storage:
- Rota `GET /api/v2/storage/pools` - Lista pools via `incus list storage-pools --format=json`
- Estrutura `StoragePool` com campos: name, driver, status, total_size, used_size, available_size
- Tratamento de erros e resposta JSON limpa

**src/api/mod.rs** - Atualizado:
- `.nest("/storage", storage::router())`

### Frontend (React)

**src/lib/api.js** - Adicionada função:
- `getStoragePools()` - Consome `/api/v2/storage/pools`

**ui/src/pages/kcp/Storage.jsx** (refatorado):
- Tabs superiores: **Pools** (active), **Volumes** (disabled), **Health** (disabled)
- Cards modernos para cada pool mostrando:
  - Driver badge (ZFS=blue, Ceph=purple, Btrfs=green)
  - Status indicator (Created/Running=green, else=yellow)
  - Size/Used metrics com `formatBytes()`
- Empty state com ícone AlertCircle quando não há pools
- Cards com hover shadow para melhor UX

---

## Validações executadas

```bash
# Backend
cargo check --workspace
# Resultado: 
warning: unused import: InstallPlan (non-crítico)
warning: resolver versioning (non-crítico)
# Status: SUCCESS

# Frontend
npm run build
# Resultado:
✓ built in 5.91s
# Status: SUCCESS
```

## Evidências

- **Commit P0:** `4745f01` - feat(kcp): add secure WebSocket console proxy for Incus instances
- **Commit P2:** `199b276` - feat(storage): add Storage Command Center v1 with Pools tab
- **dev server rodando:** http://localhost:5173

## Pendências

1. **Testes integrados**: A conexão WebSocket precisa de teste real com Incus rodando
2. **Resize endpoint**: Incus console pode precisar de `/1.0/instances/:name/exec` com width/height
3. **Autenticação**: O RBAC atual usa `kryx::services::identity::check_identity()` - verificar integração
4. **Volumes/Health tabs**: Implementar nas fases P3/P4

## Próximo passo recomendado

Testar ambas as implementações com uma instância Incus real para validar:
1. Fluxo de conexão WebSocket (P0)
2. RBAC funcionando corretamente (P0)
3. Exibição de Storage Pools (P2)
4. Redimensionamento do terminal (P0)

#tags: kcp, console, websocket, incus, xterm, storage, rbac