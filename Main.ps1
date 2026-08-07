# ============================================================================
#
# EPSetup
#
# Main entry point
#
# Author: Thiago Sathler
#
# ============================================================================

$RootPath = Split-Path $PSCommandPath

$ErrorActionPreference = "Continue"

try {

    Write-Host "Main iniciado"

    . "$RootPath\Modules\Elevation\Elevation.ps1"

    Write-Host "Elevation carregado"

    if (-not (Test-IsElevated)) {
        Write-Host "Tentando elevar..."
        Invoke-SelfElevation -ScriptPath $PSCommandPath
        exit
    }

    Write-Host "Executado como administrador"

    . "$RootPath\Modules\UI\Banner.ps1"
    Write-Host "UI carregado"

    . "$RootPath\Modules\Logging\Logging.ps1"
    Write-Host "Logging carregado"

    Initialize-Logging
    Write-Host "Logging inicializado"

    Write-Log -Message "EPSetup iniciado" -Level "INFO"

    Show-Banner

}
catch {

    Write-Host "ERRO ENCONTRADO:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    Read-Host "Pressione ENTER para fechar"
}

Read-Host "Pressione ENTER para sair"