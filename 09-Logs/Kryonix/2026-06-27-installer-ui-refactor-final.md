# Refatoração Final da UI do Kryonix Installer

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- repos/kryonix-installer

## Objetivo
Finalizar a refatoração completa da UI/UX do Kryonix Installer, trazendo o design system com estética premium (dark mode com glassmorphism, accent colors, sem componentes nativos conflitantes) para as abas restantes, além de implementar barra de progresso híbrida.

## Contexto consultado
O usuário indicou insatisfação com a aparência e disposição antigas (que possuíam excesso de cinza/branco nativo em dark mode, layouts apertados e visual de painel técnico). 
A prioridade final era restaurar as abas de Localização e Timezone (agora mescladas de forma elegante com o wizard de instalação) e por fim corrigir a página de Resumo, Instalação e Discos (mantendo consistência visual Tailwind CSS).

## Mudanças realizadas
- `Localization.jsx`: Substituição de inputs e labels estáticos por tokens semânticos e classes unificadas (`bg-bg-elevated/30`, `hover:bg-bg-elevated/50`, uso de grid).
- `Timezone.jsx` / `TimezoneMap.jsx` / `TimezoneSelector.jsx`: Modernização do seletor e do mapa global do Calamares, removendo overlays hardcoded para fundos translúcidos e adicionando responsividade ao dark/light mode via Tailwind tokens.
- `Install.jsx`: Implementada barra de progresso real híbrida, com contagem de tempo decorrido, estimativa de conclusão (ETA 5min), e um header full-width.
- `Disks.jsx`: Conversão completa do legado de classes CSS para Tailwind. Agora `.disk-card` e abas utilizam design system com bordas semânticas (`border-accent-blue/40`, `bg-accent-blue/10`, text color states), suporte visual para bloqueios e seleção avançada, e tabela manual com glassmorphism e `transition-colors`.

## Commits e branches
Todas as mudanças estão prontas localmente para serem commitadas pelo usuário via workflow do repositório raiz (já validadas via `npm run build` no `ui`).

## Validações executadas
- Build via `npm run build` passou sem erros com todos os módulos transformados corretamente e os assets CSS minimizados sem vazamentos ou lints quebrando.

## Evidências
O instalador agora possui um pipeline liso da escolha inicial, fuso horário interativo e discos, até a aba de `Install.jsx` que provê barra de progresso real com feedback.

## Pendências
- Testar a instalação final no backend Rust real após o design de Discos ter sido ajustado.

## Próximo passo recomendado
Fazer push do refatoramento da UI para o repositório principal e iniciar testes destrutivos em qcow2 VM para aferir a experiência híbrida progress/ETA.
