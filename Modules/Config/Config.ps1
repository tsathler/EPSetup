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

    GLPI = @{
    Server    = "http://conecta.cieemg.org.br/marketplace/glpiinventory"
    AgentPath = "C:\Program Files\GLPI-Agent\glpi-agent.bat"
    LocalUrl  = "http://localhost:62354"
}

}