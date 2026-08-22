# ============================================================================
#
# WindowsProvisioningToolkit
#
# Main entry point
#
# ============================================================================

$ErrorActionPreference = "Stop"

$rootPath = Split-Path -Parent $PSCommandPath
$moduleManifest = Join-Path -Path $rootPath -ChildPath "src\WindowsProvisioningToolkit\WindowsProvisioningToolkit.psd1"

try {
    Import-Module $moduleManifest -Force

    Start-WPT -ScriptPath $PSCommandPath
}
catch {
    Write-Host ""
    Write-Host "ERRO ENCONTRADO:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Pressione ENTER para fechar"
}
