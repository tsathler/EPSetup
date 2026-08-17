# ============================================================================
#
# EPSetup - Configuration
#
# Retorna as configuracoes da aplicacao
#
# ============================================================================


function Get-EPSetupConfig {

    return @{

        # Informacoes da aplicacao
        Application = @{
            Name    = "EPSetup"
            Version = "1.0.0"
        }


        # Diretorios utilizados
        Paths = @{
            Data = "C:\ProgramData\EPSetup"
            Logs = "C:\ProgramData\EPSetup\Logs"
        }


        # Configuracoes de execucao
        Settings = @{
            RequireAdmin = $true
        }
    }
}
