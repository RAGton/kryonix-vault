<#
.SYNOPSIS
    Instala o AD DS e cria a primeira floresta a partir do arquivo de configuracao.

.DESCRIPTION
    Fase destrutiva e com reinicializacao. Execute primeiro com -WhatIf e somente
    depois de validar nome DNS, NetBIOS, IP estatico, DNS, horario e backup.
    A senha DSRM e solicitada de forma mascarada e nunca deve ser gravada no script.

.EXAMPLE
    .\Install-CompanyADForest.ps1 -ConfigPath ..\templates\company-config.psd1 -WhatIf

.EXAMPLE
    .\Install-CompanyADForest.ps1 -ConfigPath ..\templates\company-config.psd1
#>

#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ConfigPath,

    [System.Security.SecureString]$SafeModeAdministratorPassword,

    [switch]$NoRebootOnCompletion
)

$ErrorActionPreference = 'Stop'
$config = Import-PowerShellDataFile -LiteralPath $ConfigPath

$domainName = [string]$config.DomainDnsName
$netbiosName = [string]$config.DomainNetBIOSName

if ($domainName -notmatch '^(?=.{1,253}$)(?!-)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$') {
    throw "DomainDnsName invalido: '$domainName'. Use um FQDN, por exemplo ad.empresa.com.br."
}
if ($netbiosName -notmatch '^[A-Za-z0-9][A-Za-z0-9-]{0,14}$') {
    throw "DomainNetBIOSName invalido: '$netbiosName'. Use 1-15 caracteres sem acentos."
}

Write-Host ''
Write-Host '=== Plano de criacao da floresta AD DS ===' -ForegroundColor Cyan
Write-Host "Dominio DNS : $domainName"
Write-Host "NetBIOS     : $netbiosName"
Write-Host "Servidor    : $env:COMPUTERNAME"
Write-Host "Reiniciar   : $(-not $NoRebootOnCompletion)"
Write-Host ''

if ($WhatIfPreference) {
    Write-Host '[WHATIF] Instalaria AD-Domain-Services, executaria o pre-check e promoveria este servidor.' -ForegroundColor Yellow
    return
}

$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
if ($computerSystem.DomainRole -in @(4, 5)) {
    throw "Este servidor ja e um controlador de dominio (DomainRole=$($computerSystem.DomainRole))."
}
if ($computerSystem.PartOfDomain) {
    throw "Este servidor ja pertence ao dominio '$($computerSystem.Domain)'. Para adicionar um DC a uma floresta existente, use Install-ADDSDomainController, nao este script."
}

$feature = Get-WindowsFeature -Name AD-Domain-Services
if (-not $feature.Installed) {
    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Instalar a funcao AD Domain Services e ferramentas de gerenciamento')) {
        $result = Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
        if (-not $result.Success) {
            throw 'A instalacao da funcao AD-Domain-Services falhou.'
        }
    }
}

Import-Module ADDSDeployment -ErrorAction Stop

if (-not $SafeModeAdministratorPassword) {
    $SafeModeAdministratorPassword = Read-Host 'Digite a senha DSRM (sera mascarada)' -AsSecureString
}

$testParams = @{
    DomainName                   = $domainName
    DomainNetbiosName            = $netbiosName
    InstallDns                   = $true
    SafeModeAdministratorPassword = $SafeModeAdministratorPassword
}

Write-Host 'Executando Test-ADDSForestInstallation...' -ForegroundColor Cyan
Test-ADDSForestInstallation @testParams

if ($PSCmdlet.ShouldProcess("$env:COMPUTERNAME -> $domainName", 'Promover como primeiro controlador da nova floresta')) {
    Install-ADDSForest @testParams `
        -NoRebootOnCompletion:$NoRebootOnCompletion `
        -Force:$true
}
