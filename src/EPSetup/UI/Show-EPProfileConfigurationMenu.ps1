# ============================================================================
#
# EPSetup - Profile Configuration Menu
#
# Exibe o menu de perfil Portfolio/Corporate
#
# ============================================================================

function Show-EPProfileConfigurationMenu {

    Clear-Host
    Show-EPSetupBanner

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "        PERFIL E CONFIGURACAO" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[1] Ver perfil ativo"
    Write-Host "[2] Configurar Corporate local"
    Write-Host "[3] Limpar Corporate local"
    Write-Host ""
    Write-Host "[0] Voltar"
    Write-Host ""

    return Read-Host "Digite uma opcao"
}
