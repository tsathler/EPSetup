# ============================================================================
#
# WindowsProvisioningToolkit - Network Tasks
#
# Define as tarefas relacionadas a rede
#
# ============================================================================

function Get-WPTNetworkTasks {

    @(
        @{
            Name = "Verificar conex�o com a internet"

            Condition = {
                $true
            }

            Action = {
                Test-WPTInternetConnection
            }
        }
    )
}
