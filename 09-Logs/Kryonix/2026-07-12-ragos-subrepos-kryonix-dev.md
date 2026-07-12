# RagOS e RagOS Installer no workspace kryonix-dev

Data: 2026-07-12
Agente: Codex
Repos afetados:

- `kryonix-dev`
- `kryonix-vault`

## Objetivo

Adicionar os repositórios oficiais do RagOS e do RagOS Installer como
submódulos independentes do workspace de desenvolvimento Kryonix.

## Contexto consultado

- `AGENTS.md` e `README.md` do `kryonix-dev`.
- `AGENTS.md`, `VAULT_INDEX.md`, `03-Projetos/RAGOS.md` e
  `03-Projetos/RAGOS Installer.md` do Vault.
- Remotes e branches padrão confirmados com `git ls-remote --symref`.

## Mudanças realizadas

- Adicionado `repos/ragos` a partir de
  `https://github.com/RAGEnterprise/ragos.git`, branch `main`.
- Adicionado `repos/ragos-installer` a partir de
  `https://github.com/RAGEnterprise/ragos-installer.git`, branch `main`.
- Atualizadas a estrutura e a tabela de repositórios em `AGENTS.md` e
  `README.md` do meta-repo.

## Commits e branches

- Branch do meta-repo: `main`.
- Commit do Vault: `docs(vault): register ragos subrepos in dev workspace`.
- Commit do meta-repo: `chore(dev): add ragos repositories`.

## Validações executadas

- `git ls-remote --symref` nos dois remotes: PASS.
- `git submodule status repos/ragos repos/ragos-installer`: PASS para os dois
  submódulos de topo.
- `git diff --check` e `git diff --cached --check`: PASS.
- `git submodule update --init --recursive repos/ragos`: BROKEN.

## Evidências

- `repos/ragos` fixado inicialmente em
  `5d51ceef6b8bc9280253345b0ceffb2f61625e95`.
- `repos/ragos-installer` fixado inicialmente em
  `a7e0b37b07f16f3a63967bfd2e295c2a0ee5f6c8`.
- O RagOS fixa seu submódulo interno `installer` em
  `43de828ddd9289c5ee6662bc398892a1ae202dd2`.
- O remote do installer não disponibiliza mais esse objeto; a tentativa
  recursiva falhou com `upload-pack: not our ref`.

## Pendências

- Corrigir no repositório RagOS o gitlink interno de `installer` para um commit
  publicado e validar novamente o clone recursivo.
- O profile MCP `kryonix-test` não estava disponível nesta sessão; a validação
  pelo profile `vault` permanece UNKNOWN.

## Próximo passo recomendado

Atualizar o ponteiro interno `installer` no RagOS em um commit separado e
reexecutar `git submodule update --init --recursive repos/ragos` antes de
considerar o clone recursivo do workspace funcional.

## Links relacionados

- [[03-Projetos/RAGOS]]
- [[03-Projetos/RAGOS Installer]]
- [[VAULT_INDEX]]
