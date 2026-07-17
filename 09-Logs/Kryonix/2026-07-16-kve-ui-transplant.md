# KVE Enterprise UI Transplant — AI Studio → Vite/React

Data: 2026-07-16
Agente: Aura
Repos afetados:

- `repos/kryxd`
- `repos/kryonix-vault`

## Objetivo

Transplantar cirurgicamente a interface premium exportada do AI Studio em `/tmp/kve-ui-export/src/` para o frontend oficial do KVE em `repos/kryxd/ui/src/`, preservando:

- bootstrap de identidade do installer;
- fallback `WizardInstaller` quando não houver `/api/v1/system/identity`;
- autenticação via Axum `POST /api/v1/auth/login`;
- console WebSocket oficial `/api/v2/virt/instances/:id/console/ws`;
- backend Rust/Axum sem servir UI estática.

## Fonte lida

Arquivos do export AI Studio auditados:

- `/tmp/kve-ui-export/package.json`
- `/tmp/kve-ui-export/src/index.css`
- `/tmp/kve-ui-export/src/App.tsx`
- `/tmp/kve-ui-export/src/views/Login.tsx`
- `/tmp/kve-ui-export/src/components/dashboard/TerminalConsole.tsx`
- `/tmp/kve-ui-export/src/views/PveResourceView.tsx`
- árvore `/tmp/kve-ui-export/src/components/`
- árvore `/tmp/kve-ui-export/src/views/`
- árvore `/tmp/kve-ui-export/src/hooks/`
- árvore `/tmp/kve-ui-export/src/types/`

Não havia `tailwind.config.ts` nem `tailwind.config.js` no export. A fonte real do design system exportado foi `src/index.css` com `@theme` Tailwind v4.

## Diretórios transplantados

Foram copiados para `repos/kryxd/ui/src/`:

| Origem | Destino | Arquivos |
|---|---|---:|
| `/tmp/kve-ui-export/src/components/` | `ui/src/components/` | 27 |
| `/tmp/kve-ui-export/src/views/` | `ui/src/views/` | 15 |
| `/tmp/kve-ui-export/src/hooks/` | `ui/src/hooks/` | 1 |
| `/tmp/kve-ui-export/src/types/` | `ui/src/types/` | 1 |
| `/tmp/kve-ui-export/src/assets/` | `ui/src/assets/` | imagem de logo usada pelo Login |

## Dependências instaladas

Comando executado:

```bash
npm install motion recharts react-grid-layout clsx tailwind-merge --prefix repos/kryxd/ui
npm install -D typescript @types/react @types/react-dom @types/react-grid-layout --prefix repos/kryxd/ui
```

Dependências novas/garantidas:

- `motion`
- `recharts`
- `react-grid-layout`
- `clsx`
- `tailwind-merge`
- `typescript`
- `@types/react`
- `@types/react-dom`
- `@types/react-grid-layout`

Observação de `npm install`:

```txt
2 vulnerabilities (1 low, 1 high)
```

Não foi executado `npm audit fix` para evitar mutações automáticas fora do escopo.

## Tailwind e CSS

Atualizado:

- `ui/tailwind.config.js`
- `ui/src/index.css`

Tokens e utilitários incorporados:

- `kve-bg`
- `kve-panel`
- `kve-border`
- `kve-accent`
- `kve-accent-muted`
- `kve-success`
- `kve-warning`
- `kve-danger`
- `kve-indigo`
- `pulse-slow`
- `pulse-soft`
- `.glass`
- `.technical-grid`
- `.hex-grid`
- `.noise-overlay`
- estilos base de `react-grid-layout`

As cores existentes `kryonix-dark` e `kryonix-blue` foram preservadas.

## Login premium integrado ao gateway Axum

Arquivo transplantado e ajustado:

```txt
ui/src/views/Login.tsx
```

O login do AI Studio originalmente simulava credenciais locais. Foi alterado para chamar:

```txt
POST /api/v1/auth/login
credentials: same-origin
Content-Type: application/json
```

Payload:

```json
{
  "username": "<fornecido pelo usuário>",
  "password": "<fornecido pelo usuário>",
  "realm": "<realm selecionado>"
}
```

Nenhum segredo foi gravado no código, no Vault ou em log.

## Preservação do IdentityGuard / Installer Fallback

Arquivo de integração:

```txt
ui/src/App.jsx
```

Foi mantido o comportamento crítico do app oficial:

- busca inicial em `/api/v1/system/identity`;
- se identidade não existir, renderiza `WizardInstaller`;
- o painel KVE só carrega após identidade/sessão;
- o `Login` agora aponta para o componente premium transplantado.

Marcadores verificados:

```txt
/api/v1/system/identity
return <WizardInstaller />
import Login from './views/Login'
```

## Console premium com motor WebSocket oficial

Arquivo transplantado e ajustado:

```txt
ui/src/components/dashboard/TerminalConsole.tsx
```

O componente do AI Studio simulava terminal via `/api/nodes/:id/terminal`. Esse fluxo foi removido. O design premium foi preservado e o motor passou para WebSocket oficial:

```txt
/api/v2/virt/instances/:id/console/ws
```

Implementado:

- `new WebSocket(wsUrl)`;
- normalização de IDs `vm-`, `ct-`, `qemu-`, `lxc-`;
- envio de comandos pelo socket aberto;
- feedback visual conectado/desconectado;
- cleanup no unmount com `ws.close()`;
- nenhum token, cookie ou chave Incus no frontend.

Fluxo preservado:

```txt
Frontend → WS → Axum → Unix Socket → Incus
```

## Validações executadas

### Build frontend

```bash
npm run build --prefix repos/kryxd/ui
```

Resultado:

```txt
✓ 2476 modules transformed.
✓ built in 7.31s
```

Avisos conhecidos:

```txt
/img/noise.png referenced in /img/noise.png didn't resolve at build time
Some chunks are larger than 500 kB after minification
```

### Backend

```bash
cargo check --workspace
```

Resultado:

```txt
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.29s
```

Aviso conhecido:

```txt
virtual workspace defaulting to resolver = "1"
```

### Diff check

```bash
git diff --check -- ui/package.json ui/package-lock.json ui/tailwind.config.js ui/src/index.css ui/src/App.jsx ui/src/components ui/src/views ui/src/hooks ui/src/types ui/src/assets
```

Resultado:

```txt
diff check ok; ui/dist cleanup ok
```

### Verificação ad-hoc

Script temporário criado em `/tmp/nix-shell-266339-3526915383/hermes-verify-6_slj6kn.py`, executado e removido.

Resultado:

```txt
AD-HOC VERIFY KVE UI TRANSPLANT: PASS
- dependency installed: motion
- dependency installed: recharts
- dependency installed: react-grid-layout
- dependency installed: clsx
- dependency installed: tailwind-merge
- dependency installed: typescript
- dependency installed: @types/react
- dependency installed: @types/react-dom
- transplanted folder exists: src/components
- transplanted folder exists: src/views
- transplanted folder exists: src/hooks
- transplanted folder exists: src/types
- transplanted folder exists: src/assets
- IdentityGuard/bootstrap still fetches system identity
- installer fallback preserved when identity is absent
- premium AI Studio login is wired into official App
- premium Login posts to Axum auth gateway
- premium TerminalConsole uses official Axum console websocket
- TerminalConsole opens and cleans up websocket
- tailwind enterprise token present: kve-bg
- tailwind enterprise token present: kve-panel
- tailwind enterprise token present: kve-accent
- tailwind enterprise token present: pulse-slow
- AI Studio CSS utility present: technical-grid
- AI Studio CSS utility present: hex-grid
- AI Studio CSS utility present: react-grid-layout
- AI Studio CSS utility present: noise-overlay
- generated ui/dist absent after cleanup
- scoped git diff --check passed
cleanup ok
```

## Diff/stat

Comando:

```bash
git diff --stat -- ui/package.json ui/package-lock.json ui/tailwind.config.js ui/src/index.css ui/src/App.jsx ui/src/components ui/src/views ui/src/hooks ui/src/types ui/src/assets
```

Saída observada para arquivos já rastreados:

```txt
ui/package-lock.json                          | 609 +++++++++++++++++++++++++-
ui/package.json                               |  11 +-
ui/src/App.jsx                                | 402 +++++++++++++++--
ui/src/components/kcp/console/KcpTerminal.jsx | 100 +++--
ui/src/index.css                              | 116 +++++
ui/tailwind.config.js                         |  19 +
6 files changed, 1173 insertions(+), 84 deletions(-)
```

Arquivos transplantados novos aparecem como `??` no status Git e não entram no `git diff --stat` padrão até serem adicionados ao index.

## Status Git escopado

```txt
M ui/package-lock.json
M ui/package.json
M ui/src/App.jsx
M ui/src/components/kcp/console/KcpTerminal.jsx
M ui/src/index.css
M ui/tailwind.config.js
?? ui/src/assets/images/
?? ui/src/components/BackgroundMosaic.tsx
?? ui/src/components/ContextMenu.tsx
?? ui/src/components/KveCard.tsx
?? ui/src/components/Modal.tsx
?? ui/src/components/Sidebar.tsx
?? ui/src/components/Topbar.tsx
?? ui/src/components/dashboard/
?? ui/src/hooks/useDashboardLayout.ts
?? ui/src/types/
?? ui/src/views/
```

## Restrições respeitadas

- Nenhuma rota backend foi alterada nesta missão.
- Nenhum comando de storage, boot, rede ou Ceph foi executado.
- Nenhum secret foi lido, impresso, armazenado ou versionado.
- Nenhum arquivo solto foi criado na raiz dos repositórios.
- `ui/dist` foi removido após build.
- Nenhum commit/push foi feito.

## Estado

```txt
READY_FOR_REVIEW
```

## Pendências recomendadas

1. Fazer preview visual no navegador e comparar com a intenção do AI Studio.
2. Decidir se o shell premium completo do AI Studio deve substituir também o layout `/kcp/*`, ou se ele ficará como biblioteca de componentes premium integrada gradualmente.
3. Auditar `npm audit` separadamente antes de qualquer fix automático.
4. Em uma etapa futura, fazer code-splitting para reduzir chunk > 500 kB.
