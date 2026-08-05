<#
.SYNOPSIS
    Executa verificacoes basicas de saude e de conformidade estrutural do baseline.

.DESCRIPTION
    Nao altera o ambiente. Falhas estruturais retornam exit code 1. Alertas de
    resiliência/seguranca exigem decisao humana e nao sao mascarados como sucesso.

.EXAMPLE
    .\Test-CompanyADBaseline.ps1 -ConfigPath ..\templates\company-config.psd1
#>

#Requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ConfigPath
)

$ErrorActionPreference = 'Continue'
$config = Import-PowerShellDataFile -LiteralPath $ConfigPath
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Pass([string]$Message) { Write-Host "[PASS] $Message" -ForegroundColor Green }
function Fail([string]$Message) { $script:failures.Add($Message); Write-Host "[FAIL] $Message" -ForegroundColor Red }
function Warn([string]$Message) { $script:warnings.Add($Message); Write-Host "[WARN] $Message" -ForegroundColor Yellow }

try {
    $domain = Get-ADDomain -Identity $config.DomainDnsName
    Pass "Dominio acessivel: $($domain.DNSRoot)"
} catch {
    Fail "Dominio inacessivel: $_"
    exit 1
}

$rootOuDn = "OU=$($config.RootOuName),$($domain.DistinguishedName)"
$expectedOus = @($config.RootOuName) + @($config.OUs)
foreach ($ouName in $expectedOus) {
    $dn = if ($ouName -eq $config.RootOuName) { $rootOuDn } else { "OU=$ouName,$rootOuDn" }
    if (Get-ADOrganizationalUnit -Identity $dn -ErrorAction SilentlyContinue) {
        Pass "OU existe: $dn"
    } else {
        Fail "OU ausente: $dn"
    }
}

$groupNames = @(
    $config.Groups.AllUsersGlobal
    $config.Groups.WorkstationAdminsGlobal
    $config.Groups.HelpdeskPasswordResetGlobal
    $config.Groups.DefaultShareModifyDomainLocal
)
foreach ($groupName in $groupNames) {
    if (Get-ADGroup -Identity $groupName -ErrorAction SilentlyContinue) {
        Pass "Grupo existe: $groupName"
    } else {
        Fail "Grupo ausente: $groupName"
    }
}

try {
    $records = Resolve-DnsName "_ldap._tcp.dc._msdcs.$($domain.DNSRoot)" -Type SRV -ErrorAction Stop
    if ($records) { Pass 'Registros SRV LDAP encontrados no DNS' }
} catch {
    Fail "Falha nos registros SRV do AD DNS: $_"
}

$dcs = @(Get-ADDomainController -Filter *)
if ($dcs.Count -ge 2) {
    Pass "Resiliencia: $($dcs.Count) controladores de dominio"
} else {
    Warn 'Existe somente um controlador de dominio: ha ponto unico de falha.'
}

$recycleBin = Get-ADOptionalFeature -Filter 'Name -like "Recycle Bin Feature"' |
    Where-Object EnabledScopes
if ($recycleBin) {
    Pass 'Active Directory Recycle Bin habilitada'
} else {
    Warn 'Active Directory Recycle Bin desabilitada; habilitacao e irreversivel e deve ser planejada.'
}

Write-Host ''
Write-Host 'Politica efetiva de senha do dominio:' -ForegroundColor Cyan
Get-ADDefaultDomainPasswordPolicy | Format-List MinPasswordLength, ComplexityEnabled, LockoutThreshold, LockoutDuration, MaxPasswordAge | Out-Host

if (Get-Command dcdiag.exe -ErrorAction SilentlyContinue) {
    & dcdiag.exe /q
    if ($LASTEXITCODE -eq 0) { Pass 'dcdiag /q sem falhas' } else { Fail "dcdiag retornou codigo $LASTEXITCODE" }
} else {
    Warn 'dcdiag.exe nao esta disponivel neste host; execute em um DC ou instale RSAT.'
}

if ($dcs.Count -ge 2 -and (Get-Command repadmin.exe -ErrorAction SilentlyContinue)) {
    & repadmin.exe /replsummary
    if ($LASTEXITCODE -eq 0) { Pass 'repadmin /replsummary sem falhas' } else { Fail "repadmin retornou codigo $LASTEXITCODE" }
}

Write-Host ''
Write-Host "Falhas: $($failures.Count) | Alertas: $($warnings.Count)" -ForegroundColor Cyan
if ($warnings.Count -gt 0) {
    Write-Host 'Alertas exigem registro de risco ou correcao; nao equivalem a conformidade.' -ForegroundColor Yellow
}
if ($failures.Count -gt 0) { exit 1 }
exit 0
