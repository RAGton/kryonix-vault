# Rebase do PR-003 pós PR-004

**Data:** 16 de Junho de 2026
**Repositório:** `kryonix-installer`

## Operações Realizadas

1. **Merge do PR #4 (Hardening do Contrato):**
   * Verificou-se uma falha de lint (`cargo fmt`) resolvida localmente antes do merge.
   * Feito merge via Squash (`gh pr merge 4 --squash --delete-branch`) direto na `main`.

2. **Rebase do PR #3 (`feat/disk-visualizer-hardening`):**
   * Rebase feito sobre a nova `main` que agora inclui regras estritas de UID, `target_remote_access` separado e senha omitida.
   * **Conflitos Resolvidos:**
     * `ui/package.json`: Mesclados os novos scripts de teste adicionados por ambos PRs (`wizardStress.test.js`, `wizardFuzz.test.js`, `layoutAssistant.test.js`).
     * `ui/src/pages/Install.jsx`: Conciliado o listener `onScroll` (do PR #4) com a injeção de variáveis de cores de token CSS (`var(--term-bg)`) do PR #3.
     * `src/executor/partition.rs`: O update na estrutura do `InstallPlan` e `PlanUser` pelo PR #4 (adição do `uid`, `email`, `authorized_keys` e `target_remote_access`) quebrou testes do PR #3 durante a compilação. Injetamos as propriedades requeridas com valores default nos testes.

3. **Validações Pós-Rebase:**
   * `git diff --check`: OK (nenhum whitespace indesejado).
   * `cargo test`: 50/50 test suites aprovados.
   * `npm --prefix ui test`: 65/65 testes passaram sem vazamento ou quebra do reducer determinístico.
   * `npm --prefix ui run build`: OK.
   * As dependências e o `package-lock.json` permaneceram inalteradas e limpas após as avaliações.
   
4. **Deploy Temporário:**
   * Branch local `feat/disk-visualizer-hardening` enviada por force-push seguro: `git push --force-with-lease`.

## Riscos e Próximos Passos Restantes
- Aguardar aprovação do CI/checks do PR #3 no GitHub.
- Confirmar mountpoint `/iso` (ISO-boot guard) em ambiente VM real.
- O modo "Remote Web Installer" na ISO ainda não foi iniciado e será alvo de seu próprio PR assim que a esteira ficar limpa.
- O PR #3 ainda deve ser avaliado e receber merge por um humano, não por IA.
