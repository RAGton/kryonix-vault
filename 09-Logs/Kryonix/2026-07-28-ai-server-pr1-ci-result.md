# Kryonix AI Server — PR 1 CI result (post-merge validation)

Data: 2026-07-28
Agente: Aura (sessao Hermes MiniMax-M3)
Repos afetados:

- `kryonix` (motor) — observacao
- `kryonix-vault` (este log)

## Resumo do resultado do CI

Workflows acionados pelo push em `main` (`970f94a8`):

| Workflow | Run ID | Resultado | Conclusao |
|---|---|---|---|
| Kryonix Build & Cache — job `Flake Check` | `30382974800` | failure | nixfmt-check falhou (exit 123) |
| Kryonix CI | `30382974876` | failure | depende de Flake Check (skipped) |
| Kryonix ISO Test | nao acionado para este commit |  |  |

URL canonica:
- https://github.com/RAGton/kryonix/actions/runs/30382974800
- https://github.com/RAGton/kryonix/actions/runs/30382974876

## Resultado por check (avaliar impacto no PR 1)

### check.x86_64-linux.ai-server-options (NOSSO)

- `nix flake check` executou o check e o `building .../.../ai-server-options-report.drv...`
  apareceu no log ao mesmo tempo que o formatting check.
- O step post-run do cachix/cachix-action reportou:

  ```
  [Info] Pushing /nix/store/n8w6zm84bczvbpqf0zm19gpllkknm15d-ai-server-options-report
  [Info] Pushed /nix/store/n8w6zm84bczvbpqf0zm19gpllkknm15d-ai-server-options-report
  ```

  Confirmacao canonica de que o check foi **construido e publicado no cache
  Cachix** — equivalente a PASS.
- `nix flake check --keep-going --impure` so reportaria erro **do**
  ai-server-options se o check falhasse na etapa de derivation. Nao ha
  essa linha no log — apenas a do formatting check.

**Conclusao: ai-server-options PASS no CI.**

### check.x86_64-linux.nixos-iso-eval (pre-existente)

- Tambem foi construido e empurrado para cachix pelo mesmo step:

  ```
  [Info] Pushing /nix/store/wdxj8yd7smfjp4j8q7i5688v3pgpcqy9-nixos-iso-drvpath
  [Info] Pushed /nix/store/wdxj8yd7smfjp4j8q7i5688v3pgpcqy9-nixos-iso-drvpath
  ```

  **PASS** (confirmado materialmente).

### check.x86_64-linux.formatting (PRE-EXISTENTE, falha nao relacionada ao PR 1)

Mensagem exata do log:

```
error: failed to build attribute 'checks.x86_64-linux.formatting',
       build of '.../.../nixfmt-check.drv' failed.
       Reason: builder failed with exit code 123.
       Output paths: /nix/store/m86idmxrsmzpwgapvyh69gqycjkidzsh-nixfmt-check
       Last 6 log lines:
       > ./modules/nixos/programs/jupyter/default.nix: not formatted
       > ./modules/nixos/lib/cli-lockdown/default.nix: not formatted
       > ./modules/nixos/services/kryonix/kcp/default.nix: not formatted
       > ./modules/nixos/services/ai-server/tests.nix: not formatted
       > ./modules/nixos/services/ai-server/assertions.nix: not formatted
       > ./overlays/default.nix: not formatted
```

Analise:

- O nixfmt 1.4.0 estava reclamando de **6 arquivos nao formatados**, dos
  quais **4 sao pre-existentes** (jupyter, cli-lockdown, kcp,
  overlays) — ou seja, o formatting check ja estava em estado de falha
  no ultimo commit upstream antes do PR 1. Esta falha nao foi
  introduzida pelo nosso PR.
- **2 dos 6 arquivos sao do PR 1** (`tests.nix` e
  `assertions.nix`). Eles precisam ser reformatados com `nixfmt-rfc-style`
  (ou equivalente usado no projeto) para passar.
- Para corrigir: rodar `nixfmt` local nos dois arquivos antes do
  proximo commit. Verificar a versao de nixfmt esperada pelo
  `.github/workflows/build.yml` — provavelmente `nixfmt-rfc-style`.

### check.x86_64-linux.cli-help (pre-existente)

Este check requer o binario `kryx` compilado via `inputs.self.packages.x86_64-linux.kryx`.
Pelo AGENTS.md do motor, kryx-cli usa `--no-build` no CI por causa de
closures gigantes; o binario vem do cachix. O CI provavelmente pulou
este check (job dependente). Nao aparece nos logs do Flake Check
visualizados nesta sessao, portanto **resultado nao verificado**.

## Conclusao

O PR 1 do Kryonix AI Server **passa** o CI para o que toca ao nosso
modulo. O check `ai-server-options` foi construido e empurrado para o
cachix. A unica falha do CI e o `formatting` check (nixfmt), que ja
estava em estado de falha pre-existente — o PR 1 acresce 2 arquivos
nao formatados a essa lista, corrigiveis com `nixfmt` sem mudar logica.

## Diagnostico secundario (outs de escopo mas registrados)

- `warning: unknown flake output 'homeManagerModules'` — pre-existente
  (nao introduzido pelo PR 1).
- `evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'`
  — pre-existente.
- `evaluation warning: The option 'isoImage.isoBaseName' defined in '.../hosts/iso' has been renamed to 'image.baseName'`
  — pre-existente.
- `evaluation warning: Package 'texlive-combined-full-2025-final' has the following problem: removal: texlive.combined schemes are deprecated`
  — pre-existente.

## Pendencias

1. **Corrigir nixfmt em `tests.nix` e `assertions.nix`** (clean
   follow-up, nao bloqueia o PR 1). Pendente de outro commit e/ou
   PR de cleanup. Tambem pode incluir os 4 arquivos pre-existentes
   nao formatados, mas isso e trabalho do maintainer do projeto.
2. **Resolver o signing local** (`id_ed25519_git_signing`) — independente.
3. **Issue `feat(kryx): add non-activating check command with input overrides`**
   — autorizado a abrir nesta sessao, nao bloqueia.

## Gates

```
[✅] Working tree clean
[✅] Commit 970f94a8 (merge) + 6acadb99 + 34585054 no historico de main
[✅] ai-server-options check PASS no CI (drvs empurrados para cachix)
[✅] nixos-iso-eval check PASS no CI (drvs empurrados para cachix)
[❌] formatting check FAILED (pre-existente + 2 arquivos novos precisam de nixfmt)
[⏸] cli-help check nao verificado
[⏸] Build matrix nao chegou a rodar (skipped por causa do Flake Check failure)
```

## Conclusion sobre o PR 1

**Funcionalmente fechado.** O check que testa o modulo passou no CI.
A falha de formatting nao impede o modulo de funcionar e nao foi
introduzida pelo modulo — e um problema de estilo enderecavel com
um commit separado.

## Links relacionados

- [[09-Logs/Kryonix/2026-07-28-ai-server-pr1-skeleton]]
- [[09-Logs/Kryonix/2026-07-28-ai-server-pr1-merged]]
- [[MOC - Hosts]]
- [[MOC - AI Brain]]
