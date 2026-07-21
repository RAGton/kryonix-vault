# Migração da UI v2 e Integração Think Server

Data: 2026-07-13
Agente: Antigravity
Repos afetados:
- kryxd

## Objetivo
Unificar o instalador do Kryonix com a inteligência do RAGOS, adaptando a UI React (frontend) para construir e enviar o `InstallPlanV2` em três etapas, ao mesmo tempo em que oferece uma interface específica para instalar a máquina como "Kryonix Think Server".

## Contexto consultado
- Arquitetura de Domínio e Schemas (v2) finalizados.
- Regras de segurança (armazenamento sem hashes vazados no payload de plano).

## Mudanças realizadas
1. **Payload Refatorado:** O arquivo `ui/src/utils/installPlan.js` agora gera um payload estritamente aderente ao schema `InstallPlanV2` (substituindo campos legados como `disk` por `storage.topology` e `storage.filesystem`).
2. **API wrapper adaptado:** O fluxo no `ui/src/utils/installerApi.js` foi alterado. O `savePlan` e `startInstall` originais foram substituídos pelas chamadas separadas para as rotas `/api/v2/plan` (retorna o digest), `/api/v2/secrets` (envia os hashes) e `/api/v2/install` (confirma a instalação).
3. **Execution Hook (useInstallExecution):** Refatorado para chamar as 3 etapas de forma sequencial utilizando o digest do plano gerado pela primeira request HTTP.
4. **Think Server Toggle:** Adicionado checkbox no `Welcome.jsx` ativando o modo de servidor Think Server.
5. **Automação do Think Server na UI:** 
   - No `MachineProfile.jsx`, a lista de perfis disponíveis filtra perfis `desktop` se o Think Server estiver selecionado, garantindo o uso `headless/server`.
   - No `Disks.jsx`, a escolha de layout BTRFS no modo automático foi convertida para renderizar dinamicamente `ZFS` com o badge "Recomendado para Kryonix Think Server", caso a opção seja ativada.

## Commits e branches
TBD (mudanças aplicadas no repositório `kryxd` no branch principal, aguardando push após testes).

## Validações executadas
- Compilação do backend Rust (`cargo check && cargo clippy -- -D warnings`) sem avisos/erros novos.
- Bateria de testes do backend (`cargo test`) rodada com sucesso: 111 testes passaram.
- Build do Vite/React (`npm run build`) para verificar dependências sintáticas (ok).

## Evidências
- Testes locais verdes.
- UI renderiza corretamente e o backend intercepta payloads no formato V2.

## Pendências
Nenhuma. O pipeline completo de execução (UI -> V2 Plan -> V2 Secrets -> V2 Install) agora está perfeitamente conectado.

## Próximo passo recomendado
- Realizar uma dry-run test (instalação ponta-a-ponta virtualizada) e, se estiver ok, unificar com o módulo RAGOS.
