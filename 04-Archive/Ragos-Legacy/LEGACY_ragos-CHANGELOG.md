# Changelog

Este arquivo registra mudancas relevantes de release do RAGOS.

O foco aqui e operacional:

- mudancas de arquitetura que alteram a forma de operar
- consolidacoes de repositorio e workflow
- riscos conhecidos que ainda importam para release

## v1.0.1 - 2026-03-18

### Added

- perfis de cliente separados para `physical-generic`, `hyperv-debug` e `rescue`
- modulo de `rescue` independente do desktop principal
- hardware split entre baseline fisico e Hyper-V
- lint organizacional em `scripts/tests/lint-repo-organization.sh`
- `CONTRIBUTING.md`
- CI em GitHub Actions com jobs separados para `repo-hygiene` e `flake-check`
- bootstrap declarativo do inventario externo em `server/network/clients-inventory.bootstrap.nix`

### Changed

- documentacao canonica consolidada em `docs/`
- documentacao historica movida para `docs/archive/`
- scripts reorganizados em `scripts/ops/`, `scripts/tests/` e `scripts/lab/`
- `README.md`, `docs/dev.md` e `scripts/README.md` alinhados com o fluxo oficial
- `ragc` endurecido para publicacao, lock, manifest, boot e rollback mais previsiveis
- cliente padrao alinhado com hardware fisico real em vez de tuning de laboratorio
- CI e validacao local alinhados com `flake check` e lint organizacional

### Removed

- wrappers mortos em `flake/client.nix`, `flake/server.nix` e `flake/installer.nix`
- arvore legada `ragos/` do fluxo oficial
- `docs/clients-inventory.csv`
- artefatos versionados por acidente como `result-1`
- `client/modules/kernel-initrd.nix`

### Known issues

- `flake check` ainda emite warning sobre swap ausente no servidor
- a release nao substitui prova final de boot `current` e `rescue` em runtime real
- o historico do repositorio ja continha uma tag `v1.0.0`; por isso esta consolidacao saiu como `v1.0.1`

## v1.0.3 - 2026-04-08

### Added

- BrandLab scripts e artefatos para prova visual auditavel de SDDM, Plasma e baseline de branding
- prova via QEMU guest agent para validar `Current=ragos-control` e o greeter ativo dentro do guest

### Changed

- `ragos-control` passa a ser o tema SDDM efetivo dos clientes `desktop-lab` e `desktop-generic`
- o fluxo Git-first de publicacao do cliente fica documentado com evidencias de `lab` e `generic`

### Fixed

- wiring real do SDDM para impedir fallback visual no cliente publicado
- bootstrap limpo do `srv-rag` no installer, corrigindo o caminho do asset GRUB do servidor
- helpers do servidor usados em `system-path` e timers, agora empacotados com runtime proprio para nao quebrar a instalacao limpa

### Known issues

- `flake check` continua bloqueado nos outputs oficiais sem runtime persistente real; use runtime valido no host ou outputs `dev` para validacao local
- `scripts/tests/lint-repo-organization.sh` ainda falha por debitos pre-existentes fora do escopo desta release

## v1.0.0

### Changed

- primeira tag existente no historico local do repositorio
- consolidacao inicial de `README.md` e ajustes de `.gitignore`

### Notes

- o estado atual do projeto evoluiu significativamente alem desse ponto; use `v1.0.1` como baseline mais fiel da estrutura atual
