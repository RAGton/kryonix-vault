# Validação de Limite Físico de Disco no Installer

Data: 2026-06-28
Agente: Antigravity
Repos afetados:

- kryonix-installer
- kryonix-dev

## Objetivo
Impedir que o particionador manual continue a instalação quando o tamanho de um disco é identificado como `0 B` (indicativo de problema no disco ou falha na leitura pelo backend) e impor limites estritos de alocação onde a soma das partições nunca pode exceder o tamanho físico total.

## Contexto consultado
- A documentação de regras para agentes requer registros no Vault ao implementar mudanças críticas no repositório `kryonix-installer`.
- O payload proveniente do backend rust reportava adequadamente o `size_bytes` lido do `lsblk -b`. O erro original derivava da ausência de proteção da interface em casos onde `sizeBytes` fosse zero ou quando a soma das partições alocadas (`allocatedBytes`) ultrapassasse a capacidade física disponível (`freeBytes`).

## Mudanças realizadas
- Adição da função `validateDiskAllocation` em `ui/src/utils/layoutAssistant.js` para realizar a matemática do disco (usado vs. livre) gerando erros estritos (`> 0`) e alertas ("Disco totalmente alocado").
- Revisão completa do componente `TabManual` em `ui/src/pages/Disks.jsx` para:
  - Adotar `validateDiskAllocation` universalmente.
  - Bloquear botão "Nova Partição" (`disabled={!canCreatePartition}`).
  - Em uma "Nova Partição", preencher automaticamente todo o tamanho restante não utilizado (maxFree).
  - Exibir badges de aviso para Over-Allocation ("Excedido") e Ocultar blocos vazios na progressbar (`PartitionBar`).
- Criação de suítes de testes dedicadas em `ui/src/tests/layoutAssistant.test.js`.

## Commits e branches
- Commit em `kryonix-installer` na `main` (`feat(ui): implement strict physical disk limits for manual partitioning`).
- Atualização do submodule no `kryonix-dev`.

## Validações executadas
- Rodou `npm test` localmente na interface, cobrindo com sucesso os novos casos em `layoutAssistant.test.js`.
- O layout de validação não interfere com os casos existentes de Single Disk/Split Disk, nem quebra a lógica transiente do draft.

## Evidências
- Testes confirmados e build limpo no repositório `kryonix-installer`.

## Pendências
- Nenhuma. O UI agora barra 100% alocações acima do limite ou de discos defeituosos com tamanho aparente de 0 bytes.

## Próximo passo recomendado
- Realizar teste e2e com uma ISO final em uma máquina virtual (ou testbed) forçando um disco com falha (size: 0) para verificar se o backend rust reage bem em sinergia com o frontend.
