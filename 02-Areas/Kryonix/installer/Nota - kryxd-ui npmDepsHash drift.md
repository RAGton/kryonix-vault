---
title: "kryxd-ui npmDepsHash — drift e regeneração"
type: nota
status: active
tags: [nota-tecnica, kryonix, kryxd, ui, nix]
area: kryonix-installer
source: "experiência própria (2026-08) + docs Nix manual"
confidence: high
created: 2026-08-04
updated: 2026-08-04
---

# kryxd-ui npmDepsHash — drift e regeneração

> **Área:** [[02-Areas/Kryonix/installer/MOC - Installer|MOC - Installer]] · **Projeto:** [[03-Projetos/Kryonix Installer]]

<context>
  O daemon kryxd tem uma UI React/Vite buildada como derivação Nix em
  `nix/ui.nix`. Quando `ui/package-lock.json` muda (nova dep, upgrade,
  conflito de merge), o `npmDepsHash` pinado no Nix fica stale e o build
  falha com erro de hash mismatch. Sem regeneração explícita, o Nix não
  tem como saber qual é o novo hash válido.
</context>

<task>
  Diagnosticar e regenerar o `npmDepsHash` sem quebrar o lockfile de quem
  está em outra branch.
</task>

## Resumo

Quando `ui/package-lock.json` muda, o hash SHA256 esperado em `nix/ui.nix`
(linha do atributo `npmDepsHash = "sha256-...";`) precisa ser atualizado
para o hash real do novo `node_modules` resolvido.

## Quando usar

- Build do `kryxd-ui` falha com `hash mismatch in fixed-output derivation`.
- Merge de PR na UI traz mudança em `package-lock.json`.
- Após `npm install` ou `npm ci` local que muda o lockfile.

## Quando evitar

- Mudança só em código fonte (`ui/src/**`) sem alterar deps → não precisa.
- Tentativa de atualizar hash "no escuro" via copy-paste de log.

## Procedimento / Conteúdo

### 1. Confirmar o drift

```bash
cd /home/rocha/Proyectos/kryonix-dev/repos/kryxd
nix build .#kryxd-ui -L 2>&1 | tail -20
```

Procurar mensagem contendo `hash mismatch` ou `specified: sha256-...` vs
`got: sha256-...`. O `got:` é o hash novo válido.

### 2. Regenerar via build (modo oficial)

```bash
nix build .#kryxd-ui -L --extra-experimental-features 'nix-command flakes' --rebuild
```

Alternativa manual (preferida em PR):

```bash
nix-prefetch-url --unpack https://registry.npmjs.org/<package>/-/<pkg>-<ver>.tgz
```

Ou simplesmente copiar o hash `got:` que o Nix imprimiu no erro do passo 1.

### 3. Atualizar `nix/ui.nix`

```nix
npmDepsHash = "sha256-NOVO_HASH_AQUI";
```

Validar:

```bash
nix build .#kryxd-ui -L
nix flake check -L --impure
```

## Exemplo prático

Caso real (2026-08): após merge de upgrade do `react-router-dom` no
`ui/package-lock.json`, build quebrou com hash mismatch. Regeneração via
`nix build` aceitando o novo hash e commit em `nix/ui.nix` resolveu em
2 minutos.

```bash
nix build .#kryxd-ui -L 2>&1 | grep 'got:'
# atualizar nix/ui.nix com o hash 'got:'
git add nix/ui.nix
git commit -m "fix(kryxd-ui): regenerate npmDepsHash after lockfile bump"
```

<acceptance>
  - [ ] build do `kryxd-ui` passa sem hash mismatch
  - [ ] `nix flake check -L` verde
  - [ ] commit só mexe em `nix/ui.nix` (não toca `ui/package-lock.json`)
  - [ ] CI roda o build da UI e valida o hash novo
</acceptance>

<risks>
  - regenerar hash sem entender a mudança de deps pode mascarar supply-chain issue
  - esquecimento de rebuildar lockfile localmente antes do PR gera drift recorrente
  - não commitar o `package-lock.json` mudado causa re-drift no próximo build
</risks>

## Conexões

- [[02-Areas/Kryonix/installer/MOC - Installer|MOC - Installer]] — MOC pai
- [[02-Areas/Kryonix/installer/UI Flow|UI Flow]] — fluxo da UI
- [[02-Areas/Kryonix/installer/Testing|Testing]] — como validar build Nix
- [[VAULT_INDEX]] — entrada do vault

## Próxima ação

Quando voltar a quebrar hash mismatch: aplicar o procedimento do passo 2
sem pular o `nix flake check -L`.
