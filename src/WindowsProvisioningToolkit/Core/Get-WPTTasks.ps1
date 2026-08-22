# ============================================================================
#
# WindowsProvisioningToolkit - Task Collection
#
# Agrega todas as tarefas disponíeis no WindowsProvisioningToolkit
#
# ============================================================================


function Get-WPTTasks {

    return @(
        Get-WPTSystemTasks
        Get-WPTNetworkTasks
        Get-WPTSoftwareTasks
    )
}
