# ============================================================================
#
# EPSetup - System Tasks
#
# Define as tarefas relacionadas ao sistema operacional
#
# ============================================================================

function Get-EPSystemTasks {

    @(
        @{
            Name = "Configurar energia temporariamente"

            Condition = {
                $false
            }

            Action = {
                Set-EPSystemPowerTemporary
            }
        }
    )
}
