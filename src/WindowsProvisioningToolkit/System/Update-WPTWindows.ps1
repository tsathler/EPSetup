# ============================================================================
#
# WindowsProvisioningToolkit - Windows Update
#
# Gerencia o serviço do Windows Update
#
# ============================================================================


# ============================================================================
# Verifica se o serviço do Windows Update está em execução
# ============================================================================

function Test-WPTWindowsUpdateRunning {

    $service = Get-Service `
        -Name "wuauserv" `
        -ErrorAction SilentlyContinue

    if (-not $service) {
        return $false
    }

    return $service.Status -eq "Running"
}


# ============================================================================
# Inicia o serviço do Windows Update
# ============================================================================

function Start-WPTWindowsUpdate {

    Start-Service `
        -Name "wuauserv" `
        -ErrorAction Stop

    $service = Get-Service `
        -Name "wuauserv" `
        -ErrorAction Stop

    if ($service.Status -ne "Running") {

        throw "Nao foi possivel iniciar o servico do Windows Update."
    }

    return $true
}
