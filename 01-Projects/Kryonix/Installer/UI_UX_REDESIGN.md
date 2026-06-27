# Kryonix Installer UI/UX Redesign

## Princípios Diretivos

1. **Elegância Técnica:** Sair do estilo terminal/clunky para algo limpo, fluido, profissional e técnico (Sci-Fi suave / Glassmorphism).
2. **Confiança & Transparência:** Nenhuma ação destrutiva acontece sem validação robusta; quando falha, a UI não apenas diz "Erro", mas traz diagnóstico e ação, reduzindo a ansiedade do usuário.
3. **Foco e Modularidade:**
   - Sidebar compacta listando passos com status (Aguardando, OK, Falha, Trabalhando).
   - Card principal espaçoso.
   - Logs ocultáveis em "Drawer" em vez de dominar a tela de execução.

## Estrutura da Nova Interface

### Header
- Identidade KryonixOS.
- Versão atual e status da ISO.
- Indicador visual de conexão segura (Token backend) com ping latency.

### Main Area (Stepper Múltiplas Fases)
1. **Welcome / Hardware Probe:**
   - Detecta CPU, RAM, Boot Mode (EFI/Legacy).
   - Bloqueia continuidade caso a RAM seja perigosamente baixa para uma instalação em disco real.
2. **Networking:**
   - Scan dinâmico. Animação suave para loading.
3. **Users:**
   - Layout clean de formulários, com feedback inline de password strength e restrições.
4. **Disks (Particionamento):**
   - Combos visuais claros para escolher disco e modo.
   - Modos aceitos e visíveis no UI.
5. **Execution (Review & Install):**
   - Revisão final baseada em texto legível.
   - Botão destrutivo exige ação deliberada (Hold ou Type "INSTALL").
   - Quando rodando, exibe progresso percentual e de estágio (ex: "Formatting", "Extracting").
   - Log completo vai para um Drawer expansível, e não ocupa a tela inteira com o clássico layout de terminal escuro se não houver erro.

### Tratamento de Erros Estruturados
O `InstallError` vindo do backend é formatado no Frontend de forma analítica:
- **Título**: O que falhou.
- **Ação Recomendada**: Próximo passo seguro (ex: Voltar para disks).
- **Detalhes Técnicos**: Exibidos em box monospace para fácil cópia/diagnóstico.
