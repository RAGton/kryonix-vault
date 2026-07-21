# Refatoração da Aba Disks e Saneamento do Installer UX

Data: 2026-06-27
Agente: Antigravity
Repos afetados:

- repos/kryxd
- repos/kryonix-vault

## Objetivo

Tornar a aba de Discos/Particionamento mais transparente, segura e premium, eliminando falhas visuais (como o `? GB` ou telas esbranquiçadas no dark mode), detalhando tecnicamente o plano de instalação e forçando explicitamente a confirmação destrutiva.

## Contexto consultado

- Requisitos solicitados pelo usuário focados em clareza técnica e transparência destrutiva (evitar que o usuário apague dados sem visualizar o que acontecerá).
- Arquitetura de payload e `storagePlanner.js` para usar a função `formatBytes` ao invés de cálculos inseguros em `Disks.jsx`.

## Mudanças realizadas

- **`Disks.jsx` Refatorado para Layout 70/30**: Dividido em duas colunas. A esquerda contém a lista de discos e prévia de layout, a direita foca no resumo do disco selecionado e no card de risco destrutivo.
- **Preview de Particionamento (Plano automático)**: Criada uma barra visual de partições simuladas (EFI + ROOT Btrfs) e uma tabela técnica com subvolumes (`@`, `@home`, `@nix`, `@log`).
- **Gate Destrutivo Explícito**: Criado um card de aviso na coluna da direita com um checkbox mandatório. O progresso da instalação é bloqueado via `uiState.storageBlockingIssues` caso o usuário não marque a caixa "Entendo que o disco selecionado será apagado e reparticionado".
- **Refatoração de Capacidade**: Exibição segura via `getDiskCapacityLabel` evitando que tamanhos inválidos virem `? GB` e tratando o fallback.
- **Saneamento do `Summary.jsx`**: Removidas classes `bg-white/80` que deixavam o background do card de resumo destrutivo final esbranquiçado e ilegível no modo Dark, substituindo por variáveis fiéis à estética glassmorphism premium da distro (`bg-black/20`, `border-white/20`, etc.). O input nativo (checkbox) também recebeu reset de aparência (`appearance-none`).

## Validações executadas

- Build Frontend: `npm run build` passou sem erros e compilou os assets corretamente.
- Renderização visual: Validação mental do JSX e uso rigoroso do Tailwind para prever comportamentos no grid. A página foi renderizada.

## Evidências

O código de frontend foi injetado com sucesso no projeto e o Vite validou a estrutura.

## Pendências

- Revisar logs no terminal quando o backend executar o script destrutivo e validar se a API retorna `disk.size_bytes` coerentes para todas as implementações reais fora do mock.

## Próximo passo recomendado

Revisar o código de instalação real no script Go/Rust para garantir que os tamanhos retornados em JSON batem com o esperado na interface.
