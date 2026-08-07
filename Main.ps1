# ============================================================================
#
# EPSetup
#
# Main entry point
#
# Author: Thiago Sathler
#
# ============================================================================


# Carrega módulo de elevação
. ".\Modules\Elevation\Elevation.ps1"


# Verificação de privilégios - eleva automaticamente se necessário
if (-not (Test-IsElevated)) {
    Invoke-SelfElevation
    exit
}


# Carrega módulos da aplicação
. ".\Modules\UI\Banner.ps1"
. ".\Modules\Logging\Logging.ps1"


# Inicializa logging
Initialize-Logging

Write-Log -Message "EPSetup iniciado" -Level "INFO"


# Exibe banner
Show-Banner