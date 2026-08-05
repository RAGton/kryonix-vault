<#
.SYNOPSIS
    Cria um compartilhamento SMB com ACL minima baseada em grupo Domain Local.

.DESCRIPTION
    Deve rodar preferencialmente em um servidor de arquivos membro, nao no DC.
    Para pastas existentes, exige -ApplyAclToExistingFolder para evitar substituir
    permissoes por acidente. A ACL e montada em memoria e aplicada uma unica vez.

.EXAMPLE
    .\New-CompanyFileShare.ps1 -ConfigPath ..\templates\company-config.psd1 -WhatIf
#>

#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory, SmbShare

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ConfigPath,

    [switch]$ApplyAclToExistingFolder,

    [switch]$AllowOnDomainController
)

$ErrorActionPreference = 'Stop'
$config = Import-PowerShellDataFile -LiteralPath $ConfigPath
$domain = Get-ADDomain -Identity $config.DomainDnsName
$shareConfig = $config.FileShare
$folderPath = [string]$shareConfig.FolderPath
$shareName = [string]$shareConfig.ShareName
$accessGroup = Get-ADGroup -Identity $config.Groups.DefaultShareModifyDomainLocal

if ($shareConfig.ServerName -and $env:COMPUTERNAME -ne [string]$shareConfig.ServerName) {
    throw "Servidor incorreto: o template espera '$($shareConfig.ServerName)', mas o script esta rodando em '$env:COMPUTERNAME'."
}

$domainRole = (Get-CimInstance -ClassName Win32_ComputerSystem).DomainRole
if ($domainRole -in @(4, 5) -and -not $AllowOnDomainController) {
    throw 'Este servidor e um controlador de dominio. Use um servidor de arquivos membro ou passe -AllowOnDomainController aceitando explicitamente o risco.'
}

function Resolve-WellKnownAccount {
    param([string]$Sid)
    $sidObject = New-Object System.Security.Principal.SecurityIdentifier($Sid)
    return $sidObject.Translate([System.Security.Principal.NTAccount]).Value
}

$systemAccount = Resolve-WellKnownAccount -Sid 'S-1-5-18'
$administratorsAccount = Resolve-WellKnownAccount -Sid 'S-1-5-32-544'
$domainGroupAccount = "$($domain.NetBIOSName)\$($accessGroup.SamAccountName)"

$folderExisted = Test-Path -LiteralPath $folderPath -PathType Container
if ($folderExisted -and -not $ApplyAclToExistingFolder) {
    throw "A pasta '$folderPath' ja existe. Revise seu conteudo/ACL e repita com -ApplyAclToExistingFolder somente se deseja substituir a ACL da raiz."
}

if (-not $folderExisted -and $PSCmdlet.ShouldProcess($folderPath, 'Criar diretorio do compartilhamento')) {
    New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
}

$canApplyAcl = (Test-Path -LiteralPath $folderPath -PathType Container)
if ($canApplyAcl -and $PSCmdlet.ShouldProcess($folderPath, "Aplicar ACL minima; $domainGroupAccount = Modify")) {
    $acl = New-Object System.Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    $acl.SetOwner((New-Object System.Security.Principal.NTAccount($administratorsAccount)))

    $inheritance = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'
    $propagation = [System.Security.AccessControl.PropagationFlags]::None
    $allow = [System.Security.AccessControl.AccessControlType]::Allow

    $rules = @(
        New-Object System.Security.AccessControl.FileSystemAccessRule($systemAccount, 'FullControl', $inheritance, $propagation, $allow)
        New-Object System.Security.AccessControl.FileSystemAccessRule($administratorsAccount, 'FullControl', $inheritance, $propagation, $allow)
        New-Object System.Security.AccessControl.FileSystemAccessRule($domainGroupAccount, 'Modify', $inheritance, $propagation, $allow)
    )
    foreach ($rule in $rules) {
        [void]$acl.AddAccessRule($rule)
    }
    Set-Acl -LiteralPath $folderPath -AclObject $acl
}

$existingShare = Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue
if ($existingShare) {
    if ([System.IO.Path]::GetFullPath($existingShare.Path) -ne [System.IO.Path]::GetFullPath($folderPath)) {
        throw "O compartilhamento '$shareName' ja aponta para '$($existingShare.Path)', nao para '$folderPath'."
    }
    Write-Host "[EXISTE] \\$env:COMPUTERNAME\$shareName" -ForegroundColor Yellow
    Get-SmbShareAccess -Name $shareName | Format-Table -AutoSize | Out-Host
} elseif ($canApplyAcl -and $PSCmdlet.ShouldProcess($shareName, "Criar compartilhamento SMB em $folderPath")) {
    New-SmbShare `
        -Name $shareName `
        -Path $folderPath `
        -FullAccess $administratorsAccount `
        -ChangeAccess $domainGroupAccount `
        -FolderEnumerationMode AccessBased `
        -EncryptData:([bool]$shareConfig.EncryptData) `
        -Description "Compartilhamento gerenciado - $($config.CompanyDisplayName)" | Out-Null
    Write-Host "[OK] \\$env:COMPUTERNAME\$shareName" -ForegroundColor Green
}

Write-Host "Acesso de escrita: $domainGroupAccount" -ForegroundColor Cyan
Write-Host 'Adicione grupos globais de funcao a esse grupo Domain Local; nao atribua usuarios diretamente na ACL.' -ForegroundColor Cyan
