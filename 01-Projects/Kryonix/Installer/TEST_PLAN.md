# Kryonix Installer Test Plan

A estratégia de testes visa mitigar os riscos de destruição indevida de dados reais e assegurar a confiabilidade do processo.

## L0: Static Analysis
- **Ferramentas:** `cargo fmt --check`, `cargo clippy`, `nix flake check`.
- **Objetivo:** Prevenir falhas de sintaxe e más práticas, garantindo tipos estritos em todo payload.

## L1: Unit Tests
- **Ferramentas:** `cargo test`.
- **Foco:** Lógicas críticas de particionamento (`partition.rs`), validação de payloads de UI, validação de regras do Disko e validação de tokens/CSRF.
- **Execução:** Obrigatória em cada build ou PR.

## L2: Integration Tests (API/UI)
- **Foco:** Validar a integração UI ↔ Backend (contrato de API).
- **Mocks:** Utilização de stubs (via flags) para que o backend devolva eventos falsos (SSE) sem tocar em disco.

## L3: VM Dry Run
- **Objetivo:** O Kiosk abre e interage com o Backend, o qual roda `disko --mode dry-run` e acerta a montagem do script, validando a ausência de chamadas destrutivas acidentais.

## L4: VM Install
- **Objetivo:** Formatação e instalação em um QCOW2 real isolado (via QEMU/Libvirt), verificando a inicialização bem-sucedida do novo disco instalado sem ISO.
- **Integração:** Usa a automação guiada pela skill `libvirt-ui-runtime-tester`.

## L5: Hardware Gate
- **Objetivo:** Instalação canônica bare-metal. Teste final em Glacier/Inspiron ou máquinas alvo, incluindo layout BTRFS e LUKS reais, além de validação térmica e de bootloaders.
