@{
    # ========================================================================
    # Identidade do modulo
    # ========================================================================

    RootModule        = 'EPSetup.psm1'
    ModuleVersion      = '0.1.1'
    GUID              = '5f3a1c8e-2b4d-4e6a-9c7f-1a2b3c4d5e6f'

    Author            = 'Thiago Sathler'
    CompanyName       = 'Nao especificado'
    Copyright         = '(c) 2026. Todos os direitos reservados.'

    Description       = 'Automatiza a configuracao de maquinas corporativas: desinstalacao/instalacao de softwares, ajustes de sistema, rede e dominio.'

    # ========================================================================
    # Requisitos de ambiente
    # ========================================================================

    PowerShellVersion = '5.1'

    # ========================================================================
    # O que o modulo exporta (a API publica)
    # ========================================================================

    FunctionsToExport = @(
        'Start-EPSetup'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    # ========================================================================
    # Metadados extras
    # ========================================================================

    PrivateData = @{
        PSData = @{
            Tags       = @('EPSetup', 'Provisioning', 'Windows')
            ProjectUri = 'https://github.com/tsathler/EPSetup'
        }
    }
}
