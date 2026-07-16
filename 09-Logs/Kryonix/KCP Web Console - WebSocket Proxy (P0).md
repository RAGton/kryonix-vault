# KCP Web Console - WebSocket Proxy (P0)

Data: 2026-07-16
Agente: Hermes
Repos afetados: kryonix-installer

## Objetivo

Implementar a ponte WebSocket segura entre a API do Incus e o frontend KCP, permitindo acesso ao console de instâncias via navegador com xterm.js.

## Contexto consultado

- `repos/kryonix-installer/src/api/virt.rs` - API existente de virtualização
- `repos/kryonix-installer/src/api/v1/rbac.rs` - Middleware RBAC RequireCoreRole
- `repos/kryonix-installer/src/api/mod.rs` - Estrutura de rotas v2
- `repos/kryonix-installer/ui/src/pages/kcp/Virt.jsx` - Página de instâncias
- `repos/kryonix-installer/ui/src/components/VirtWizard.jsx` - Padrão de modal

## Mudanças realizadas

### Backend (Rust/Axum)

1. **Cargo.toml** - Adicionadas dependências:
   - `axum = { version = "0.7", features = ["ws"] }` - Suporte WebSocket
   - `tokio-tungstenite = "0.24"` - Cliente WebSocket para conectar ao Incus
   - `url = "2.5"` - Parsing de URLs WebSocket

2. **src/api/console.rs** (novo) - Proxy WebSocket bidirecional:
   - Rota `GET /api/v2/console/instances/:name/console/ws`
   - Middleware `RequireCoreRole` para RBAC (apenas Core/ThinkServer)
   - `get_incus_console_url()` - Executa `incus exec --raw` para obter WebSocket URL
   - `handle_websocket_upgrade()` - Proxy bidirecional Browser <-> Axus <-> Incus
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

## Validações executadas

```bash
# Backend
cargo check --workspace
# Resultado: 
warning: unused import: InstallPlan (non-crítico)
warning: resolver versioning (non-crítico)
# Status: SUCCESS

# Frontend
npm run build --prefix ui
# Resultado:
✓ built in 7.43s
# Status: SUCCESS
```

## Evidências

- Commit: `4745f01` - feat(kcp): add secure WebSocket console proxy for Incus instances
- Arquivos criados: `src/api/console.rs`, `ui/src/components/kcp/console/KcpTerminal.jsx`
- Arquivos modificados: `Cargo.toml`, `src/api/mod.rs`, `ui/src/pages/kcp/Virt.jsx`

## Pendências

1. **Testes integrados**: A conexão WebSocket precisa de teste real com Incus rodando
2. **Resize endpoint**: Incus console pode precisar de `/1.0/instances/:name/exec` com width/height
3. **Autenticação**: O RBAC atual usa `kryx::services::identity::check_identity()` - verificar integração
4. **HTTPS/WSS**: Configurar TLS adequado para produção (atualmente usa WSS se disponível)

## Próximo passo recomendado

Testar a implementação com uma instância Incus real para validar:
1. Fluxo de conexão WebSocket
2. RBAC funcionando corretamente
3. Redimensionamento do terminal
4. Performance do proxy bidirecional

#tags: kcp, console, websocket, incus, xterm, rbac