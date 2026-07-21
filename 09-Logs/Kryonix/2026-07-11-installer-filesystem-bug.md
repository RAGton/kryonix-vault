# Diagnóstico: Falha de root filesystem no Installer E2E

Data: 2026-07-11
Agente: Antigravity / Agentic Coding
Repos afetados:
- kryxd
- kryonix (core)

## Objetivo
Resolver o problema do instalador falhar na etapa de preflight eval com a mensagem de erro estruturado `UNKNOWN_ERROR` ou falha de fetch por timeout, e, posteriormente, a falha real: `Failed assertions: - The ‘fileSystems’ option does not specify your root file system.`

## Contexto e Descobertas
1. O backend rodava preso em `127.0.0.1`. Foi introduzida e testada uma variável de override no módulo `web-kiosk.nix` (`kryonix.installer.e2eRemoteApi.enable`) para permitir testes E2E do instalador e diagnosticar falhas na VM.
2. Com a API acessível, identificou-se que o verdadeiro erro não era "Failed to fetch", mas sim um erro de *nix eval* no `target_tree.rs`.
3. A falha no `nix eval` (fase de preflight) ocorreu porque o flake configurado pelo instalador para o `/mnt` (o *target tree*) **NÃO** importa o módulo `disko` em sua lista de módulos. 
4. Como o módulo `disko` não é carregado durante a avaliação pré-particionamento, as configurações do `disko.devices` comentadas ou ignoradas não resultam na criação de um `fileSystems."/"`.
5. Em resposta a isso, foi feito um plano de implementação para o código Rust no instalador para injetar o `disko` nos módulos do target tree e realizar verificações estáticas prévias sobre a raiz `/` (evitando falhas mascaradas do nixos).
6. O usuário pausou os trabalhos requisitando um salvamento no estado atual para posterior retomada, mantendo o workspace consolidado.

## Mudanças realizadas
- `kryonix` (core): Modificado o arquivo `modules/nixos/installer/web-kiosk.nix` para expor o instalador no endereço `0.0.0.0` sob uso de flag de E2E, essencial para debug.

## Pendências (Próximos Passos)
A implementação do plano foi abortada pelo usuário para um "save and stop". O plano (agora listado nas issues) previu:
1. **Validar Existência de `/`:** No `src/main.rs`, antes do `eval_target_flake`, validar que o `InstallPlan` efetivamente tem ou gera um `mountpoint = "/"`. Em caso negativo, lançar código de falha estruturado `STORAGE_ROOT_FILESYSTEM_MISSING`.
2. **Importação do Disko:** No `src/executor/target_tree.rs`, incluir explicitamente `inputs.disko.nixosModules.disko` no arquivo flake.nix gerado, além de descomentar as chamadas disko no `storage.generated.nix`.
3. **Preservar Workdir:** Adicionar suporte a `KRYONIX_INSTALLER_KEEP_WORKDIR` para debug facilitado quando o instalador falha.

Estas pendências foram transformadas em issues.
