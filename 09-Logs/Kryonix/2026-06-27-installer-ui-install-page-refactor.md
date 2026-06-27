# Refatoração Visual do Dashboard de Instalação (Install.jsx)

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- repos/kryonix-installer

## Objetivo
Transformar a última página do Kryonix Installer (`Install.jsx`) em um **dashboard operacional robusto e coerente**. A página anterior apresentava estado misto, layout espremido e componentes genéricos que passavam uma falsa impressão de execução antes do processo sequer ter começado. 

## Contexto consultado
O usuário forneceu o diagnóstico e wireframe exigindo a arquitetura 35/65, um header "full-width" para status, e uma lógica rígida amarrando UX e CTAs aos estados do instalador (idle, starting/running, success, error).

## Mudanças realizadas
- **`ui/src/pages/Install.jsx`**:
  - Removido o modal de segurança intrusivo (`showSafetyModal`). A segurança passou para um _Gate Destrutivo_ passivo inserido na própria UI (baseado no consentimento obtido nas telas anteriores).
  - Adoção de **Grid Layout `35/65`**:
    - **Esquerda (Ações & Contexto)**: Resumo limpo dos dados do alvo, Card de Segurança da Operação, Alertas pendentes, e botões unificados.
    - **Direita (Terminal)**: Apenas se a operação for disparada é que renderizamos a stream de terminal (`AdvancedLogsDrawer`); caso contrário exibimos uma empty-state limpa (`Aguardando Início`).
  - **Header Operacional**: A barra de progresso (e variáveis dependentes como ETA e Tempo Decorrido) só são renderizadas na UI caso a instalação passe do estado `idle`, eliminando as falsas leituras de "100%" antecipado.

## Commits e branches
- Commit local no `kryonix-installer`: `refactor(installer-ui): stabilize install page states and operational layout`.

## Validações executadas
- Build local do instalador (`npm run build`).
- Validação visual dos estados renderizados contra a documentação (idle).

## Próximo passo recomendado
Atualizar o submodule `kryonix-installer` no workspace do `kryonix-dev` (root) e validar todas as transições de tela no navegador (verificar o stepper completo da Preparação até Instalação).
