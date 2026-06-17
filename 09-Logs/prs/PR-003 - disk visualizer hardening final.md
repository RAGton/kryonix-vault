# PR-003: Disk Visualizer & Hardening (Final)

## Status Final
**Mergeado**. O Pull Request #3 foi consolidado e feito squash na branch `main`.
O PR #4 (Install Contract Fields) já havia sido mergeado anteriormente, ditando as regras de contrato do Install Plan que precisaram ser seguidas neste PR.

## Histórico da Finalização
1. **Rebase**: O PR #3 foi rebaseado em cima da `main` para incorporar as mudanças críticas feitas pelo PR #4 (preservação de `authorized_keys`, `uid`, isolamento de `target_remote_access`, etc).
2. **Conflitos Resolvidos**: Múltiplos conflitos lógicos resolvidos, em especial na geração de partições e UI.
3. **Falha na CI (UI Test)**: 
   - Logo após o force-push do rebase, a CI falhou no GitHub Actions acusando `Could not find 'src/tests/wizardStress.test.js'`.
   - **Causa**: Em sessões anteriores, o script `test` no `ui/package.json` foi atualizado para referenciar `wizardStress.test.js`, mas o arquivo propriamente dito não existia na base de código nem foi commitado.
   - **Discrepância de Ambiente**: O erro não ocorria localmente devido ao `Node v22`, cujo test runner (`node --test`) ignora arquivos inexistentes se pelo menos um arquivo alvo for testado com sucesso. Contudo, a CI do GitHub utiliza **Node v20**, cujo comportamento aborta o processo de teste (código de erro 1) lançando a exceção `ERR_MODULE_NOT_FOUND`.
4. **Falha na CI (Rust Lint)**: 
   - Um erro secundário do `cargo clippy` parou a pipeline com o lint `unused_imports` e `unused_mut`. A limpeza de variáveis e pacotes inutilizados (`PlanDisk` imports em `kryonixos.rs`, `safety.rs` e `verify.rs`, e a palavra `mut` em `target_tree.rs`) foi aplicada para satisfazer `-D warnings`.
5. **Correção**: 
   - A menção a `wizardStress.test.js` foi removida do script de testes.
   - Foram executadas localmente (em diretório clonado limpo) as validações de ambiente do frontend.
6. **Aprovação**:
   - As verificações CI/Nix Flake Check, CI/Rust (fmt + clippy + test), e CI/UI passaram.

## Validações Locais Confirmadas
Antes de autorizar a subida da branch atualizada para o merge final, o código foi duplamente validado sem `skip` ou bypass administrativo:
- `npm --prefix ui ci`
- `npm --prefix ui test`
- `npm --prefix ui run build`
- `cargo test`

## Pendências e Próximos Passos
- [ ] Confirmar o instalador `/iso` em uma VM/ISO real para garantir que as alterações no Disk Visualizer e na lógica de validação do Wizard não quebraram o target.
- [ ] O **Remote Web Mode** para o Live Installer foi arquitetado nos passos de planejamento mas **ainda não implementado**. Este escopo é o próximo alvo e deverá rodar no modo de boot e não confundir-se com a flag `targetRemoteAccess`.
