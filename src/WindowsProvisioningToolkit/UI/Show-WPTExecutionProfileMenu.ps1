# ============================================================================
#
# WindowsProvisioningToolkit - Execution Profile Menu
#
# Exibe os perfis de execucao disponiveis
#
# ============================================================================

function Show-WPTExecutionProfileMenu {

    Clear-Host
    Show-WPTBanner

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "          PERFIS DE EXECUCAO" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[1] Portfolio"
    Write-Host "[2] Corporate basico"
    Write-Host "[3] Corporate completo"
    Write-Host "[4] Somente aplicativos"
    Write-Host "[5] Somente sistema"
    Write-Host ""
    Write-Host "[0] Voltar"
    Write-Host ""

    return Read-Host "Digite uma opcao"
}
