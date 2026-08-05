<#
.SYNOPSIS
    Cria a estrutura minima de OUs e grupos para o escritorio RioMar (5 usuarios).

.DESCRIPTION
    Cria a arvore enxuta de OUs dentro de RIOMAR e os grupos minimos:
      - Computadores (vai receber os 5 PCs)
      - Usuarios (vai receber os 5 funcionarios)
      - Usuarios-Desativados (quarentena)
      - Clientes (vai receber 1 OU por cliente, opcional)
      - G_Escritorio (todos os usuarios do escritorio - acesso a pasta compartilhada)
      - GG_ADM_WORKSTATIONS (voce, admin local das estacoes)
      - GG_HELPDESK_RESET_PASSWORD (voce, resetar senhas)

    Pensado para escritorio PEQUENO (5 maquinas). Sem departments separados.

.PARAMETER DomainDn
    Distinguished Name do dominio. Padrao: DC=riomar,DC=contabilidade

.PARAMETER RootOuName
    Nome da OU raiz. Padrao: RIOMAR

.EXAMPLE
    PS C:\> .\New-RIOArvore.ps1 -WhatIf

.EXAMPLE
    PS C:\> .\New-RIOArvore.ps1 -Verbose

.NOTES
    Idempotente: re-rodar pula o que ja existe.
    Requer: RSAT ActiveDirectory, Domain Admin.
#>

#Requires -Modules ActiveDirectory

[CmdletBinding(SupportsShouldProcess = $true)]
param(
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

Write-Banner "New-RIOArvore - Estrutura minima do escritorio RioMar"

# ---------------------------------------------------------------------------
# Pre-check
# ---------------------------------------------------------------------------
$rootOuDn = "OU=$RootOuName,$DomainDn"
if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$rootOuDn)" -ErrorAction SilentlyContinue)) {
    throw "OU raiz '$rootOuDn' nao encontrada. Crie-a manualmente (Fase 7 do roteiro) ou ajuste -RootOuName."
}

# ---------------------------------------------------------------------------
# OUs (lista minima)
# ---------------------------------------------------------------------------
$ous = @(
    @{ Name = 'Computadores';         Parent = $RootOuName;   Desc = 'Estacoes do escritorio' }
    @{ Name = 'Usuarios';             Parent = $RootOuName;   Desc = 'Funcionarios do escritorio' }
    @{ Name = 'Usuarios-Desativados'; Parent = $RootOuName;   Desc = 'Quarentena de usuarios' }
    @{ Name = 'Clientes';             Parent = $RootOuName;   Desc = 'OUs por cliente (1 OU por empresa atendida)' }
)

function New-RIOLeafOu {
    param(
        [string]$Name,
        [string]$ParentDn
    )
    $dn = "OU=$Name,$ParentDn"
    $existing = Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$dn)" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "[EXISTE] OU $Name" -ForegroundColor Yellow
        return $existing
    }
    if ($PSCmdlet.ShouldProcess($dn, "Criar OU")) {
        New-ADOrganizationalUnit `
            -Name $Name `
            -Path $ParentDn `
            -Description $Desc `
            -ProtectedFromAccidentalDeletion $true `
            -ErrorAction Stop | Out-Null
        Write-Host "[OK]      OU $Name criada" -ForegroundColor Green
    }
}

$createdOu = 0
$existingOu = 0
foreach ($ou in $ous) {
    $parentDn = if ($ou.Parent -eq $RootOuName) { $rootOuDn } else { "OU=$($ou.Parent),$rootOuDn" }
    $Desc = $ou.Desc
    $before = if (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=OU=$($ou.Name),$parentDn)" -ErrorAction SilentlyContinue) { 1 } else { 0 }
    New-RIOLeafOu -Name $ou.Name -ParentDn $parentDn | Out-Null
    $after = if (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=OU=$($ou.Name),$parentDn)" -ErrorAction SilentlyContinue) { 1 } else { 0 }
    if ($before -eq 0 -and $after -eq 1) { $createdOu++ }
    if ($before -eq 1) { $existingOu++ }
}

# ---------------------------------------------------------------------------
# Grupos
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '--- Criando grupos ---' -ForegroundColor Cyan

$gruposDn = "OU=Computadores,$rootOuDn"

# Estes grupos vao dentro da OU Computadores (convencao) - mas como nao criamos
# OU=Grupos separada, vamos colocar na OU Usuarios para simplicidade.
$containerGruposDn = "OU=Usuarios,$rootOuDn"

$grupos = @{
    'G_Escritorio'              = 'Todos os usuarios do escritorio - acesso a pasta compartilhada'
    'GG_ADM_WORKSTATIONS'       = 'Admin local das estacoes (voce)'
    'GG_HELPDESK_RESET_PASSWORD'= 'Permissao para resetar senhas de usuarios'
}

$createdGrp = 0
$existingGrp = 0
foreach ($gn in $grupos.Keys) {
    $gDesc = $grupos[$gn]
    $gDn   = "CN=$gn,$containerGruposDn"
    $existing = Get-ADGroup -LDAPFilter "(distinguishedName=$gDn)" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "[EXISTE] Grupo $gn" -ForegroundColor Yellow
        $existingGrp++
        continue
    }
    if ($PSCmdlet.ShouldProcess($gDn, "Criar grupo $gn")) {
        try {
            New-ADGroup `
                -Name $gn `
                -SamAccountName $gn `
                -GroupCategory Security `
                -GroupScope Global `
                -DisplayName $gn `
                -Description $gDesc `
                -Path $containerGruposDn `
                -ErrorAction Stop | Out-Null
            Write-Host "[OK]      Grupo $gn criado" -ForegroundColor Green
            $createdGrp++
        } catch {
            Write-Warning "Falha ao criar grupo $gn : $_"
        }
    }
}

# ---------------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '=== Resumo ===' -ForegroundColor Cyan
Write-Host ("OUs criadas        : {0}" -f $createdOu)  -ForegroundColor Green
Write-Host ("OUs ja existentes  : {0}" -f $existingOu) -ForegroundColor Yellow
Write-Host ("Grupos criados     : {0}" -f $createdGrp)  -ForegroundColor Green
Write-Host ("Grupos existentes  : {0}" -f $existingGrp) -ForegroundColor Yellow
Write-Host ''
Write-Host 'Proximo passo: criar a pasta compartilhada' -ForegroundColor Cyan
Write-Host '   .\scripts\New-RIOCompartilhado.ps1' -ForegroundColor White
Write-Host ''
