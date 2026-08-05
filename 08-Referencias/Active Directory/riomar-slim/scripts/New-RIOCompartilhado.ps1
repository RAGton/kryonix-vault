<#
.SYNOPSIS
    Cria a pasta compartilhada "Escritorio" e da acesso ao grupo G_Escritorio.

.DESCRIPTION
    Para o escritorio pequeno com 5 maquinas, uma unica pasta compartilhada
    resolve o trabalho do dia-a-dia (subpastas por assunto/mes dentro dela).

    Este script:
      1. Cria o diretorio D:\Escritorio (ou -FolderPath customizado)
      2. Cria o compartilhamento SMB "Escritorio$" (hidden share, $-suffix)
      3. Define permissoes NTFS:
         - SYSTEM: Full Control
         - Administrators: Full Control
         - G_Escritorio: Modify (criar, editar, deletar)
         - CREATOR OWNER: Full Control (subfolders/files only)
      4. Define permissoes de share:
         - Administrators: Full Control
         - G_Escritorio: Change (read/write)

.PARAMETER FolderPath
    Caminho local da pasta. Padrao: D:\Escritorio

.PARAMETER ShareName
    Nome do compartilhamento. Padrao: Escritorio$  (com $ = hidden)

.PARAMETER DomainDn
    Distinguished Name do dominio. Padrao: DC=riomar,DC=contabilidade

.PARAMETER RootOuName
    Nome da OU raiz. Padrao: RIOMAR

.EXAMPLE
    PS C:\> .\New-RIOCompartilhado.ps1 -WhatIf

.EXAMPLE
    PS C:\> .\New-RIOCompartilhado.ps1 -Verbose

.EXAMPLE
    PS C:\> .\New-RIOCompartilhado.ps1 -FolderPath 'E:\Compartilhado' -ShareName 'Rede$'

.NOTES
    Roda direto no servidor que vai hospedar a pasta (geralmente o DC).
    Requer: administrador local + Domain Admin (para resolver G_Escritorio).
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$FolderPath   = 'D:\Escritorio',
    [string]$ShareName    = 'Escritorio$',
    [string]$DomainDn     = 'DC=riomar,DC=contabilidade',
    [string]$RootOuName   = 'RIOMAR'
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

Write-Banner "New-RIOCompartilhado - Cria a pasta Escritorio"

# ---------------------------------------------------------------------------
# Pre-checks
# ---------------------------------------------------------------------------
$rootOuDn   = "OU=$RootOuName,$DomainDn"
$grupoDn    = "CN=G_Escritorio,OU=Usuarios,$rootOuDn"
$grupoName  = 'G_Escritorio'

# Grupo existe no AD?
$grupo = Get-ADGroup -LDAPFilter "(distinguishedName=$grupoDn)" -ErrorAction SilentlyContinue
if (-not $grupo) {
    throw "Grupo '$grupoName' nao encontrado no AD. Rode New-RIOArvore.ps1 antes."
}

# Verifica se a unidade alvo existe (D:, E:, etc.)
$driveLetter = ($FolderPath -split ':')[0] + ':'
if (-not (Get-PSDrive -Name $driveLetter.TrimEnd(':') -ErrorAction SilentlyContinue)) {
    Write-Warning "A unidade ${driveLetter} nao existe neste servidor."
    Write-Warning "Voce pode passar -FolderPath para apontar para outra unidade."
    Write-Warning "Ex: -FolderPath 'C:\Escritorio' (sem D:)"
    throw "Unidade ${driveLetter} nao disponivel."
}

# ---------------------------------------------------------------------------
# Cria o diretorio
# ---------------------------------------------------------------------------
if (Test-Path $FolderPath) {
    Write-Host "[EXISTE] Diretorio $FolderPath" -ForegroundColor Yellow
} else {
    if ($PSCmdlet.ShouldProcess($FolderPath, "Criar diretorio")) {
        New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
        Write-Host "[OK]      Diretorio $FolderPath criado" -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------------
# Cria o compartilhamento SMB
# ---------------------------------------------------------------------------
$share = Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue
if ($share) {
    Write-Host "[EXISTE] Compartilhamento \\$($env:COMPUTERNAME)\$ShareName" -ForegroundColor Yellow
} else {
    if ($PSCmdlet.ShouldProcess($ShareName, "Criar compartilhamento SMB")) {
        try {
            New-SmbShare `
                -Name $ShareName `
                -Path $FolderPath `
                -FullAccess 'Administrators' `
                -ChangeAccess "$($env:USERDOMAIN)\$grupoName" `
                -ReadAccess 'Authenticated Users' `
                -Description 'Pasta compartilhada do escritorio RioMar' `
                -ErrorAction Stop | Out-Null
            Write-Host "[OK]      Compartilhamento $ShareName criado" -ForegroundColor Green
        } catch {
            throw "Falha ao criar compartilhamento: $_"
        }
    }
}

# ---------------------------------------------------------------------------
# Permissoes NTFS
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '--- Aplicando permissoes NTFS ---' -ForegroundColor Cyan

# Remove permissoes herdadas para ter controle total
if ($PSCmdlet.ShouldProcess($FolderPath, "Desabilitar heranca de permissoes")) {
    try {
        $acl = Get-Acl $FolderPath
        $acl.SetAccessRuleProtection($true, $false)
        $acl | Set-Acl $FolderPath
        Write-Host "[OK]      Heranca desabilitada" -ForegroundColor Green
    } catch {
        Write-Warning "Nao foi possivel desabilitar heranca (pode ser ja desabilitada): $_"
    }
}

# Re-aplica as 4 regras canonicas
$rules = @(
    # SYSTEM: Full Control (em tudo)
    [pscustomobject]@{
        Id     = 'SYSTEM'
        Rights = 'FullControl'
        Type   = 'Allow'
        Inh    = 'ContainerInherit, ObjectInherit'
        Prop   = 'None'
    }
    # Administrators: Full Control
    [pscustomobject]@{
        Id     = 'BUILTIN\Administrators'
        Rights = 'FullControl'
        Type   = 'Allow'
        Inh    = 'ContainerInherit, ObjectInherit'
        Prop   = 'None'
    }
    # G_Escritorio: Modify (criar, editar, deletar arquivos)
    [pscustomobject]@{
        Id     = "$($env:USERDOMAIN)\$grupoName"
        Rights = 'Modify'
        Type   = 'Allow'
        Inh    = 'ContainerInherit, ObjectInherit'
        Prop   = 'None'
    }
    # CREATOR OWNER: Full Control em subpastas/arquivos (para o dono poder mover/renomear)
    [pscustomobject]@{
        Id     = 'CREATOR OWNER'
        Rights = 'FullControl'
        Type   = 'Allow'
        Inh    = 'ContainerInherit, ObjectInherit'
        Prop   = 'InheritOnly'
    }
)

foreach ($r in $rules) {
    if ($PSCmdlet.ShouldProcess($FolderPath, "Aplicar permissao $($r.Id) = $($r.Rights)")) {
        try {
            $ace = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $r.Id, $r.Rights, $r.Inh, $r.Prop, $r.Type
            )
            $acl = Get-Acl $FolderPath
            # Remove regra antiga desse mesmo Id se existir
            $acl.Access | Where-Object { $_.IdentityReference.Value -eq $r.Id } | ForEach-Object {
                $acl.RemoveAccessRule($_) | Out-Null
            }
            $acl.AddAccessRule($ace)
            $acl | Set-Acl $FolderPath
            Write-Host "  [OK]      $($r.Id) = $($r.Rights)" -ForegroundColor Green
        } catch {
            Write-Warning "Falha ao aplicar permissao $($r.Id) : $_"
        }
    }
}

# ---------------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '=== Pronto ===' -ForegroundColor Cyan
Write-Host ''
Write-Host "Caminho local:  $FolderPath" -ForegroundColor White
Write-Host "Compartilhado:  \\$($env:COMPUTERNAME)\$ShareName" -ForegroundColor White
Write-Host "Acesso:         $grupoName = Modify" -ForegroundColor White
Write-Host ''
Write-Host 'Para acessar das estacoes:' -ForegroundColor Cyan
Write-Host '  Win+R  ->  \\RIO-SRV-ADDS\Escritorio$' -ForegroundColor White
Write-Host '  (share oculto - nao aparece em "Network")' -ForegroundColor DarkGray
Write-Host ''
Write-Host 'Para mapear como unidade de rede (opcional, em cada estacao):' -ForegroundColor Cyan
Write-Host '  net use E: \\RIO-SRV-ADDS\Escritorio$ /persistent:yes' -ForegroundColor White
Write-Host ''
