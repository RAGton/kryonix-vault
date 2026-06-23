# Kryonix Core Boundary Audit — 2026-06-22

## Contexto

Gabriel identificou que o PR #87 (browser-automation) funcionou tecnicamente mas tem uma parte arquiteturalmente errada. Isso motivou uma auditoria completa de boundaries do core Kryonix.

## O que foi feito

1. Auditado o repositório core (`/home/rocha/kryonix/kryonix`)
2. Auditado o downstream (`/home/rocha/kryonix/kryonixos` e `/etc/kryonixos`)
3. Confirmado Vault oficial (`/home/rocha/kryonix/kryonix-vault`)
4. Classificado cada item com taxonomia
5. Gerado 13 documentos de documentação no Vault

## Achados principais

- `hosts/inspiron/` no core é resíduo — o verdadeiro está no downstream
- `profiles/glacier-*.nix` no core são perfis de servidor que deveriam estar no downstream
- `packages/kryonix-brain-lightrag` e `kryonix-home` são submódulos que deveriam ser flake inputs puros
- Contexto IA fragmentado em 4 diretórios ocultos
- Desktop assets pesados poluem o core

## Decisões

- Nada foi movido ainda (fase de documentação apenas)
- Próximo passo: Gabriel revisar e aprovar a ordem dos PRs

## Erratas aplicadas

Gabriel solicitou revisão da auditoria com evidências concretas. Resultado:
1. `.agents/` reclassificado de LEGACY para CANONICAL_AGENT_CONTEXT (é ativo)
2. `profiles/glacier-*` reclassificados de DOWNSTREAM_ONLY para CORE_MODULE (ativos e usados pelo downstream)
3. `kryonix-hardware-probe` reclassificado de INSTALLER_PRODUCT para CORE_SHARED (usado pela CLI)
4. `desktop/` separado em assets (SDDM/wallpapers) e config funcional (core modules)
5. Submódulos brain-lightrag e kryonix-home confirmados como obsoletos vs flake inputs
6. Evidence Pack gerado em `11-evidence-pack.md` com comandos e outputs reais

## Arquivos criados

13 arquivos no Vault sob `02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/`

## Links

[[MOC - Kryonix Core Boundaries]]
[[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/README]]
