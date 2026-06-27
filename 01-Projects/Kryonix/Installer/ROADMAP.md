# Kryonix Installer Roadmap

## Fase 1: Correções Críticas e Contratos (Atual)
- [x] Diagnóstico da falha do `disko --mode dry-run`.
- [x] Backend valida rigorosamente modos permitidos antes de instanciar `tokio::process::Command`.
- [x] Retorno de erro estruturado (JSON com campos para UI) e prevenção de falsos "PASS".
- [x] Escrever documentação canônica (ARCHITECTURE, API_CONTRACT, TEST_PLAN, ROADMAP).
- [x] Criar e documentar skill `libvirt-ui-runtime-tester`.

## Fase 2: Design System e UI Foundation (Next)
- [ ] Limpeza do Tailwind e CSS global obsoleto.
- [ ] Implementar Tokens de Cor, Tipografia e Layout baseados em estilo "Glassmorphism Blue/Sci-Fi limpo".
- [ ] Criar componentes de fundação (Cards, Buttons, Headers, Progress Indicators).
- [ ] Integrar tratamento do novo `InstallError` (erro estruturado da Fase 1) em um componente de painel de falha seguro.

## Fase 3: Refatoração das Telas (Execution Screen & Stepper)
- [ ] Redesenhar as etapas do wizard para um formato mais limpo (Sidebar com status + Painel Principal).
- [ ] Tela de particionamento mais visual (discos, modos).
- [ ] Tela de logs substituindo o visual terminal antigo por um Drawer técnico.

## Fase 4: Automação e Testes Avançados
- [ ] Integrar testes E2E para o Kiosk via testes Playwright locais.
- [ ] Validar a ISO e runtime do Installer em VM usando o framework descrito no skill Libvirt.
- [ ] Homologação em hardware real (L5) - testes persistentes sem live ISO.
