# ============================================================================
#
# EPSetup - Logging Initialization
#
# Inicializa o sistema de logging da aplicacao
#
# ============================================================================

$script:LogFilePath = $null

function Initialize-EPSetupLogging {

<#
.SYNOPSIS
Inicializa o sistema de logging do EPSetup.
#>

try {

    $config = Get-EPSetupConfig

    $logDirectory = $config.Paths.Logs


    # Cria o diretorio de logs caso nao exista
    if (-not (Test-Path -LiteralPath $logDirectory)) {

        New-Item `
            -Path $logDirectory `
            -ItemType Directory `
            -Force `
            -ErrorAction Stop |
        Out-Null
    }


    # Gera um arquivo de log exclusivo para cada execucao
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

    $fileName = "EPSetup_$timestamp.log"


    # Define o caminho completo do arquivo de log
    $script:LogFilePath = Join-Path `
        -Path $logDirectory `
        -ChildPath $fileName


    return $script:LogFilePath
}
catch {

    throw "Falha ao inicializar o sistema de logging: $($_.Exception.Message)"
}

}

