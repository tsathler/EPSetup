# ============================================================================
#
# EPSetup
#
# Main entry point
#
# Author: Thiago Sathler
#
# ============================================================================

# ============================================================================
#
# EPSetup
#
# Main entry point
#
# Author: Thiago Sathler
#
# ============================================================================
# ============================================================================
#
# EPSetup
#
# Main entry point
#
# ============================================================================


$RootPath = Split-Path $PSCommandPath

$ErrorActionPreference = "Stop"


try {

    # Configuração
    . "$RootPath\Modules\Config\Config.ps1"


    # Elevação
    . "$RootPath\Modules\Elevation\Elevation.ps1"

    if (-not (Test-IsElevated)) {
        Invoke-SelfElevation -ScriptPath $PSCommandPath
        exit
    }


    # Módulos da aplicação
    . "$RootPath\Modules\Logging\Logging.ps1"
    . "$RootPath\Modules\UI\Banner.ps1"


    # Inicialização
    Initialize-Logging

    Write-Log `
        -Message "$($EPSetupConfig.Application.Name) iniciado" `
        -Level "INFO"


    Show-Banner


}
catch {

    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red

}

Read-Host "Pressione ENTER para sair"