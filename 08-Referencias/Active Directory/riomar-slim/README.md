# RioMar Contabilidade — Pacote SLIM

> Pacote enxuto pra escritório pequeno (~5 máquinas, 5 usuários).
> Sem departamentalização, sem 30 grupos — só o necessário.

## Ambiente alvo

| Item | Valor |
|---|---|
| Servidor | `RIO-SRV-ADDS` |
| IP | `192.168.1.2` |
| Domínio DNS | `riomar.contabilidade` |
| NetBIOS | `RIOMAR` |
| OU raiz | `RIOMAR` (criada pelo roteiro, Fase 7) |
| Estações | 5 PCs |
| Usuários | ~5 funcionários |
| Pasta compartilhada | `\\RIO-SRV-ADDS\Escritorio$` (mapeia pra `D:\Escritorio`) |

## O que vem no pacote

```
riomar-slim/
├── scripts/
│   ├── New-RIOArvore.ps1         # Cria 4 OUs + 3 grupos
│   ├── New-RIOUsuarios.ps1       # Cria usuários a partir do CSV
│   └── New-RIOCompartilhado.ps1  # Cria a pasta compartilhada + permissões
├── templates/
│   └── funcionarios.csv          # Modelo (UTF-8 com BOM)
└── README.md                     # Este arquivo
```

## Pré-requisitos

- Windows Server com AD DS já promovido (domínio `riomar.contabilidade` existe)
- Módulo `ActiveDirectory` (RSAT) instalado
- Logado como **Domain Admin** no `RIO-SRV-ADDS`
- Unidade `D:` disponível (pode mudar com `-FolderPath`)
- Política de execução permitindo scripts locais:
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```

## Ordem de execução (sempre com `-WhatIf` antes)

### 1) Criar a estrutura mínima (4 OUs + 3 grupos)
```powershell
cd C:\Tools\riomar-slim
.\scripts\New-RIOArvore.ps1 -WhatIf
.\scripts\New-RIOArvore.ps1
```

Cria:
- `RIOMAR\Computadores` — onde os 5 PCs vão entrar
- `RIOMAR\Usuarios` — onde os funcionários vão entrar
- `RIOMAR\Usuarios-Desativados` — quarentena
- `RIOMAR\Clientes` — vazia, pronta pra OUs de clientes no futuro
- `G_Escritorio` (dentro de `Usuarios`) — grupo principal, todos os usuários são membros
- `GG_ADM_WORKSTATIONS` — você, pra admin local das estações
- `GG_HELPDESK_RESET_PASSWORD` — você, pra resetar senha de funcionário

### 2) Preencher o CSV de funcionários
Abra `templates\funcionarios.csv` (ou copie pra `funcionarios.csv` no mesmo dir).
Remova o `#` das linhas que quiser usar e ajuste os dados.

Exemplo:
```csv
FirstName,LastName,SamAccountName,UPN,Title,Password
Joao,Silva,joao.silva,joao.silva@riomar.contabilidade,Contador,
```
> Senha vazia = o script gera uma senha aleatória de 16 chars e imprime no console.
> Se quiser definir a senha manually, preencha a coluna `Password`.

### 3) Criar os usuários
```powershell
.\scripts\New-RIOUsuarios.ps1 -CsvPath .\funcionarios.csv -WhatIf
.\scripts\New-RIOUsuarios.ps1 -CsvPath .\funcionarios.csv
```
> ⚠️ As senhas geradas aparecem no console e **não são salvas em log**. Anote antes de fechar a janela.

Cada usuário vai pra `RIOMAR\Usuarios` e é adicionado ao `G_Escritorio` automaticamente.

### 4) Criar a pasta compartilhada
```powershell
.\scripts\New-RIOCompartilhado.ps1 -WhatIf
.\scripts\New-RIOCompartilhado.ps1
```

Cria:
- `D:\Escritorio`
- Compartilhamento `\\RIO-SRV-ADDS\Escritorio$` (oculto)
- Permissões NTFS: `G_Escritorio` = Modify
- Permissões de share: `G_Escritorio` = Change

> Se quiser a pasta em outra unidade, use `-FolderPath`. Ex: `.\scripts\New-RIOCompartilhado.ps1 -FolderPath 'C:\Compartilhado'`

### 5) Mapear nas estações (uma vez em cada PC)
Em cada uma das 5 máquinas (como o usuário):
```powershell
net use E: \\RIO-SRV-ADDS\Escritorio$ /persistent:yes
```
> `$` no final = share oculto, não aparece em "Rede" do Explorer — tem que mapear ou digitar o caminho.

## Conta de admin (separada do uso diário)

Você já deve ter uma conta pessoal (ex: `seu.nome`) e uma conta administrativa (ex: `adm-seu.nome`). **Use a adm só pra rodar os scripts e administrar AD — pra trabalho normal, usa a pessoal.**

Pra ficar mais seguro ainda, coloque sua conta de admin nos grupos:
```powershell
# Rodar como Domain Admin
Add-ADGroupMember -Identity "GG_ADM_WORKSTATIONS"        -Members "adm-seu.nome"
Add-ADGroupMember -Identity "GG_HELPDESK_RESET_PASSWORD" -Members "adm-seu.nome"
```

## Verificação rápida

Depois de tudo rodado:

```powershell
# OUs
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=RIOMAR,DC=riomar,DC=contabilidade" | Select-Object Name

# Usuarios
Get-ADUser -Filter * -SearchBase "OU=Usuarios,OU=RIOMAR,DC=riomar,DC=contabilidade" | Select-Object Name, SamAccountName, Enabled

# Membros do G_Escritorio
Get-ADGroupMember -Identity "G_Escritorio" | Select-Object Name, SamAccountName

# Compartilhamento
Get-SmbShare -Name "Escritorio$"
```

## Troubleshooting

| Problema | Solução |
|---|---|
| `módulo ActiveDirectory não encontrado` | Instale o RSAT: `Install-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0` |
| `acesso negado ao criar OU` | Rode o PowerShell como Administrator e com usuário Domain Admin |
| `Unidade D: não disponível` | Passe `-FolderPath 'C:\Escritorio'` (ou outra letra) no New-RIOCompartilhado |
| `Computador não acha o share` | Confirme DNS apontando pro DC (`192.168.1.2`) e que o firewall liberou SMB (porta 445) |
| `Senha gerada perdida` | Rode de novo o script com a senha já preenchida na coluna `Password` (re-roda é idempotente, pula usuário existente) |
| Esqueci a senha de alguém | `Set-ADAccountPassword -Identity "sam" -Reset` (precisa estar no `GG_HELPDESK_RESET_PASSWORD`) |

## Próximos passos (quando precisar crescer)

- **LAPS** — rotação automática de senha de admin local de cada estação
- **GPO** — wallpaper padrão, drives mapeados, política de senha visual
- **Backup** — `Install-WindowsFeature Windows-Server-Backup` + snapshot do System State
- **Mais usuários** — mesmo script, mesma estrutura, só acrescentar linhas no CSV

Detalhe dessas extensões no roteiro original (Fase 13-16).
