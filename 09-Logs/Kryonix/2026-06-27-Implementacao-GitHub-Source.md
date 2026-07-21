# Implementação da Fonte GitHub KryonixOS no Instalador

Data: 2026-06-27
Agente: Antigravity (IA)
Repos afetados:

- kryxd
- kryonix-dev

## Objetivo

Tornar a opção "GitHub /etc/kryonixos" na etapa de Source funcional, permitindo que o usuário clone dinamicamente as configurações oficiais diretamente do GitHub durante a instalação. Isso substitui o estado anterior que marcava a opção como "Previsto para P2".

## Contexto consultado

- O usuário solicitou explicitamente que a funcionalidade saísse do P2 e se tornasse real.
- O caminho temporário usado para clone foi estabelecido como `/run/kryxd/sources/kryonixos` (no Live ISO) para evitar sujeira em `/etc` antes da instalação real (que usará `/mnt/etc/kryonixos`).

## Mudanças realizadas

1. **Backend (Rust)**
   - Adicionado o módulo `source.rs` com o endpoint `POST /api/source/github/prepare`.
   - Adicionada verificação de segurança (allowlist) aceitando estritamente o repositório `https://github.com/RAGton/Kryonixos.git`.
   - Execução de `git clone --depth 1` seguida da validação de existência do arquivo `flake.nix`.

2. **Frontend (React)**
   - Adicionadas variáveis de estado transitórias (`githubSourceStatus`, `githubSourceError`) em `wizardState.js`.
   - A API `prepareGithubSource` foi adicionada em `installerApi.js`.
   - Total redesign do componente `Source.jsx` para refletir os estados interativos (`idle`, `checking`, `cloning`, `validating`, `ready`, `failed`).

3. **I18n**
   - Atualizados os dicionários `pt-BR`, `en-US` e `es-ES` com as chaves para os novos status e textos.

## Commits e branches

- Commits diretos na `main` do repositório `kryxd`.
- Atualização do submodule no `kryonix-dev`.

## Validações executadas

- `cargo check` rodou sem erros críticos no backend.
- `npm run build` do vite concluiu o empacotamento da interface (UI) com sucesso.

## Pendências

- O `installPlan` final agora pode carregar `sourceKind: 'github'`. O próximo passo lógico é garantir que o processo principal de instalação (`executor` backend) saiba usar esse `target_path` para copiar ou sincronizar os arquivos clonados para o HD final (`/mnt/etc/kryonixos`).

## Próximo passo recomendado

- Auditar o executor de instalação em Rust (`src/executor`) para garantir que os pacotes locais clonados sejam corretamente referenciados durante o `nixos-install`.
