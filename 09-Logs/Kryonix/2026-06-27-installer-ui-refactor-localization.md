# Refatoração Guiada: Localização e Fuso Horário

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- repos/kryonix-installer

## Objetivo
Refatorar completamente a página de localização e fuso horário para torná-las mais simples, guiadas e de estética premium (layout 70/30). A estrutura anterior estava poluída, redundante e misturava muitas listas abertas permanentemente, prejudicando a UX (semelhante a um painel técnico).

## Contexto consultado
O usuário determinou explicitamente que a aba de Localização/Idioma/Teclado estava muito densa. Instruiu-se a remoção de redundâncias visuais (ex: país aparecendo em vários cartões, listas longas sempre abertas) e a criação de uma estrutura wizard onde 70% é a configuração limpa e 30% é um resumo (sidebar).

## Mudanças realizadas
- **Novo componente `KxCombobox.jsx`**: Desenvolvido um combobox customizado (popover absoluto com busca nativa, limitação visual e navegação fechada) para substituir as extensas `SearchableList` nativas que quebravam o fluxo visual.
- **`Localization.jsx` refatorado**:
  - Dividido em 70/30 usando grid/flexbox.
  - Dropdowns agora usam `KxCombobox` para `País/Região`, `Idioma` e `Teclado`.
  - Sidebar à direita ("Resumo regional") exibe de forma concisa e elegante as escolhas atuais e a origem dos dados (Backend vs Catálogo).
  - Alerta de "Catálogo local" reduzido para uma nota discreta ao final do formulário principal, em vez de uma imensa caixa de aviso amarela.
- **`Timezone.jsx` refatorado**:
  - Adotou o layout 70/30 (Map/Search na esquerda, Resumo na direita).
  - Componente `TimezoneSelector.jsx` foi removido e absorvido, transformando a busca num simples `KxCombobox` focado por cima do mapa interativo.
  - Resumo de fuso horário lateral agora mostra coordenadas exatas e preview do horário de forma "viva".

## Commits e branches
- Feito commit com a mensagem recomendada: `refactor(installer-ui): simplify localization page into guided setup`.

## Validações executadas
- Build frontend via `npm run build` passou integralmente sem falhas ou loops.
- `Timezone.jsx` agora renderiza perfeitamente com 4 importações corretas.

## Próximo passo recomendado
Agora que as abas de Localização estão premium e alinhadas ao restante do design, o usuário deve ser notificado e poderá realizar o preview via Vite (`npm run dev`). A refatoração das etapas EULA, Summary e Install pode seguir com mais confiança no Design System estabelecido.
