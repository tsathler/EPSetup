# ============================================================================
#
# WindowsProvisioningToolkit - System Tasks
#
# Define as tarefas relacionadas ao sistema operacional
#
# ============================================================================

function Get-WPTSystemTasks {

    @(
        @{
            Name = "Configurar energia temporariamente"

            Condition = {
                $false
            }

            Action = {
                Set-WPTSystemPowerTemporary
            }
        }
    )
}
