---
tipo: evidence
projeto: kryonix
componente: downstream-home-manager
created: 2026-06-22
updated: 2026-06-22
author: aura
tags: [downstream, home-manager, zsh, bloqueio, compatibilidade]
---

# Bloqueio — downstream home-manager zsh incompatível com motor remoto

## Resumo

O build atual do downstream (`/etc/kryonixos`, rev `2e60720`, motor PROD `c8c7f8c8`) passa. Mas quando o input `kryonix` é sobrescrito para o motor remoto (`main` ou `feat/browser-automation`), o build falha com erro no módulo `programs/zsh`.

## Testes (2026-06-22)

| Teste | Motor | Resultado | Erro |
|---|---|---|---|
| downstream atual sem override | `/etc/kryonix` rev `c8c7f8c8` (PROD) | **PASS** ✅ | — |
| override `main` remoto | `github:RAGton/kryonix/main` | **FAIL** ❌ | `programs/zsh: unsupported attribute 'home'` |
| override PR #87 remoto | `github:RAGton/kryonix/feat/browser-automation` | **FAIL** ❌ | `programs/zsh: unsupported attribute 'home'` |
| override PR #87 anterior (DEV dirty) | `git+file:///home/rocha/kryonix/kryonix` | **FAIL** ❌ | mesmo erro |

## Conclusão

**PR #87 é inocente.** A falha `programs/zsh` aparece exatamente igual com `main` (sem PR #87) e com `feat/browser-automation` (com PR #87). Causa: descompasso do `home-manager.follows = "kryonix/home-manager"` — o motor remoto atual resolve uma versão do home-manager que introduziu breaking change na API do módulo `programs/zsh` (atributo `home` em top-level não é mais suportado).

## Risco

Atualizar o motor para main remoto sem corrigir o downstream pode quebrar o rebuild do host `inspiron`.

## Decisão operacional

Manter PR #87 em Draft até existir plano de correção/validação do downstream.

## Próximos passos

1. Localizar onde o downstream define/usa `programs.zsh` (provavelmente no `modules/home-manager/programs/zsh`).
2. Corrigir a configuração para a API atual do Home Manager (mover atributo `home` para dentro de `config` explícito).
3. Repetir os três builds (teste 1 sem override + teste 2 com override main + teste 3 com override PR #87).
4. Se passarem, tirar PR #87 de Draft e planejar merge.

## Links

- [[09-Logs/prs/PR-087 - browser automation runtime support]]
- [[09-Logs/evidence/kryonix-general-audit-2026-06-22]]