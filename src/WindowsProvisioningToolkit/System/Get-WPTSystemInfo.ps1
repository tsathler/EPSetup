# ============================================================================
#
# WindowsProvisioningToolkit - System Information
#
# Coleta informações do computador atual
#
# ============================================================================


function Get-WPTSystemInfo {

    $computerName = $env:COMPUTERNAME
    $currentUser = $env:USERNAME

    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $totalMemory = Get-CimInstance Win32_ComputerSystem


    return @{

        ComputerName = $computerName

        User = $currentUser

        OperatingSystem = $os.Caption

        OSVersion = $os.Version

        Processor = $cpu.Name

        MemoryGB = [math]::Round(
            $totalMemory.TotalPhysicalMemory / 1GB,
            2
        )
    }
}
