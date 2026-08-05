<#
.SYNOPSIS
    Cria usuarios do escritorio RioMar a partir de um CSV (max 5-10 usuarios).

.DESCRIPTION
    Le um CSV com os dados dos funcionarios, cria cada usuario na OU=Usuarios
    e adiciona automaticamente ao grupo G_Escritorio.

    Colunas obrigatorias: FirstName, LastName, SamAccountName, UPN
    Colunas opcionais: Title, Password

    Se a coluna Password vier vazia, gera uma senha aleatoria de 16 caracteres
    (4 classes) e imprime no console. NAO grava em log.

    Idempotente: pula usuarios ja existentes.

.PARAMETER CsvPath
    Caminho do CSV de funcionarios.

.PARAMETER DomainDn
    Distinguished Name do dominio. Padrao: DC=riomar,DC=contabilidade

.PARAMETER RootOuName
    Nome da OU raiz. Padrao: RIOMAR

.EXAMPLE
    PS C:\> .\New-RIOUsuarios.ps1 -CsvPath .\funcionarios.csv -WhatIf

.EXAMPLE
    PS C:\> .\New-RIOUsuarios.ps1 -CsvPath .\funcionarios.csv -Verbose

.NOTES
    Dependencia: New-RIOArvore.ps1 deve ter sido executado antes.
#>

#Requires -Modules ActiveDirectory

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,
    [string]$DomainDn       = 'DC=riomar,DC=contabilidade',
    [string]$RootOuName     = 'RIOMAR'
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
function Write-Banner {
    param([string]$Text)
    $line = '=' * 70
    Write-Host ''
    Write-Host $line -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor Cyan
    Write-Host $line -ForegroundColor Cyan
    Write-Host ''
}

Write-Banner "New-RIOUsuarios - Cria usuarios do CSV"

# ---------------------------------------------------------------------------
# Pre-checks
# ---------------------------------------------------------------------------
if (-not (Test-Path $CsvPath)) {
    throw "Arquivo CSV nao encontrado: $CsvPath"
}

$rootOuDn     = "OU=$RootOuName,$DomainDn"
$usuariosDn   = "OU=Usuarios,$rootOuDn"
$grupoDn      = "CN=G_Escritorio,OU=Usuarios,$rootOuDn"

if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$usuariosDn)" -ErrorAction SilentlyContinue)) {
    throw "OU 'Usuarios' nao encontrada. Rode New-RIOArvore.ps1 antes."
}
if (-not (Get-ADGroup -LDAPFilter "(distinguishedName=$grupoDn)" -ErrorAction SilentlyContinue)) {
    throw "Grupo 'G_Escritorio' nao encontrado. Rode New-RIOArvore.ps1 antes."
}

# ---------------------------------------------------------------------------
# Gerador de senha
# ---------------------------------------------------------------------------
function New-RIOSenha {
    param([int]$Length = 16)
    $upper   = [char[]](65..90)
    $lower   = [char[]](97..122)
    $digits  = [char[]](48..57)
    $special = ([char[]](33..47) + [char[]](58..64) + [char[]](91..96) + [char[]](123..126)) | Where-Object { $_ -notin @('"','`','\') }
    $all     = $upper + $lower + $digits + $special

    # Garante pelo menos 1 de cada classe
    $pwd = @()
    $pwd += $upper   | Get-Random
    $pwd += $lower   | Get-Random
    $pwd += $digits  | Get-Random
    $pwd += $special | Get-Random

    # Completa ate o tamanho pedido
    while ($pwd.Count -lt $Length) {
        $pwd += $all | Get-Random
    }

    # Embaralha
    $shuffled = $pwd | Get-Random -Count $pwd.Count
    return -join $shuffled
}

# ---------------------------------------------------------------------------
# Le CSV (ignora linhas comentadas com #)
# ---------------------------------------------------------------------------
$rows = Import-Csv -Path $CsvPath -Encoding UTF8 |
    Where-Object { $_.SamAccountName -and -not $_.SamAccountName.StartsWith('#') }

if (-not $rows -or $rows.Count -eq 0) {
    throw "Nenhuma linha valida no CSV. Lembre de descomentar as linhas de exemplo (remover o # do inicio)."
}

Write-Host "Linhas validas no CSV: $($rows.Count)" -ForegroundColor Cyan
Write-Host ''

# ---------------------------------------------------------------------------
# Loop
# ---------------------------------------------------------------------------
$created    = 0
$existing   = 0
$errors     = 0
$logSenhas  = @()  # lista de [sam, senha] para impressao final

foreach ($row in $rows) {
    $fn  = $row.FirstName.Trim()
    $ln  = $row.LastName.Trim()
    $sam = $row.SamAccountName.Trim().ToLower()
    $upn = $row.UPN.Trim().ToLower()
    $tit = if ($row.Title) { $row.Title.Trim() } else { '' }
    $pwdIn = if ($row.Password) { $row.Password.Trim() } else { '' }

    $display = "$fn $ln"

    Write-Host "--- $sam ---" -ForegroundColor DarkCyan

    # Ja existe?
    $existingUser = Get-ADUser -LDAPFilter "(sAMAccountName=$sam)" -ErrorAction SilentlyContinue
    if ($existingUser) {
        Write-Host "  [EXISTE] Usuario $sam ja existe - pulando" -ForegroundColor Yellow
        $existing++
        continue
    }

    # Gera senha se vier vazia
    if ([string]::IsNullOrWhiteSpace($pwdIn)) {
        $pwd = New-RIOSenha -Length 16
        $pwdSource = 'generated'
    } else {
        $pwd = $pwdIn
        $pwdSource = 'csv'
    }

    if ($PSCmdlet.ShouldProcess($sam, "Criar usuario")) {
        try {
            $securePwd = ConvertTo-SecureString $pwd -AsPlainText -Force
            $params = @{
                Name                  = $display
                GivenName             = $fn
                Surname               = $ln
                SamAccountName        = $sam
                UserPrincipalName     = $upn
                DisplayName           = $display
                Path                  = $usuariosDn
                AccountPassword       = $securePwd
                Enabled               = $true
                ChangePasswordAtLogon = $true
                PasswordNeverExpires  = $false
                CannotChangePassword  = $false
                ErrorAction           = 'Stop'
            }
            if ($tit) { $params['Title'] = $tit }

            New-ADUser @params | Out-Null
            Write-Host "  [OK]      Usuario criado ($sam)" -ForegroundColor Green
            $created++

            # Adiciona ao grupo
            try {
                Add-ADGroupMember -Identity $grupoDn -Members $sam -ErrorAction Stop
                Write-Host "  [OK]      Adicionado ao G_Escritorio" -ForegroundColor Green
            } catch {
                Write-Warning "Falha ao adicionar $sam ao G_Escritorio : $_"
            }

            # Guarda a senha gerada para impressao final
            if ($pwdSource -eq 'generated') {
                $logSenhas += [pscustomobject]@{ Sam = $sam; Senha = $pwd }
            }
        } catch {
            Write-Warning "Falha ao criar $sam : $_"
            $errors++
        }
    }
}

# ---------------------------------------------------------------------------
# Resumo + senhas geradas
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '=== Resumo ===' -ForegroundColor Cyan
Write-Host ("Usuarios criados       : {0}" -f $created)   -ForegroundColor Green
Write-Host ("Ja existentes (pulados): {0}" -f $existing)  -ForegroundColor Yellow
Write-Host ("Erros                  : {0}" -f $errors)    -ForegroundColor Red
Write-Host ''

if ($logSenhas.Count -gt 0) {
    Write-Host '=== Senhas geradas (APENAS para este lote) ===' -ForegroundColor Magenta
    Write-Host 'Guarde em local seguro. NAO foram gravadas em log.' -ForegroundColor Magenta
    Write-Host ''
    foreach ($s in $logSenhas) {
        Write-Host ("  {0,-25} {1}" -f $s.Sam, $s.Senha) -ForegroundColor White
    }
    Write-Host ''
}

Write-Host 'Proximo passo: criar a pasta compartilhada' -ForegroundColor Cyan
Write-Host '   .\scripts\New-RIOCompartilhado.ps1' -ForegroundColor White
Write-Host ''
