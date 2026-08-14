# ============================================================================
#
# EPSetup - Configuration Module
#
# Centraliza configurações globais da aplicação
#
# ============================================================================


$Global:EPSetupConfig = @{

    # Informações da aplicação
    Application = @{
        Name = "EPSetup"
        Version = "1.0.0"
    }


    # Diretórios utilizados
    Paths = @{
        Root = $PSScriptRoot
        Data = "C:\ProgramData\EPSetup"
        Logs = "C:\ProgramData\EPSetup\Logs"
    }


    # Configurações de execução
    Settings = @{
        RequireAdmin = $true
    }

}