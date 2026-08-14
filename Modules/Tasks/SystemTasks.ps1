# ============================================================================
#
# EPSetup - System Tasks
#
# Tarefas relacionadas ao sistema operacional
#
# ============================================================================


# Verifica se o serviço do Windows Update existe
function Test-WindowsUpdateService {

    $service = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue

    return $null -ne $service
}

# Configura as opcoes de energia do computador
function Configure-PowerSettings {

    powercfg /change monitor-timeout-ac 0
    powercfg /change standby-timeout-ac 0

    return $true
}