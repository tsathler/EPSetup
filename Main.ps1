# ============================================================================
#
# WindowsProvisioningToolkit
#
# Main entry point
#
# ============================================================================

param(
    [switch]$NoPause
)

$ErrorActionPreference = "Stop"

if ($NoPause) {
    $env:WPT_NO_PAUSE = "1"
}

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
    if (-not $NoPause) {
        Read-Host "Pressione ENTER para fechar"
    }
}
