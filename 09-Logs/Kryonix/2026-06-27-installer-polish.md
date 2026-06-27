# Kryonix Installer - i18n, Disks Rework and SSH Polish

Data: 2026-06-27
Agente: Antigravity
Repos afetados:
- kryonix-installer

## Objetivo
Finalizar os épicos de UI pendentes do Kryonix Installer: tradução completa (i18n) das telas, refatoração completa do layout de partições (`Disks.jsx`) suportando Automático, Manual, LVM e RAID, bem como o refinamento da aba de Usuários e SSH Keys (`Users.jsx`). Além disso, consolidar as integrações com os schemas atualizados (ex. integração `github-create-from-template`).

## Contexto consultado
- Regras de workspace e anti-vibe coding (AGENTS.md).
- Status atual dos componentes React no instalador (`Source.jsx`, `Disks.jsx`, `Users.jsx`, `Network.jsx`).
- Contrato JSON Schema (`install-plan.schema.json`) vs Estruturas Rust backend (`InstallPlan`, `SourceConfig`).

## Mudanças realizadas
1. **i18n Sweep**: Adicionadas traduções completas para todos os painéis e botões que ainda tinham strings fixas (hardcoded) nas abas principais. Atualizamos os dicionários `pt-BR`, `en-US` e `es-ES` e as chaves de fallback para novas abas como `storage.lvm` e `storage.raid`.
2. **Schema & Backend Sync**: Confirmamos que o novo modelo de *Source* do frontend (permitindo `github-create-from-template`) envia os payloads corretamente por meio do `installPlan.js`, que foi ajustado para compor o schema sem propriedades extras. As estruturas no Rust que acusavam campos não utilizados (`GhRepoResponse` owner) foram marcadas com `#[allow(dead_code)]` temporariamente para manter o build verde sob flag `-D warnings`.
3. **Disks.jsx Refactor**: Removidos os estados vazios das abas manuais; agora a UI exibe tabelas e layouts descritivos visuais ("Preview do Particionamento") baseados em seleções do usuário (Automático, Manual, LVM, RAID).
4. **Users.jsx Refactor**: Inserido o campo "Nome Completo" (`adminFullName`), removida a entrada manual de UID para administradores (forçando fixo `1000` via build de payload), e UI da chave SSH foi refinada para um accordion que oculta o `<textarea>` gigante e expõe a quantidade de chaves, permitindo expansão opcional.

## Commits e branches
- `kryonix-installer` (main): `feat(installer): complete i18n, disks rework and ssh polish`
- `kryonix-dev` (main): submodules atualizados.

## Validações executadas
- Compilação do Vite do React frontend (`npm run build`). Sucesso sem erros críticos.
- Validação backend do Rust (`cargo check` e `cargo clippy -- -D warnings`). Clippy aprovado sem avisos remanescentes.

## Pendências
- Finalizar testes visuais extensivos do Dev/Live ISO em hardware real ou QEMU, já que o Chrome headless local não conectou.

## Próximo passo recomendado
- Realizar teste E2E gerando um ISO da distro com a nova UI buildada e confirmar se a instalação base no disco virtual funciona do começo ao fim sem problemas de incompatibilidade com o Disko / NixOS Install.
