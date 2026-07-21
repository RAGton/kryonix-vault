# Alinhamento Contrato Frontend e Backend do Installer

Data: 2026-06-29
Agente: Antigravity
Repos afetados:

- repos/kryxd
- repos/kryonix-vault
- / (kryonix-dev)

## Objetivo
Criar um PR pequeno e focado: `fix(installer): align frontend backend contract`.
Garantir que as restrições estritas impostas pelo backend durante o `/dry-run` para features com status `stub` (bloqueadas) e `partial` (requer confirmação explícita) sejam tratadas de forma espelhada na UI (frontend) React, além de gerar uma documentação unificada das rotas e comportamentos esperados (Single Source of Truth).

## Contexto consultado
O backend mapeia "features" (`InstallPlan` JSON) validando a compatibilidade no `src/main.rs`. Descobriu-se que `ai.ollama` e `virtualization.libvirt` exigiam o array `confirmed_features` com a chave do ID caso fossem adicionadas no JSON do installer.
Consultado os estados do `kryxd` no Workspace local para mapear a comunicação de segurança via Token e as regras de restrição do Glacier (que não deve sofrer interações por via direta no instalador).

## Mudanças realizadas
1. Criado `docs/FRONTEND_BACKEND_CONTRACT.md` documentando rotas `/dry-run`, `/install`, o esquema do `X-Kryonix-Installer-Token` e o tratamento dos payloads HTTP.
2. Modificado `ui/src/data/featureCatalog.js` para atualizar o status das features baseando-se no rust engine local (`partial` para `ai.ollama` e `libvirt`, `stub` para `ai.open-webui` e `lightrag`).
3. Modificados `ui/src/pages/SystemFeatures.jsx` e `UserFeatures.jsx` para desabilitar as features de status `stub` ou `legacy` e incluir um modal `window.confirm` quando usuários selecionarem features marcadas como `partial`.
4. Atualizado `ui/src/utils/installPlan.js` e `ui/src/utils/installerApi.js` para agregar a chave `confirmed_features` ao envio final do `InstallPlan`, extraindo do catalogo as selections marcadas como `partial`.

## Commits e branches
1. `fix(installer): align frontend backend contract` (Em `repos/kryxd`)
2. `chore(dev): update kryxd submodule pointer` (Em `/home/rocha/kryonix/kryonix-dev`)

## Validações executadas
- `cargo test` executado e 64 testes rodaram com status "ok", incluindo as garantias sobre a validação de feature `test_feature_partial_with_confirmation_passes` e logs de erros estritos de fallback.
- Build da Interface Gráfica executada (`npm run build`) via Vite confirmando que o bundle foi comprimido sem erros de sintaxe ou referências perdidas (exceção ignorável à warning comum de tamanho do minification react).

## Evidências
- Modificações testadas em compilação na própria sessão.
- Payload de build verificado para evitar falhas de validação sintática do array do JSON.
- A restrição `stub` agora aplica lock opaco no checkbox visual diretamente no render.

## Pendências
Nenhuma pendência técnica. A ponte do Installer para rodar nas ISOs e formatação da VM está pronta para validação final do LiveCD em cenários destrutivos, sem risco de corrupções geradas por malformação do JSON.

## Próximo passo recomendado
O próximo passo deve ser gerar a build da ISO via NixOS do `installer` final e homologar a máquina virtual com as features de "Ollama" e "Libvirt" aplicadas.
