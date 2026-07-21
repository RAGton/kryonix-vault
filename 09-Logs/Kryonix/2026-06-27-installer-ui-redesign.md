# Refatoração Visual e Contrato de Temas no Kryonix Installer

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- repos/kryxd

## Objetivo
Refatorar a interface do Kryonix Installer para remover a navegação lateral vertical e implementar um design horizontal estilo macOS com suporte avançado a temas (Claro/Escuro), preparando a base para a identidade visual premium do sistema.

## Contexto consultado
- Regras de desenvolvimento do workspace (`AGENTS.md`).
- Decisões anteriores sobre isolamento de ambiente (uso de mocks, prevenção contra danos em hardware real).

## Mudanças realizadas
1. **Layout Horizontal**: Substituição do menu lateral vertical (`<aside>`) por uma barra de navegação no topo (macOS style).
2. **Agrupamento de Etapas (Phases)**: Condensamos os 11 passos de instalação em 6 grandes grupos (Preparação, Rede, Sistema, Armazenamento, Contas, Instalação) para um *stepper* mais enxuto e escalável.
3. **Seletor de Temas**: Criamos cards limpos na tela de "Welcome" para permitir a seleção entre modo Claro (Branco Gelo e Azul Discreto) e Escuro (Blue glass premium).
4. **Contrato de API (`appearance`)**: Atualizamos o schema JSON (`install-plan.schema.json`) e a função `buildInstallPlanPayload` para emitir o objeto `appearance` em vez de depender exclusivamente de feature flags obscuras. O payload agora define claramente `installerTheme` e `desktopThemeMode`. Uma regra de compatibilidade (`features.desktop["appearance.dark-mode"]`) foi mantida temporariamente para não quebrar o backend atual.

## Commits e branches
- `main` em `kryxd`: `feat(installer-ui): refactor horizontal layout, add light/dark mode selection, update payload schema for appearance`

## Validações executadas
- Vite frontend Build (`npm run build`) via tasks.
- Troca de temas refletida dinamicamente no DOM (`classList.add('dark')`).
- Nenhuma chamada destrutiva (QEMU, Libvirt, Disko) executada, mantendo o ambiente em segurança.

## Pendências
- O frontend precisará continuar iterando componentes internos das próximas etapas (Disks, Users) para garantir total coesão com o novo layout horizontal.
- Validação QEMU/ISO *end-to-end* após a estabilização completa da nova UI.

## Próximo passo recomendado
- Realizar a refatoração visual da etapa de Discos (`Disks.jsx`), adaptando os cards de visualização para casar perfeitamente com a tipografia e as sombras do novo tema.
