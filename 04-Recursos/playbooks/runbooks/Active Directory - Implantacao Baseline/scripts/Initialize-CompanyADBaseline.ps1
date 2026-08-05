<#
.SYNOPSIS
    Cria a arvore baseline de OUs e grupos de seguranca de uma empresa.

.DESCRIPTION
    Idempotente para objetos ja criados. Nao delega privilegios administrativos,
    nao cria GPO e, por padrao, nao concede acesso ao compartilhamento.

.EXAMPLE
    .\Initialize-CompanyADBaseline.ps1 -ConfigPath ..\templates\company-config.psd1 -WhatIf
#>

#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'
$config = Import-PowerShellDataFile -LiteralPath $ConfigPath

$domainName = [string]$config.DomainDnsName
$rootOuName = [string]$config.RootOuName
$companyName = [string]$config.CompanyDisplayName

if ($rootOuName -notmatch '^[A-Za-z0-9][A-Za-z0-9 _-]{0,63}$') {
    throw "RootOuName invalido: '$rootOuName'. Use nome curto, sem acentos ou caracteres especiais."
}

$domain = Get-ADDomain -Identity $domainName
$domainDn = $domain.DistinguishedName
$rootOuDn = "OU=$rootOuName,$domainDn"
$groupsOuDn = "OU=Grupos,$rootOuDn"

function Get-ExistingOu {
    param([string]$DistinguishedName)
    Get-ADOrganizationalUnit -Identity $DistinguishedName -ErrorAction SilentlyContinue
}

function Ensure-OrganizationalUnit {
    param(
        [string]$Name,
        [string]$ParentDn,
        [string]$Description
    )

    $dn = "OU=$Name,$ParentDn"
    $existing = Get-ExistingOu -DistinguishedName $dn
    if ($existing) {
        Write-Host "[EXISTE] OU $dn" -ForegroundColor Yellow
        return
    }

    if ($PSCmdlet.ShouldProcess($dn, 'Criar OU protegida contra exclusao acidental')) {
        New-ADOrganizationalUnit `
            -Name $Name `
            -Path $ParentDn `
            -Description $Description `
            -ProtectedFromAccidentalDeletion $true | Out-Null
        Write-Host "[OK] OU $dn" -ForegroundColor Green
    }
}

function Ensure-SecurityGroup {
    param(
        [string]$SamAccountName,
        [ValidateSet('Global', 'DomainLocal')]
        [string]$Scope,
        [string]$Description
    )

    if ($SamAccountName -notmatch '^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$') {
        throw "Nome de grupo invalido: '$SamAccountName'."
    }

    $existing = Get-ADGroup -Identity $SamAccountName -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.GroupScope -ne $Scope -or $existing.GroupCategory -ne 'Security') {
            throw "Grupo '$SamAccountName' existe com tipo/escopo diferente do esperado ($Scope/Security)."
        }
        $expectedDn = "CN=$SamAccountName,$groupsOuDn"
        if ($existing.DistinguishedName -ne $expectedDn) {
            throw "Grupo '$SamAccountName' existe fora de '$groupsOuDn'. Revise manualmente; o script nao move objetos."
        }
        Write-Host "[EXISTE] Grupo $SamAccountName" -ForegroundColor Yellow
        return
    }

    if ($PSCmdlet.ShouldProcess($SamAccountName, "Criar grupo de seguranca $Scope")) {
        New-ADGroup `
            -Name $SamAccountName `
            -SamAccountName $SamAccountName `
            -GroupCategory Security `
            -GroupScope $Scope `
            -Path $groupsOuDn `
            -Description $Description | Out-Null
        Write-Host "[OK] Grupo $SamAccountName" -ForegroundColor Green
    }
}

Write-Host "Inicializando baseline de '$companyName' em '$domainName'..." -ForegroundColor Cyan

Ensure-OrganizationalUnit -Name $rootOuName -ParentDn $domainDn -Description "OU raiz gerenciada de $companyName"

foreach ($ouName in $config.OUs) {
    if ($ouName -notmatch '^[A-Za-z0-9][A-Za-z0-9 _-]{0,63}$') {
        throw "Nome de OU invalido na configuracao: '$ouName'."
    }
    Ensure-OrganizationalUnit -Name $ouName -ParentDn $rootOuDn -Description "$ouName - $companyName"
}

$g = $config.Groups
Ensure-SecurityGroup -SamAccountName $g.AllUsersGlobal -Scope Global -Description 'Contas de usuarios comuns habilitadas'
Ensure-SecurityGroup -SamAccountName $g.WorkstationAdminsGlobal -Scope Global -Description 'Operadores autorizados a administrar estacoes; requer GPO separada'
Ensure-SecurityGroup -SamAccountName $g.HelpdeskPasswordResetGlobal -Scope Global -Description 'Operadores de reset de senha; requer delegacao separada na OU Usuarios'
Ensure-SecurityGroup -SamAccountName $g.DefaultShareModifyDomainLocal -Scope DomainLocal -Description 'Permissao Modify no compartilhamento padrao'

if ([bool]$config.NestAllUsersInDefaultShare) {
    $allUsers = Get-ADGroup -Identity $g.AllUsersGlobal -ErrorAction SilentlyContinue
    $shareModify = Get-ADGroup -Identity $g.DefaultShareModifyDomainLocal -ErrorAction SilentlyContinue
    if ($allUsers -and $shareModify) {
        $alreadyMember = Get-ADGroupMember -Identity $shareModify.DistinguishedName |
            Where-Object DistinguishedName -eq $allUsers.DistinguishedName
        if (-not $alreadyMember -and $PSCmdlet.ShouldProcess($shareModify.SamAccountName, "Adicionar $($allUsers.SamAccountName)")) {
            Add-ADGroupMember -Identity $shareModify.DistinguishedName -Members $allUsers.DistinguishedName
            Write-Host "[OK] $($allUsers.SamAccountName) -> $($shareModify.SamAccountName)" -ForegroundColor Green
        }
    }
} else {
    Write-Host '[SEGURO] O grupo de todos os usuarios NAO foi aninhado no compartilhamento.' -ForegroundColor Cyan
}

Write-Host ''
Write-Host 'IMPORTANTE:' -ForegroundColor Magenta
Write-Host "- $($g.HelpdeskPasswordResetGlobal) ainda nao possui delegacao; use o Delegation of Control Wizard na OU Usuarios."
Write-Host "- $($g.WorkstationAdminsGlobal) ainda nao e administrador local; aplique por GPO somente nas estacoes."
Write-Host '- Grupos vazios nao concedem acesso por si so.'
