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
    . "$RootPath\Modules\System\SystemInfo.ps1"


    # Inicialização
    Initialize-Logging

    Write-Log `
        -Message "$($EPSetupConfig.Application.Name) iniciado" `
        -Level "INFO"


    Show-Banner


    $systemInfo = Get-SystemInfo


    Write-Log -Message "Computador: $($systemInfo.ComputerName)" -Level INFO

    Write-Log -Message "Usuário: $($systemInfo.User)" -Level INFO

    Write-Log -Message "Sistema: $($systemInfo.OperatingSystem)" -Level INFO

    Write-Log -Message "Versão: $($systemInfo.OSVersion)" -Level INFO

    Write-Log -Message "Processador: $($systemInfo.Processor)" -Level INFO

    Write-Log -Message "Memória: $($systemInfo.MemoryGB) GB" -Level INFO
    }
catch {

    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red

}

Read-Host "Pressione ENTER para sair"