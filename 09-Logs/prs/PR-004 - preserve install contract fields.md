---
title: "fix(installer): preserve install contract fields"
type: pr-log
status: done
project: Kryonix
created: 2026-06-16
updated: 2026-06-16
tags:
  - kryonix
  - installer
---

# fix(installer): preserve install contract fields

URL: https://github.com/RAGton/kryxd/pull/4

## Fato
- Preserva os campos `features`, `admin.authorizedKeys`, `admin.uid`, e `admin.email` no contrato de instalação.
- Troca o conceito ambíguo de `remoteAccess` por `targetRemoteAccess`.
- Separa o Target Remote Access do Live Installer Remote Mode.
- A senha continua fora do `InstallPlan`.
- O UID do administrador não pode virar `0`.
- O array `authorized_keys` agora é sanitizado/escapado antes de virar código Nix.
- `services.openssh.enable` representa exclusivamente o SSH do sistema instalado.
- O Remote Web Mode da ISO ficou fora do escopo neste PR.

## Decisão
- Ajustar os modelos do backend e da UI para garantir a integridade do `InstallPlan`, não perdendo configurações vitais do usuário.
- Deixar a implementação do Remote Web Mode da ISO para uma iteração futura separada, visando focar na estabilidade do contrato de instalação.

## Validação
- `cargo test`: 48 passed
- `npm --prefix ui test`: 53 passed
- `npm --prefix ui run build`: OK
- `git diff --check`: OK

## Riscos
- PR #3 pode conflitar com PR #4 nos arquivos `App.jsx`, `installerApi.js` e `main.rs`.
- Remote Web Mode da ISO ainda não está implementado.
- Hashing final da senha de admin ainda está fora do escopo.
- Smoke test completo com VM de instalação ainda está pendente.

## Próximos passos
- Resolver possíveis conflitos caso o PR #3 seja mergeado antes ou depois.
- Implementar o Remote Web Mode da ISO.
- Implementar o hashing seguro de senhas.
- Executar o teste de instalação fim-a-fim em VM (smoke test).
