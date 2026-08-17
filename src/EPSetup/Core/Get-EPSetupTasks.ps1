# ============================================================================
#
# EPSetup - Task Collection
#
# Agrega todas as tarefas disponíeis no EPSetup
#
# ============================================================================


function Get-EPSetupTasks {

    return @(
        Get-EPSystemTasks
        Get-EPNetworkTasks
        Get-EPSoftwareTasks
    )
}
