# Roadmap de Unificação CLI `kryx` (Rust)

A unificação do ecossistema substitui dezenas de bash scripts por um binário Rust seguro, orquestrando deploy, rebuilds atômicos, telemetria e diagnósticos de forma padronizada.

### Fase 1: Padronização
- [x] Criar CLI `kryx` em `packages/kryx/` com `clap`.
- [x] Estabelecer subcomandos stub (`switch`, `deploy`, `system`, `doctor`, `theme`).
- [x] Empacotar via `rustPlatform.buildRustPackage`.
- [x] Expor `packages.${system}.kryx` no `flake.nix`.

### Fase 2: Migração de Lógica
- [ ] Portar a lógica de deploy (RAGOS Diskless) de `ragos-installer/bin/ragos-install` para o subcomando `kryx deploy`.
- [ ] Mover as chamadas de transição de estado (`nh os switch` e afins) presentes em `kryonix-cli/nixos.sh` para `kryx switch`.
- [ ] Trazer a lógica de telemetria e checagem de saúde de `glacier-doctor.sh` e `kryonix-monitors.sh` para os subcomandos `kryx doctor` e `kryx system`.

### Fase 3: Evolução Gráfica e Limpeza de Legado
- [ ] Implementar TUI nativa em Rust (e.g. `ratatui`) para o subcomando de deploy.
- [ ] Remover permanentemente o pacote antigo `kryonix-cli`.
- [ ] Deletar scripts migrados do diretório `scripts/`.
- [ ] Arquivar / descontinuar o repositório `ragos-installer`.
