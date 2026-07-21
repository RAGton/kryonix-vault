# Transformação do kryxd em Daemon Contínuo (24/7) e Segurança PAM

Data: 2026-07-21
Agente: Antigravity
Repos afetados:

- `kryonix`
- `kryxd` (via submodule `kryonix-installer` ou repo independente do installer)

## Objetivo

Transformar o `kryxd` de um binário focado exclusivamente na Live ISO para um daemon de gerenciamento contínuo, capaz de rodar 24/7 tanto em sistemas instalados (Desktop, Node Think) quanto na mídia de instalação. Além disso, garantir que rotas destrutivas e de instalação estejam inacessíveis em ambientes instalados.

## Contexto consultado

- O plano de implementação validado pelo usuário em `implementation_plan.md`.
- Regras de segurança requerendo autenticação PAM e bloqueio de rotas destrutivas pós-instalação.
- O funcionamento do React UI do `kpanel` que necessita identificar corretamente se o ambiente é o Live ISO ou um ambiente Instalado.

## Mudanças realizadas

1. **Backend Rust (Axum)**:
   - Adicionado o crate `pam = "0.8.0"` e habilitado no `buildInputs` do pacote em `nix/package.nix`.
   - Modificado `AppState` para carregar e injetar um enum `RuntimeMode`, contendo `LiveInstaller` (caso não exista identidade em `/etc/kryonix/identity.json`) ou `InstalledHost` (com os dados do host).
   - Desenvolvido o middleware `installer_guard.rs` para interceptar rotas de instalação (`/install`, `/dry-run`, `/disk/apply`) e bloqueá-las com erro `403 Forbidden` caso o sistema não esteja rodando em modo Live.
   - Refatoração inicial de `src/api/auth.rs` para utilizar `pam::Client::with_password()` (com autenticação real via Linux PAM).
   
2. **Módulos NixOS**:
   - Criado o novo módulo declarativo `modules/nixos/services/kryxd/default.nix` para expor as opções `services.kryxd` (permitindo configurar a porta e injetar tokens de forma robusta no sistema final).
   - Refatorado `modules/nixos/installer/web-kiosk.nix` para consumir `services.kryxd.enable = true` no lugar de definir uma systemd unit isolada `kryxd-backend`, mantendo no entanto os overrides de `path` e `environment` necessários ao ambiente live.

3. **Frontend (kpanel)**:
   - Atualizado `App.jsx` para verificar a `identity` retornada em `/api/v1/system/identity`. Caso falhe (o que indica que estamos no modo Live ISO), o Wizard Installer é montado diretamente na raiz do app, bloqueando renderização do login/dashboard até a instalação terminar.

## Commits e branches

- Commits serão gerados nos repositórios alvo logo em seguida: `kryonix` e `kryxd`.
- O submodule root em `kryonix-dev` será atualizado.

## Validações executadas

- Rodado `cargo build` com sucesso na sandbox Nix (`nix develop --command cargo build`) validando bindings do PAM.
- Executado teste automatizado contido no `installer_guard.rs`, assegurando que o `AppState` inicializado intercepta requisições de forma segura.
- `nix flake check --keep-going` rodado e validado no core após correção do module path.

## Pendências

- O frontend do Installer ainda não foi globalizado para as outras telas do RAGOS (pendência para a próxima iteração).

## Próximo passo recomendado

1. Merge da branch principal e rebuild do desktop e servidor KVE.
2. Iniciar a refatoração visual do frontend de instalação (e do iPXE) conforme exigido nas requests de modernização estética solicitadas.
