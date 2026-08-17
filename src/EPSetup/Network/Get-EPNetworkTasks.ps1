# ============================================================================
#
# EPSetup - Network Tasks
#
# Define as tarefas relacionadas a rede
#
# ============================================================================

function Get-EPNetworkTasks {

    @(
        @{
            Name = "Verificar conex�o com a internet"

            Condition = {
                $true
            }

            Action = {
                Test-EPInternetConnection
            }
        }
    )
}
