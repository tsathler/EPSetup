# ============================================================================
#
# EPSetup - Windows Update Tasks
#
# Verifica e configura o servico do Windows Update
#
# ============================================================================


# Verifica se o servico do Windows Update esta em execucao
function Test-WindowsUpdateSettings {

    # Obtém o servico do Windows Update
    $service = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue

    # Verifica se o servico existe
    if (-not $service) {
        return $false
    }

    # Verifica se o servico esta em execucao
    if ($service.Status -eq "Running") {
        return $true
    }

    return $false
}


# Inicia o servico do Windows Update
function Start-WindowsUpdateService {

    # Inicia o servico
    Start-Service -Name "wuauserv" -ErrorAction Stop

    # Aguarda o servico iniciar
    $service = Get-Service -Name "wuauserv"

    if ($service.Status -ne "Running") {
        throw "Nao foi possivel iniciar o servico do Windows Update."
    }

    return $true
}