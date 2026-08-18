# ============================================================================
#
# EPSetup - Main Menu
#
# Exibe o menu principal do EPSetup
#
# ============================================================================

function Show-EPMainMenu {

    Clear-Host
    Show-EPSetupBanner

    Write-Host "[1] Instalacao de Aplicativos"
    Write-Host "[2] Configuracao do Sistema"
    Write-Host "[3] Perfil e Configuracao"
    Write-Host ""
    Write-Host "[0] Sair"
    Write-Host ""

    return Read-Host "Digite uma opcao"
}
