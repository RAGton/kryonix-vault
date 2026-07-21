# Dashboards KCP Implementados

Data: 2026-07-15
Agente: Antigravity
Repos afetados:
- kryxd (UI)

## Objetivo
Implementar os componentes reais das abas do Kryonix Control Plane (KCP), substituindo os placeholders criados na etapa de refatoração do layout base.

## Contexto consultado
Endpoints da API local Axum (`/api/v1/fleet/status`, `/api/v1/storage/quotas`, `/api/virt/list`) e biblioteca visual (Tailwind + Lucide-react).

## Mudanças realizadas
1. **Módulo HTTP (`src/lib/api.js`)**:
   - Isolou chamadas utilitárias do tipo `fetch` que garantem tratamento apropriado da reposta JSON.

2. **Fleet Management (`src/pages/kcp/Fleet.jsx`)**:
   - Criação de Cards (Grid System) baseados em `kryonix-dark`.
   - Adicionada animação visual `animate-ping` que pulsa verde/vermelho a depender do status de rede do Host listado na API de manifesto.

3. **Storage Quotas (`src/pages/kcp/Storage.jsx`)**:
   - Exibição limpa das partições e datasets mapeados pelo sistema.
   - Geração de barras de progresso proporcionais ao consumo em bytes (`bg-kryonix-blue`).

4. **Incus Virtualization (`src/pages/kcp/Virt.jsx`)**:
   - Lista tabular de contêineres e VMs atrelados ao backend nativo.
   - Identificação visual imediata do status (Running/Stopped) com botões coloridos para gerência rápida de energia.
   - Adicionada na interface via modificações de routing no `App.jsx` e `DashboardLayout.jsx`.

## Evidências
- O build via `npm run build` confirmou ausência de quebras de sintaxe e dependências válidas.
- Rotas injetadas no layout e na barra lateral perfeitamente.
