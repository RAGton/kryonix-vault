# Secrets

## Objetivo

Gerenciar segredos sem vazar para repo, logs ou Nix store.

## Regras

- não commitar segredo;
- não colocar segredo em derivation output;
- não logar segredo;
- usar mecanismo aprovado como sops-nix, agenix ou Vault;
- documentar rotação.

## Links

- [[01-MOCs/Mapa - Segurança]]
- [[06-Playbooks/Playbook - Auditoria de Secrets]]
