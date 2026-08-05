# Criação do baseline reutilizável de Active Directory

Data: 2026-07-29  
Agente: Aura  
Repo afetado: `kryonix-vault`

## Objetivo

Preservar o pacote RioMar enviado por Gabriel e transformá-lo em um runbook genérico, seguro e passo a passo para empresas de diferentes nichos.

## Contexto consultado

- `AGENTS.md` e `VAULT_INDEX.md`;
- MOCs de DevOps e Segurança;
- pacote `riomar-slim.zip`;
- documentação oficial Microsoft Learn para AD DS, DNS, hardening, LAPS, Recycle Bin, backup, DCDiag, replicação e GPO.

## Mudanças realizadas

- criada a nota [[04-Recursos/playbooks/runbooks/Active Directory - Implantacao Baseline/README|Runbook - Active Directory para empresas]];
- adicionados templates genéricos de empresa e usuários;
- adicionados scripts para floresta, OUs/grupos, usuários, compartilhamento e verificação;
- preservada a fonte em [[08-Referencias/Active Directory/Fonte - Pacote RioMar SLIM]];
- ligados os MOCs de DevOps e Segurança.

## Validações executadas

- extração comparada por SHA-256: 5/5 arquivos idênticos à fonte;
- `git diff --check`: sem erro;
- 23 wikilinks novos/afetados resolvidos por verificação focada;
- parser PowerShell 7.5: 5/5 scripts sem erro de sintaxe;
- template PSD1 e CSV carregados no PowerShell;
- gerador criptográfico: 200/200 senhas únicas de 20 caracteres com quatro classes;
- revisão técnica independente da fonte: riscos prioritários conferidos e mapeados para os controles do baseline genérico.

## Limitações

- ambiente local é Linux e não possui um domínio Windows; os scripts não foram executados contra AD DS real;
- PSScriptAnalyzer via PSGallery não ficou disponível no contêiner dentro do tempo de validação;
- o verificador global de wikilinks já falha por links antigos fora do escopo; a verificação focada das notas alteradas passou.

## Pendências

- executar em laboratório Windows Server com segundo DC;
- revisar por outro administrador;
- testar promoção, replicação, delegação, GPO, LAPS, SMB e restauração;
- adaptar controles de acesso e compliance ao nicho da empresa.
