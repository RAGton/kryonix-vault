# Redesign UI: Topologia de Rede (Kryonix Installer)

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- repos/kryxd

## Objetivo
Refatorar a etapa “Topologia de Rede” (`Network.jsx`) e melhorar a distribuição da UI para uma experiência mais premium, clara, séria e funcional, saindo de um visual de painel de debug improvisado para uma interface de produto madura.

## Contexto consultado
O usuário forneceu diretrizes claras sobre uma mudança estrutural, exigindo:
- Split de área 70% configuração e 30% contexto.
- Modo Manual com protagonismo nos campos de rede.
- Modo DHCP limpo e claro.
- Remoção de poluição visual (caixas dentro de caixas).

## Mudanças realizadas
1. **Nova Arquitetura de Página**: A página foi reconstruída em um `lg:grid-cols-[7fr_3fr]`.
2. **Área Principal (Esquerda)**:
   - Novo Toggle Mode para DHCP vs Manual.
   - Quando DHCP: Mostra apenas Interface, Porta HTTP e um banner amigável.
   - Quando Manual: Exibe o formulário em Grid (Interface, Porta HTTP, IP, Mask, Gateway, DNS 1, DNS 2, Domain).
   - Sessão Avançada (WAN) oculta por padrão em um `<details>` mais limpo.
   - Checkbox de confirmação e botão "Aplicar" alinhados e espaçados no fim do form.
3. **Área Contextual (Direita)**:
   - Consolidamos Status da Conexão, Resumo Operacional e Checklist de Liberação.
   - Painel Wi-Fi Inline integrado ao status, sem poluir a configuração principal.
   - Os erros e avisos migraram para mensagens Inline.

## Commits e branches
- `refactor(installer-ui): redesign network topology page layout and improve dhcp/manual flows` (Branch: main)

## Validações executadas
- Build local do vite (`npm run build`).
- `git diff --check` validando espaços em branco.
- Nenhuma execução destrutiva ao sistema host (QEMU/Disko intocados).

## Próximo passo recomendado
Atualizar o submodule `kryxd` no workspace principal e iniciar o refinamento da página de Particionamento (Disks), se aplicável.
