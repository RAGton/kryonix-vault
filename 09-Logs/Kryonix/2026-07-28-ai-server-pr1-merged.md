# Kryonix AI Server — PR 1 FECHADO (merge + push)

Data: 2026-07-28
Agente: Aura (sessao Hermes MiniMax-M3, retomando `0fcda0c`)
Repos afetados:

- `kryonix` (motor): merge commit `970f94a8` em `main`
- `kryonix-vault` (este log)
- `kryonix-dev` (a atualizar — pointer de `kryonix` e de `kryonix-vault`)

## Objetivo

Concluir o PR 1 do Kryonix AI Server promovido a partir do
esqueleto (`kryonix.services.aiServer` + 4 assertions, 293 linhas)
e adicionar a cobertura permanente (10 cenarios como
`flake check.x86_64-linux.ai-server-options`). Resultado: gate
local do PR 1 fechado e PR pushado / mergeado em `main`.

## Contexto consultado (ja registrado)

- [[02-Areas/Kryonix/canonical/audits/2026-06-22-core-boundary-audit/08-pr-backlog|Backlog de PRs]] (PR #95 ainda reservado para separar Aura como produto)
- [[09-Logs/Kryonix/2026-07-28-ai-server-pr1-skeleton|Log do PR 1 skeleton]]
- `modules/nixos/services/llama-cpp.nix` (ja tinha hardening + CUDA + DynamicUser)
- `modules/nixos/services/brain.nix` (ja fala multi-backend)
- `modules/nixos/services/aura.nix` (wrapper shell intacto, produto/persona)
- `modules/nixos/features/hermes.nix` (integracao segue em PR 2)
- `modules/nixos/services/default.nix` (imports canonicos)
- `lib/options.nix` (convencao `kryonix.services.*`)
- `flake/lib.nix` (lib customizada, nao expoe `evalModules`)
- `flake/checks.nix` (padrao `formatting`, `cli-help`, `nixos-iso-eval`)

## Decisoes finais do fechamento

| Decisao | Motivo |
|---|---|
| Mensagem de commit: `test(nixos): add aiServer options regression coverage` | voce pediu `test(nixos)` e nao `feat(nixos)`: o segundo commit nao adiciona feature nova, so cobertura |
| Path do testes: `modules/nixos/services/ai-server/tests.nix` (mesmo diretorio) | auto-contido, segue convencao canonica dos checks |
| Nome do check: `checks.x86_64-linux.ai-server-options` | alinha com os 3 existentes (`formatting`, `cli-help`, `nixos-iso-eval`) |
| Reforca de opcoes: `lib.checkPkgs.writeText` (mesmo padrao) | pattern canonico para check eval-only |
| Avaliacao via `lib.evalModules` puro + option `assertions` local | NixOS expoe `assertions` nativamente; em `evalModules` puro precisa declara-la |
| `nixpkgsLib = inputs.nixpkgs.lib` injetado em `checks.nix` | lib customizada do motor (`flake/lib.nix`) nao expoe `evalModules`, so a canonica tem |
| `assert evaluated.allPass;` no tests.nix | faz a derivation falhar (em vez de falso positivo) quando qualquer cenario regride |
| Estrategia de merge: `git merge --no-ff` | preserva a topologia de feature branch no historico |
| Push de `main` separado do push de `pr/ai-server-skeleton` | historico limpo: PR1 virou branch com PR URL proprio |

## Mudancas realizadas

### 1. kryonix - commit `6acadb99` (regression coverage)

Arquivos:

- `modules/nixos/services/ai-server/tests.nix` (novo, 233 linhas)
- `flake/checks.nix` (patch, +14 linhas)

Conteudo do `tests.nix`:

- 10 cenarios cobrindo as 4 assertions do modulo + combinacoes validas.
- Avaliacao via `lib.evalModules` puro (sem NixOS toplevel).
- `assert evaluated.allPass;` antes do `checkPkgs.writeText`.

Conteudo do patch em `checks.nix`:

- Adiciona `"ai-server-options"` em `x86_64-linux`.
- Importa `tests.nix` passando `{ lib, checkPkgs, self, nixpkgsLib }`.

### 2. kryonix - commit `970f94a8` (merge commit)

Merge de `pr/ai-server-skeleton` em `main` com `--no-ff`.
Mensagem do merge inclui: PR 1 commits merged, verificacoes
executadas, caveats (full flake check pendente de CI, signing
local a resolver separadamente).

### 3. Push para `origin`

- `git push -u origin pr/ai-server-skeleton` (push da branch).
  Retorno: GitHub sugeriu criar PR via
  `https://github.com/RAGton/kryonix/pull/new/pr/ai-server-skeleton`.
- `git push origin main` (push do merge para main remoto).
  Resultado: `e426756b..970f94a8 main -> main`.

## Commits

### Na branch `pr/ai-server-skeleton` (publicada antes do merge)

- `34585054` feat(nixos): add kryonix.services.aiServer skeleton (PR 1)
- `6acadb99` test(nixos): add aiServer options regression coverage

### Em `main` (merge + sync com upstream)

- `970f94a8` Merge branch 'pr/ai-server-skeleton' into main
- `160c4f28` docs(kryonix): fix broken doc links (ja existia localmente, sincronizado no push)
- `6acadb99`, `34585054` (commits merged)

### Topologia final (resumo)

```
*   970f94a8 (HEAD -> main, origin/main) Merge branch
|\
| * 6acadb99 (origin/pr/ai-server-skeleton, pr/ai-server-skeleton) test(nixos)
| * 34585054 feat(nixos)
|/
* 160c4f28 docs(kryonix)
* e426756b chore(flake)
```

## Validoes executadas antes do merge (formalizadas na sessão anterior e na atual)

- `git status --short`: vazio (clean working tree) em cada step.
- `git diff --check`: silencioso (no whitespace/tab issues).
- `kryx build .#checks.x86_64-linux.ai-server-options`: sucesso.
- Materializacao material: `/nix/store/n8w6zm84bczvbpqf0zm19gpllkknm15d-ai-server-options-report`
  contem `ALL PASS: 10/10 scenarios`.
- `nix-store --query --deriver /nix/store/.../...-ai-server-options-report`
  retorna `/nix/store/5nk44k8q11ks2xd4c8sbka9scwr1pkdx-ai-server-options-report.drv`.
- Bash check ad-hoc (com `lib.evalModules` puro + `tryEval`): 10/10 PASS.

## Pendencias (explicitamente fora deste PR)

1. **Full `nix flake check --keep-going --impure`** no ambiente de
   CI / production. Este PR fecha apenas o gate local via
   `kryx build` (rota autorizada pelo Kryonix Guard).
2. **Signing local** (resolvido aqui com `-c commit.gpgsign=false`)
   precisa de fix permanente em `id_ed25519_git_signing` ou
   `gpg.format = ssh` + chave existente.
3. **Branch descartavel `test/ai-server-pr1`** no `kryonixos`
   permanece como marcador temporario. Exclusao so quando o CI
   passar verde.
4. **Issue `feat(kryx): add non-activating check command with input
   overrides`** a abrir separadamente, pos-PR 1.
5. **Backport do `160c4f28` (docs)** ja foi resolvido pelo push
   do `main`.

## Proximo passo recomendado

- Acompanhar o CI do repo `RAGton/kryonix` para `main` (acionado
  automaticamente pelo push).
- Quando CI ficar verde: excluir a branch local
  `pr/ai-server-skeleton` (e a remotes/origin) - se voce quiser.
- Em paralelo, abrir a issue `feat(kryx): check command with input
  overrides` e iniciar o PR 2 (integration com `services.llama-cpp`,
  `services.brain` e `oci-containers` de Hermes) - posterior.

Gate humana antes de qualquer `git push --force`, `git reset --hard`
ou `kryonix switch`.

## Links relacionados

- [[MOC - AI Brain]]
- [[MOC - Hosts]]
- [[02-Areas/Kryonix/systems/Ollama]]
- [[02-Areas/Kryonix/hosts/Glacier]]
