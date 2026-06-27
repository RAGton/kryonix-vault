# Remoção do Light Mode do Instalador

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- repos/kryonix-installer

## Objetivo
Remover completamente o seletor de "Light Mode" do Kryonix Installer e fixar toda a experiência no que chamaremos de "Kryonix Premium Installer Theme" (baseado no antigo Dark Mode). O objetivo é reduzir complexidade de estado e manter uma estética singular, altamente premium e consistente em todas as telas sem risco de flashes visuais.

## Contexto consultado
O usuário pediu expressamente para remover qualquer campo `installerUiTheme`, `desktopThemeMode`, sync da classe `dark` do React, e da geração de payload de instalação. 

## Mudanças realizadas
- **`ui/index.html`**: Fixado nativamente `<html class="dark">` para garantir que as classes Tailwind sejam computadas logo no primeiro render do DOM sem ajuda de React.
- **`ui/src/App.jsx`**: Removido o `useEffect` que injetava/retirava dinamicamente a classe `dark`.
- **`ui/src/pages/Welcome.jsx`**: Excluída toda a UI e os cards de seleção de Light vs Dark mode, substituídos por um espaço de branding unificado.
- **`ui/src/state/wizardState.js`**: `installerUiTheme` e `desktopThemeMode` removidos do esquema de chaves (`STATE_KEYS` e `INITIAL_INSTALL_PLAN_DRAFT`).
- **`ui/src/utils/installPlan.js`**: O payload agora despacha presets fixos (ex: `appearance.desktopThemeMode: 'dark'` e `appearance.plasmaPreset: 'kryonix-blue-glass-dark'`) para o backend de instalação.

## Commits e branches
- Commit gerado localmente em `/repos/kryonix-installer` com a mensagem `feat(installer-ui): remove light mode and enforce unified premium dark theme`.

## Validações executadas
- Build local do instalador via Vite (`npm run build`) ocorreu sem quebras de dependência, estado ou tipo no Ajv Validator.

## Próximo passo recomendado
Atualizar o submodule `kryonix-installer` no workspace do `kryonix-dev` (root) para refletir essas exclusões. O usuário pode iniciar o servidor de desenvolvimento para visualizar o layout "cleaner" do Welcome.
