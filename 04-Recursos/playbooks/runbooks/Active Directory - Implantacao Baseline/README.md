---
title: Runbook - Active Directory para Empresas - Implantacao Baseline
aliases:
  - Active Directory passo a passo
  - AD DS para pequenas e medias empresas
type: runbook
status: active
created: 2026-07-29
updated: 2026-07-29
tags: [active-directory, windows-server, ad-ds, dns, powershell, infraestrutura, seguranca]
---

# Runbook — Active Directory para empresas: implantação baseline

> [!warning] Escopo e risco
> Este runbook é uma **base reutilizável**, não uma receita cega para produção. Active Directory é o plano de identidade da empresa: erro de DNS, delegação, backup ou privilégio pode parar todos os usuários. Faça laboratório, revisão por outro administrador, janela de mudança, plano de reversão e backup testado.

## Objetivo

Implantar um domínio Microsoft Active Directory Domain Services (AD DS) com:

- floresta e DNS interno;
- OUs e grupos mínimos;
- usuários importados por CSV sem senha em texto claro no arquivo;
- compartilhamento SMB baseado em grupo;
- validações básicas de saúde;
- caminho explícito para segurança, backup e crescimento.

Este material generaliza o pacote original `riomar-slim.zip`. Os scripts originais continuam preservados em [[08-Referencias/Active Directory/riomar-slim/README|Fonte - RioMar SLIM]], mas **não devem ser executados sem revisão**.

## Quando usar

- empresa pequena ou média com estações Windows e necessidade real de domínio local;
- ambiente on-premises ou híbrido em que AD DS é requisito de aplicações, GPO, autenticação Kerberos/LDAP ou arquivos;
- laboratório de implantação antes de produção;
- baseline inicial para qualquer nicho, antes das extensões específicas.

## Quando não usar

- a empresa usa apenas SaaS e dispositivos gerenciados por Microsoft Entra ID/Intune e não tem dependência de AD DS;
- não existe responsável por operação, atualização, backup e recuperação;
- pretende-se colocar o único DC exposto à internet;
- o plano é manter apenas um DC sem risco formalmente aceito;
- o nicho exige controles que ainda não foram mapeados (saúde, jurídico, financeiro, educação, indústria, PCI etc.).

## Princípio: baseline comum × extensão por nicho

A floresta, DNS, OUs, grupos, contas separadas, LAPS, backup e auditoria formam o **baseline comum**. O nicho muda principalmente:

- classificação e retenção de dados;
- grupos de acesso e segregação de funções;
- auditoria e evidências;
- criptografia, DLP e resposta a incidentes;
- integrações com aplicações do setor;
- exigências legais e contratuais.

| Nicho | Extensões a decidir com o responsável da empresa |
|---|---|
| Contabilidade/financeiro | segregação fiscal/folha/financeiro; acesso por cliente; trilha de auditoria; retenção e LGPD |
| Saúde | prontuário por função; acesso mínimo; auditoria reforçada; LGPD para dados sensíveis; requisitos do sistema clínico |
| Jurídico | grupos por caso/cliente; barreiras éticas; retenção; trilha de acesso |
| Varejo | contas de caixa sem privilégio; segmentação de PDV; PCI DSS se houver dados de cartão |
| Educação | separação de alunos, professores e administrativo; laboratório; sazonalidade de contas |
| Indústria | separação TI/OT; não ingressar equipamentos industriais no domínio sem validação do fabricante |

> [!important]
> AD DS não “torna a empresa compatível” com LGPD, PCI DSS ou qualquer norma. Compliance depende de pessoas, processos, contratos, aplicações e evidências, além da tecnologia.

## Arquivos deste runbook

```text
Active Directory - Implantacao Baseline/
├── README.md                         # esta nota
├── scripts/
│   ├── Install-CompanyADForest.ps1  # instala a primeira floresta
│   ├── Initialize-CompanyADBaseline.ps1
│   ├── Import-CompanyADUsers.ps1
│   ├── New-CompanyFileShare.ps1
│   └── Test-CompanyADBaseline.ps1
└── templates/
    ├── company-config.psd1
    └── users.csv
```

## Arquitetura mínima recomendada

```text
Internet
   |
Firewall/roteador (não encaminhar portas do AD/SMB da internet)
   |
Rede interna/VLANs
   |-- EMP-DC01  -> AD DS + DNS
   |-- EMP-DC02  -> AD DS + DNS (recomendado para produção)
   |-- EMP-FS01  -> servidor membro para arquivos
   |-- Estações  -> DNS aponta somente para DNS interno do AD
```

- O DC deve ser dedicado a AD DS/DNS sempre que possível.
- Não use o DC para navegação, e-mail, Office ou trabalho diário.
- O servidor de arquivos deve ser um servidor membro separado sempre que possível.
- Em produção, use no mínimo dois DCs e valide replicação; um único DC é ponto único de falha.
- DNS dos clientes aponta para os DNS internos do AD. Resolução externa sai por encaminhadores configurados no DNS interno.
- Hora correta é obrigatória para Kerberos. Defina uma fonte NTP confiável para o PDC Emulator.

## Fase 0 — descobrir se AD DS é a solução certa

Antes de comprar licença ou promover servidor, responda:

- [ ] Existe aplicativo, GPO, arquivo, Kerberos/LDAP ou legado que exige AD DS?
- [ ] Microsoft 365/Entra ID/Intune sozinho resolveria o caso?
- [ ] Quantos usuários, PCs, servidores, locais e links WAN existem hoje e em 3 anos?
- [ ] Há filial sem conectividade confiável? RODC faz sentido?
- [ ] Quem é dono do serviço e quem atende incidentes?
- [ ] Quanto tempo a empresa tolera ficar sem login/DNS/arquivos?
- [ ] Há orçamento para segundo DC, backup e licença/CAL?
- [ ] Quais regulações, contratos e dados sensíveis se aplicam?

**Gate:** se não houver necessidade técnica e responsável operacional, não implante AD DS por hábito.

## Fase 1 — preencher a ficha da empresa

Copie `templates/company-config.psd1` para fora deste runbook e altere:

- `DomainDnsName`: prefira um subdomínio de nome público que a empresa controla, por exemplo `ad.empresa.com.br`;
- `DomainNetBIOSName`: 1–15 caracteres, por exemplo `EMPRESA`;
- `RootOuName`: nome curto sem acentos;
- nomes de grupos e compartilhamento;
- nome e caminho do servidor de arquivos.

Se os usuários forem entrar com um UPN diferente do domínio AD — por exemplo, domínio AD `ad.empresa.com.br`, mas login `usuario@empresa.com.br` — configure primeiro o sufixo alternativo em **Active Directory Domains and Trusts** ou com:

```powershell
Set-ADForest `
  -Identity 'ad.empresa.com.br' `
  -UPNSuffixes @{ Add = 'empresa.com.br' }
```

O script de importação recusa sufixos UPN que não estejam configurados na floresta.

> [!danger] Decisões difíceis de mudar
> Nome DNS da floresta, NetBIOS e desenho da floresta não são “detalhes”. Revise juridicamente a titularidade do domínio e tecnicamente as integrações antes de promover o primeiro DC. Evite inventar TLD interno como `.local`.

Ficha mínima:

| Campo | Valor da empresa |
|---|---|
| Razão/nome curto | |
| Domínio público controlado | |
| Domínio AD proposto | |
| NetBIOS | |
| Site(s)/filial(is) | |
| Faixa IP/VLAN | |
| DC01 / IP | |
| DC02 / IP | |
| servidor de arquivos / IP | |
| DNS forwarders | |
| responsável técnico | |
| RTO/RPO | |
| solução e destino de backup | |
| janela de mudança | |
| nicho/regulação | |

## Fase 2 — preparar Windows Server e rede

Em cada servidor:

- [ ] Windows Server suportado, licenciado e atualizado;
- [ ] firmware/hipervisor atualizados;
- [ ] nome final definido (`EMP-DC01`, `EMP-DC02`, `EMP-FS01`);
- [ ] IP estático, gateway, máscara e DNS planejados;
- [ ] acesso administrativo restrito;
- [ ] firewall ativo;
- [ ] volume e destino de backup definidos;
- [ ] horário/fuso/NTP verificados;
- [ ] nenhuma porta AD, RDP ou SMB publicada diretamente na internet;
- [ ] proteção física e de console do hipervisor.

Comandos de inventário, sem alterar o servidor:

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, CsName
Get-NetIPConfiguration
Get-DnsClientServerAddress -AddressFamily IPv4
Get-TimeZone
w32tm /query /status
```

## Fase 3 — laboratório e revisão

1. Clone a topologia em VMs isoladas.
2. Use valores de laboratório — nunca clone um DC de produção como VM comum.
3. Execute todos os scripts com `-WhatIf` quando suportado.
4. Revise a saída com outro administrador.
5. Teste criação, login, DNS, GPO, recuperação de objeto e restauração de backup.
6. Registre o rollback: antes da promoção, reinstalar/descartar VM; depois da promoção, seguir procedimento suportado de despromoção/recuperação — não “apagar a VM” como rotina de produção.

## Fase 4 — instalar a primeira floresta

No `EMP-DC01`, PowerShell como administrador:

```powershell
Set-Location C:\Tools\AD-Baseline\scripts

# Simulacao do wrapper (nao instala)
.\Install-CompanyADForest.ps1 `
  -ConfigPath ..\templates\company-config.psd1 `
  -WhatIf

# Execucao real: solicita a senha DSRM mascarada, roda o pre-check oficial
# Test-ADDSForestInstallation e promove/reinicia o servidor.
.\Install-CompanyADForest.ps1 `
  -ConfigPath ..\templates\company-config.psd1
```

A senha DSRM:

- não vai no `.ps1`, `.psd1`, CSV, ticket, chat ou repositório;
- deve ir para cofre de senhas aprovado, com acesso e auditoria restritos;
- deve ter procedimento de teste/rotação.

Após reiniciar:

```powershell
Get-ADForest
Get-ADDomain
Get-ADDomainController -Filter *
Resolve-DnsName "_ldap._tcp.dc._msdcs.$((Get-ADDomain).DNSRoot)" -Type SRV
dcdiag /q
```

**Gate:** não prossiga com erro de DNS, SYSVOL, Netlogon ou `dcdiag`.

## Fase 5 — instalar o segundo DC

Prepare `EMP-DC02` com IP estático e DNS apontando inicialmente para `EMP-DC01`. Ingresse-o no domínio e instale a função:

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Somente pre-check
Test-ADDSDomainControllerInstallation `
  -DomainName 'ad.empresa.com.br' `
  -InstallDns

# Promocao; solicita credenciais e DSRM de forma interativa
Install-ADDSDomainController `
  -DomainName 'ad.empresa.com.br' `
  -InstallDns
```

Depois do reboot:

```powershell
Get-ADDomainController -Filter *
repadmin /replsummary
repadmin /showrepl
dcdiag /e /q
```

Configure cada DC para usar **DNS interno**, considerando o outro DC e a orientação oficial de DNS client. Não aponte o NIC do DC diretamente para DNS público.

## Fase 6 — criar OUs e grupos baseline

```powershell
.\Initialize-CompanyADBaseline.ps1 `
  -ConfigPath ..\templates\company-config.psd1 `
  -WhatIf

.\Initialize-CompanyADBaseline.ps1 `
  -ConfigPath ..\templates\company-config.psd1
```

Estrutura padrão:

```text
OU=EMPRESA
├── Administracao
├── Usuarios
├── Computadores
├── Servidores
├── Contas-de-Servico
├── Grupos
└── Desativados
```

Grupos baseline:

- `GG_Todos_Usuarios`: grupo global de contas comuns;
- `GG_Admin_Local_Estacoes`: função administrativa de estações, ainda sem privilégio;
- `GG_Helpdesk_Reset_Senha`: função de helpdesk, ainda sem delegação;
- `DL_Compartilhado_Modificar`: grupo Domain Local ligado à ACL do recurso.

O desenho segue **AGDLP**:

```text
Accounts -> Global role group -> Domain Local resource group -> Permission
```

Não adicione usuários diretamente em ACLs de pasta, salvo exceção documentada.

## Fase 7 — delegar sem entregar Domain Admin

Crie contas separadas:

- `gabriel.rocha` — uso diário, sem privilégio;
- `adm-gabriel.rocha` — administração, não usada para e-mail/navegação;
- conta de emergência (“break glass”) — protegida, monitorada e testada.

Para helpdesk:

1. Abra **Active Directory Users and Computers**.
2. Clique na OU `Usuarios` → **Delegate Control**.
3. Selecione `GG_Helpdesk_Reset_Senha`.
4. Delegue somente o necessário, por exemplo reset de senha e obrigar troca no próximo logon.
5. Teste com uma conta de laboratório que ela **consegue** resetar usuário comum e **não consegue** alterar admin, GPO, grupo privilegiado ou objeto fora da OU.

Para admin local de estações, aplique `GG_Admin_Local_Estacoes` por GPO somente à OU `Computadores`. Não adicione esse grupo a servidores ou DCs.

> [!danger]
> Apenas criar os grupos não delega nada. O pacote RioMar original criava nomes de grupos, mas não aplicava as delegações descritas.

## Fase 8 — importar usuários

1. Copie `templates/users.csv` para um local administrativo protegido.
2. Deixe no CSV apenas identidade e metadados — **não existe coluna Password**.
3. Marque `Enabled=true` somente nas linhas aprovadas.
4. Valide primeiro:

```powershell
.\Import-CompanyADUsers.ps1 `
  -ConfigPath ..\templates\company-config.psd1 `
  -CsvPath .\usuarios-reais.csv `
  -WhatIf
```

5. Execute:

```powershell
.\Import-CompanyADUsers.ps1 `
  -ConfigPath ..\templates\company-config.psd1 `
  -CsvPath .\usuarios-reais.csv `
  -PasswordMode Generate
```

O script:

- exige `Enabled=true`;
- valida `sAMAccountName` e UPN;
- usa gerador criptográfico para senha inicial;
- obriga troca no primeiro logon;
- não armazena senha no CSV ou log;
- não sobrescreve atributos de usuário existente;
- recusa sufixo UPN que não esteja configurado na floresta;
- reconcilia a associação ao grupo baseline.

Entregue senha inicial por canal separado e aprovado. Não fotografe a tela, não envie em grupo de chat e não grave no Vault.

## Fase 9 — ingressar computadores

Antes de ingressar:

- DNS do cliente aponta para `EMP-DC01` e `EMP-DC02`;
- nome do computador segue padrão;
- Windows é edição compatível com domain join;
- relógio está correto;
- objeto irá para a OU correta.

Exemplo:

```powershell
Add-Computer `
  -DomainName 'ad.empresa.com.br' `
  -OUPath 'OU=Computadores,OU=EMPRESA,DC=ad,DC=empresa,DC=com,DC=br' `
  -Credential (Get-Credential) `
  -Restart
```

Teste após reiniciar:

```powershell
whoami
gpresult /r
nltest /dsgetdc:ad.empresa.com.br
Test-ComputerSecureChannel -Verbose
```

## Fase 10 — criar compartilhamento em servidor membro

No `EMP-FS01`, com RSAT ActiveDirectory instalado e o servidor ingressado no domínio:

```powershell
.\New-CompanyFileShare.ps1 `
  -ConfigPath ..\templates\company-config.psd1 `
  -WhatIf

.\New-CompanyFileShare.ps1 `
  -ConfigPath ..\templates\company-config.psd1
```

Safe defaults do script:

- recusa rodar em DC, salvo aceite explícito;
- recusa substituir ACL de pasta existente sem `-ApplyAclToExistingFolder`;
- NTFS: SYSTEM/Admins = Full, grupo Domain Local = Modify;
- share: Admins = Full, grupo Domain Local = Change;
- Access-Based Enumeration;
- criptografia SMB habilitada no template;
- não concede leitura para todos os usuários autenticados.

Para liberar acesso, aninhe o grupo global de função no grupo Domain Local do recurso:

```powershell
Add-ADGroupMember `
  -Identity 'DL_Compartilhado_Modificar' `
  -Members 'GG_Equipe_Autorizada'
```

Mapeie por GPO Preferences em vez de `net use` manual em cada PC quando houver várias estações.

## Fase 11 — GPO baseline

Crie GPOs pequenas, com escopo e dono claros. Teste em uma OU piloto antes de produção.

Baseline a avaliar:

- Windows LAPS;
- Microsoft Defender/EDR e firewall;
- atualizações;
- bloqueio de tela;
- auditoria avançada;
- restrição de logon de contas privilegiadas;
- grupo de administradores locais das estações;
- mapeamento de drives;
- desabilitação de protocolos legados após inventário (por exemplo SMBv1);
- BitLocker e recuperação de chaves conforme política;
- hardening de DCs e servidores conforme baseline Microsoft aplicável.

Não misture configuração de usuário, estação, servidor e DC na mesma GPO “geral”.

## Fase 12 — política de senha e MFA

1. Observe o estado efetivo:

```powershell
Get-ADDefaultDomainPasswordPolicy
```

2. Defina política com segurança e RH/diretoria, considerando comprimento, bloqueio, histórico, MFA e suporte.
3. Use Fine-Grained Password Policy somente quando houver necessidade real para grupos específicos.
4. Não copie números “universais” sem avaliar o risco e a capacidade operacional.
5. Para administração remota/híbrida, use MFA e host administrativo seguro quando a arquitetura suportar.

## Fase 13 — LAPS

Windows LAPS deve gerenciar senhas únicas de administrador local. Fluxo resumido:

1. confirmar versões suportadas e nível funcional;
2. atualizar o schema conforme a documentação oficial;
3. conceder self-permission na OU de computadores;
4. conceder leitura/rotação somente a grupos aprovados;
5. aplicar a política LAPS por GPO;
6. testar rotação, leitura autorizada, negação para não autorizados e eventos.

Não use uma senha local de administrador igual em todas as máquinas.

## Fase 14 — lixeira do AD, backup e recuperação

### Active Directory Recycle Bin

A Lixeira preserva atributos de objetos excluídos depois da habilitação. A habilitação é **irreversível**; revise requisitos e depois use o procedimento oficial.

### Backup

- instale e configure solução de backup suportada;
- faça System State de DCs;
- mantenha cópia fora do servidor/host e protegida contra ransomware;
- use retenção alinhada ao RPO;
- monitore cada job;
- teste restauração em ambiente isolado;
- documente recuperação de objeto, DC e floresta.

Exemplo oficial de execução manual — ajuste o destino e não confunda com política completa de backup:

```powershell
wbadmin start systemstatebackup -backuptarget:E:
```

> [!danger]
> Snapshot/checkpoint de hipervisor não substitui uma estratégia suportada de backup do AD. “Backup concluído” sem teste de restauração é apenas esperança.

## Fase 15 — validar o baseline

```powershell
.\Test-CompanyADBaseline.ps1 `
  -ConfigPath ..\templates\company-config.psd1
```

O script verifica OUs, grupos, DNS SRV, quantidade de DCs, Recycle Bin, política de senha, `dcdiag` e replicação quando aplicável.

Checklist de aceite:

- [ ] dois DCs visíveis e replicando;
- [ ] DNS SRV responde;
- [ ] `dcdiag /e /q` sem falhas;
- [ ] `repadmin /replsummary` sem erro;
- [ ] SYSVOL e NETLOGON disponíveis;
- [ ] usuário piloto faz login e troca senha;
- [ ] GPO piloto é aplicada (`gpresult /h`);
- [ ] helpdesk consegue somente o que foi delegado;
- [ ] conta diária não é admin;
- [ ] LAPS rotaciona e só grupo autorizado lê;
- [ ] share permite a equipe autorizada e nega não autorizados;
- [ ] backup monitorado e restauração testada;
- [ ] documentação e contatos de incidente atualizados.

## Operação recorrente

### Diário/automatizado

- backup, espaço, eventos críticos, DNS e replicação;
- alertas de autenticação e mudanças privilegiadas;
- falhas de atualização/antimalware.

### Semanal

```powershell
dcdiag /e /q
repadmin /replsummary
Get-ADDomainController -Filter *
```

### Mensal

- patches de DCs, servidores e estações com janela e rollback;
- revisão de membros de `Domain Admins`, `Enterprise Admins`, `Administrators` e grupos delegados;
- contas inativas e contas de serviço;
- jobs de backup e amostra de restauração;
- GPOs sem uso, alterações e divergências.

### Trimestral/semestral

- exercício de recuperação;
- revisão de RTO/RPO;
- teste de conta break-glass;
- revisão de acessos com gestores;
- revisão de extensões do nicho e contratos.

## Onboarding, mudança e desligamento

### Onboarding

- aprovação do gestor;
- função e grupos mínimos;
- conta diária sem privilégio;
- senha inicial entregue de forma segura;
- MFA onde aplicável;
- data/owner registrados.

### Mudança de função

- remover acessos antigos antes/de forma coordenada com os novos;
- não apenas acumular grupos;
- revisar dados sensíveis e segregação.

### Desligamento

- desabilitar conta imediatamente conforme processo aprovado;
- revogar sessões/tokens em sistemas integrados;
- remover grupos privilegiados;
- transferir propriedade de dados;
- mover para OU `Desativados`;
- manter/excluir conforme retenção e jurídico;
- registrar quem autorizou e executou.

## Riscos conhecidos no pacote original RioMar

Não execute a fonte original em produção sem corrigir, entre outros:

1. Ela pressupõe que o domínio e a OU raiz já existem; portanto não cria o AD completo.
2. Os grupos “admin de estação” e “reset de senha” são apenas criados; nenhuma delegação/GPO é aplicada.
3. O script de OU usa uma variável de descrição externa à função, o que é frágil.
4. O gerador usa `Get-Random`, não um RNG criptográfico.
5. O CSV aceita senha em texto claro.
6. Senhas geradas são impressas em tela; capturas e transcript podem expô-las.
7. O share concede leitura a `Authenticated Users`, contrariando a descrição de acesso restrito.
8. O share é sugerido no próprio DC, aumentando a superfície de ataque.
9. A ACL de pasta existente pode ter herança/regras removidas sem inspeção/rollback adequado.
10. Nome do servidor e caminho UNC ficam hardcoded na mensagem final.
11. `-WhatIf` não cobre de forma perfeita todos os pre-checks e contadores.
12. Não inclui segundo DC, replicação, GPO baseline, LAPS, backup testado ou recuperação.

## Troubleshooting

| Sintoma | Diagnóstico inicial |
|---|---|
| cliente não encontra domínio | confira DNS do cliente; `Resolve-DnsName _ldap._tcp.dc._msdcs.<dominio> -Type SRV`; não use DNS público no cliente |
| login lento/falha Kerberos | DNS e hora; `w32tm /query /status`; eventos System/Kerberos |
| GPO não aplica | `gpresult /h C:\Temp\gp.html`; eventos GroupPolicy; escopo, link e filtros |
| replicação falha | `repadmin /replsummary`; `repadmin /showrepl`; DNS, RPC, hora e firewall |
| share nega acesso | compare `Get-SmbShareAccess` com `Get-Acl`; confirme grupo efetivo e novo logon/ticket |
| script acha objeto existente | valide tipo, escopo e DN; não apague/mova automaticamente para “fazer passar” |
| senha inicial falha | confira política efetiva; gere nova senha e entregue por canal seguro |

## Rollback por fase

| Fase | Estratégia |
|---|---|
| pré-floresta em laboratório | descartar/recriar VM de laboratório |
| promoção da primeira floresta | despromoção suportada ou recuperação planejada; não remover metadados ad hoc |
| OU/grupo recém-criado | remover apenas após confirmar vazio, dependências e proteção; preferir mudança revisada |
| importação de usuário | desabilitar/mover; preservar evidência; excluir só com aprovação |
| ACL/share | exportar ACL/config antes; restaurar ACL e remover share de forma controlada |
| GPO | backup da GPO; unlink/desabilitar após teste; não editar Default Domain Policy indiscriminadamente |

## Fontes oficiais

- [Microsoft Learn — Install Active Directory Domain Services](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-)
- [Microsoft Learn — Install-ADDSForest](https://learn.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest)
- [Microsoft Learn — DNS and AD DS](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/dns-and-ad-ds)
- [Microsoft Learn — Best practices for securing Active Directory](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory)
- [Microsoft Learn — Windows LAPS overview](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview)
- [Microsoft Learn — Active Directory Recycle Bin](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/adac/active-directory-recycle-bin)
- [Microsoft Learn — Back up System State](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-backing-up-system-state)
- [Microsoft Learn — DCDiag](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/dcdiag)
- [Microsoft Learn — Diagnose replication failures](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/diagnose-replication-failures)
- [Microsoft Learn — Group Policy overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview)

## Links relacionados

- [[VAULT_INDEX]]
- [[01-MOCs/Mapa - DevOps e SRE]]
- [[01-MOCs/Mapa - Segurança]]
- [[02-Areas/Seguranca/Secrets e Credenciais]]
- [[04-Recursos/playbooks/Playbook - Validar Seguranca Antes do Deploy]]
- [[08-Referencias/Active Directory/riomar-slim/README|Fonte - RioMar SLIM]]

## Próxima ação

Copiar o template, preencher a ficha de uma empresa real, executar exclusivamente em laboratório e registrar decisões que diferem do baseline antes de qualquer produção.
