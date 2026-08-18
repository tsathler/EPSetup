# ============================================================================
#
# EPSetup - System Configuration Menu
#
# Exibe o menu de configuracao do sistema
#
# ============================================================================

function Show-EPSystemConfigurationMenu {

    Clear-Host
    Show-EPSetupBanner

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "      CONFIGURACAO DO SISTEMA" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[1] Delegacao de credenciais RDP"
    Write-Host "[2] Adicionar ao dominio"
    Write-Host "[3] Configuracao do usuario"
    Write-Host "[4] Executar configuracao completa"
    Write-Host ""
    Write-Host "[0] Voltar"
    Write-Host ""

    return Read-Host "Digite uma opcao"
}
