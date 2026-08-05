<#
.SYNOPSIS
    Importa usuarios de CSV sem aceitar senhas em texto claro no arquivo.

.DESCRIPTION
    Linhas so sao processadas quando Enabled=true. A senha inicial e gerada com
    RNG criptografico ou solicitada de forma mascarada. Usuarios existentes nao
    sao alterados; apenas a associacao ao grupo baseline e reconciliada.

.EXAMPLE
    .\Import-CompanyADUsers.ps1 -ConfigPath ..\templates\company-config.psd1 -CsvPath ..\templates\users.csv -WhatIf

.EXAMPLE
    .\Import-CompanyADUsers.ps1 -ConfigPath ..\templates\company-config.psd1 -CsvPath .\usuarios-reais.csv -PasswordMode Generate
#>

#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ConfigPath,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$CsvPath,

    [ValidateSet('Generate', 'Prompt')]
    [string]$PasswordMode = 'Generate',

    [ValidateRange(16, 128)]
    [int]$GeneratedPasswordLength = 20
)

$ErrorActionPreference = 'Stop'
$config = Import-PowerShellDataFile -LiteralPath $ConfigPath
$domain = Get-ADDomain -Identity $config.DomainDnsName
$forest = Get-ADForest -Identity $domain.Forest
$allowedUpnSuffixes = @($domain.DNSRoot) + @($forest.UPNSuffixes) |
    Where-Object { $_ } |
    ForEach-Object { $_.ToLowerInvariant() } |
    Select-Object -Unique
$rootOuDn = "OU=$($config.RootOuName),$($domain.DistinguishedName)"
$usersOuDn = "OU=Usuarios,$rootOuDn"
$defaultGroup = Get-ADGroup -Identity $config.Groups.AllUsersGlobal

if (-not (Get-ADOrganizationalUnit -Identity $usersOuDn -ErrorAction SilentlyContinue)) {
    throw "OU de usuarios nao encontrada: $usersOuDn. Execute Initialize-CompanyADBaseline.ps1."
}

$requiredHeaders = @('Enabled', 'FirstName', 'LastName', 'SamAccountName', 'UserPrincipalName', 'Title', 'Department')
$header = (Get-Content -LiteralPath $CsvPath -TotalCount 1) -split ','
$missingHeaders = $requiredHeaders | Where-Object { $_ -notin $header }
if ($missingHeaders) {
    throw "CSV sem cabecalhos obrigatorios: $($missingHeaders -join ', ')."
}

function Get-SecureRandomIndex {
    param(
        [System.Security.Cryptography.RandomNumberGenerator]$Rng,
        [int]$UpperExclusive
    )

    if ($UpperExclusive -lt 1 -or $UpperExclusive -gt 256) {
        throw 'UpperExclusive deve estar entre 1 e 256.'
    }

    $buffer = New-Object byte[] 1
    $limit = 256 - (256 % $UpperExclusive)
    do {
        $Rng.GetBytes($buffer)
    } while ([int]$buffer[0] -ge $limit)
    return ([int]$buffer[0] % $UpperExclusive)
}

function New-CryptographicPassword {
    param([int]$Length)

    $sets = @(
        'ABCDEFGHJKLMNPQRSTUVWXYZ'.ToCharArray(),
        'abcdefghijkmnopqrstuvwxyz'.ToCharArray(),
        '23456789'.ToCharArray(),
        '!@#$%*-_=+?'.ToCharArray()
    )
    $all = ($sets | ForEach-Object { $_ })
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

    try {
        $chars = New-Object System.Collections.Generic.List[char]
        foreach ($set in $sets) {
            $chars.Add($set[(Get-SecureRandomIndex -Rng $rng -UpperExclusive $set.Count)])
        }
        while ($chars.Count -lt $Length) {
            $chars.Add($all[(Get-SecureRandomIndex -Rng $rng -UpperExclusive $all.Count)])
        }

        for ($i = $chars.Count - 1; $i -gt 0; $i--) {
            $j = Get-SecureRandomIndex -Rng $rng -UpperExclusive ($i + 1)
            $tmp = $chars[$i]
            $chars[$i] = $chars[$j]
            $chars[$j] = $tmp
        }
        return -join $chars
    } finally {
        $rng.Dispose()
    }
}

function Ensure-DirectGroupMembership {
    param(
        [Microsoft.ActiveDirectory.Management.ADUser]$User,
        [Microsoft.ActiveDirectory.Management.ADGroup]$Group
    )

    $member = Get-ADGroupMember -Identity $Group.DistinguishedName |
        Where-Object DistinguishedName -eq $User.DistinguishedName
    if (-not $member -and $PSCmdlet.ShouldProcess($Group.SamAccountName, "Adicionar $($User.SamAccountName)")) {
        Add-ADGroupMember -Identity $Group.DistinguishedName -Members $User.DistinguishedName
        Write-Host "  [OK] Associado a $($Group.SamAccountName)" -ForegroundColor Green
    }
}

$rows = Import-Csv -LiteralPath $CsvPath -Encoding UTF8
$enabledRows = @($rows | Where-Object { $_.Enabled.Trim().ToLowerInvariant() -eq 'true' })
if ($enabledRows.Count -eq 0) {
    throw 'Nenhuma linha com Enabled=true. O modelo vem desabilitado por seguranca.'
}

$generated = New-Object System.Collections.Generic.List[object]
$created = 0
$existing = 0
$errors = 0

foreach ($row in $enabledRows) {
    $first = $row.FirstName.Trim()
    $last = $row.LastName.Trim()
    $sam = $row.SamAccountName.Trim().ToLowerInvariant()
    $upn = $row.UserPrincipalName.Trim().ToLowerInvariant()
    $title = $row.Title.Trim()
    $department = $row.Department.Trim()

    if (-not $first -or -not $last) {
        Write-Warning 'Linha ignorada: FirstName e LastName sao obrigatorios.'
        $errors++
        continue
    }
    if ($sam -notmatch '^[a-z0-9][a-z0-9._-]{0,19}$') {
        Write-Warning "SamAccountName invalido: '$sam'."
        $errors++
        continue
    }
    if ($upn -notmatch '^[^@\s]+@[^@\s]+$') {
        Write-Warning "UserPrincipalName invalido para '$sam': '$upn'."
        $errors++
        continue
    }
    $upnSuffix = ($upn -split '@', 2)[1]
    if ($upnSuffix -notin $allowedUpnSuffixes) {
        Write-Warning "Sufixo UPN '$upnSuffix' nao esta configurado na floresta. Permitidos: $($allowedUpnSuffixes -join ', ')."
        $errors++
        continue
    }

    $existingUser = Get-ADUser -Identity $sam -ErrorAction SilentlyContinue
    if ($existingUser) {
        Write-Host "[EXISTE] $sam; atributos nao serao sobrescritos." -ForegroundColor Yellow
        Ensure-DirectGroupMembership -User $existingUser -Group $defaultGroup
        $existing++
        continue
    }

    if (-not $PSCmdlet.ShouldProcess($sam, "Criar usuario em $usersOuDn")) {
        continue
    }

    try {
        if ($PasswordMode -eq 'Prompt') {
            $securePassword = Read-Host "Senha inicial para $sam" -AsSecureString
            $plainPassword = $null
        } else {
            $plainPassword = New-CryptographicPassword -Length $GeneratedPasswordLength
            $securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force
        }

        $parameters = @{
            Name                  = "$first $last"
            GivenName             = $first
            Surname               = $last
            DisplayName           = "$first $last"
            SamAccountName        = $sam
            UserPrincipalName     = $upn
            Path                  = $usersOuDn
            AccountPassword       = $securePassword
            Enabled               = $true
            ChangePasswordAtLogon = $true
            PasswordNeverExpires  = $false
        }
        if ($title) { $parameters.Title = $title }
        if ($department) { $parameters.Department = $department }

        New-ADUser @parameters
        $newUser = Get-ADUser -Identity $sam
        Ensure-DirectGroupMembership -User $newUser -Group $defaultGroup
        $created++

        if ($plainPassword) {
            $generated.Add([pscustomobject]@{ Usuario = $sam; SenhaInicial = $plainPassword })
        }
        Write-Host "[OK] Usuario $sam criado" -ForegroundColor Green
    } catch {
        Write-Warning "Falha ao criar '$sam': $_"
        $errors++
    }
}

Write-Host ''
Write-Host "Criados: $created | Existentes: $existing | Erros: $errors" -ForegroundColor Cyan
if ($generated.Count -gt 0) {
    Write-Host ''
    Write-Host 'SENHAS INICIAIS — aparecem somente agora; entregue por canal seguro e nao salve no CSV/repo.' -ForegroundColor Magenta
    $generated | Format-Table -AutoSize | Out-Host
    Write-Host 'Feche a sessao assim que registrar a entrega no cofre de senhas aprovado.' -ForegroundColor Magenta
}
