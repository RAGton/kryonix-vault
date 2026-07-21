# Kryxd Desktop Scope e Bind de Rede

Data: 2026-07-21
Agente: Aura
Repos afetados:

- repos/kryxd
- repos/kryonix
- repos/kryonixos
- kryonix-dev

## Objetivo

Consolidar o daemon `kryxd` na branch `main`, adicionar a opção visual/operacional `Desktop` no login do KPanel e corrigir a exposição declarativa do serviço no host desktop `inspiron`.

## Contexto consultado

- `AGENTS.md` do workspace Kryonix Dev.
- `repos/kryxd/ui/src/views/Login.tsx`.
- `repos/kryxd/src/main.rs`.
- `repos/kryxd/nix/package.nix` e `flake.nix`.
- `repos/kryonix/modules/nixos/services/kryxd/default.nix`.
- `repos/kryonixos/hosts/inspiron/default.nix`.

## Mudanças realizadas

### kryxd

- Adicionada opção `Desktop` no seletor de escopo operacional do login, ao lado de `Think Server` e `Node`.
- O login agora registra `kve_operational_scope=desktop|cluster|node` e `kve_requested_capabilities` no `localStorage`.
- O payload de login passou a incluir `operationalScope` e `requestedCapabilities` para manter o contrato explícito do cliente.
- O Axum passou a servir a UI de produção via `tower_http::services::ServeDir` com fallback para `index.html`.
- O pacote Nix do `kryxd` passou a incluir o build da UI e definir `KRYXD_UI_DIST` no wrapper.
- A branch `refactor/installer-phase1` foi consolidada em `main` por merge local seguro. Como `origin/main` continha um commit de deleção em massa, foi criado merge com estratégia `ours` para preservar a árvore validada da fase 1 sem force-push.

### kryonix

- `services.kryxd` agora define bind padrão em `0.0.0.0:${port}` com `KRYONIX_ALLOW_REMOTE_BIND=1`, usando `lib.mkDefault` para não conflitar com o kiosk do instalador.
- Firewall abre declarativamente `config.services.kryxd.port`, `3000` e `5173` quando `services.kryxd.enable = true`.
- `flake.lock` atualizado para consumir `kryxd` em `main` no commit consolidado.

### kryonixos

- `hosts/inspiron/default.nix` habilita `services.kryxd.enable = true` e `services.kryxd.port = 8080`.
- `flake.lock` atualizado para o core `kryonix` com a integração do daemon.

## Commits e branches

- `repos/kryxd`:
  - `f45fcc4 feat(ui): add Desktop option to login/wizard environment selector`
  - `896d155 fix(server): serve production UI dist from Axum`
  - `6ea5cb8 merge: preserve kryxd phase1 while acknowledging origin main`
- `repos/kryonix`:
  - `7ca731d fix(kryxd): bind daemon on host network and open telemetry ports`
  - `d5681dc chore(flake): pin kryxd main after daemon merge`
- `repos/kryonixos`:
  - `83b7cbc fix(inspiron): enable kryxd daemon on desktop host`
  - `ae7ad54 chore(flake): update Kryonix daemon integration inputs`

## Validações executadas

- `npm run build` em `repos/kryxd/ui`: PASS.
- `nix flake check --keep-going` em `repos/kryxd`: PASS.
- `nix flake check --keep-going --override-input kryxd git+file:///home/rocha/kryonix-dev/repos/kryxd` em `repos/kryonix`: PASS.
- `nix flake check --keep-going` em `repos/kryonix` após lock: PASS.
- `nix flake check --keep-going --impure` em `repos/kryonixos`: PASS.

## Evidências

- KPanel buildou com Vite sem erros.
- O package Nix de `kryxd` avalia junto com a UI empacotada.
- A avaliação NixOS do downstream `inspiron` passou com `services.kryxd` habilitado.

## Pendências

- Aplicar em runtime no host `inspiron` em janela segura, sem executar `nixos-rebuild switch` automaticamente.
- Após ativação, verificar portas `8080`, `3000` e `5173` com `ss`/curl a partir da LAN.

## Próximo passo recomendado

Executar apenas uma validação de build/boot planejada no downstream antes do switch real, depois aplicar em janela segura com plano de rollback da geração NixOS anterior.
