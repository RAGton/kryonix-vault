@{
    # Use um subdominio de um nome DNS que a empresa controla.
    DomainDnsName      = 'ad.empresa.com.br'
    DomainNetBIOSName  = 'EMPRESA'

    # Nome curto, sem acentos e sem caracteres especiais de DN.
    RootOuName         = 'EMPRESA'
    CompanyDisplayName = 'Empresa Exemplo'

    OUs = @(
        'Administracao'
        'Usuarios'
        'Computadores'
        'Servidores'
        'Contas-de-Servico'
        'Grupos'
        'Desativados'
    )

    Groups = @{
        AllUsersGlobal                = 'GG_Todos_Usuarios'
        WorkstationAdminsGlobal       = 'GG_Admin_Local_Estacoes'
        HelpdeskPasswordResetGlobal   = 'GG_Helpdesk_Reset_Senha'
        DefaultShareModifyDomainLocal = 'DL_Compartilhado_Modificar'
    }

    # Safe default: criar os grupos nao concede acesso automaticamente.
    # Mude para $true somente se TODOS os usuarios realmente puderem alterar
    # o compartilhamento padrao.
    NestAllUsersInDefaultShare = $false

    FileShare = @{
        ServerName  = 'EMP-FS01'
        FolderPath  = 'D:\Compartilhado'
        ShareName   = 'Compartilhado$'
        EncryptData = $true
    }
}
