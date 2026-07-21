# Refatoração Frontend (KCP Web UI)

Data: 2026-07-15
Agente: Antigravity
Repos afetados:
- kryxd (UI)

## Objetivo
Evoluir a interface do usuário do instalador original para suportar o novo Dashboard dinâmico (Kryonix Control Plane), implementando roteamento condicional baseado na identidade do host.

## Contexto consultado
Missão de refatoração do Frontend React/Vite, estrutura do `App.jsx` legado e configuração do Tailwind.

## Mudanças realizadas
1. Instaladas dependências `react-router-dom` e `lucide-react`.
2. O conteúdo original do `App.jsx` foi isolado em um novo componente chamado `WizardInstaller.jsx`, preservando completamente o estado de instalação legado.
3. Criado o novo layout base `DashboardLayout.jsx` com barra lateral condicional e estilos nativos.
4. O `App.jsx` tornou-se o roteador (Dispatcher) do sistema:
   - Faz fetch na API (`/api/v1/system/identity`) ao montar.
   - Renderiza `<WizardInstaller />` se o host não possuir identidade (`404/500`).
   - Renderiza `<DashboardLayout />` populado com rotas (`/fleet`, `/storage`) caso a identidade seja `Core` ou `ThinkServer`.
   - Limita o acesso somente a `/local-settings` caso a identidade seja `Desktop`.

## Evidências
- Build do Vite (`npm run build`) concluído com sucesso.
- O componente roteador está montado sobre dependências React modernas e sem conflitos de estilização (Tailwind).
