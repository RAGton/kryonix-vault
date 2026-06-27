# Correção Visual: Controles de Formulário e Área WAN no Instalador

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- repos/kryonix-installer
- repos/kryonix-vault
- (workspace pointer)

## Objetivo
Corrigir a renderização dos controles de formulário nativos (inputs, selects, textarea) que apresentavam aspecto claro e discrepante no Dark Mode, afetando a estética premium exigida para a página "Topologia de Rede". Adicionalmente, restaurar a visibilidade da seção WAN que estava incorretamente escondida.

## Contexto consultado
O usuário apontou que os form controls não devem depender da estilização crua nativa, mas sim de tokens CSS estritos (`.kx-input`, `.kx-select`), para neutralizar o fundo branco em dark mode e preservar a interface limpa e premium. A seção WAN, embora opcional, precisa estar contida visualmente na área contextual para fácil acesso, sem poluir a área principal 70%.

## Mudanças realizadas
- Adicionado novas variáveis globais de CSS (`--kx-input-bg`, `--kx-input-border`, `--kx-input-text`, `--kx-input-placeholder`, `--kx-focus-ring`) em `:root` e `.dark` dentro de `ui/src/index.css`.
- Criadas as classes base `.kx-input`, `.kx-select`, `.kx-textarea`, `.kx-field-label` e `.kx-field-hint` para padronizar e unificar o comportamento visual.
- Substituído todos os inputs e selects na `Network.jsx` pelas novas classes, removendo o CSS atrelado à estilização fixa (backgrounds, texts).
- Ajustados os modificadores de opacidade problemáticos do Tailwind que causavam falha no build de `@apply`.
- Remanejado o bloco WAN para a seção 30% Contextual na página Network, estruturado em um card independente com um accordion ("Configurar WAN avançado") limpo e acessível.

## Validações executadas
- Build local do Vite (`npm run build`) concluído com sucesso (4.28s) após correção de bug de conversão do Tailwind.
- O preview local via (`VITE_INSTALLER_MOCK=1 npm run dev`) reflete inputs corretamente tematizados no dark mode.
- O campo numérico porta HTTP (`type="number"`) agora respeita a flag `color-scheme` via CSS nativo.
- Verificação de layout (WAN na barra direita renderizando conforme especificações).

## Próximo passo recomendado
- Avançar para a refatoração visual do componente de Discos (`Disks.jsx`).
- (Futuro) Criar wrappers customizados em React (`KxSelect`, `KxInput`) para desacoplar a lógica de estilização e resolver as limitações intrínsecas de estilização de opções do `<select>` nativo.
