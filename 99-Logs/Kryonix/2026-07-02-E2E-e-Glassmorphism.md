# E2E Navigation Fix & Glassmorphism UI

Data: 2026-07-02
Agente: Antigravity
Repos afetados:
- kryonix-installer

## Objetivo
1. Consertar a suíte E2E do instalador (fase 1) que falhava na transição da etapa "Network" para "Host Selection" devido a bugs de sincronização do mock da API.
2. Aplicar um estilo visual de "glassmorphism" (transparência/blur) em todas as abas e painéis do instalador, removendo o "aspecto cinza" (uso excessivo de bg-slate-*).

## Contexto consultado
- Configurações do Playwright
- src/utils/installerApiMock.js
- Tailwind CSS bg-slate-* usages.

## Mudanças realizadas
- `ui/tests/e2e/mocks/mockBackend.ts`: Ajustado para regex robusta que intercepta as rotas corretamente independentemente de parâmetros de query.
- `ui/src/utils/installerApiMock.js`: Corrigido o retorno da função `getNetworkStatus()` de `{ status: 'connected' }` para `{ connected: true, internet: true }`, o que impedia que a validação na etapa Network permitisse o clique no botão "Next".
- `ui/src/App.jsx`: Atualizado `console.log` para facilitar o debugging dos `blockingIssues`.
- Arquivos JSX em `ui/src/pages/` e `ui/src/components/`: Substituídas centenas de ocorrências de `bg-slate-*` para um estilo limpo usando `bg-white/5` ou `bg-black/5` com `backdrop-blur-md` e bordas translúcidas.
- `ui/src/index.css`: Remoção das cores de painel legado.

## Commits e branches
Pendente commit nos repositórios pelo usuário (está pronto e em estado limpo localmente).

## Validações executadas
- `npx playwright test`: ✅ (As duas suítes E2E de navegação e features estão passando).
- Renderização visual: confirmada via estilos utilitários corretos no Tailwind.

## Pendências
- Testar visualmente a interface (em dev mode).
- Continuar as próximas fases de E2E (storage-selection, install-execution) usando mocks baseados em Playwright page.route de forma segura.

## Próximo passo recomendado
Fazer os commits em `repos/kryonix-installer`, submetê-los upstream e atualizar os submodules em `kryonix-dev`.
